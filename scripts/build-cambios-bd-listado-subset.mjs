/**
 * Genera Install & config/docs/Cambios_BD_MonitoreApp_listado_subset.sql
 *
 * Lee el Listado oficial (Total creadas + Total preexistentes) y Cambios_BD_MonitoreApp.sql.
 * Incluye en el orden indicado CREATE + FK (solo tablas marcadas como "creadas" en el listado)
 * y ALTER/índices/FK correlativos (solo los ya definidos en Cambios_BD, tablas preexistentes
 * intersectadas por la lista de entrada).
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { shortenSubsetMysqlIdentifiers } from "./cambios-bd-subset-short-names.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");

/** Orden canónico del usuario — se ignoran entradas que no aparezcan en el Listado. */
const TABLES_REQUESTED_ORDER = [
    "a_recovery_password_token",
    "c_accion_personal",
    "c_apertura_cierre_puesto",
    "c_articulo_mantenimiento",
    "c_archivos_adjuntos_articulo_mantenimiento",
    "c_archivos_solicitud_permiso",
    "c_ausencia",
    "c_bitacora_vehiculo_detenido",
    "c_encuesta_cliente",
    "c_empleado",
    "c_empleado_almuerzo",
    "c_empleado_notification",
    "c_empleado_plaza",
    "c_horario",
    "c_imagenes_apertura_cierre_puesto",
    "c_imagenes_vehiculos_corporativos",
    "c_marca_dia",
    "c_mantenimiento_vehiculos_corporativos",
    "c_movimientos_articulo_mantenimiento",
    "c_notifications",
    "c_plaza_notification",
    "c_salida_anticipada",
    "c_solicitud_permiso",
    "c_tipo_accion",
    "c_usos_vehiculos_corporativos",
    "c_vehiculos_corporativos",
    "e_actividades",
    "e_actividades_puesto",
    "e_actividades_puesto_plaza",
    "e_estructura_empresa",
    "e_estructura_cliente",
    "e_estructura_contrato",
    "e_estructura_sucursal",
    "e_estructura_puesto",
    "e_estructura_plazas",
    "e_estructura_combo_articulo_cp",
    "e_estructura_articulo_corpo_puesto_plan",
    "e_estructura_articulo_corpo_puesto_entrega",
    "e_llave",
    "e_llave_en_llavero",
    "e_llavero",
    "e_movimiento_llave",
    "e_movimiento_llavero",
    "n_division",
    "n_articulo_corpo_puesto",
    "n_tipo_contratacion",
    "n_tipo_mantenimiento_articulo",
    "p_periodopago_config",
    "pg_categoria_salarial",
    "pg_categoria_empleado",
    "refresh_token",

    // Incidentes, visitas activas, catálogos de apoyo (lista ampliada — ver Listado)
    "c_categoria_mantenimiento",
    "n_novedades_categoria",
    "n_tipo_activo_visitas",
    "e_registro_personas",
    "n_clasificacion_incidente",
    "n_tipo_cliente_quejas",
    "n_tipo_quejas",
    "e_tipo_documento",
    "e_activo_visitante",
    "c_incidente",
    "c_archivos_incidente",
    "c_contribucion_incidente",
    "c_archivos_aporte_incidente",
    "n_ejecutivo_cuenta",
    "e_mutuos_acuerdos",
];

function parseListadoTableNames(markdown) {
    const names = new Set();
    const re = /^\s*\d+\.\s*`([^`]+)`/gm;
    let m;
    while ((m = re.exec(markdown)) !== null) names.add(m[1]);
    return names;
}

/** Extrae bloques CREATE TABLE ... ; del archivo MonitoreApp completo. */
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

/** Líneas de alteración inicial de Cambios_BD (hasta antes de primera CREATE TABLE). */
function extractCorporateAlterLines(cambiosFull) {
    const startMarker = "-- Cambios en tablas corporativas preexistentes";
    const endMarker = "-- Tablas nuevas (MonitoreApp)";
    const i = cambiosFull.indexOf(startMarker);
    const j = cambiosFull.indexOf(endMarker);
    if (i === -1 || j === -1) return [];
    const slice = cambiosFull.slice(i, j);
    return slice.split("\n").filter((line) => {
        const t = line.trim();
        return t.startsWith("ALTER TABLE ") || t.startsWith("CREATE INDEX ");
    });
}

function alterTargetsTable(line, tableName) {
    const reBt = /^ALTER TABLE `([^`]+)`|^CREATE INDEX `\S+` ON `([^`]+)`/;
    const mBt = line.match(reBt);
    if (mBt) return Boolean(mBt[1] === tableName || mBt[2] === tableName);
    return false;
}

/** FK líneas después del marcador Relaciones */
function extractFkLines(cambiosFull) {
    const fkHeader = "-- Relaciones (FK) —";
    const k = cambiosFull.indexOf(fkHeader);
    if (k === -1) return [];
    const rest = cambiosFull.slice(k);
    return rest.split("\n").filter((ln) => ln.trim().startsWith("ALTER TABLE `"));
}

const listadoPath = path.join(root, "Install & config", "docs", "Listado de tablas nuevas y originales del schema.md");
const cambiosPath = path.join(root, "Install & config", "docs", "Cambios_BD_MonitoreApp.sql");

const listadoRaw = fs.readFileSync(listadoPath, "utf8");
const listadoSet = parseListadoTableNames(listadoRaw);

/** Tablas solicitadas válidas por el Listado */
const validatedOrder = [];
const skippedNotInListado = [];
for (const t of TABLES_REQUESTED_ORDER) {
    if (listadoSet.has(t)) validatedOrder.push(t);
    else skippedNotInListado.push(t);
}

const listadoCreataRaw = listadoRaw.split("### Total preexistentes")[0];
const crearSet = parseListadoTableNames(listadoCreataRaw);
const crearInScript = validatedOrder.filter((t) => crearSet.has(t));

const preexistentValidated = validatedOrder.filter((t) => !crearSet.has(t));

const cambiosFull = fs.readFileSync(cambiosPath, "utf8");
const createMap = extractMysqlCreates(cambiosFull);
const corpAlterAll = extractCorporateAlterLines(cambiosFull);
const corpAlterFiltered = [];
for (const line of corpAlterAll) {
    for (const t of preexistentValidated) {
        if (alterTargetsTable(line, t)) {
            corpAlterFiltered.push(line);
            break;
        }
    }
}
// dedupe alter lines preserving order
const seenAlter = new Set();
const corpAlterDedup = corpAlterFiltered.filter((l) => (seenAlter.has(l) ? false : seenAlter.add(l)));

const fkAll = extractFkLines(cambiosFull);
const crearSetForFk = new Set(crearInScript);
const fkFiltered = fkAll.filter((line) => {
    const m = /^ALTER TABLE `([^`]+)`/.exec(line);
    return Boolean(m && crearSetForFk.has(m[1]));
});

for (const t of crearInScript) {
    if (!createMap.has(t)) {
        console.error(`Falta CREATE en Cambios_BD_MonitoreApp.sql para tabla creada: ${t}`);
        process.exit(1);
    }
}

const createBlocksOrdered = crearInScript.map((t) => createMap.get(t)).join("\n\n");

const outPath = path.join(root, "Install & config", "docs", "Cambios_BD_MonitoreApp_listado_subset.sql");

const header = `-- Motor objetivo: MySQL (InnoDB, utf8mb4)
--
-- Subconjunto derivado de Cambios_BD_MonitoreApp.sql según tabla pedidas + Listado oficial.
-- Tablas solicitadas pero NO incluidas en Listado de tablas nuevas y originales del schema.md (omitidas aquí): ${skippedNotInListado.length ? skippedNotInListado.join(", ") : "(ninguna)"}.
-- Solo se emiten ALTER/CREATE INDEX declarados ya en Cambios_BD_MonitoreApp.sql para preexistentes; el resto de preexistentes de la lista quedan sin DDL de actualización en este archivo.
-- Nombres de índices y FK internos están abreviados (scripts/cambios-bd-subset-short-names.mjs).
--
-- Regenerar: node scripts/build-cambios-bd-listado-subset.mjs
--
SET FOREIGN_KEY_CHECKS = 0;

-- =============================
-- Actualización tablas corporativas (subconjunto permitido por listado — ver encabezado)
-- =============================
`;

const mid = corpAlterDedup.length
    ? corpAlterDedup.join("\n") +
      "\n\n-- =============================\n-- Creación tablas nuevas MonitoreApp (solo las de la lista + Listado)\n-- =============================\n\n"
    : `-- (Sin ALTER inicial en esta lista — ver Cambios_BD_MonitoreApp.sql)\n\n-- =============================\n-- Creación tablas nuevas MonitoreApp (solo las de la lista + Listado)\n-- =============================\n\n`;

const fkSection =
    fkFiltered.length > 0
        ? `\n\n-- =============================\n-- Relaciones (FK) — solo tablas nuevas incluidas arriba\n-- =============================\n` +
          fkFiltered.join("\n") +
          "\n"
        : "";


const footer = `
SET FOREIGN_KEY_CHECKS = 1;
`;

const rawSql = header.trimEnd() + "\n" + mid + createBlocksOrdered + fkSection + footer.trim() + "\n";
fs.writeFileSync(outPath, shortenSubsetMysqlIdentifiers(rawSql), "utf8");

console.log("Escrito:", outPath);
console.log(
    "Válidas (listado):",
    validatedOrder.length,
    "| CREATE:",
    crearInScript.length,
    "| ALTER inicial:",
    corpAlterDedup.length,
    "| FK:",
    fkFiltered.length,
);
console.log("Omitidas (no en Listado):", skippedNotInListado.join(", ") || "-");
