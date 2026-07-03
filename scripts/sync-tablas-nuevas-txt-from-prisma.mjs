/**
 * Regenera Install & config/docs/Tablas nuevas del schema.txt copiando cada bloque
 * `model ... { }` completo desde app/prisma/schema.prisma (misma fuente que Prisma).
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { MONITOREAPP_NEW_TABLES } from "./monitoreapp-new-tables.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");

function escapeRe(s) {
    return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

/**
 * Extrae el texto del modelo desde la primera línea `model Name {` hasta la `}` de cierre,
 * ignorando llaves dentro de strings y comentarios de línea o bloque.
 */
function extractModelBlock(schema, modelName) {
    const re = new RegExp(`^model\\s+${escapeRe(modelName)}\\s*\\{`, "m");
    const m = schema.match(re);
    if (!m || m.index === undefined) return null;
    const start = m.index;
    const openIdx = start + m[0].length - 1;
    let i = openIdx;
    let depth = 0;
    let inString = null;
    let inLineComment = false;
    let inBlockComment = false;

    while (i < schema.length) {
        const c = schema[i];
        const next = schema[i + 1];

        if (inLineComment) {
            if (c === "\n" || c === "\r") inLineComment = false;
            i++;
            continue;
        }
        if (inBlockComment) {
            if (c === "*" && next === "/") {
                inBlockComment = false;
                i += 2;
                continue;
            }
            i++;
            continue;
        }
        if (inString) {
            if (c === "\\" && (inString === '"' || inString === "'")) {
                i += 2;
                continue;
            }
            if (c === inString) inString = null;
            i++;
            continue;
        }

        if (c === "/" && next === "/") {
            inLineComment = true;
            i += 2;
            continue;
        }
        if (c === "/" && next === "*") {
            inBlockComment = true;
            i += 2;
            continue;
        }
        if (c === '"' || c === "'") {
            inString = c;
            i++;
            continue;
        }

        if (c === "{") depth++;
        else if (c === "}") {
            depth--;
            if (depth === 0) return schema.slice(start, i + 1);
        }
        i++;
    }
    return null;
}

const schemaPath = path.join(root, "app", "prisma", "schema.prisma");
const schema = fs.readFileSync(schemaPath, "utf8");

const blocks = [];
for (const name of MONITOREAPP_NEW_TABLES) {
    const block = extractModelBlock(schema, name);
    if (!block) {
        console.error(`Modelo no encontrado en schema.prisma: ${name}`);
        process.exit(1);
    }
    blocks.push(`// ===== ${name} =====\n${block.trimEnd()}`);
}

const header = `# Modelos Prisma creados (no existían en schema-original)

Este archivo se regenera desde app/prisma/schema.prisma con:

  node scripts/sync-tablas-nuevas-txt-from-prisma.mjs

Cada bloque es una copia literal del modelo en Prisma. El conjunto y orden de tablas coinciden con \`MONITOREAPP_NEW_TABLES\` en scripts/monitoreapp-new-tables.mjs (listado en Install & config/docs/Listado de tablas nuevas y originales del schema.md y usado por scripts/sync-monitoreapp-sql-from-prisma.mjs).

`;

const outPath = path.join(root, "Install & config", "docs", "Tablas nuevas del schema.txt");
const body = blocks.join("\n\n");
fs.writeFileSync(outPath, header.trimEnd() + "\n\n" + body + "\n", "utf8");
console.log("Escrito:", outPath);
console.log("Modelos:", MONITOREAPP_NEW_TABLES.length);
