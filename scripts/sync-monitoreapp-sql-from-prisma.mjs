/**
 * Regenera la sección "Tablas nuevas" + FKs de Cambios_BD_MonitoreApp.sql
 * a partir de `prisma migrate diff` y el listado de tablas MonitoreApp.
 *
 * Prerrequisito: generar Install & config/docs/_prisma_full_diff.sql con:
 *   npx prisma migrate diff --from-empty --to-schema-datamodel app/prisma/schema.prisma --script > "Install & config/docs/_prisma_full_diff.sql"
 *   node scripts/sync-monitoreapp-sql-from-prisma.mjs
 *
 * Tablas incluidas: `MONITOREAPP_NEW_TABLES` en scripts/monitoreapp-new-tables.mjs
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { MONITOREAPP_NEW_TABLES as TABLES } from "./monitoreapp-new-tables.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");

const tableSet = new Set(TABLES);

const diffPath = path.join(root, "Install & config", "docs", "_prisma_full_diff.sql");
const diffRaw = fs.readFileSync(diffPath, "utf8");
/** Solo la parte CreateTable; las FK vienen después de `-- AddForeignKey` */
const fkMarker = diffRaw.indexOf("\n-- AddForeignKey");
const diff = fkMarker === -1 ? diffRaw : diffRaw.slice(0, fkMarker);

/** Extrae bloques CREATE TABLE del diff de Prisma */
function extractCreateBlocks(sql) {
    const re =
        /-- CreateTable\r?\nCREATE TABLE `([^`]+)` (\([\s\S]*?\))\s*DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;/g;
    const map = new Map();
    let m;
    while ((m = re.exec(sql)) !== null) {
        map.set(m[1], m[2]);
    }
    return map;
}

function prismaCreateToMysql(name, bodyParen) {
    let inner = bodyParen.slice(1, -1);
    inner = inner.replace(/\bINTEGER\b/g, "INT");
    inner = inner.replace(/\bBOOLEAN\b/g, "TINYINT(1)");
    inner = inner.replace(/DEFAULT true\b/g, "DEFAULT 1");
    inner = inner.replace(/DEFAULT false\b/g, "DEFAULT 0");
    const body = inner
        .split("\n")
        .map((line) => {
            const t = line.trim();
            if (!t) return "";
            return "    " + t;
        })
        .filter((line) => line.length > 0)
        .join("\n");
    return `CREATE TABLE IF NOT EXISTS \`${name}\` (\n${body}\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`;
}

const createMap = extractCreateBlocks(diff);
const missing = TABLES.filter((t) => !createMap.has(t));
if (missing.length) {
    console.error("Tablas sin CREATE en el diff de Prisma:", missing.join(", "));
    process.exit(1);
}

const createSql = TABLES.map((t) => `${prismaCreateToMysql(t, createMap.get(t))};`).join("\n\n");

/** FK: sección AddForeignKey del diff completo */
const fkSection = fkMarker === -1 ? "" : diffRaw.slice(fkMarker);
const alterMatch = fkSection.match(/-- AddForeignKey\r?\n(ALTER TABLE `[^`]+` ADD CONSTRAINT[\s\S]*?);/g) || [];
const fkLines = [];
for (const block of alterMatch) {
    const line = block.replace(/^-- AddForeignKey\r?\n/, "").trim();
    const tbl = /^ALTER TABLE `([^`]+)`/.exec(line);
    if (tbl && tableSet.has(tbl[1])) fkLines.push(line);
}

const fkSql =
    fkLines.length > 0
        ? `-- =============================\n-- Relaciones (FK) — generadas desde Prisma (tablas del listado MonitoreApp)\n-- =============================\n` +
          fkLines.join("\n") +
          "\n"
        : "";

const header = `-- Motor objetivo: MySQL (InnoDB, utf8mb4)
--
-- Esta sección "Tablas nuevas" se regenera desde app/prisma/schema.prisma mediante:
--   npx prisma migrate diff --from-empty --to-schema-datamodel app/prisma/schema.prisma --script > "Install & config/docs/_prisma_full_diff.sql"
--   node scripts/sync-monitoreapp-sql-from-prisma.mjs
--
SET FOREIGN_KEY_CHECKS = 0;

-- =============================
-- Cambios en tablas corporativas preexistentes (no creadas por este script)
-- =============================
`;

const alterCorporate = `ALTER TABLE \`c_accion_personal\` ADD COLUMN \`mobile_upload\` BOOLEAN NULL;
ALTER TABLE \`c_cambio_guardia\` ADD COLUMN \`mobile_upload\` BOOLEAN NULL;
ALTER TABLE \`c_empleado\` ADD COLUMN \`firma_manual\` LONGTEXT NULL;
ALTER TABLE \`c_empleado\` ADD COLUMN \`ingresado\` BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE \`c_marca_dia\` ADD COLUMN \`usuarioMarcaEntrada\` VARCHAR(191) NULL;
ALTER TABLE \`c_salida_anticipada\` ADD COLUMN \`empleado_id\` INT NULL;
ALTER TABLE \`c_salida_anticipada\` ADD COLUMN \`motivo\` LONGTEXT NULL;
ALTER TABLE \`e_estructura_puesto\` ADD COLUMN \`coordenadas_gpslat\` VARCHAR(255) NULL;
ALTER TABLE \`e_estructura_puesto\` ADD COLUMN \`coordenadas_gpslng\` VARCHAR(255) NULL;
ALTER TABLE \`e_estructura_articulo_corpo_puesto_entrega\` ADD COLUMN \`modelo\` VARCHAR(255) NULL;
CREATE INDEX \`c_salida_anticipada_empleado_id_fkey\` ON \`c_salida_anticipada\` (\`empleado_id\`);
ALTER TABLE \`c_salida_anticipada\` ADD CONSTRAINT \`c_salida_anticipada_empleado_id_fkey\` FOREIGN KEY (\`empleado_id\`) REFERENCES \`c_empleado\`(\`id\`) ON DELETE CASCADE;

-- =============================
-- Tablas nuevas (MonitoreApp) — columnas alineadas con Prisma
-- =============================
`;

const footer = `
SET FOREIGN_KEY_CHECKS = 1;
`;

const out =
    header +
    alterCorporate +
    "\n" +
    createSql +
    "\n\n" +
    fkSql +
    footer;

const outPath = path.join(root, "Install & config", "docs", "Cambios_BD_MonitoreApp.sql");
fs.writeFileSync(outPath, out, "utf8");
console.log("Escrito:", outPath);
console.log("CREATE:", TABLES.length, "| FK (ALTER):", fkLines.length);
