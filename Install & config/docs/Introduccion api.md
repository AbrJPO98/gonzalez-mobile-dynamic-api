## API dinámica de base de datos y archivos

Este documento describe la API dinámica utilizada en este proyecto para interactuar con la base de datos y con el sistema de archivos, construida sobre **Next.js** (rutas de la carpeta `app/api`) y **Prisma**.

---

### 1. ¿Qué es la API dinámica?

La API dinámica está implementada principalmente a través de la ruta:

- `app/api/dynamic-prisma/route.ts`

Esta ruta fue creada usando **Next.js** y actúa como un _proxy_ genérico hacia la base de datos:

- Recibe una petición HTTP con un **payload JSON** que incluye:
  - `action`: `"GET" | "POST" | "UPDATE" | "DELETE"`
  - `table`: nombre de la tabla en la base de datos (por ejemplo, `"c_marca_dia"`, `"e_estructura_plazas"`, etc.).
  - `operation`: operación específica de Prisma (por ejemplo, `"findMany"`, `"findFirst"`, `"findUnique"`, `"create"`, `"update"`, `"deleteMany"`, etc.).
  - Parámetros de Prisma (`where`, `data`, `orderBy`, `include`, `select`, `take`, `skip`, etc.), según corresponda.
- La API traduce estos parámetros a una llamada concreta de Prisma contra la tabla indicada y devuelve el resultado en formato JSON.

### 2. Referencias de modelo y tablas utilizadas

Para entender las **tablas nuevas** y las **tablas preexistentes** que se implementan en la API dinámica (y si tienen diferencias respecto a la base original), es obligatorio revisar los siguientes documentos en `apps/server/docs`:

- `Tablas nuevas del schema.txt`
- `Tablas originales del schema.md`
- `Listado de tablas nuevas y tablas originales del schema.md`

En estos documentos se detalla:

- Qué modelos/tablas nuevas se añadieron al `schema.prisma`.
- Qué tablas ya existentes se están utilizando en la API dinámica.
- Qué diferencias o ajustes se han hecho respecto al esquema original.

> **Nota de referencia de base:**  
> Para crear esta base de datos se usó como referencia la base **`corpglez_planillas_master_mirror`**, proporcionada al equipo de **Udevs**.
> Cualquier cambio sobre las tablas que se están utilizando debe considerar la compatibilidad con el modelo y el cliente de prisma.

En particular, el archivo:

- `Listado de tablas nuevas y originales del schema.md`

incluye el bloque de **“Total preexistentes”**, donde se listan las tablas preexistentes que han sido modeladas en Prisma. Cambios en estas tablas requieren atención especial (ver sección 5).

---

### 3. Adaptación de base de datos (SQL)

Para adaptar la base de datos a los cambios de MonitoreApp, ejecutar:

- `Install & config/docs/Cambios_BD_MonitoreApp.sql`

Antes de ejecutar ese script, debes seleccionar explícitamente la base de datos destino:

```sql
USE `db_name`;
```

> Reemplaza `db_name` por el nombre real de la base en la que aplicarás los cambios.

---

### 4. Configuración de Prisma

Después de hacer cambios en la base de datos, ejecuta:

```bash
npx prisma db pull
```

para traer el estado actual de la base de datos al `schema.prisma`.

Luego ejecuta:

```bash
npx prisma generate
```

para actualizar/modificar el cliente de Prisma con esos cambios.

---

### 5. Cambios en tablas preexistentes y flujo de trabajo

La API dinámica está pensada para **no interferir con el flujo de trabajo normal de la empresa**, pero es importante coordinar cambios en las tablas preexistentes.

En particular:

- Cuando se haga un cambio en **alguna de las tablas listadas en “Total preexistentes”** de  
  `Listado de tablas nuevas y originales del schema.md`  
  (por ejemplo:
  - Añadir / eliminar columnas.
  - Cambiar tipos de datos.
  - Cambiar claves primarias o foráneas.
  - Renombrar tablas o columnas.)

  entonces:
  1. **Revisar y actualizar `schema.prisma`** con los comandos anteriormente mencionados para que siga reflejando fielmente la estructura de la base (incluyendo relaciones, índices, tipos, etc.).
  2. **Probar los flujos afectados** (endpoints y pantallas móviles correspondientes).

- Además, **es obligatorio informar al equipo de Udevs** cuando se realicen cambios en estas tablas preexistentes, para que puedan:
  - Adaptar el servicio que brinda la app mobile a los nuevos cambios de esquema.
  - Actualizar, si es necesario, el mapeo y las validaciones que se realizan del lado de la infraestructura o servicios auxiliares.

> En resumen: los cambios en tablas listadas como “Total preexistentes” deben ser tratados como cambios de contrato entre la base de datos corporativa y la API dinámica.

---

### 6. Resumen

- La API dinámica de este proyecto está construida con **Next.js + Prisma**.
- Antes de trabajar con tablas y modelos, se deben revisar:
  - `Tablas nuevas del schema.txt`
  - `Tablas originales del schema.md`
  - `Listado de tablas nuevas y originales del schema.md`
- Para adaptar la base de datos a cambios de MonitoreApp:
  - Ejecutar `USE \`db_name\`;`
  - Ejecutar `Install & config/docs/Cambios_BD_MonitoreApp.sql`.
- Después de cambios en base de datos:
  - Ejecutar `npx prisma db pull`.
  - Ejecutar `npx prisma generate`.
- Cualquier cambio en tablas preexistentes:
  - Requiere actualizar `schema.prisma`, probar los flujos afectados y coordinar con **Udevs** para mantener la API dinámica alineada con la base de referencia.
