import fs from "fs/promises";
import {
    DeleteObjectCommand,
    GetObjectCommand,
    HeadObjectCommand,
    PutObjectCommand,
    S3Client,
} from "@aws-sdk/client-s3";
import { getLocalUploadAbsolutePath, normalizeUploadRelativePath } from "./uploadPath";

let s3Client: S3Client | null = null;

function getBucketName(): string {
    const bucket = process.env.AWS_BUCKET_NAME?.trim();
    if (!bucket) {
        throw new Error("AWS_BUCKET_NAME no configurado en el servidor");
    }
    return bucket;
}

function getS3Client(): S3Client {
    if (s3Client) return s3Client;

    const accessKeyId = process.env.AWS_ACCESS_KEY_ID?.trim();
    const secretAccessKey = process.env.AWS_SECRET_ACCESS_KEY?.trim();
    if (!accessKeyId || !secretAccessKey) {
        throw new Error("AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY no configurados en el servidor");
    }

    const endpoint = process.env.AWS_ENDPOINT_URL?.trim() || undefined;
    const region = process.env.AWS_REGION?.trim() || "auto";

    s3Client = new S3Client({
        region,
        endpoint,
        credentials: { accessKeyId, secretAccessKey },
        forcePathStyle: Boolean(endpoint),
    });

    return s3Client;
}

function toObjectKey(relativePath: string): string {
    return normalizeUploadRelativePath(relativePath);
}

export async function uploadExists(relativePath: string): Promise<boolean> {
    const key = toObjectKey(relativePath);
    try {
        await getS3Client().send(
            new HeadObjectCommand({
                Bucket: getBucketName(),
                Key: key,
            }),
        );
        return true;
    } catch (error: unknown) {
        const status = (error as { $metadata?: { httpStatusCode?: number }; name?: string })?.$metadata
            ?.httpStatusCode;
        const name = (error as { name?: string })?.name;
        if (status === 404 || name === "NotFound" || name === "NoSuchKey") {
            return false;
        }
        throw error;
    }
}

async function localUploadExists(relativePath: string): Promise<boolean> {
    try {
        const localPath = getLocalUploadAbsolutePath(relativePath);
        const stat = await fs.stat(localPath);
        return stat.isFile();
    } catch (error: unknown) {
        const code = (error as NodeJS.ErrnoException)?.code;
        if (code === "ENOENT") return false;
        throw error;
    }
}

export async function uploadExistsAnywhere(relativePath: string): Promise<boolean> {
    if (await uploadExists(relativePath)) return true;
    return localUploadExists(relativePath);
}

export async function putUploadObject(
    relativePath: string,
    body: Buffer,
    contentType: string,
): Promise<void> {
    const key = toObjectKey(relativePath);
    await getS3Client().send(
        new PutObjectCommand({
            Bucket: getBucketName(),
            Key: key,
            Body: body,
            ContentType: contentType,
        }),
    );
}

export async function getUploadObject(relativePath: string): Promise<Buffer> {
    const key = toObjectKey(relativePath);

    try {
        const response = await getS3Client().send(
            new GetObjectCommand({
                Bucket: getBucketName(),
                Key: key,
            }),
        );
        const bytes = await response.Body?.transformToByteArray();
        if (!bytes) {
            throw new Error("Respuesta vacía del almacenamiento");
        }
        return Buffer.from(bytes);
    } catch (error: unknown) {
        const status = (error as { $metadata?: { httpStatusCode?: number }; name?: string })?.$metadata
            ?.httpStatusCode;
        const name = (error as { name?: string })?.name;
        if (status === 404 || name === "NotFound" || name === "NoSuchKey") {
            return getLocalUploadFallback(relativePath);
        }
        throw error;
    }
}

export async function deleteUploadObject(relativePath: string): Promise<void> {
    const key = toObjectKey(relativePath);

    try {
        await getS3Client().send(
            new DeleteObjectCommand({
                Bucket: getBucketName(),
                Key: key,
            }),
        );
    } catch {
        /* Si no existe en S3, intentar borrar copia local legacy */
    }

    try {
        const localPath = getLocalUploadAbsolutePath(relativePath);
        await fs.unlink(localPath);
    } catch (error: unknown) {
        const code = (error as NodeJS.ErrnoException)?.code;
        if (code !== "ENOENT") throw error;
    }
}

async function getLocalUploadFallback(relativePath: string): Promise<Buffer> {
    const localPath = getLocalUploadAbsolutePath(relativePath);
    try {
        return await fs.readFile(localPath);
    } catch (error: unknown) {
        const code = (error as NodeJS.ErrnoException)?.code;
        if (code === "ENOENT") {
            throw new Error("Archivo no encontrado");
        }
        throw error;
    }
}
