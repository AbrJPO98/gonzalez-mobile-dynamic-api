import path from "path";
import { prisma } from "./prismaClient";
import { getUploadObject, uploadExistsAnywhere } from "./s3UploadsStorage";
import { normalizeUploadRelativePath } from "./uploadPath";
import { safeDownloadFileName } from "./fileDownloadResponse";

type ReportFilters = {
    outputFile?: string;
    outputUrl?: string;
};

export type ReportZipEntry = {
    reportId: number;
    relativePath: string;
    zipEntryName: string;
    buffer: Buffer;
};

const parseFilters = (filtersRaw: string): ReportFilters => {
    try {
        const parsed = JSON.parse(filtersRaw) as ReportFilters;
        return parsed && typeof parsed === "object" ? parsed : {};
    } catch {
        return {};
    }
};

export const parseReportIds = (raw: unknown): number[] => {
    let values: unknown[] = [];
    if (Array.isArray(raw)) {
        values = raw;
    } else if (typeof raw === "string") {
        values = raw.split(/[,\s]+/).filter(Boolean);
    }

    return [
        ...new Set(
            values
                .map((value) => Number(value))
                .filter((value) => Number.isFinite(value) && value > 0),
        ),
    ];
};

export const resolveReportMobileRelativePath = (
    reportId: number,
    filtersRaw: string,
): string => {
    const filters = parseFilters(filtersRaw);
    if (filters.outputUrl) {
        return normalizeUploadRelativePath(filters.outputUrl);
    }
    if (filters.outputFile) {
        return normalizeUploadRelativePath(`reportes_mobile/${reportId}/${filters.outputFile}`);
    }
    throw new Error(`El reporte ${reportId} no tiene outputUrl ni outputFile en filters`);
};

const uniqueZipEntryName = (reportId: number, relativePath: string, usedNames: Set<string>): string => {
    const baseName = safeDownloadFileName(path.basename(relativePath) || `reporte_${reportId}.xlsx`);
    let candidate = `${reportId}_${baseName}`;
    let suffix = 2;
    while (usedNames.has(candidate)) {
        const ext = path.extname(baseName);
        const stem = ext ? baseName.slice(0, -ext.length) : baseName;
        candidate = `${reportId}_${stem}_${suffix}${ext}`;
        suffix += 1;
    }
    usedNames.add(candidate);
    return candidate;
};

export async function loadReportZipEntries(ids: number[]): Promise<ReportZipEntry[]> {
    if (!ids.length) {
        throw new Error("Debe enviar al menos un id de reporte");
    }

    const reports = await prisma.e_reportes_mobile.findMany({
        where: { id: { in: ids } },
        select: { id: true, estado: true, filters: true },
    });

    const reportById = new Map(reports.map((report) => [report.id, report]));
    const missingIds = ids.filter((id) => !reportById.has(id));
    if (missingIds.length) {
        throw new Error(`Reportes no encontrados: ${missingIds.join(", ")}`);
    }

    const notCompleted = ids.filter((id) => reportById.get(id)?.estado !== "completado");
    if (notCompleted.length) {
        throw new Error(`Reportes no completados: ${notCompleted.join(", ")}`);
    }

    const usedNames = new Set<string>();
    const entries: ReportZipEntry[] = [];

    for (const id of ids) {
        const report = reportById.get(id)!;
        const relativePath = resolveReportMobileRelativePath(id, report.filters);
        if (!(await uploadExistsAnywhere(relativePath))) {
            throw new Error(`Archivo no encontrado para el reporte ${id}: ${relativePath}`);
        }

        entries.push({
            reportId: id,
            relativePath,
            zipEntryName: uniqueZipEntryName(id, relativePath, usedNames),
            buffer: await getUploadObject(relativePath),
        });
    }

    return entries;
}
