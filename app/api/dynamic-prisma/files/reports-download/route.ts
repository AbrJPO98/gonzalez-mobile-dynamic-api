import JSZip from "jszip";
import { NextRequest, NextResponse } from "next/server";
import { parseBoolean, validateDynamicFilesAccess } from "../../../../../utils/dynamicFilesAccess";
import { buildBinaryFileResponse } from "../../../../../utils/fileDownloadResponse";
import { loadReportZipEntries, parseReportIds } from "../../../../../utils/mobileReportFiles";

export const runtime = "nodejs";

type DownloadReportsPayload = {
    token?: string;
    mobileAccessToken?: string;
    shouldVerifyAccessToken?: boolean;
    ids?: Array<number | string>;
    report_ids?: Array<number | string>;
};

const buildReportsZipBuffer = async (ids: number[]): Promise<Buffer> => {
    const entries = await loadReportZipEntries(ids);
    const zip = new JSZip();
    for (const entry of entries) {
        zip.file(entry.zipEntryName, entry.buffer);
    }
    return Buffer.from(await zip.generateAsync({ type: "nodebuffer", compression: "DEFLATE" }));
};

const buildZipFileName = (): string => {
    const stamp = new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0, 14);
    return `reportes_mobile_${stamp}.zip`;
};

const mapErrorToResponse = (error: unknown): NextResponse => {
    const message = error instanceof Error ? error.message : "Error desconocido";
    if (message.includes("no encontrados") || message.includes("no encontrado")) {
        return NextResponse.json({ status: false, message }, { status: 404 });
    }
    if (message.includes("no completados") || message.includes("al menos un id")) {
        return NextResponse.json({ status: false, message }, { status: 400 });
    }
    return NextResponse.json({ status: false, message }, { status: 500 });
};

export async function GET(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url);
        const token = String(searchParams.get("token") || "").trim();
        const mobileAccessToken = String(searchParams.get("mobileAccessToken") || "").trim();
        const shouldVerifyAccessToken = parseBoolean(searchParams.get("shouldVerifyAccessToken"), true);
        const ids = parseReportIds(searchParams.get("ids") || searchParams.get("report_ids"));

        const accessError = validateDynamicFilesAccess(
            req,
            mobileAccessToken,
            token,
            shouldVerifyAccessToken,
        );
        if (accessError) return accessError;

        if (!ids.length) {
            return NextResponse.json(
                { status: false, message: "ids es obligatorio" },
                { status: 400 },
            );
        }

        const zipBuffer = await buildReportsZipBuffer(ids);
        return buildBinaryFileResponse(zipBuffer, "application/zip", buildZipFileName(), true);
    } catch (error: unknown) {
        console.error("Error in GET /api/dynamic-prisma/files/reports-download:", error);
        return mapErrorToResponse(error);
    }
}

export async function POST(req: NextRequest) {
    try {
        const payload = (await req.json().catch(() => null)) as DownloadReportsPayload | null;
        if (!payload || typeof payload !== "object") {
            return NextResponse.json({ status: false, message: "Payload inválido" }, { status: 400 });
        }

        const shouldVerifyAccessToken = payload.shouldVerifyAccessToken !== false;
        const accessError = validateDynamicFilesAccess(
            req,
            payload.mobileAccessToken,
            payload.token,
            shouldVerifyAccessToken,
        );
        if (accessError) return accessError;

        const ids = parseReportIds(payload.ids ?? payload.report_ids);
        if (!ids.length) {
            return NextResponse.json(
                { status: false, message: "ids es obligatorio" },
                { status: 400 },
            );
        }

        const zipBuffer = await buildReportsZipBuffer(ids);
        return buildBinaryFileResponse(zipBuffer, "application/zip", buildZipFileName(), true);
    } catch (error: unknown) {
        console.error("Error in POST /api/dynamic-prisma/files/reports-download:", error);
        return mapErrorToResponse(error);
    }
}
