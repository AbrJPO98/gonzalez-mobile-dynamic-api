/**
 * Genera Install & config/docs/Cambios_BD_MonitoreApp_solo_tablas_creadas.sql
 *
 * A partir de Cambios_BD_MonitoreApp.sql + Listado oficial:
 * - CREATE de todas las tablas en "Total creadas" (MONITOREAPP_NEW_TABLES).
 * - Sin ALTER ni FK hacia tablas "Total preexistentes".
 * - Columnas que apuntan a preexistentes se conservan; solo se omiten ADD CONSTRAINT / REFERENCES.
 * - Se conservan FK entre tablas creadas (MonitoreApp).
 *
 * Regenerar: node scripts/build-cambios-bd-solo-tablas-creadas.mjs
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { MONITOREAPP_NEW_TABLES } from "./monitoreapp-new-tables.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");

function parseListadoTableNames(markdown) {
    const names = new Set();
    const re = /^\s*\d+\.\s*`([^`]+)`/gm;
    let m;
    while ((m = re.exec(markdown)) !== null) names.add(m[1]);
    return names;
}

/** Extrae bloques CREATE TABLE ... ; del SQL MonitoreApp. */
function extractMysqlCreates(full) {
    const map = new Map();
    const prefix = "CREATE TABLE IF NOT EXISTS `";
    let search = 0;
    while (true) {
        const idx = full.indexOf(prefix, search);
        if (idx === -1) break;
        const nameEnd = full.indexOf("`", idx + prefix.length);
        const name = full.slice(idx + prefix.length, nameEnd);
        const openParen = full.indexOf("(", nameEnd);
        if (openParen === -1) throw new Error("parse open paren " + name);
        let depth = 0;
        let i = openParen;
        for (; i < full.length; i++) {
            const ch = full[i];
            if (ch === "(") depth++;
            else if (ch === ")") {
                depth--;
                if (depth === 0) {
                    const semi = full.indexOf(";", i);
                    map.set(name, full.slice(idx, semi + 1).trimEnd());
                    search = semi + 1;
                    break;
                }
            }
        }
        if (depth !== 0) throw new Error("unbalanced parens CREATE " + name);
    }
    return map;
}

function extractFkLines(cambiosFull) {
    const fkHeader = "-- Relaciones (FK) —";
    const k = cambiosFull.indexOf(fkHeader);
    if (k === -1) return [];
    const rest = cambiosFull.slice(k);
    return rest.split("\n").filter((ln) => ln.trim().startsWith("ALTER TABLE `"));
}

function referencesTable(fkLine) {
    const m = /REFERENCES `([^`]+)`/.exec(fkLine);
    return m ? m[1] : null;
}

function sourceTable(fkLine) {
    const m = /^ALTER TABLE `([^`]+)`/.exec(fkLine.trim());
    return m ? m[1] : null;
}

const listadoPath = path.join(root, "Install & config", "docs", "Listado de tablas nuevas del schema.md");
const cambiosPath = path.join(root, "Install & config", "docs", "Cambios_BD_MonitoreApp.sql");
const outPath = path.join(root, "Install & config", "docs", "Cambios_BD_MonitoreApp.sql");

const listadoRaw = fs.readFileSync(listadoPath, "utf8");
const preexistentRaw = listadoRaw.split("### Total preexistentes")[1] ?? "";
const preexistentSet = preexistentRaw ? parseListadoTableNames(preexistentRaw) : new Set();
const crearSet = new Set(MONITOREAPP_NEW_TABLES);

const cambiosFull = fs.readFileSync(cambiosPath, "utf8");
const createMap = extractMysqlCreates(cambiosFull);

const missing = MONITOREAPP_NEW_TABLES.filter((t) => !createMap.has(t));
if (missing.length) {
    console.error("Falta CREATE en Cambios_BD_MonitoreApp.sql:", missing.join(", "));
    process.exit(1);
}

const createBlocks = MONITOREAPP_NEW_TABLES.map((t) => createMap.get(t)).join("\n\n");

const fkAll = extractFkLines(cambiosFull);
const fkKept = [];
const fkOmittedPreexistent = [];

for (const line of fkAll) {
    const src = sourceTable(line);
    const ref = referencesTable(line);
    if (!src || !ref || !crearSet.has(src)) continue;

    if (preexistentSet.has(ref)) {
        fkOmittedPreexistent.push(line);
        continue;
    }
    if (!crearSet.has(ref)) {
        fkOmittedPreexistent.push(line);
        continue;
    }
    fkKept.push(line);
}

const header = `-- Motor objetivo: MySQL (InnoDB, utf8mb4)
--
-- Solo tablas nuevas MonitoreApp ("Total creadas" del Listado oficial).
-- NO modifica tablas preexistentes (sin ALTER corporativo).
-- Las columnas que referencian tablas preexistentes se crean; las FOREIGN KEY hacia ellas se omiten.
-- FK entre tablas creadas: ${fkKept.length} | FK omitidas (→ preexistentes u otras): ${fkOmittedPreexistent.length}
--
-- Fuente: Cambios_BD_MonitoreApp.sql
-- Regenerar: node scripts/build-cambios-bd-solo-tablas-creadas.mjs
--
SET FOREIGN_KEY_CHECKS = 0;

-- =============================
-- Creación tablas nuevas MonitoreApp (${MONITOREAPP_NEW_TABLES.length} tablas)
-- =============================

`;

const fkSection =
    fkKept.length > 0
        ? `\n-- =============================\n-- Relaciones (FK) — solo entre tablas creadas\n-- =============================\n${fkKept.join("\n")}\n`
        : "";

const footer = `
SET FOREIGN_KEY_CHECKS = 1;
`;

fs.writeFileSync(outPath, header + createBlocks + fkSection + footer.trim() + "\n", "utf8");

console.log("Escrito:", outPath);
console.log("CREATE:", MONITOREAPP_NEW_TABLES.length);
console.log("FK conservadas:", fkKept.length);
console.log("FK omitidas (preexistentes):", fkOmittedPreexistent.length);
