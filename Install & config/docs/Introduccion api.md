## API dinámica de base de datos y archivos

Este documento describe la API dinámica utilizada en este proyecto para interactuar con la base de datos y con el sistema de archivos, construida sobre **Next.js** (rutas de la carpeta `app/api`) y **Prisma**.

---

### 1. ¿Qué es la API dinámica?

La API dinámica está implementada principalmente a través de la ruta:

- `app/api/dynamic-prisma/route.ts`

Esta ruta fue creada usando **Next.js** y actúa como un _proxy_ genérico hacia la base de datos:

- Recibe una petición HTTP con un **payload JSON** que incluye:
  - `action`: `"GET" | "POST" | "UPDATE" | "DELETE"`
  - `table`: nombre de la tabla en la base de datos (por ejemplo, `"c_incidente"`, `"c_solicitud_permiso"`, etc.).
  - `operation`: operación específica de Prisma (por ejemplo, `"findMany"`, `"findFirst"`, `"findUnique"`, `"create"`, `"update"`, `"deleteMany"`, etc.).
  - Parámetros de Prisma (`where`, `data`, `orderBy`, `include`, `select`, `take`, `skip`, etc.), según corresponda.
- La API traduce estos parámetros a una llamada concreta de Prisma contra la tabla indicada y devuelve el resultado en formato JSON.

### 2. Referencias de modelo y tablas utilizadas

Para entender las **tablas nuevas** que implementa la API dinámica, revisa los documentos en `Install & config/docs`:

- `Tablas nuevas del schema.txt`
- `Listado de tablas nuevas del schema.md`

En ellos se detalla qué modelos/tablas nuevas se añadieron al `schema.prisma`.

> **Nota de referencia de base:**  
> Para crear esta base de datos se usó como referencia la base **`corpglez_planillas_master_mirror`**, proporcionada al equipo de **Udevs**.  
> Cualquier cambio sobre las tablas utilizadas debe considerar la compatibilidad con el modelo y el cliente de Prisma.

---

### 3. Adaptación de base de datos (SQL)

El script `Install & config\docs\Cambios_BD_MonitoreApp.sql` debe ejecutarse sobre una **base de datos nueva y dedicada** para MonitoreApp (vacía o recién creada). **No** debe aplicarse sobre la base corporativa ya existente ni sobre cualquier base en producción que ya contenga datos operativos de la empresa.

Motivo: el script instala el esquema de MonitoreApp en un entorno aislado; usar una base ya en uso puede mezclar datos, afectar integraciones vigentes o generar conflictos de estructura.

Pasos recomendados:

1. Crear una base de datos nueva (por ejemplo `monitoreapp_dev` o el nombre acordado con el equipo).
2. Seleccionar esa base antes de ejecutar el script:

```sql
CREATE DATABASE IF NOT EXISTS `db_name` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_name`;
```

3. Ejecutar el contenido de:

- `Install & config\docs\Cambios_BD_MonitoreApp.sql`

> Reemplaza `db_name` por el nombre real de la **nueva** base. Apunta `DATABASE_URL` en `.env` a esa misma base.

---

### 4. Variables de entorno (`.env`)

Antes de configurar Prisma o iniciar la API, los usuarios **deben crear un archivo `.env` en la raíz del proyecto**, tomando como referencia el contenido de `.env.example` (no modificar `.env.example`).

Ejemplo:

```bash
cp .env.example .env
```

Luego editar `.env` y completar cada variable con los valores correspondientes (conexión a la base de datos, secretos JWT, tokens de acceso, URL de planillas, etc.), según los comentarios de `.env.example`.

---

### 5. Configuración de Prisma

Después de aplicar el script SQL en la base nueva, ejecuta en la raíz del proyecto:

```bash
npx prisma db pull
```

para traer el estado actual de la base de datos al `schema.prisma`.

Luego ejecuta:

```bash
npx prisma generate
```

para actualizar el cliente de Prisma con esos cambios.

---

### 6. Inicio de la API

Después de ejecutar los comandos de Prisma anteriores, para iniciar la API en desarrollo digita en la **raíz del proyecto**:

```bash
npm run dev
```

Para ejecutarse en el **servicio brindado** (despliegue / entorno de producción o el que opere el equipo receptor), el usuario tiene **libertad para modificar las instrucciones de inicio** (por ejemplo, el comando de arranque, el puerto, el orquestador o el empaquetado del proceso), **siempre que no se altere el funcionamiento de los endpoints brindados** por esta API.

---

### 7. Resumen

- La API dinámica de este proyecto está construida con **Next.js + Prisma**.
- Antes de trabajar con tablas y modelos, revisar:
  - `Tablas nuevas del schema.txt`
  - `Listado de tablas nuevas del schema.md`
- Para preparar la base de datos de MonitoreApp:
  - Crear una **base de datos nueva** (no reutilizar la corporativa existente).
  - Ejecutar `CREATE DATABASE` / `USE \`db_name\`;` sobre esa base.
  - Ejecutar `Install & config/docs/Cambios_BD_MonitoreApp.sql`.
  - Configurar `DATABASE_URL` en `.env` apuntando a esa base.
- Variables de entorno:
  - Crear un archivo `.env` en la raíz del proyecto a partir de `.env.example` (por ejemplo, `cp .env.example .env`) y completar los valores indicados en ese ejemplo.
- Después de aplicar el script en la base:
  - Ejecutar `npx prisma db pull`.
  - Ejecutar `npx prisma generate`.
- Para iniciar la API en desarrollo (raíz del proyecto):
  - Ejecutar `npm run dev`.
- En el servicio brindado se pueden modificar las instrucciones de inicio, pero **no** el funcionamiento de los endpoints brindados.
