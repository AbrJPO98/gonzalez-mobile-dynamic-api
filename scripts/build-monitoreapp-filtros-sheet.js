/**
 * Lee MONITOREAPP.xlsx, conserva las hojas existentes y añade la hoja "Filtros":
 * columnas = nombres de "MODULOS MONITOREAPP", celdas = valores de "Filtros"
 * partidos por comas en filas sucesivas.
 *
 * Uso: node scripts/build-monitoreapp-filtros-sheet.js [entrada.xlsx] [salida.xlsx]
 */
const fs = require("fs");
const path = require("path");
const XLSX = require("xlsx");

const ROOT = path.resolve(__dirname, "..");
const DEFAULT_IN = path.join(ROOT, "MONITOREAPP.xlsx");
const DEFAULT_OUT = path.join(ROOT, "MONITOREAPP_con_Filtros.xlsx");

const inFile = path.resolve(process.argv[2] || DEFAULT_IN);
const outFile = path.resolve(process.argv[3] || DEFAULT_OUT);

if (!fs.existsSync(inFile)) {
    console.error("No existe el archivo:", inFile);
    process.exit(1);
}

const wb = XLSX.readFile(inFile);
const permisosName = wb.SheetNames.includes("PERMISOS") ? "PERMISOS" : wb.SheetNames[0];
const data = XLSX.utils.sheet_to_json(wb.Sheets[permisosName], { header: 1, defval: "" });

let headerRowIndex = data.findIndex(
    (row) =>
        Array.isArray(row) &&
        row.some((c) => String(c).trim() === "MODULOS MONITOREAPP") &&
        row.some((c) => String(c).trim() === "Filtros")
);

if (headerRowIndex === -1) {
    console.error('No se encontró una fila de encabezado con "MODULOS MONITOREAPP" y "Filtros".');
    process.exit(1);
}

const headerRow = data[headerRowIndex];
const modCol = headerRow.findIndex((c) => String(c).trim() === "MODULOS MONITOREAPP");
const filtCol = headerRow.findIndex((c) => String(c).trim() === "Filtros");

if (modCol === -1 || filtCol === -1) {
    console.error("No se pudieron localizar las columnas MODULOS / Filtros.");
    process.exit(1);
}

/** @type {{ name: string, parts: string[] }[]} */
const columns = [];

for (let i = headerRowIndex + 1; i < data.length; i++) {
    const row = data[i];
    if (!Array.isArray(row)) continue;
    const name = String(row[modCol] ?? "").trim();
    if (!name) continue;
    const raw = String(row[filtCol] ?? "").trim();
    const parts = raw
        .split(",")
        .map((s) => s.trim())
        .filter((s) => s.length > 0);
    columns.push({ name, parts });
}

if (!columns.length) {
    console.error("No hay filas de datos con módulo en", permisosName);
    process.exit(1);
}

const maxDepth = Math.max(0, ...columns.map((c) => c.parts.length));

/** @type {(string | number)[][]} */
const aoa = [columns.map((c) => c.name)];
for (let r = 0; r < maxDepth; r++) {
    aoa.push(columns.map((c) => c.parts[r] ?? ""));
}

const filtrosSheet = XLSX.utils.aoa_to_sheet(aoa);

const colWidths = columns.map((c) => {
    const w = Math.min(60, Math.max(c.name.length, ...c.parts.map((p) => p.length), 10));
    return { wch: w };
});
filtrosSheet["!cols"] = colWidths;

if (wb.SheetNames.includes("Filtros")) {
    const idx = wb.SheetNames.indexOf("Filtros");
    wb.SheetNames.splice(idx, 1);
    delete wb.Sheets.Filtros;
}

XLSX.utils.book_append_sheet(wb, filtrosSheet, "Filtros");
XLSX.writeFile(wb, outFile);

console.log("Entrada:", inFile);
console.log("Salida:", outFile);
console.log("Módulos (columnas):", columns.length, "| Filas de filtros (máx.):", maxDepth);
