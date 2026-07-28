import { NextResponse } from "next/server";

export const safeDownloadFileName = (nameRaw: string): string => {
    const base = String(nameRaw || "archivo")
        .trim()
        .replace(/[<>:"/\\|?*\x00-\x1F]/g, "_");
    const normalized = base.replace(/[^\x20-\x7E]/g, "_").replace(/["\\]/g, "_");
    return normalized || "archivo";
};

export const buildAttachmentContentDisposition = (fileName: string): string => {
    const asciiName = safeDownloadFileName(fileName);
    const encodedUtf8 = encodeURIComponent(fileName);
    return `attachment; filename="${asciiName}"; filename*=UTF-8''${encodedUtf8}`;
};

export const buildBinaryFileResponse = (
    fileBuffer: Buffer,
    contentType: string,
    fileName: string,
    forceDownload: boolean,
): NextResponse => {
    const headers: Record<string, string> = {
        "Content-Type": contentType,
        "Content-Length": String(fileBuffer.length),
        "Cache-Control": forceDownload ? "private, no-store" : "public, max-age=31536000",
        "X-Content-Type-Options": "nosniff",
    };

    if (forceDownload) {
        headers["Content-Disposition"] = buildAttachmentContentDisposition(fileName);
    }

    return new NextResponse(new Uint8Array(fileBuffer), {
        status: 200,
        headers,
    });
};
