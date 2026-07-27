import path from "path";

/** Ruta relativa dentro de uploads (sin prefijo `uploads/`). */
export function normalizeUploadRelativePath(inputPath: string): string {
    let cleaned = decodeURIComponent(String(inputPath || ""))
        .replace(/\\/g, "/")
        .replace(/^\/+/, "")
        .trim();

    if (!cleaned) {
        throw new Error("La ruta del archivo/carpeta es obligatoria");
    }
    if (cleaned.startsWith("public/")) {
        cleaned = cleaned.slice("public/".length);
    }
    if (cleaned.startsWith("uploads/")) {
        cleaned = cleaned.slice("uploads/".length);
    }

    const normalizedPosix = path.posix.normalize(cleaned);
    if (
        normalizedPosix === "." ||
        normalizedPosix.startsWith("../") ||
        normalizedPosix.includes("/../") ||
        normalizedPosix.includes("\0")
    ) {
        throw new Error("Ruta inválida");
    }

    return normalizedPosix.replace(/^\/+/, "");
}

export function toUploadApiUrl(relativePath: string): string {
    return `/uploads/${relativePath.replace(/\\/g, "/")}`;
}

export function getLocalUploadAbsolutePath(relativePath: string): string {
    const uploadsRoot = path.resolve(process.cwd(), "public", "uploads");
    const absolutePath = path.resolve(uploadsRoot, relativePath.replace(/\\/g, path.sep));
    if (!(absolutePath === uploadsRoot || absolutePath.startsWith(`${uploadsRoot}${path.sep}`))) {
        throw new Error("Ruta fuera del directorio permitido");
    }
    return absolutePath;
}
