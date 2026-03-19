import { NextRequest, NextResponse } from "next/server";
import { toZonedTime } from "date-fns-tz";
import { prisma } from "../../../../utils/prismaClient";
import { verifyAccessToken } from "../../../../utils/verifyToken";
import { verifyTokenFromBody } from "../../../../utils/verifyTokenFromBody";

type TipoMantenimientoArticuloDTO = { id: number; nombre: string };

type MainStructurePayload = {
    token?: string;
    mobileAccessToken?: string;
    shouldVerifyAccessToken?: boolean;
};

function uniqueFiniteNumberArray(values: Array<unknown>): number[] {
    return Array.from(
        new Set(values.filter((id): id is number => typeof id === "number" && Number.isFinite(id)))
    );
}

export async function POST(req: NextRequest) {
    try {
        const payload = (await req.json()) as MainStructurePayload;
        if (!payload || typeof payload !== "object") {
            return NextResponse.json({ status: false, message: "Payload inválido" }, { status: 400 });
        }

        const expectedMobileToken = process.env.MOBILE_ACCESS_TOKEN?.trim();
        const incomingMobileToken = String(payload.mobileAccessToken || "").trim();

        if (!expectedMobileToken) {
            return NextResponse.json(
                { status: false, message: "MOBILE_ACCESS_TOKEN no configurado en el servidor" },
                { status: 500 }
            );
        }
        if (!incomingMobileToken) {
            return NextResponse.json(
                { status: false, message: "mobileAccessToken es obligatorio" },
                { status: 403 }
            );
        }
        if (incomingMobileToken !== expectedMobileToken) {
            return NextResponse.json(
                { status: false, message: "mobileAccessToken inválido" },
                { status: 403 }
            );
        }

        const shouldVerifyAccessToken = payload.shouldVerifyAccessToken !== false;
        if (shouldVerifyAccessToken) {
            const tokenValidationHeader = verifyAccessToken(req);
            const tokenValidationBody = verifyTokenFromBody(payload.token);
            const tokenValidation = tokenValidationHeader.valid ? tokenValidationHeader : tokenValidationBody;

            if (!tokenValidation.valid) {
                return NextResponse.json(
                    { status: false, expired: tokenValidation.expired, message: tokenValidation.message },
                    { status: tokenValidation.expired ? 401 : 403 }
                );
            }
        }

        const nowCostaRica = toZonedTime(new Date(), "America/Costa_Rica");
        const structure: any[] = [];

        const divisions = await prisma.n_division.findMany({
            select: { id: true, nombre: true },
            orderBy: { id: "asc" },
        });

        const empresas = await prisma.e_estructura_empresa.findMany({
            where: { deleted: null },
            select: { id: true, codigo: true, nombre: true },
            orderBy: { id: "asc" },
        });

        for (const empresa of empresas) {
            const empresa_data = {
                id: empresa.id,
                nombre: `${empresa.codigo} - ${empresa.nombre}`,
                clientes: [] as any[],
            };

            const clientes = await prisma.e_estructura_cliente.findMany({
                where: {
                    empresa_id: empresa.id,
                    deleted: null,
                    OR: [{ fecha_inactivacion: null }, { fecha_inactivacion: { gte: nowCostaRica } }],
                },
                select: { id: true, nombre: true },
                orderBy: { id: "asc" },
            });

            for (const cliente of clientes) {
                const cliente_data = { id: cliente.id, nombre: cliente.nombre, division: [] as any[] };

                const contratos = await prisma.e_estructura_contrato.findMany({
                    where: {
                        cliente_id: cliente.id,
                        deleted: null,
                        OR: [{ fecha_inactivacion: null }, { fecha_inactivacion: { gte: nowCostaRica } }],
                    },
                    select: { id: true, nombre: true, division_id: true },
                    orderBy: { id: "asc" },
                });

                const contratosByDivisionId = new Map<number, any[]>();
                const contratoIds = contratos.map((c) => c.id);
                for (const contrato of contratos) {
                    const divisionKey = contrato.division_id ?? -1;
                    const list = contratosByDivisionId.get(divisionKey) ?? [];
                    list.push(contrato);
                    contratosByDivisionId.set(divisionKey, list);
                }

                const sucursalesAll =
                    contratoIds.length > 0
                        ? await prisma.e_estructura_sucursal.findMany({
                              where: {
                                  contrato_id: { in: contratoIds },
                                  deleted: null,
                                  OR: [{ fecha_inactivacion: null }, { fecha_inactivacion: { gte: nowCostaRica } }],
                              },
                              select: { id: true, nombre: true, nro_sucursal: true, contrato_id: true },
                              orderBy: { id: "asc" },
                          })
                        : [];

                const sucursalesByContratoId = new Map<number, any[]>();
                for (const sucursal of sucursalesAll) {
                    const contratoKey = sucursal.contrato_id ?? -1;
                    const list = sucursalesByContratoId.get(contratoKey) ?? [];
                    list.push(sucursal);
                    sucursalesByContratoId.set(contratoKey, list);
                }

                for (const division of divisions) {
                    const division_data = {
                        id: division.id,
                        nombre: division.nombre,
                        contratos: [] as any[],
                    };

                    const contratosForDivision = contratosByDivisionId.get(division.id) ?? [];
                    for (const contrato of contratosForDivision) {
                        const contrato_data = { id: contrato.id, nombre: contrato.nombre, sucursales: [] as any[] };
                        const sucursales = sucursalesByContratoId.get(contrato.id) ?? [];

                        for (const sucursal of sucursales) {
                            const sucursal_data = {
                                id: sucursal.id,
                                nombre: `${sucursal.nro_sucursal} - ${sucursal.nombre}`,
                                vehiculos_corporativos: [] as any[],
                                puestos: [] as any[],
                            };

                            const vehiculos = await prisma.c_vehiculos_corporativos.findMany({
                                where: { sucursal_id: sucursal.id },
                                include: {
                                    c_usos_vehiculos_corporativos: true,
                                    c_mantenimiento_vehiculos_corporativos: true,
                                },
                            });

                            const bitacoraIds = uniqueFiniteNumberArray(
                                vehiculos.flatMap((v: any) =>
                                    v.c_usos_vehiculos_corporativos.map((u: any) => u.bitacora_id)
                                )
                            );
                            const bitacoras = bitacoraIds.length
                                ? await prisma.c_bitacora_vehiculo_detenido.findMany({
                                      where: { id: { in: bitacoraIds } },
                                  })
                                : [];
                            const bitacoraById = new Map(bitacoras.map((b: any) => [b.id, b]));

                            sucursal_data.vehiculos_corporativos = vehiculos.map((v: any) => ({
                                ...v,
                                usos: v.c_usos_vehiculos_corporativos.map((u: any) => ({
                                    ...u,
                                    bitacora: u.bitacora_id ? bitacoraById.get(u.bitacora_id) ?? null : null,
                                })),
                            }));

                            const puestos = await prisma.e_estructura_puesto.findMany({
                                where: {
                                    sucursal_id: sucursal.id,
                                    deleted: null,
                                    OR: [{ fecha_inactivacion: null }, { fecha_inactivacion: { gte: nowCostaRica } }],
                                },
                                select: {
                                    id: true,
                                    codigo: true,
                                    nombre: true,
                                    coordenadas_gpslat: true,
                                    coordenadas_gpslng: true,
                                    comboArticulosCP_id: true,
                                },
                                orderBy: { id: "asc" },
                            });

                            const puestoIds = puestos.map((p) => p.id);
                            const plazas =
                                puestoIds.length > 0
                                    ? await prisma.e_estructura_plazas.findMany({
                                          where: {
                                              puesto_id: { in: puestoIds },
                                              deleted: null,
                                              OR: [{ fecha_inactivacion: null }, { fecha_inactivacion: { gte: nowCostaRica } }],
                                          },
                                          select: {
                                              id: true,
                                              puesto_id: true,
                                              codigo_plaza: true,
                                              nombre: true,
                                          },
                                      })
                                    : [];

                            const plazasByPuestoId = new Map<number, any[]>();
                            const plazaIds = plazas.map((p) => p.id);
                            for (const plaza of plazas) {
                                const puestoKey = plaza.puesto_id ?? -1;
                                const list = plazasByPuestoId.get(puestoKey) ?? [];
                                list.push(plaza);
                                plazasByPuestoId.set(puestoKey, list);
                            }

                            const plazaEmpleadoRows =
                                plazaIds.length > 0
                                    ? await prisma.c_empleado_plaza.findMany({
                                          where: { plaza_id: { in: plazaIds }, empleado_id: { not: null } },
                                          select: { plaza_id: true, empleado_id: true },
                                      })
                                    : [];

                            const empleadoIds = uniqueFiniteNumberArray(
                                plazaEmpleadoRows.map((row: any) => row.empleado_id)
                            );

                            const empleados =
                                empleadoIds.length > 0
                                    ? await prisma.c_empleado.findMany({
                                          where: {
                                              id: { in: empleadoIds },
                                              fecha_contratacion: { not: null },
                                              OR: [{ estado: null }, { estado: { not: "BA" } }],
                                              NOT: [{ cedula: { contains: "@" } }],
                                          },
                                          select: {
                                              id: true,
                                              codigo: true,
                                              cedula: true,
                                              nombre: true,
                                              primer_apellido: true,
                                              segundo_apellido: true,
                                              Email: true,
                                              telefono: true,
                                              tipoCedula: true,
                                              fecha_contratacion: true,
                                              estado: true,
                                              supervisor_id: true,
                                              firma_manual: true,
                                          },
                                          orderBy: [
                                              { nombre: "asc" },
                                              { primer_apellido: "asc" },
                                              { segundo_apellido: "asc" },
                                              { id: "asc" },
                                          ],
                                      })
                                    : [];

                            const plazaIdsByEmpleadoId = new Map<number, number[]>();
                            for (const row of plazaEmpleadoRows) {
                                if (row.empleado_id == null || row.plaza_id == null) continue;
                                const list = plazaIdsByEmpleadoId.get(row.empleado_id) ?? [];
                                list.push(row.plaza_id);
                                plazaIdsByEmpleadoId.set(row.empleado_id, list);
                            }

                            const empleadosByPlazaId = new Map<number, any[]>();
                            for (const empleado of empleados) {
                                const relatedPlazas = plazaIdsByEmpleadoId.get(empleado.id) ?? [];
                                for (const plazaId of relatedPlazas) {
                                    const list = empleadosByPlazaId.get(plazaId) ?? [];
                                    list.push(empleado);
                                    empleadosByPlazaId.set(plazaId, list);
                                }
                            }

                            for (const puesto of puestos) {
                                const puesto_data = {
                                    id: puesto.id,
                                    nombre: `${puesto.codigo} - ${puesto.nombre}`,
                                    ubicacion: {
                                        lat: puesto.coordenadas_gpslat ?? null,
                                        lng: puesto.coordenadas_gpslng ?? null,
                                    },
                                    plazas: [] as any[],
                                    articulos: [] as any[],
                                };

                                const plazasForPuesto = plazasByPuestoId.get(puesto.id) ?? [];
                                for (const plaza of plazasForPuesto) {
                                    puesto_data.plazas.push({
                                        id: plaza.id,
                                        nombre: `${plaza.codigo_plaza} - ${plaza.nombre}`,
                                        empleados: empleadosByPlazaId.get(plaza.id) ?? [],
                                    });
                                }

                                let articulos_return: any[] = [];

                                const articulos_combo = puesto.comboArticulosCP_id
                                    ? await prisma.e_estructura_articulo_corpo_puesto_plan.findMany({
                                          where: { combo_id: puesto.comboArticulosCP_id },
                                          select: { id: true, articuloCP_id: true, cantidad: true },
                                      })
                                    : [];

                                const comboIds = articulos_combo.map((a: any) => a.id);
                                const articulos_plan = await prisma.e_estructura_articulo_corpo_puesto_plan.findMany({
                                    where: {
                                        puesto_id: puesto.id,
                                        ...(comboIds.length ? { id: { notIn: comboIds } } : {}),
                                    },
                                    select: { id: true, articuloCP_id: true, cantidad: true },
                                });

                                const articulos_entrega =
                                    await prisma.e_estructura_articulo_corpo_puesto_entrega.findMany({
                                        where: { puesto_id: puesto.id },
                                        select: {
                                            id: true,
                                            nomencladorArticuloCP_id: true,
                                            marca: true,
                                            serie: true,
                                        },
                                    });

                                const nomencladorIds = uniqueFiniteNumberArray([
                                    ...articulos_combo.map((a: any) => a.articuloCP_id),
                                    ...articulos_plan.map((a: any) => a.articuloCP_id),
                                    ...articulos_entrega.map((a: any) => a.nomencladorArticuloCP_id),
                                ]);

                                const nomencladores =
                                    nomencladorIds.length > 0
                                        ? await prisma.n_articulo_corpo_puesto.findMany({
                                              where: { id: { in: nomencladorIds } },
                                              select: { id: true, nombre: true },
                                          })
                                        : [];
                                const nombreByNomencladorId = new Map(
                                    nomencladores.map((n: any) => [n.id, n.nombre])
                                );

                                for (const articulo of articulos_combo) {
                                    articulos_return.push({
                                        id: articulo.id,
                                        nombre: nombreByNomencladorId.get(articulo.articuloCP_id ?? -1) ?? "Desconocido",
                                        tipo: "Plan",
                                        marca: "",
                                        serie: "",
                                        cantidad: articulo.cantidad,
                                        articulo_nomenclador_id: articulo.articuloCP_id ?? null,
                                        tipos_mantenimiento: [],
                                    });
                                }

                                for (const articulo of articulos_plan) {
                                    articulos_return.push({
                                        id: articulo.id,
                                        nombre: nombreByNomencladorId.get(articulo.articuloCP_id ?? -1) ?? "Desconocido",
                                        tipo: "Plan",
                                        marca: "",
                                        serie: "",
                                        cantidad: articulo.cantidad,
                                        articulo_nomenclador_id: articulo.articuloCP_id ?? null,
                                        tipos_mantenimiento: [],
                                    });
                                }

                                for (const articulo of articulos_entrega) {
                                    articulos_return.push({
                                        id: articulo.id,
                                        nombre:
                                            nombreByNomencladorId.get(articulo.nomencladorArticuloCP_id ?? -1) ??
                                            "Artículo inidentificable",
                                        tipo: "Asignado",
                                        marca: articulo.marca,
                                        serie: articulo.serie,
                                        cantidad: 1,
                                        articulo_nomenclador_id: articulo.nomencladorArticuloCP_id ?? null,
                                        tipos_mantenimiento: [],
                                    });
                                }

                                const articuloNomencladorIds = uniqueFiniteNumberArray(
                                    articulos_return.map((a) => a.articulo_nomenclador_id)
                                );
                                if (articuloNomencladorIds.length > 0) {
                                    const tiposRows = await prisma.n_tipo_mantenimiento_articulo.findMany({
                                        where: { articulo_id: { in: articuloNomencladorIds } },
                                        select: { id: true, articulo_id: true, nombre: true },
                                        orderBy: { id: "asc" },
                                    });
                                    const tiposByArticuloId = new Map<number, TipoMantenimientoArticuloDTO[]>();
                                    for (const t of tiposRows) {
                                        const list = tiposByArticuloId.get(t.articulo_id) ?? [];
                                        list.push({ id: t.id, nombre: t.nombre });
                                        tiposByArticuloId.set(t.articulo_id, list);
                                    }
                                    articulos_return = articulos_return.map((a) => ({
                                        ...a,
                                        tipos_mantenimiento: a.articulo_nomenclador_id
                                            ? (tiposByArticuloId.get(a.articulo_nomenclador_id) ?? [])
                                            : [],
                                    }));
                                }

                                const planIds = articulos_return.filter((a) => a.tipo === "Plan").map((a) => a.id);
                                const asignadoIds = articulos_return
                                    .filter((a) => a.tipo === "Asignado")
                                    .map((a) => a.id);

                                if (planIds.length > 0 || asignadoIds.length > 0) {
                                    const or: any[] = [];
                                    if (planIds.length) or.push({ articulo_plan_id: { in: planIds } });
                                    if (asignadoIds.length) or.push({ articulo_asignado_id: { in: asignadoIds } });

                                    const mantenimientos = await prisma.c_articulo_mantenimiento.findMany({
                                        where: { OR: or },
                                        orderBy: { id: "desc" },
                                        include: {
                                            c_archivos_adjuntos_articulo_mantenimiento: {
                                                select: {
                                                    id: true,
                                                    name: true,
                                                    original_name: true,
                                                    type: true,
                                                    extension: true,
                                                },
                                            },
                                        },
                                    });

                                    const latestByPlanId = new Map<number, any>();
                                    const latestByAsignadoId = new Map<number, any>();
                                    const mantenimientosByPlanId = new Map<number, any[]>();
                                    const mantenimientosByAsignadoId = new Map<number, any[]>();
                                    for (const m of mantenimientos) {
                                        if (m.articulo_plan_id && !latestByPlanId.has(m.articulo_plan_id)) {
                                            latestByPlanId.set(m.articulo_plan_id, m);
                                        }
                                        if (
                                            m.articulo_asignado_id &&
                                            !latestByAsignadoId.has(m.articulo_asignado_id)
                                        ) {
                                            latestByAsignadoId.set(m.articulo_asignado_id, m);
                                        }
                                        if (m.articulo_plan_id) {
                                            const list = mantenimientosByPlanId.get(m.articulo_plan_id) ?? [];
                                            if (list.length < 8) {
                                                list.push(m);
                                                mantenimientosByPlanId.set(m.articulo_plan_id, list);
                                            }
                                        }
                                        if (m.articulo_asignado_id) {
                                            const list = mantenimientosByAsignadoId.get(m.articulo_asignado_id) ?? [];
                                            if (list.length < 8) {
                                                list.push(m);
                                                mantenimientosByAsignadoId.set(m.articulo_asignado_id, list);
                                            }
                                        }
                                    }

                                    const movimientos = await prisma.c_movimientos_articulo_mantenimiento.findMany({
                                        where: { OR: or },
                                        orderBy: { id: "desc" },
                                        select: {
                                            id: true,
                                            articulo_plan_id: true,
                                            articulo_asignado_id: true,
                                            nombre_persona_recibe: true,
                                            nombre_persona_entrega: true,
                                            departamento: true,
                                            telefono: true,
                                            entrega: true,
                                            recibe: true,
                                            fecha: true,
                                            hora: true,
                                            firma_entrega: true,
                                            firma_recibe: true,
                                            firma_responsable: true,
                                        },
                                    });

                                    const movsByPlanId = new Map<number, any[]>();
                                    const movsByAsignadoId = new Map<number, any[]>();
                                    for (const mov of movimientos) {
                                        if (mov.articulo_plan_id) {
                                            const list = movsByPlanId.get(mov.articulo_plan_id) ?? [];
                                            list.push(mov);
                                            movsByPlanId.set(mov.articulo_plan_id, list);
                                        }
                                        if (mov.articulo_asignado_id) {
                                            const list = movsByAsignadoId.get(mov.articulo_asignado_id) ?? [];
                                            list.push(mov);
                                            movsByAsignadoId.set(mov.articulo_asignado_id, list);
                                        }
                                    }

                                    articulos_return = articulos_return.map((a) => ({
                                        ...a,
                                        key: `${a.tipo === "Plan" ? "plan" : "asignado"}-${a.id}`,
                                        source: a.tipo === "Plan" ? "plan" : "asignado",
                                        estructura_id: a.id,
                                        articulo_nombre: a.nombre,
                                        cantidad_plan: a.tipo === "Plan" ? a.cantidad : null,
                                        marca:
                                            a.tipo === "Plan"
                                                ? (latestByPlanId.get(a.id)?.marca ?? a.marca ?? null)
                                                : (a.marca ?? null),
                                        serie:
                                            a.tipo === "Plan"
                                                ? (latestByPlanId.get(a.id)?.serie_placa ?? a.serie ?? null)
                                                : (a.serie ?? null),
                                        mantenimientos:
                                            a.tipo === "Plan"
                                                ? (mantenimientosByPlanId.get(a.id) ?? [])
                                                : (mantenimientosByAsignadoId.get(a.id) ?? []),
                                        ultimo_mantenimiento:
                                            a.tipo === "Plan"
                                                ? (latestByPlanId.get(a.id) ?? null)
                                                : (latestByAsignadoId.get(a.id) ?? null),
                                        ultimo_registro_mantenimiento:
                                            a.tipo === "Plan"
                                                ? (latestByPlanId.get(a.id) ?? null)
                                                : (latestByAsignadoId.get(a.id) ?? null),
                                        movimientos:
                                            a.tipo === "Plan"
                                                ? (movsByPlanId.get(a.id) ?? [])
                                                : (movsByAsignadoId.get(a.id) ?? []),
                                    }));
                                } else {
                                    articulos_return = articulos_return.map((a) => ({
                                        ...a,
                                        key: `${a.tipo === "Plan" ? "plan" : "asignado"}-${a.id}`,
                                        source: a.tipo === "Plan" ? "plan" : "asignado",
                                        estructura_id: a.id,
                                        articulo_nombre: a.nombre,
                                        cantidad_plan: a.tipo === "Plan" ? a.cantidad : null,
                                        mantenimientos: [],
                                        ultimo_mantenimiento: null,
                                        ultimo_registro_mantenimiento: null,
                                        movimientos: [],
                                    }));
                                }

                                puesto_data.articulos = articulos_return as never[];
                                sucursal_data.puestos.push(puesto_data as never);
                            }

                            contrato_data.sucursales.push(sucursal_data as never);
                        }

                        division_data.contratos.push(contrato_data as never);
                    }

                    cliente_data.division.push(division_data as never);
                }

                empresa_data.clientes.push(cliente_data as never);
            }

            structure.push(empresa_data as never);
        }

        // Imprimr la cantidad de caracteres de la estructura cuando se convierta a string
        console.log("Cantidad de caracteres de la estructura:", JSON.stringify(structure).length);
        return NextResponse.json({ status: true, structure }, { status: 200 });
    } catch (error: unknown) {
        const errorMessage = error instanceof Error ? error.message : "Error desconocido";
        return NextResponse.json({ message: errorMessage }, { status: 500 });
    }
}

/*

import { NextRequest, NextResponse } from "next/server";
import { toZonedTime } from "date-fns-tz";
import { prisma } from "../../../../utils/prismaClient";
import { verifyAccessToken } from "../../../../utils/verifyToken";
import { verifyTokenFromBody } from "../../../../utils/verifyTokenFromBody";

type TipoMantenimientoArticuloDTO = { id: number; nombre: string };

type MainStructurePayload = {
    token?: string;
    mobileAccessToken?: string;
    shouldVerifyAccessToken?: boolean;
};

function uniqueFiniteNumberArray(values: Array<unknown>): number[] {
    return Array.from(
        new Set(values.filter((id): id is number => typeof id === "number" && Number.isFinite(id)))
    );
}

export async function POST(req: NextRequest) {
    try {
        const payload = (await req.json()) as MainStructurePayload;
        if (!payload || typeof payload !== "object") {
            return NextResponse.json({ status: false, message: "Payload inválido" }, { status: 400 });
        }

        const expectedMobileToken = process.env.MOBILE_ACCESS_TOKEN?.trim();
        const incomingMobileToken = String(payload.mobileAccessToken || "").trim();

        if (!expectedMobileToken) {
            return NextResponse.json(
                { status: false, message: "MOBILE_ACCESS_TOKEN no configurado en el servidor" },
                { status: 500 }
            );
        }
        if (!incomingMobileToken) {
            return NextResponse.json(
                { status: false, message: "mobileAccessToken es obligatorio" },
                { status: 403 }
            );
        }
        if (incomingMobileToken !== expectedMobileToken) {
            return NextResponse.json(
                { status: false, message: "mobileAccessToken inválido" },
                { status: 403 }
            );
        }

        const shouldVerifyAccessToken = payload.shouldVerifyAccessToken !== false;
        if (shouldVerifyAccessToken) {
            const tokenValidationHeader = verifyAccessToken(req);
            const tokenValidationBody = verifyTokenFromBody(payload.token);
            const tokenValidation = tokenValidationHeader.valid ? tokenValidationHeader : tokenValidationBody;

            if (!tokenValidation.valid) {
                return NextResponse.json(
                    { status: false, expired: tokenValidation.expired, message: tokenValidation.message },
                    { status: tokenValidation.expired ? 401 : 403 }
                );
            }
        }

        const nowCostaRica = toZonedTime(new Date(), "America/Costa_Rica");
        const structure: any[] = [];

        // Pre-carga global para evitar query repetida por cliente.
        const divisions = await prisma.n_division.findMany({
            select: { id: true, nombre: true },
            orderBy: { id: "asc" },
        });

        const empresas = await prisma.e_estructura_empresa.findMany({
            where: { deleted: null },
            select: { id: true, codigo: true, nombre: true },
            orderBy: { id: "asc" },
        });

        for (const empresa of empresas) {
            const empresa_data = {
                id: empresa.id,
                nombre: `${empresa.codigo} - ${empresa.nombre}`,
                clientes: [] as any[],
            };

            const clientes = await prisma.e_estructura_cliente.findMany({
                where: {
                    empresa_id: empresa.id,
                    deleted: null,
                    OR: [{ fecha_inactivacion: null }, { fecha_inactivacion: { gte: nowCostaRica } }],
                },
                select: { id: true, nombre: true },
                orderBy: { id: "asc" },
            });

            for (const cliente of clientes) {
                const cliente_data = { id: cliente.id, nombre: cliente.nombre, division: [] as any[] };

                // Contratos del cliente en un solo query (en vez de por division).
                const contratos = await prisma.e_estructura_contrato.findMany({
                    where: {
                        cliente_id: cliente.id,
                        deleted: null,
                        OR: [{ fecha_inactivacion: null }, { fecha_inactivacion: { gte: nowCostaRica } }],
                    },
                    select: { id: true, nombre: true, division_id: true },
                    orderBy: { id: "asc" },
                });

                const contratosByDivisionId = new Map<number, any[]>();
                const contratoIds = contratos.map((c) => c.id);
                for (const contrato of contratos) {
                    const list = contratosByDivisionId.get(contrato.division_id) ?? [];
                    list.push(contrato);
                    contratosByDivisionId.set(contrato.division_id, list);
                }

                // Sucursales en un solo query para todos los contratos del cliente.
                const sucursalesAll =
                    contratoIds.length > 0
                        ? await prisma.e_estructura_sucursal.findMany({
                              where: {
                                  contrato_id: { in: contratoIds },
                                  deleted: null,
                                  OR: [{ fecha_inactivacion: null }, { fecha_inactivacion: { gte: nowCostaRica } }],
                              },
                              select: { id: true, nombre: true, nro_sucursal: true, contrato_id: true },
                              orderBy: { id: "asc" },
                          })
                        : [];

                const sucursalesByContratoId = new Map<number, any[]>();
                for (const sucursal of sucursalesAll) {
                    const list = sucursalesByContratoId.get(sucursal.contrato_id) ?? [];
                    list.push(sucursal);
                    sucursalesByContratoId.set(sucursal.contrato_id, list);
                }

                // Mantiene misma estructura final: todas las divisiones con contratos (o vacias).
                for (const division of divisions) {
                    const division_data = {
                        id: division.id,
                        nombre: division.nombre,
                        contratos: [] as any[],
                    };

                    const contratosForDivision = contratosByDivisionId.get(division.id) ?? [];
                    for (const contrato of contratosForDivision) {
                        const contrato_data = { id: contrato.id, nombre: contrato.nombre, sucursales: [] as any[] };
                        const sucursales = sucursalesByContratoId.get(contrato.id) ?? [];

                        for (const sucursal of sucursales) {
                            const sucursal_data = {
                                id: sucursal.id,
                                nombre: `${sucursal.nro_sucursal} - ${sucursal.nombre}`,
                                vehiculos_corporativos: [] as any[],
                                puestos: [] as any[],
                            };

                            const vehiculos = await prisma.c_vehiculos_corporativos.findMany({
                                where: { sucursal_id: sucursal.id },
                                include: {
                                    c_usos_vehiculos_corporativos: true,
                                    c_mantenimiento_vehiculos_corporativos: true,
                                },
                            });

                            const bitacoraIds = uniqueFiniteNumberArray(
                                vehiculos.flatMap((v: any) =>
                                    v.c_usos_vehiculos_corporativos.map((u: any) => u.bitacora_id)
                                )
                            );
                            const bitacoras = bitacoraIds.length
                                ? await prisma.c_bitacora_vehiculo_detenido.findMany({
                                      where: { id: { in: bitacoraIds } },
                                  })
                                : [];
                            const bitacoraById = new Map(bitacoras.map((b: any) => [b.id, b]));

                            sucursal_data.vehiculos_corporativos = vehiculos.map((v: any) => ({
                                ...v,
                                usos: v.c_usos_vehiculos_corporativos.map((u: any) => ({
                                    ...u,
                                    bitacora: u.bitacora_id ? bitacoraById.get(u.bitacora_id) ?? null : null,
                                })),
                            }));

                            const puestos = await prisma.e_estructura_puesto.findMany({
                                where: {
                                    sucursal_id: sucursal.id,
                                    deleted: null,
                                    OR: [{ fecha_inactivacion: null }, { fecha_inactivacion: { gte: nowCostaRica } }],
                                },
                                select: {
                                    id: true,
                                    codigo: true,
                                    nombre: true,
                                    coordenadas_gpslat: true,
                                    coordenadas_gpslng: true,
                                    comboArticulosCP_id: true,
                                },
                                orderBy: { id: "asc" },
                            });

                            const puestoIds = puestos.map((p) => p.id);
                            const plazas =
                                puestoIds.length > 0
                                    ? await prisma.e_estructura_plazas.findMany({
                                          where: {
                                              puesto_id: { in: puestoIds },
                                              deleted: null,
                                              OR: [{ fecha_inactivacion: null }, { fecha_inactivacion: { gte: nowCostaRica } }],
                                          },
                                          select: {
                                              id: true,
                                              puesto_id: true,
                                              codigo_plaza: true,
                                              nombre: true,
                                          },
                                      })
                                    : [];

                            const plazasByPuestoId = new Map<number, any[]>();
                            const plazaIds = plazas.map((p) => p.id);
                            for (const plaza of plazas) {
                                const list = plazasByPuestoId.get(plaza.puesto_id) ?? [];
                                list.push(plaza);
                                plazasByPuestoId.set(plaza.puesto_id, list);
                            }

                            const plazaEmpleadoRows =
                                plazaIds.length > 0
                                    ? await prisma.c_empleado_plaza.findMany({
                                          where: { plaza_id: { in: plazaIds }, empleado_id: { not: null } },
                                          select: { plaza_id: true, empleado_id: true },
                                      })
                                    : [];

                            const empleadoIds = uniqueFiniteNumberArray(
                                plazaEmpleadoRows.map((row: any) => row.empleado_id)
                            );

                            const empleados =
                                empleadoIds.length > 0
                                    ? await prisma.c_empleado.findMany({
                                          where: {
                                              id: { in: empleadoIds },
                                              fecha_contratacion: { not: null },
                                              OR: [{ estado: null }, { estado: { not: "BA" } }],
                                              NOT: [{ cedula: { contains: "@" } }],
                                          },
                                          select: {
                                              id: true,
                                              codigo: true,
                                              cedula: true,
                                              nombre: true,
                                              primer_apellido: true,
                                              segundo_apellido: true,
                                              Email: true,
                                              telefono: true,
                                              tipoCedula: true,
                                              fecha_contratacion: true,
                                              estado: true,
                                              supervisor_id: true,
                                              firma_manual: true,
                                          },
                                          orderBy: [
                                              { nombre: "asc" },
                                              { primer_apellido: "asc" },
                                              { segundo_apellido: "asc" },
                                              { id: "asc" },
                                          ],
                                      })
                                    : [];

                            const plazaIdsByEmpleadoId = new Map<number, number[]>();
                            for (const row of plazaEmpleadoRows) {
                                const list = plazaIdsByEmpleadoId.get(row.empleado_id) ?? [];
                                list.push(row.plaza_id);
                                plazaIdsByEmpleadoId.set(row.empleado_id, list);
                            }

                            const empleadosByPlazaId = new Map<number, any[]>();
                            for (const empleado of empleados) {
                                const relatedPlazas = plazaIdsByEmpleadoId.get(empleado.id) ?? [];
                                for (const plazaId of relatedPlazas) {
                                    const list = empleadosByPlazaId.get(plazaId) ?? [];
                                    list.push(empleado);
                                    empleadosByPlazaId.set(plazaId, list);
                                }
                            }

                            for (const puesto of puestos) {
                                const puesto_data = {
                                    id: puesto.id,
                                    nombre: `${puesto.codigo} - ${puesto.nombre}`,
                                    ubicacion: {
                                        lat: puesto.coordenadas_gpslat ?? null,
                                        lng: puesto.coordenadas_gpslng ?? null,
                                    },
                                    plazas: [] as any[],
                                    articulos: [] as any[],
                                };

                                const plazasForPuesto = plazasByPuestoId.get(puesto.id) ?? [];
                                for (const plaza of plazasForPuesto) {
                                    puesto_data.plazas.push({
                                        id: plaza.id,
                                        nombre: `${plaza.codigo_plaza} - ${plaza.nombre}`,
                                        empleados: empleadosByPlazaId.get(plaza.id) ?? [],
                                    });
                                }

                                let articulos_return: any[] = [];

                                const articulos_combo = puesto.comboArticulosCP_id
                                    ? await prisma.e_estructura_articulo_corpo_puesto_plan.findMany({
                                          where: { combo_id: puesto.comboArticulosCP_id },
                                          select: { id: true, articuloCP_id: true, cantidad: true },
                                      })
                                    : [];

                                const comboIds = articulos_combo.map((a: any) => a.id);
                                const articulos_plan = await prisma.e_estructura_articulo_corpo_puesto_plan.findMany({
                                    where: {
                                        puesto_id: puesto.id,
                                        ...(comboIds.length ? { id: { notIn: comboIds } } : {}),
                                    },
                                    select: { id: true, articuloCP_id: true, cantidad: true },
                                });

                                const articulos_entrega =
                                    await prisma.e_estructura_articulo_corpo_puesto_entrega.findMany({
                                        where: { puesto_id: puesto.id },
                                        select: {
                                            id: true,
                                            nomencladorArticuloCP_id: true,
                                            marca: true,
                                            serie: true,
                                        },
                                    });

                                const nomencladorIds = uniqueFiniteNumberArray([
                                    ...articulos_combo.map((a: any) => a.articuloCP_id),
                                    ...articulos_plan.map((a: any) => a.articuloCP_id),
                                    ...articulos_entrega.map((a: any) => a.nomencladorArticuloCP_id),
                                ]);

                                const nomencladores =
                                    nomencladorIds.length > 0
                                        ? await prisma.n_articulo_corpo_puesto.findMany({
                                              where: { id: { in: nomencladorIds } },
                                              select: { id: true, nombre: true },
                                          })
                                        : [];
                                const nombreByNomencladorId = new Map(
                                    nomencladores.map((n: any) => [n.id, n.nombre])
                                );

                                for (const articulo of articulos_combo) {
                                    articulos_return.push({
                                        id: articulo.id,
                                        nombre:
                                            nombreByNomencladorId.get(articulo.articuloCP_id ?? -1) ??
                                            "Desconocido",
                                        tipo: "Plan",
                                        marca: "",
                                        serie: "",
                                        cantidad: articulo.cantidad,
                                        articulo_nomenclador_id: articulo.articuloCP_id ?? null,
                                        tipos_mantenimiento: [],
                                    });
                                }

                                for (const articulo of articulos_plan) {
                                    articulos_return.push({
                                        id: articulo.id,
                                        nombre:
                                            nombreByNomencladorId.get(articulo.articuloCP_id ?? -1) ??
                                            "Desconocido",
                                        tipo: "Plan",
                                        marca: "",
                                        serie: "",
                                        cantidad: articulo.cantidad,
                                        articulo_nomenclador_id: articulo.articuloCP_id ?? null,
                                        tipos_mantenimiento: [],
                                    });
                                }

                                for (const articulo of articulos_entrega) {
                                    articulos_return.push({
                                        id: articulo.id,
                                        nombre:
                                            nombreByNomencladorId.get(articulo.nomencladorArticuloCP_id ?? -1) ??
                                            "Artículo inidentificable",
                                        tipo: "Asignado",
                                        marca: articulo.marca,
                                        serie: articulo.serie,
                                        cantidad: 1,
                                        articulo_nomenclador_id: articulo.nomencladorArticuloCP_id ?? null,
                                        tipos_mantenimiento: [],
                                    });
                                }

                                const articuloNomencladorIds = uniqueFiniteNumberArray(
                                    articulos_return.map((a) => a.articulo_nomenclador_id)
                                );
                                if (articuloNomencladorIds.length > 0) {
                                    const tiposRows = await prisma.n_tipo_mantenimiento_articulo.findMany({
                                        where: { articulo_id: { in: articuloNomencladorIds } },
                                        select: { id: true, articulo_id: true, nombre: true },
                                        orderBy: { id: "asc" },
                                    });
                                    const tiposByArticuloId = new Map<number, TipoMantenimientoArticuloDTO[]>();
                                    for (const t of tiposRows) {
                                        const list = tiposByArticuloId.get(t.articulo_id) ?? [];
                                        list.push({ id: t.id, nombre: t.nombre });
                                        tiposByArticuloId.set(t.articulo_id, list);
                                    }
                                    articulos_return = articulos_return.map((a) => ({
                                        ...a,
                                        tipos_mantenimiento: a.articulo_nomenclador_id
                                            ? (tiposByArticuloId.get(a.articulo_nomenclador_id) ?? [])
                                            : [],
                                    }));
                                }

                                const planIds = articulos_return
                                    .filter((a) => a.tipo === "Plan")
                                    .map((a) => a.id);
                                const asignadoIds = articulos_return
                                    .filter((a) => a.tipo === "Asignado")
                                    .map((a) => a.id);

                                if (planIds.length > 0 || asignadoIds.length > 0) {
                                    const or: any[] = [];
                                    if (planIds.length) or.push({ articulo_plan_id: { in: planIds } });
                                    if (asignadoIds.length) or.push({ articulo_asignado_id: { in: asignadoIds } });

                                    const mantenimientos = await prisma.c_articulo_mantenimiento.findMany({
                                        where: { OR: or },
                                        orderBy: { id: "desc" },
                                        include: {
                                            c_archivos_adjuntos_articulo_mantenimiento: {
                                                select: {
                                                    id: true,
                                                    name: true,
                                                    original_name: true,
                                                    type: true,
                                                    extension: true,
                                                },
                                            },
                                        },
                                    });

                                    const latestByPlanId = new Map<number, any>();
                                    const latestByAsignadoId = new Map<number, any>();
                                    const mantenimientosByPlanId = new Map<number, any[]>();
                                    const mantenimientosByAsignadoId = new Map<number, any[]>();
                                    for (const m of mantenimientos) {
                                        if (m.articulo_plan_id && !latestByPlanId.has(m.articulo_plan_id)) {
                                            latestByPlanId.set(m.articulo_plan_id, m);
                                        }
                                        if (
                                            m.articulo_asignado_id &&
                                            !latestByAsignadoId.has(m.articulo_asignado_id)
                                        ) {
                                            latestByAsignadoId.set(m.articulo_asignado_id, m);
                                        }
                                        if (m.articulo_plan_id) {
                                            const list = mantenimientosByPlanId.get(m.articulo_plan_id) ?? [];
                                            if (list.length < 8) {
                                                list.push(m);
                                                mantenimientosByPlanId.set(m.articulo_plan_id, list);
                                            }
                                        }
                                        if (m.articulo_asignado_id) {
                                            const list = mantenimientosByAsignadoId.get(m.articulo_asignado_id) ?? [];
                                            if (list.length < 8) {
                                                list.push(m);
                                                mantenimientosByAsignadoId.set(m.articulo_asignado_id, list);
                                            }
                                        }
                                    }

                                    const movimientos =
                                        await prisma.c_movimientos_articulo_mantenimiento.findMany({
                                            where: { OR: or },
                                            orderBy: { id: "desc" },
                                            select: {
                                                id: true,
                                                articulo_plan_id: true,
                                                articulo_asignado_id: true,
                                                nombre_persona_recibe: true,
                                                nombre_persona_entrega: true,
                                                departamento: true,
                                                telefono: true,
                                                entrega: true,
                                                recibe: true,
                                                fecha: true,
                                                hora: true,
                                                firma_entrega: true,
                                                firma_recibe: true,
                                                firma_responsable: true,
                                            },
                                        });

                                    const movsByPlanId = new Map<number, any[]>();
                                    const movsByAsignadoId = new Map<number, any[]>();
                                    for (const mov of movimientos) {
                                        if (mov.articulo_plan_id) {
                                            const list = movsByPlanId.get(mov.articulo_plan_id) ?? [];
                                            list.push(mov);
                                            movsByPlanId.set(mov.articulo_plan_id, list);
                                        }
                                        if (mov.articulo_asignado_id) {
                                            const list = movsByAsignadoId.get(mov.articulo_asignado_id) ?? [];
                                            list.push(mov);
                                            movsByAsignadoId.set(mov.articulo_asignado_id, list);
                                        }
                                    }

                                    articulos_return = articulos_return.map((a) => ({
                                        ...a,
                                        key: `${a.tipo === "Plan" ? "plan" : "asignado"}-${a.id}`,
                                        source: a.tipo === "Plan" ? "plan" : "asignado",
                                        estructura_id: a.id,
                                        articulo_nombre: a.nombre,
                                        cantidad_plan: a.tipo === "Plan" ? a.cantidad : null,
                                        marca:
                                            a.tipo === "Plan"
                                                ? latestByPlanId.get(a.id)?.marca ?? a.marca ?? null
                                                : a.marca ?? null,
                                        serie:
                                            a.tipo === "Plan"
                                                ? latestByPlanId.get(a.id)?.serie_placa ?? a.serie ?? null
                                                : a.serie ?? null,
                                        mantenimientos:
                                            a.tipo === "Plan"
                                                ? (mantenimientosByPlanId.get(a.id) ?? [])
                                                : (mantenimientosByAsignadoId.get(a.id) ?? []),
                                        ultimo_mantenimiento:
                                            a.tipo === "Plan"
                                                ? (latestByPlanId.get(a.id) ?? null)
                                                : (latestByAsignadoId.get(a.id) ?? null),
                                        ultimo_registro_mantenimiento:
                                            a.tipo === "Plan"
                                                ? (latestByPlanId.get(a.id) ?? null)
                                                : (latestByAsignadoId.get(a.id) ?? null),
                                        movimientos:
                                            a.tipo === "Plan"
                                                ? (movsByPlanId.get(a.id) ?? [])
                                                : (movsByAsignadoId.get(a.id) ?? []),
                                    }));
                                } else {
                                    articulos_return = articulos_return.map((a) => ({
                                        ...a,
                                        key: `${a.tipo === "Plan" ? "plan" : "asignado"}-${a.id}`,
                                        source: a.tipo === "Plan" ? "plan" : "asignado",
                                        estructura_id: a.id,
                                        articulo_nombre: a.nombre,
                                        cantidad_plan: a.tipo === "Plan" ? a.cantidad : null,
                                        mantenimientos: [],
                                        ultimo_mantenimiento: null,
                                        ultimo_registro_mantenimiento: null,
                                        movimientos: [],
                                    }));
                                }

                                puesto_data.articulos = articulos_return as never[];
                                sucursal_data.puestos.push(puesto_data as never);
                            }

                            contrato_data.sucursales.push(sucursal_data as never);
                        }

                        division_data.contratos.push(contrato_data as never);
                    }

                    cliente_data.division.push(division_data as never);
                }

                empresa_data.clientes.push(cliente_data as never);
            }

            structure.push(empresa_data as never);
        }

        return NextResponse.json({ status: true, structure }, { status: 200 });
    } catch (error: unknown) {
        const errorMessage = error instanceof Error ? error.message : "Error desconocido";
        return NextResponse.json({ message: errorMessage }, { status: 500 });
    }
}

import { NextRequest, NextResponse } from "next/server";
import { toZonedTime } from "date-fns-tz";
import { prisma } from "../../../../utils/prismaClient";
import { verifyAccessToken } from "../../../../utils/verifyToken";
import { verifyTokenFromBody } from "../../../../utils/verifyTokenFromBody";

type TipoMantenimientoArticuloDTO = { id: number; nombre: string };

type MainStructurePayload = {
    token?: string;
    mobileAccessToken?: string;
    shouldVerifyAccessToken?: boolean;
};

export async function POST(req: NextRequest) {
    try {
        console.log("Inicio del endpoint");
        const payload = (await req.json()) as MainStructurePayload;
        if (!payload || typeof payload !== "object") {
            return NextResponse.json({ status: false, message: "Payload inválido" }, { status: 400 });
        }

        const expectedMobileToken = process.env.MOBILE_ACCESS_TOKEN?.trim();
        const incomingMobileToken = String(payload.mobileAccessToken || "").trim();

        if (!expectedMobileToken) {
            return NextResponse.json(
                { status: false, message: "MOBILE_ACCESS_TOKEN no configurado en el servidor" },
                { status: 500 }
            );
        }
        if (!incomingMobileToken) {
            console.log("mobileAccessToken es obligatorio");
            return NextResponse.json(
                { status: false, message: "mobileAccessToken es obligatorio" },
                { status: 403 }
            );
        }
        if (incomingMobileToken !== expectedMobileToken) {
            console.log("mobileAccessToken inválido");
            return NextResponse.json(
                { status: false, message: "mobileAccessToken inválido" },
                { status: 403 }
            );
        }

        const shouldVerifyAccessToken = payload.shouldVerifyAccessToken !== false;
        const tokenValidationHeader = verifyAccessToken(req);
        const tokenValidationBody = verifyTokenFromBody(payload.token);
        const tokenValidation = tokenValidationHeader.valid ? tokenValidationHeader : tokenValidationBody;

        if (shouldVerifyAccessToken && !tokenValidation.valid) {
            return NextResponse.json(
                { status: false, expired: tokenValidation.expired, message: tokenValidation.message },
                { status: tokenValidation.expired ? 401 : 403 }
            );
        }

        const nowCostaRica = toZonedTime(new Date(), "America/Costa_Rica");

        const main = await prisma.e_estructura_empresa.findMany({ where: { deleted: null } });

        // Nota: este endpoint se usa como "cache" offline en mobile. Evitamos tipado rígido aquí
        // porque se le agregan propiedades nuevas con el tiempo (ej: vehículos corporativos).
        const structure: any[] = [];

        console.log("Inicio del bucle");
        for (const empresa of main) {
            console.log("Empresa");
            const empresa_data = { id: empresa.id, nombre: `${empresa.codigo} - ${empresa.nombre}`, clientes: [] };
            const clientes = await prisma.e_estructura_cliente.findMany({
                where: {
                    empresa_id: empresa.id,
                    deleted: null,
                    OR: [{ fecha_inactivacion: null }, { fecha_inactivacion: { gte: nowCostaRica } }],
                },
            });
            for (const cliente of clientes) {
                console.log("Cliente");
                const cliente_data = { id: cliente.id, nombre: cliente.nombre, division: [] };
                const divisions = await prisma.n_division.findMany();
                for (const division of divisions) {
                    console.log("Division");
                    const division_data = { id: division.id, nombre: division.nombre, contratos: [] };
                    const contratos = await prisma.e_estructura_contrato.findMany({
                        where: {
                            cliente_id: cliente.id,
                            division_id: division.id,
                            deleted: null,
                            OR: [
                                { fecha_inactivacion: null },
                                { fecha_inactivacion: { gte: nowCostaRica } },
                            ],
                        },
                    });
                    for (const contrato of contratos) {
                        console.log("Contrato");
                        const contrato_data = { id: contrato.id, nombre: contrato.nombre, sucursales: [] };
                        const sucursales = await prisma.e_estructura_sucursal.findMany({
                            where: {
                                contrato_id: contrato.id,
                                deleted: null,
                                OR: [
                                    { fecha_inactivacion: null },
                                    { fecha_inactivacion: { gte: nowCostaRica } },
                                ],
                            },
                        });
                        for (const sucursal of sucursales) {
                            console.log("Sucursal");
                            const sucursal_data = {
                                id: sucursal.id,
                                nombre: `${sucursal.nro_sucursal} - ${sucursal.nombre}`,
                                // Nuevo: vehículos corporativos + usos + bitácora vinculada (si existe)
                                vehiculos_corporativos: [] as any[],
                                puestos: [] as any[],
                            };

                            // Vehículos corporativos de la sucursal, con usos
                            const vehiculos = await prisma.c_vehiculos_corporativos.findMany({
                                where: { sucursal_id: sucursal.id },
                                include: { c_usos_vehiculos_corporativos: true, c_mantenimiento_vehiculos_corporativos: true },
                            });

                            // Adjuntamos el registro de bitácora a cada uso (si `bitacora_id` viene seteado)
                            const bitacoraIds = Array.from(
                                new Set(
                                    vehiculos
                                        .flatMap((v: any) => v.c_usos_vehiculos_corporativos.map((u: any) => u.bitacora_id))
                                        .filter((id: any): id is number => typeof id === "number" && Number.isFinite(id))
                                )
                            );
                            const bitacoras = bitacoraIds.length
                                ? await prisma.c_bitacora_vehiculo_detenido.findMany({ where: { id: { in: bitacoraIds } } })
                                : [];
                            const bitacoraById = new Map(bitacoras.map((b: any) => [b.id, b]));

                            sucursal_data.vehiculos_corporativos = vehiculos.map((v: any) => ({
                                ...v,
                                usos: v.c_usos_vehiculos_corporativos.map((u: any) => ({
                                    ...u,
                                    bitacora: u.bitacora_id ? bitacoraById.get(u.bitacora_id) ?? null : null,
                                })),
                            }));

                            const puestos = await prisma.e_estructura_puesto.findMany({
                                where: {
                                    sucursal_id: sucursal.id,
                                    deleted: null,
                                    OR: [
                                        { fecha_inactivacion: null },
                                        { fecha_inactivacion: { gte: nowCostaRica } },
                                    ],
                                },
                            });

                            for (const puesto of puestos) {
                                console.log("Puesto");
                                const puesto_data = { id: puesto.id, nombre: `${puesto.codigo} - ${puesto.nombre}`, ubicacion: { lat: puesto.coordenadas_gpslat ?? null, lng: puesto.coordenadas_gpslng ?? null }, plazas: [], articulos: [] };

                                let articulos_return: any[] = [];

                                if (puesto.comboArticulosCP_id) {
                                    const combo_articulo_cp = await prisma.e_estructura_combo_articulo_cp.findUnique({ where: { id: puesto.comboArticulosCP_id } });
                                    if (combo_articulo_cp) {
                                        const articulos_combo_articulo_cp = await prisma.e_estructura_articulo_corpo_puesto_plan.findMany({ where: { combo_id: combo_articulo_cp.id } });
                                        for (const articulo of articulos_combo_articulo_cp) {
                                            console.log("Articulo combo");
                                            let art_bd = null;
                                            if (articulo.articuloCP_id) {
                                                art_bd = await prisma.n_articulo_corpo_puesto.findUnique({ where: { id: articulo.articuloCP_id } });
                                            }
                                            articulos_return.push({
                                                id: articulo.id,
                                                nombre: art_bd ? art_bd.nombre : "Desconocido",
                                                tipo: "Plan",
                                                marca: "",
                                                serie: "",
                                                cantidad: articulo.cantidad,
                                                articulo_nomenclador_id: articulo.articuloCP_id ?? null,
                                                tipos_mantenimiento: [],
                                            });
                                        }
                                    }
                                }

                                const articulos_puesto_plan = await prisma.e_estructura_articulo_corpo_puesto_plan.findMany({ where: { puesto_id: puesto.id, id: { notIn: articulos_return.map(articulo => articulo.id) } } });
                                for (const articulo of articulos_puesto_plan) {
                                    console.log("Articulo plan");
                                    let art_bd = null;
                                    if (articulo.articuloCP_id) {
                                        art_bd = await prisma.n_articulo_corpo_puesto.findUnique({ where: { id: articulo.articuloCP_id } });
                                    }
                                    articulos_return.push({
                                        id: articulo.id,
                                        nombre: art_bd ? art_bd.nombre : "Desconocido",
                                        tipo: "Plan",
                                        marca: "",
                                        serie: "",
                                        cantidad: articulo.cantidad,
                                        articulo_nomenclador_id: articulo.articuloCP_id ?? null,
                                        tipos_mantenimiento: [],
                                    });
                                }

                                const articulos_puesto_entrega = await prisma.e_estructura_articulo_corpo_puesto_entrega.findMany({ where: { puesto_id: puesto.id } });
                                for (const articulo of articulos_puesto_entrega) {
                                    console.log("Articulo entrega");
                                    let art_bd = null;
                                    if (articulo.nomencladorArticuloCP_id) {
                                        art_bd = await prisma.n_articulo_corpo_puesto.findUnique({ where: { id: articulo.nomencladorArticuloCP_id } });
                                    }
                                    articulos_return.push({
                                        id: articulo.id,
                                        nombre: art_bd ? art_bd.nombre : `Artículo inidentificable`,
                                        tipo: "Asignado",
                                        marca: articulo.marca,
                                        serie: articulo.serie,
                                        cantidad: 1,
                                        articulo_nomenclador_id: articulo.nomencladorArticuloCP_id ?? null,
                                        tipos_mantenimiento: [],
                                    });
                                }

                                // Adjuntar tipos de mantenimiento por artículo nomenclador (n_tipo_mantenimiento_articulo)
                                const articuloNomencladorIds = Array.from(
                                    new Set(
                                        articulos_return
                                            .map((a) => a.articulo_nomenclador_id)
                                            .filter((id): id is number => typeof id === "number" && Number.isFinite(id))
                                    )
                                );
                                if (articuloNomencladorIds.length > 0) {
                                    const tiposRows = await prisma.n_tipo_mantenimiento_articulo.findMany({
                                        where: { articulo_id: { in: articuloNomencladorIds } },
                                        select: { id: true, articulo_id: true, nombre: true },
                                        orderBy: { id: "asc" },
                                    });
                                    const tiposByArticuloId = new Map<number, TipoMantenimientoArticuloDTO[]>();
                                    for (const t of tiposRows) {
                                        console.log("Tipo de mantenimiento");
                                        const list = tiposByArticuloId.get(t.articulo_id) ?? [];
                                        list.push({ id: t.id, nombre: t.nombre });
                                        tiposByArticuloId.set(t.articulo_id, list);
                                    }
                                    articulos_return = articulos_return.map((a) => ({
                                        ...a,
                                        tipos_mantenimiento: a.articulo_nomenclador_id
                                            ? (tiposByArticuloId.get(a.articulo_nomenclador_id) ?? [])
                                            : [],
                                    }));
                                }

                                // Adjuntar último mantenimiento a cada artículo del puesto
                                const planIds = articulos_return.filter((a) => a.tipo === "Plan").map((a) => a.id);
                                const asignadoIds = articulos_return.filter((a) => a.tipo === "Asignado").map((a) => a.id);

                                if (planIds.length > 0 || asignadoIds.length > 0) {
                                    const or: any[] = [];
                                    if (planIds.length) or.push({ articulo_plan_id: { in: planIds } });
                                    if (asignadoIds.length) or.push({ articulo_asignado_id: { in: asignadoIds } });

                                    const mantenimientos = await prisma.c_articulo_mantenimiento.findMany({
                                        where: { OR: or },
                                        orderBy: { id: "desc" },
                                        include: {
                                            c_archivos_adjuntos_articulo_mantenimiento: {
                                                select: {
                                                    id: true,
                                                    name: true,
                                                    original_name: true,
                                                    type: true,
                                                    extension: true,
                                                },
                                            },
                                        },
                                    });

                                    const latestByPlanId = new Map<number, any>();
                                    const latestByAsignadoId = new Map<number, any>();
                                    const mantenimientosByPlanId = new Map<number, any[]>();
                                    const mantenimientosByAsignadoId = new Map<number, any[]>();
                                    for (const m of mantenimientos) {
                                        console.log("Mantenimiento");
                                        if (m.articulo_plan_id && !latestByPlanId.has(m.articulo_plan_id)) latestByPlanId.set(m.articulo_plan_id, m);
                                        if (m.articulo_asignado_id && !latestByAsignadoId.has(m.articulo_asignado_id)) latestByAsignadoId.set(m.articulo_asignado_id, m);
                                        if (m.articulo_plan_id) {
                                            const list = mantenimientosByPlanId.get(m.articulo_plan_id) ?? [];
                                            if (list.length < 8) {
                                                list.push(m);
                                                mantenimientosByPlanId.set(m.articulo_plan_id, list);
                                            }
                                        }
                                        if (m.articulo_asignado_id) {
                                            const list = mantenimientosByAsignadoId.get(m.articulo_asignado_id) ?? [];
                                            if (list.length < 8) {
                                                list.push(m);
                                                mantenimientosByAsignadoId.set(m.articulo_asignado_id, list);
                                            }
                                        }
                                    }

                                    // Adjuntar movimientos a cada artículo del puesto
                                    const movimientos = await prisma.c_movimientos_articulo_mantenimiento.findMany({
                                        where: { OR: or },
                                        orderBy: { id: "desc" },
                                        select: {
                                            id: true,
                                            articulo_plan_id: true,
                                            articulo_asignado_id: true,
                                            nombre_persona_recibe: true,
                                            nombre_persona_entrega: true,
                                            departamento: true,
                                            telefono: true,
                                            entrega: true,
                                            recibe: true,
                                            fecha: true,
                                            hora: true,
                                            firma_entrega: true,
                                            firma_recibe: true,
                                            firma_responsable: true,
                                        },
                                    });

                                    const movsByPlanId = new Map<number, any[]>();
                                    const movsByAsignadoId = new Map<number, any[]>();
                                    for (const mov of movimientos) {
                                        console.log("Movimiento");
                                        if (mov.articulo_plan_id) {
                                            const list = movsByPlanId.get(mov.articulo_plan_id) ?? [];
                                            list.push(mov);
                                            movsByPlanId.set(mov.articulo_plan_id, list);
                                        }
                                        if (mov.articulo_asignado_id) {
                                            const list = movsByAsignadoId.get(mov.articulo_asignado_id) ?? [];
                                            list.push(mov);
                                            movsByAsignadoId.set(mov.articulo_asignado_id, list);
                                        }
                                    }

                                    articulos_return = (articulos_return as any[]).map((a) => ({
                                        ...a,
                                        key: `${a.tipo === "Plan" ? "plan" : "asignado"}-${a.id}`,
                                        source: a.tipo === "Plan" ? "plan" : "asignado",
                                        estructura_id: a.id,
                                        articulo_nombre: a.nombre,
                                        cantidad_plan: a.tipo === "Plan" ? a.cantidad : null,
                                        marca:
                                            a.tipo === "Plan"
                                                ? (latestByPlanId.get(a.id)?.marca ?? a.marca ?? null)
                                                : (a.marca ?? null),
                                        serie:
                                            a.tipo === "Plan"
                                                ? (latestByPlanId.get(a.id)?.serie_placa ?? a.serie ?? null)
                                                : (a.serie ?? null),
                                        mantenimientos:
                                            a.tipo === "Plan"
                                                ? (mantenimientosByPlanId.get(a.id) ?? [])
                                                : a.tipo === "Asignado"
                                                    ? (mantenimientosByAsignadoId.get(a.id) ?? [])
                                                    : [],
                                        ultimo_mantenimiento:
                                            a.tipo === "Plan"
                                                ? latestByPlanId.get(a.id) ?? null
                                                : a.tipo === "Asignado"
                                                    ? latestByAsignadoId.get(a.id) ?? null
                                                    : null,
                                        ultimo_registro_mantenimiento:
                                            a.tipo === "Plan"
                                                ? latestByPlanId.get(a.id) ?? null
                                                : a.tipo === "Asignado"
                                                    ? latestByAsignadoId.get(a.id) ?? null
                                                    : null,
                                        movimientos:
                                            a.tipo === "Plan"
                                                ? movsByPlanId.get(a.id) ?? []
                                                : a.tipo === "Asignado"
                                                    ? movsByAsignadoId.get(a.id) ?? []
                                                    : [],
                                    }));
                                } else {
                                    articulos_return = (articulos_return as any[]).map((a) => ({
                                        ...a,
                                        key: `${a.tipo === "Plan" ? "plan" : "asignado"}-${a.id}`,
                                        source: a.tipo === "Plan" ? "plan" : "asignado",
                                        estructura_id: a.id,
                                        articulo_nombre: a.nombre,
                                        cantidad_plan: a.tipo === "Plan" ? a.cantidad : null,
                                        mantenimientos: [],
                                        ultimo_mantenimiento: null,
                                        ultimo_registro_mantenimiento: null,
                                        movimientos: [],
                                    }));
                                }

                                puesto_data.articulos = articulos_return as never[];

                                const plazas = await prisma.e_estructura_plazas.findMany({
                                    where: {
                                        puesto_id: puesto.id,
                                        deleted: null,
                                        OR: [
                                            { fecha_inactivacion: null },
                                            { fecha_inactivacion: { gte: nowCostaRica } },
                                        ],
                                    },
                                });
                                for (const plaza of plazas) {
                                    console.log("Plaza");
                                    const plazaEmpleadoRows = await prisma.c_empleado_plaza.findMany({
                                        where: {
                                            plaza_id: plaza.id,
                                            empleado_id: { not: null },
                                        },
                                        select: { empleado_id: true },
                                    });

                                    const empleadoIds = Array.from(
                                        new Set(
                                            plazaEmpleadoRows
                                                .map((row: any) => row.empleado_id)
                                                .filter((id: any): id is number => typeof id === "number" && Number.isFinite(id))
                                        )
                                    );

                                    const empleados = empleadoIds.length > 0
                                        ? await prisma.c_empleado.findMany({
                                            where: {
                                                id: { in: empleadoIds },
                                                fecha_contratacion: { not: null },
                                                OR: [{ estado: null }, { estado: { not: "BA" } }],
                                                NOT: [{ cedula: { contains: "@" } }],
                                            },
                                            select: {
                                                id: true,
                                                codigo: true,
                                                cedula: true,
                                                nombre: true,
                                                primer_apellido: true,
                                                segundo_apellido: true,
                                                Email: true,
                                                telefono: true,
                                                tipoCedula: true,
                                                fecha_contratacion: true,
                                                estado: true,
                                                supervisor_id: true,
                                                firma_manual: true,
                                            },
                                            orderBy: [
                                                { nombre: "asc" },
                                                { primer_apellido: "asc" },
                                                { segundo_apellido: "asc" },
                                                { id: "asc" },
                                            ],
                                        })
                                        : [];

                                    const plaza_data = {
                                        id: plaza.id,
                                        nombre: `${plaza.codigo_plaza} - ${plaza.nombre}`,
                                        empleados,
                                    };
                                    puesto_data.plazas.push(plaza_data as never);
                                }
                                sucursal_data.puestos.push(puesto_data as never);
                            }
                            contrato_data.sucursales.push(sucursal_data as never);
                        }
                        division_data.contratos.push(contrato_data as never);
                    }
                    cliente_data.division.push(division_data as never);
                }
                empresa_data.clientes.push(cliente_data as never);
            }
            structure.push(empresa_data as never);
        }
        console.log("Completamos la estructura");
        return NextResponse.json({ status: true, structure: structure }, { status: 200 });
    }
    catch (error: unknown) {
        const errorMessage = error instanceof Error ? error.message : "Error desconocido";
        return NextResponse.json({ message: errorMessage }, { status: 500 });
    }
}
*/