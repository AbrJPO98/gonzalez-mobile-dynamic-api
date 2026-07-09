-- Motor objetivo: MySQL (InnoDB, utf8mb4)
--
-- Solo tablas nuevas MonitoreApp ("Total creadas" del Listado oficial).
-- NO modifica tablas preexistentes (sin ALTER corporativo).
-- Las columnas que referencian tablas preexistentes se crean; las FOREIGN KEY hacia ellas se omiten.
-- FK entre tablas creadas: 36 | FK omitidas (→ preexistentes u otras): 80
--
-- Fuente: Cambios_BD_MonitoreApp.sql
-- Regenerar: node scripts/build-cambios-bd-solo-tablas-creadas.mjs
--
SET FOREIGN_KEY_CHECKS = 0;

-- =============================
-- Creación tablas nuevas MonitoreApp (84 tablas)
-- =============================

CREATE TABLE IF NOT EXISTS `a_recovery_password_token` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `expira_en` INT NOT NULL,
    `creacion` DATETIME(0) NOT NULL,
    `token` VARCHAR(255) NOT NULL,
    `empleadoId` INT NOT NULL,
    INDEX `FK_E35A23BC952BE730`(`empleadoId`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `a_mobile_token_for_planillas` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `empleado_id` INT NOT NULL,
    `token` LONGTEXT NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `expires_at` DATETIME(0) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_acta_entre_producto` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `empresa_id` INT NOT NULL,
    `cliente_id` INT NOT NULL,
    `contrato_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `fecha` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `tipo_entrega` LONGTEXT NOT NULL,
    `mensual` LONGTEXT NOT NULL,
    `division` VARCHAR(25) NOT NULL,
    `detalle` LONGTEXT NOT NULL,
    `observaciones` LONGTEXT NOT NULL,
    `nombre_entrega` LONGTEXT NOT NULL,
    `cedula_entrega` VARCHAR(30) NOT NULL,
    `fecha_entrega` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `firma_entrega` LONGTEXT NULL,
    `nombre_recibe` LONGTEXT NOT NULL,
    `cedula_recibe` VARCHAR(30) NOT NULL,
    `fecha_recibe` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `firma_recibe` LONGTEXT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `division_id` INT NOT NULL,
    `puesto_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_agenda_minuta` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cliente_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `puesto_id` INT NOT NULL,
    `numero` INT NOT NULL,
    `titulo` VARCHAR(255) NOT NULL,
    `fecha` DATE NOT NULL,
    `hora_inicio` TIME(0) NOT NULL,
    `hora_fin` TIME(0) NOT NULL,
    `autor` LONGTEXT NOT NULL,
    `participantes` LONGTEXT NOT NULL,
    `acuerdos` LONGTEXT NOT NULL,
    `observaciones` LONGTEXT NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `created_by` VARCHAR(191) NOT NULL,
    `temas_a_tratar` LONGTEXT NULL,
    `empresa_id` INT NOT NULL DEFAULT 0,
    `division_id` INT NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    `estado` TINYINT(1) NOT NULL DEFAULT 0,
    INDEX `c_agenda_minuta_cliente_id_fkey`(`cliente_id`),
    INDEX `c_agenda_minuta_corpo_id_fkey`(`corpo_id`),
    INDEX `c_agenda_minuta_puesto_id_fkey`(`puesto_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_anexos_quejas` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` LONGTEXT NOT NULL,
    `original_name` LONGTEXT NOT NULL,
    `type` VARCHAR(25) NOT NULL,
    `extension` VARCHAR(25) NOT NULL,
    `queja_id` INT NOT NULL,
    INDEX `c_anexos_quejas_queja_id_fkey`(`queja_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_apertura_cierre_puesto` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cliente_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `puesto_id` INT NOT NULL,
    `tipo` VARCHAR(191) NOT NULL,
    `actividades` LONGTEXT NOT NULL,
    `inventario` LONGTEXT NOT NULL,
    `otras_observaciones` LONGTEXT NULL,
    `nombre_representante_cliente` VARCHAR(255) NOT NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `created_by` INT NOT NULL,
    `fecha` DATETIME(3) NOT NULL,
    `firma_representante_empresa_entrante` LONGTEXT NULL,
    `firma_representante_empresa_saliente` LONGTEXT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `nombre_representante_empresa_entrante` VARCHAR(255) NOT NULL,
    `nombre_representante_empresa_saliente` VARCHAR(255) NOT NULL,
    `firma_representante_cliente` LONGTEXT NULL,
    `division_id` INT NOT NULL,
    `empresa_id` INT NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    INDEX `c_apertura_cierre_puesto_cliente_id_fkey`(`cliente_id`),
    INDEX `c_apertura_cierre_puesto_corpo_id_fkey`(`corpo_id`),
    INDEX `c_apertura_cierre_puesto_division_id_fkey`(`division_id`),
    INDEX `c_apertura_cierre_puesto_puesto_id_fkey`(`puesto_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_archivos_adjuntos_articulo_mantenimiento` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` LONGTEXT NOT NULL,
    `original_name` LONGTEXT NOT NULL,
    `type` VARCHAR(25) NOT NULL,
    `extension` VARCHAR(25) NOT NULL,
    `activo_mantenimiento_id` INT NOT NULL,
    INDEX `c_archivos_adjuntos_articulo_mantenimiento_activo_mantenimi_fkey`(`activo_mantenimiento_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_archivos_aporte_incidente` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` LONGTEXT NOT NULL,
    `original_name` LONGTEXT NOT NULL,
    `type` VARCHAR(25) NOT NULL,
    `extension` VARCHAR(25) NOT NULL,
    `contribucion_id` INT NOT NULL,
    INDEX `c_archivos_aporte_incidente_contribucion_id_fkey`(`contribucion_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_archivos_incidente` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` LONGTEXT NOT NULL,
    `original_name` LONGTEXT NOT NULL,
    `type` VARCHAR(25) NOT NULL,
    `extension` VARCHAR(25) NOT NULL,
    `incidente_id` INT NOT NULL,
    INDEX `c_archivos_incidente_incidente_id_fkey`(`incidente_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_articulo_mantenimiento` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `articulo_plan_id` INT NULL,
    `articulo_asignado_id` INT NULL,
    `estado` VARCHAR(55) NOT NULL,
    `cantidad_necesaria` INT NOT NULL,
    `cantidad_real` INT NOT NULL,
    `observaciones` LONGTEXT NOT NULL,
    `fecha_solucion` DATETIME(0) NULL,
    `accion` VARCHAR(55) NULL,
    `fecha_inicio` DATETIME(0) NULL,
    `numero_boleta_proveeduria` LONGTEXT NULL,
    `tipo` LONGTEXT NULL,
    `marca` LONGTEXT NULL,
    `modelo` LONGTEXT NULL,
    `serie_placa` LONGTEXT NULL,
    `marca_nuevo` LONGTEXT NULL,
    `modelo_nuevo` LONGTEXT NULL,
    `serie_placa_nuevo` LONGTEXT NULL,
    `categoria` LONGTEXT NULL,
    `tipo_mantenimiento_art` LONGTEXT NULL,
    `fecha_salida` DATETIME(0) NULL,
    `fecha_entrada` DATETIME(0) NULL,
    `kilometraje` INT NULL,
    `mant_armas_form` LONGTEXT NULL,
    `categoria_mantinimiento` LONGTEXT NULL,
    `detalle` LONGTEXT NULL,
    `numero_fc` LONGTEXT NULL,
    `proveedor` LONGTEXT NULL,
    `costo_mo` INT NULL,
    `costo_i` INT NULL,
    `iva` INT NULL,
    `costo_total` INT NULL,
    `fecha_fin` DATETIME(0) NULL,
    `reincidencia_treinta_dias` TINYINT(1) NULL,
    `tipo_mant_art_reincid` LONGTEXT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `updated_at` DATETIME(0) NOT NULL,
    INDEX `c_articulo_mantenimiento_articulo_asignado_id_fkey`(`articulo_asignado_id`),
    INDEX `c_articulo_mantenimiento_articulo_plan_id_fkey`(`articulo_plan_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_bitacora_vehiculo_detenido` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `tipo` VARCHAR(52) NOT NULL,
    `informacion_general` LONGTEXT NOT NULL,
    `informacion_revision` LONGTEXT NOT NULL,
    `movimientos_vehiculos` LONGTEXT NOT NULL,
    `observaciones` LONGTEXT NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `created_by` INT NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `cliente_id` INT NOT NULL,
    `empresa_id` INT NOT NULL,
    `sucursal_id` INT NOT NULL,
    `uso_id` INT NULL,
    `vehiculo_id` INT NULL,
    `division_id` INT NOT NULL,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `puesto_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_boleta_apreciacion_vulnerabilidad` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cliente_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `puesto_id` INT NOT NULL,
    `fecha` DATETIME(0) NOT NULL,
    `enlace` VARCHAR(255) NOT NULL,
    `nombre_solicitante` VARCHAR(255) NOT NULL,
    `boleta` LONGTEXT NOT NULL,
    `metricas_vulnerablidad` LONGTEXT NOT NULL,
    `observaciones` LONGTEXT NULL,
    `firma_solicitante` LONGTEXT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `empresa_id` INT NOT NULL DEFAULT 0,
    `division_id` INT NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    INDEX `c_boleta_apreciacion_vulnerabilidad_cliente_id_fkey`(`cliente_id`),
    INDEX `c_boleta_apreciacion_vulnerabilidad_corpo_id_fkey`(`corpo_id`),
    INDEX `c_boleta_apreciacion_vulnerabilidad_puesto_id_fkey`(`puesto_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_cambios_apps_modules` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre_tabla` LONGTEXT NOT NULL,
    `registro_id` INT NOT NULL,
    `cambios` LONGTEXT NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `created_by` INT NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_categoria_mantenimiento` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_checklist_supervision` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cliente_id` INT NOT NULL,
    `division_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `puesto_id` INT NOT NULL,
    `ejecutivo_cuenta` VARCHAR(55) NOT NULL,
    `evaluacion` LONGTEXT NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `created_by` INT NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `fecha` DATETIME(0) NOT NULL,
    `firma_supervisor` LONGTEXT NULL,
    `articulos_puesto` LONGTEXT NOT NULL,
    `empresa_id` INT NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    INDEX `c_checklist_supervision_cliente_id_fkey`(`cliente_id`),
    INDEX `c_checklist_supervision_corpo_id_fkey`(`corpo_id`),
    INDEX `c_checklist_supervision_puesto_id_fkey`(`puesto_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_contribucion_incidente` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `incidente_id` INT NOT NULL,
    `empleado_id` INT NOT NULL,
    `aporte` LONGTEXT NOT NULL,
    `rol_aporte` VARCHAR(25) NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `firma_aporte_tercero` LONGTEXT NULL,
    `nombre_aporte` VARCHAR(191) NULL,
    INDEX `c_contribucion_incidente_empleado_id_fkey`(`empleado_id`),
    INDEX `c_contribucion_incidente_incidente_id_fkey`(`incidente_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_control_asistencia` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `empresa_id` INT NOT NULL,
    `contrato_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `turno` VARCHAR(191) NOT NULL,
    `total_presentes` INT NOT NULL,
    `colaboradores` LONGTEXT NOT NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `created_by` INT NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `division_id` INT NOT NULL,
    `cliente_id` INT NOT NULL,
    `fecha` DATETIME(0) NOT NULL,
    `puesto_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    `total_empleados_turno` INT NOT NULL DEFAULT 0,
    `nombre_supervisor` LONGTEXT NULL,
    `firma_manual_supervisor` LONGTEXT NULL,
    `comentarios` LONGTEXT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_control_asistencia_empleado_firmas` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `control_id` INT NOT NULL,
    `empleado_id` INT NOT NULL,
    `firma` LONGTEXT NOT NULL,
    INDEX `idx_control_id`(`control_id`),
    INDEX `idx_empleado_id`(`empleado_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_empleado_almuerzo` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `empleadoId` INT NOT NULL,
    `pausas` LONGTEXT NOT NULL,
    `inicio` DATETIME(0) NOT NULL,
    `fin` DATETIME(0) NOT NULL,
    `es_manual` TINYINT(1) NOT NULL DEFAULT 0,
    `cedula_empleado` LONGTEXT NOT NULL,
    `empleado_nombre` LONGTEXT NOT NULL,
    `firma_empleado` LONGTEXT NOT NULL,
    `minutos_almuerzo` DOUBLE NOT NULL,
    `empresa_id` INT NOT NULL DEFAULT 0,
    `cliente_id` INT NOT NULL DEFAULT 0,
    `division_id` INT NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `corpo_id` INT NOT NULL DEFAULT 0,
    `puesto_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    `marca_id` INT NOT NULL,
    INDEX `empleadoId_almuerzo_fkey`(`empleadoId`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_login_marca_almuerzo` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre_empleado` VARCHAR(255) NOT NULL,
    `cedula_empleado` VARCHAR(25) NOT NULL,
    `fecha_hora` DATETIME(0) NOT NULL,
    `device` LONGTEXT NOT NULL,
    `lat` VARCHAR(255) NULL,
    `lng` VARCHAR(255) NULL,
    `puesto_id` INT NULL,
    `marca_id` INT NULL,
    `marca_entrada_teorica` DATETIME(0) NULL,
    `marca_entrada_real` DATETIME(0) NULL,
    `marca_salida_teorica` DATETIME(0) NULL,
    `marca_salida_real` DATETIME(0) NULL,
    `hora_inicio_almuerzo` DATETIME(0) NULL,
    `hora_fin_almuerzo` DATETIME(0) NULL,
    `session_id` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_empleado_notification` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `empleadoId` INT NOT NULL,
    `notificationId` INT NOT NULL,
    `watched` TINYINT(1) NOT NULL DEFAULT 0,
    INDEX `c_empleado_notification_notificationId_fkey`(`notificationId`),
    INDEX `c_plaza_notification_empleadoId_fkey`(`empleadoId`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_encuesta_cliente` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `empresa_id` INT NOT NULL,
    `cliente_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `puesto_id` INT NOT NULL,
    `division_id` INT NOT NULL,
    `responsable_id` INT NOT NULL,
    `fecha` DATE NOT NULL,
    `evaluaciones` LONGTEXT NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `nombre_evaluado` VARCHAR(45) NOT NULL,
    `cedula_evaluado` VARCHAR(25) NOT NULL,
    `cedula_responsable` VARCHAR(25) NOT NULL,
    `nombre_responsable` VARCHAR(45) NOT NULL,
    `email_evaluado` VARCHAR(50) NOT NULL,
    `firma_evaluado` LONGTEXT NULL,
    `telefono_evaluado` VARCHAR(25) NOT NULL,
    `empresa_evaluado` VARCHAR(55) NOT NULL,
    `observaciones` LONGTEXT NOT NULL,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    INDEX `c_encuesta_cliente_cliente_id_fkey`(`cliente_id`),
    INDEX `c_encuesta_cliente_corpo_id_fkey`(`corpo_id`),
    INDEX `c_encuesta_cliente_division_id_fkey`(`division_id`),
    INDEX `c_encuesta_cliente_empresa_id_fkey`(`empresa_id`),
    INDEX `c_encuesta_cliente_puesto_id_fkey`(`puesto_id`),
    INDEX `c_encuesta_cliente_responsable_id_fkey`(`responsable_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_evaluacion_empleado` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre_empleado` VARCHAR(45) NOT NULL,
    `cedula_empleado` VARCHAR(45) NOT NULL,
    `corpo_id` INT NOT NULL,
    `puesto_id` INT NOT NULL,
    `plaza_id` INT NOT NULL,
    `empleado_id` INT NOT NULL,
    `evaluador_id` INT NOT NULL,
    `tipo` VARCHAR(25) NOT NULL,
    `fecha_ingreso` DATE NOT NULL,
    `fecha_evaluacion` DATE NOT NULL,
    `evaluacion` LONGTEXT NOT NULL,
    `comentarios` LONGTEXT NOT NULL,
    `nombre_evaluador` VARCHAR(45) NOT NULL,
    `firma_evaluador` LONGTEXT NOT NULL,
    `firma_empleado` LONGTEXT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `firma_empleado_manual` LONGTEXT NULL,
    `empresa_id` INT NOT NULL DEFAULT 0,
    `cliente_id` INT NOT NULL DEFAULT 0,
    `division_id` INT NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 0,
    INDEX `c_evaluacion_empleado_corpo_id_fkey`(`corpo_id`),
    INDEX `c_evaluacion_empleado_plaza_id_fkey`(`plaza_id`),
    INDEX `c_evaluacion_empleado_puesto_id_fkey`(`puesto_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_imagenes_acta_entrega_producto` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` LONGTEXT NOT NULL,
    `acta_id` INT NOT NULL,
    INDEX `c_imagenes_acta_entrega_producto_acta_id_fkey`(`acta_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_imagenes_apertura_cierre_puesto` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` LONGTEXT NOT NULL,
    `apetura_cierre_id` INT NOT NULL,
    `original_name` LONGTEXT NOT NULL,
    INDEX `c_imagenes_apertura_cierre_puesto_apetura_cierre_id_fkey`(`apetura_cierre_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_imagenes_checklist_supervision` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` LONGTEXT NOT NULL,
    `checklist_id` INT NOT NULL,
    `original_name` LONGTEXT NOT NULL,
    INDEX `c_imagenes_checklist_supervision_id_fkey`(`checklist_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_imagenes_control_asistencia` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` LONGTEXT NOT NULL,
    `control_id` INT NOT NULL,
    `original_name` LONGTEXT NOT NULL,
    INDEX `c_imagenes_control_asistencia_control_id_fkey`(`control_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_imagenes_registro_induccion_general` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` LONGTEXT NOT NULL,
    `registro_id` INT NOT NULL,
    INDEX `c_imagenes_registro_induccion_general_id_fkey`(`registro_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_imagenes_vehiculos_corporativos` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` LONGTEXT NOT NULL,
    `vehiculo_id` INT NOT NULL,
    INDEX `c_imagenes_vehiculos_corporativos_vehiculo_id_fkey`(`vehiculo_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_incidente` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `corpo_id` INT NOT NULL,
    `ejecutivo_cuenta` INT NOT NULL,
    `fecha_incidente` DATE NOT NULL,
    `fecha_reporte` DATE NOT NULL,
    `nombre_responsable` VARCHAR(45) NOT NULL,
    `clasificacion` INT NOT NULL,
    `descripcion` LONGTEXT NOT NULL,
    `involucrados` LONGTEXT NOT NULL,
    `fecha_libro_novedades` LONGTEXT NOT NULL,
    `nombre_responsable_atencion` VARCHAR(45) NOT NULL,
    `solucion` LONGTEXT NULL,
    `fecha_solucion` DATE NULL,
    `fecha_real_solucion` DATE NULL,
    `costo_asociado` LONGTEXT NULL,
    `consecutivo_informe` LONGTEXT NULL,
    `link_informe` LONGTEXT NULL,
    `cliente_id` INT NOT NULL DEFAULT 0,
    `empresa_id` INT NOT NULL DEFAULT 0,
    `estado` TINYINT(1) NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `created_by` INT NOT NULL,
    `division_id` INT NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `puesto_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 0,
    INDEX `c_incidente_clasificacion_fkey`(`clasificacion`),
    INDEX `c_incidente_cliente_id_fkey`(`cliente_id`),
    INDEX `c_incidente_corpo_id_fkey`(`corpo_id`),
    INDEX `c_incidente_ejecutivo_cuenta_fkey`(`ejecutivo_cuenta`),
    INDEX `c_incidente_empresa_id_fkey`(`empresa_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_maestro_quejas` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `empresa_id` INT NOT NULL,
    `cliente_id` INT NOT NULL,
    `contrato_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `puesto_id` INT NOT NULL,
    `plaza_id` INT NOT NULL,
    `sociedad` VARCHAR(191) NOT NULL,
    `nombre_realiza_queja` VARCHAR(191) NOT NULL,
    `cliente` VARCHAR(191) NOT NULL,
    `empresa_presenta_queja` VARCHAR(191) NOT NULL,
    `persona_presenta_queja` VARCHAR(191) NOT NULL,
    `medio_recepcion_queja` VARCHAR(191) NOT NULL,
    `tipo_cliente` VARCHAR(191) NOT NULL,
    `ubicacion` VARCHAR(191) NOT NULL,
    `nivel_queja` VARCHAR(191) NOT NULL,
    `fecha_queja` VARCHAR(191) NOT NULL,
    `motivo_queja` VARCHAR(191) NOT NULL,
    `descripcion_queja` LONGTEXT NOT NULL,
    `fecha_inicio` VARCHAR(191) NOT NULL,
    `fecha_revision` VARCHAR(191) NOT NULL,
    `resolucion_queja` LONGTEXT NOT NULL,
    `estado` VARCHAR(191) NOT NULL,
    `accion_correctiva_preventiva` VARCHAR(191) NOT NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `created_by` VARCHAR(191) NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `division_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 0,
    `estimacion_dannio` LONGTEXT NULL,
    `tipo_queja` LONGTEXT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_mantenimiento_vehiculos_corporativos` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `vehiculo_id` INT NOT NULL,
    `fecha` DATETIME(0) NOT NULL,
    `tipo` VARCHAR(25) NOT NULL,
    `mantenimiento` LONGTEXT NOT NULL,
    `diagnostico` LONGTEXT NOT NULL,
    `kilometraje_siguiente_revision` INT NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `imagen_antes` LONGTEXT NOT NULL,
    `imagen_despues` LONGTEXT NOT NULL,
    `created_by` INT NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `firma_mecanico` LONGTEXT NULL,
    `nombre_mecanico` LONGTEXT NOT NULL,
    INDEX `c_mantenimiento_vehiculos_corporativos_vehiculo_id_fkey`(`vehiculo_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_movimientos_articulo_mantenimiento` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `articulo_plan_id` INT NULL,
    `articulo_asignado_id` INT NULL,
    `nombre_persona_recibe` VARCHAR(255) NOT NULL,
    `nombre_persona_entrega` VARCHAR(255) NOT NULL,
    `departamento` VARCHAR(255) NOT NULL,
    `telefono` VARCHAR(20) NOT NULL,
    `entrega` VARCHAR(255) NOT NULL,
    `recibe` VARCHAR(255) NOT NULL,
    `fecha` DATE NOT NULL,
    `hora` TIME(0) NOT NULL,
    `firma_entrega` LONGTEXT NULL,
    `firma_recibe` LONGTEXT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    INDEX `c_movimientos_articulo_mantenimiento_articulo_asignado_id_fkey`(`articulo_asignado_id`),
    INDEX `c_movimientos_articulo_mantenimiento_articulo_plan_id_fkey`(`articulo_plan_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_notas_voz` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `empresa_id` INT NOT NULL,
    `cliente_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `puesto_id` INT NULL,
    `titulo` LONGTEXT NOT NULL,
    `descripcion` LONGTEXT NOT NULL,
    `path` LONGTEXT NOT NULL,
    `transcripcion` LONGTEXT NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `created_by` INT NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `division_id` INT NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    INDEX `c_notas_voz_cliente_id_fkey`(`cliente_id`),
    INDEX `c_notas_voz_corpo_id_fkey`(`corpo_id`),
    INDEX `c_notas_voz_empresa_id_fkey`(`empresa_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_notifications` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `title` LONGTEXT NOT NULL,
    `description` LONGTEXT NOT NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_plaza_notification` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `plazaId` INT NOT NULL,
    `notificationId` INT NOT NULL,
    `watched` TINYINT(1) NOT NULL DEFAULT 0,
    INDEX `c_plaza_notification_notificationId_fkey`(`notificationId`),
    INDEX `c_plaza_notification_plazaId_fkey`(`plazaId`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_producto_no_conforme` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cliente_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `fecha_identificacion` DATE NOT NULL,
    `responsable_cuenta` VARCHAR(50) NOT NULL,
    `tipo_servicio_no_conforme` VARCHAR(50) NOT NULL,
    `persona_identifico_pnc` VARCHAR(255) NOT NULL,
    `descripcion` LONGTEXT NOT NULL,
    `persona_origino_pnc` VARCHAR(255) NOT NULL,
    `accion_implementada` LONGTEXT NOT NULL,
    `fecha_solucion` DATE NOT NULL,
    `responsable_aprobar` LONGTEXT NOT NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `created_by` VARCHAR(191) NOT NULL,
    `firma_persona_identifico_pnc` LONGTEXT NULL,
    `firma_persona_origino_pnc` LONGTEXT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `empresa_id` INT NOT NULL,
    `division_id` INT NOT NULL,
    `contrato_id` INT NOT NULL,
    `puesto_id` INT NOT NULL,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    INDEX `c_producto_no_conforme_cliente_id_fkey`(`cliente_id`),
    INDEX `c_producto_no_conforme_corpo_id_fkey`(`corpo_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_puesto_notas` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `titulo` VARCHAR(255) NOT NULL,
    `description` LONGTEXT NOT NULL,
    `categoria_id` INT NULL,
    `puesto_id` INT NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `updated_at` DATETIME(0) NOT NULL,
    `relevancia` VARCHAR(16) NULL,
    `firma_manual_responsable` LONGTEXT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `is_modified` TINYINT(1) NOT NULL DEFAULT 0,
    `empresa_id` INT NOT NULL,
    `cliente_id` INT NOT NULL DEFAULT 0,
    `division_id` INT NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `corpo_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    INDEX `puesto_id_notas_fkey`(`puesto_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_imagenes_puesto_notas` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` LONGTEXT NOT NULL,
    `nota_id` INT NOT NULL,
    INDEX `c_imagenes_puesto_notas_id_fkey`(`nota_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_registro_induccion_general` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `empresa_id` INT NOT NULL,
    `cliente_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `division` VARCHAR(50) NOT NULL,
    `fecha` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `temas_a_tratar` LONGTEXT NOT NULL,
    `colaboradores` LONGTEXT NOT NULL,
    `capacitadores` LONGTEXT NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `created_by` VARCHAR(191) NOT NULL,
    `division_id` INT NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `puesto_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    INDEX `c_registro_induccion_general_cliente_id_fkey`(`cliente_id`),
    INDEX `c_registro_induccion_general_corpo_id_fkey`(`corpo_id`),
    INDEX `c_registro_induccion_general_empresa_id_fkey`(`empresa_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_registro_induccion_recorrido` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `empresa_id` INT NOT NULL,
    `cliente_id` INT NOT NULL,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `corpo_id` INT NOT NULL,
    `puesto_id` INT NOT NULL DEFAULT 0,
    `plaza_id` INT NOT NULL,
    `fecha` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `renglon_edificio` VARCHAR(191) NOT NULL,
    `supervisor_cliente` VARCHAR(191) NULL,
    `supervisor_corporacion` VARCHAR(191) NOT NULL,
    `temas_desarrollados` LONGTEXT NOT NULL,
    `aspectos_especificos` LONGTEXT NOT NULL,
    `participantes` LONGTEXT NOT NULL,
    `firma_supervisor` LONGTEXT NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `created_by` VARCHAR(191) NOT NULL,
    `division` VARCHAR(191) NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `empleado_id` INT NOT NULL,
    `firma_empleado` LONGTEXT NULL,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    `division_id` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_solicitud_permiso` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `created_by` INT NOT NULL,
    `observaciones` LONGTEXT NULL,
    `ejecutivo_cuenta` INT NOT NULL,
    `empleado_id` INT NOT NULL,
    `fecha_fin` DATETIME(0) NOT NULL,
    `fecha_inicio` DATETIME(0) NOT NULL,
    `firma_ejecutivo_cuenta_digital` LONGTEXT NULL,
    `firma_ejecutivo_cuenta_manual` LONGTEXT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `reemplazo_obligatorio` INT NULL,
    `turnos` LONGTEXT NOT NULL,
    `tipo` VARCHAR(15) NOT NULL,
    `plaza_id` INT NOT NULL,
    `accionPersonal_id` INT NULL,
    `estado` VARCHAR(15) NOT NULL DEFAULT 'pendiente',
    `empresa_id` INT NOT NULL DEFAULT 0,
    `cliente_id` INT NOT NULL DEFAULT 0,
    `division_id` INT NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `corpo_id` INT NOT NULL DEFAULT 0,
    `puesto_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    `motivo` LONGTEXT NOT NULL,
    `firma_empleado_manual` LONGTEXT NOT NULL,
    INDEX `c_solicitud_permiso_empleado_id_fkey`(`empleado_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_archivos_solicitud_permiso` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` LONGTEXT NOT NULL,
    `type` VARCHAR(25) NOT NULL,
    `extension` VARCHAR(25) NOT NULL,
    `solicitud_id` INT NOT NULL,
    `original_name` LONGTEXT NOT NULL,
    `is_main` TINYINT(1) NOT NULL DEFAULT 0,
    INDEX `e_archivos_solicitud_permiso_id_fkey`(`solicitud_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_tipos_producto_no_conforme` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre` VARCHAR(255) NOT NULL,
    UNIQUE INDEX `UNIQ_92DE8E473A988126`(`nombre`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_ubicacion_puesto_registro_cambios` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `puesto_id` INT NOT NULL,
    `latitud_anterior` VARCHAR(255) NULL,
    `longitud_anterior` VARCHAR(255) NULL,
    `latitud_nueva` VARCHAR(255) NULL,
    `longitud_nueva` VARCHAR(255) NULL,
    `created_at` DATETIME(0) NOT NULL,
    `created_by` INT NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_usos_vehiculos_corporativos` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `bitacora_id` INT NULL,
    `vehiculo_id` INT NOT NULL,
    `nombre_conductor` VARCHAR(55) NOT NULL,
    `fecha` DATETIME(0) NOT NULL,
    `combustible_inicio` LONGTEXT NOT NULL,
    `combustible_fin` LONGTEXT NOT NULL,
    `km_inicio` INT NOT NULL,
    `km_fin` INT NOT NULL,
    `motivo` LONGTEXT NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `codigo_conductor` VARCHAR(55) NOT NULL,
    `firma_conductor` LONGTEXT NULL,
    `fin` DATETIME(0) NOT NULL,
    `inicio` DATETIME(0) NOT NULL,
    INDEX `c_usos_vehiculos_corporativos_vehiculo_id_fkey`(`vehiculo_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_vehiculos_corporativos` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cliente_id` INT NOT NULL,
    `sucursal_id` INT NOT NULL,
    `placa` VARCHAR(52) NULL,
    `tipo` VARCHAR(52) NOT NULL,
    `kilometraje` INT NULL,
    `prox_cambio_aceite` INT NULL,
    `modelo` VARCHAR(52) NULL,
    `anno` INT NULL,
    `descripcion` LONGTEXT NULL,
    `titulo_propiedad` TINYINT(1) NULL,
    `rtv` TINYINT(1) NULL,
    `marchamo` TINYINT(1) NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `created_by` INT NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `estado` VARCHAR(25) NOT NULL,
    `empresa_id` INT NOT NULL DEFAULT 0,
    `tipo_autoria` VARCHAR(52) NOT NULL,
    `division_id` INT NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `puesto_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    `marca` VARCHAR(52) NOT NULL,
    INDEX `c_vehiculos_corporativos_cliente_id_fkey`(`cliente_id`),
    INDEX `c_vehiculos_corporativos_sucursal_id_fkey`(`sucursal_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_actividades` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre_actividad` VARCHAR(255) NOT NULL,
    `fecha_inicio` DATE NOT NULL,
    `frecuencia` LONGTEXT NOT NULL,
    `es_revision_equipo` TINYINT(1) NOT NULL,
    `descripcion_actividad` LONGTEXT NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `fecha_fin` DATE NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_actividades_puesto` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `actividad_id` INT NOT NULL,
    `puesto_id` INT NOT NULL,
    INDEX `e_actividad_id_fkey`(`actividad_id`),
    INDEX `e_actividad_puesto_id_fkey`(`puesto_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_actividades_puesto_plaza` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `actividad_puesto_id` INT NOT NULL,
    `plaza_id` INT NOT NULL,
    `bitacora` LONGTEXT NOT NULL,
    `file_name` LONGTEXT NULL,
    `articles` LONGTEXT NULL,
    `created_at` DATETIME(3) NOT NULL,
    `updated_at` DATETIME(3) NOT NULL,
    `marcada` TINYINT(1) NOT NULL DEFAULT 0,
    INDEX `e_actividad_actividad_puesto_id_fkey`(`actividad_puesto_id`),
    INDEX `e_actividad_puesto_plaza_id_fkey`(`plaza_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_activo_visitante` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `visitante_id` INT NOT NULL,
    `tipo_id` INT NOT NULL,
    `detalles` LONGTEXT NOT NULL,
    `numero_activo` VARCHAR(50) NULL,
    `nombre` VARCHAR(50) NOT NULL,
    `numero_id` VARCHAR(50) NOT NULL,
    INDEX `FK_BB503B25992BE739`(`visitante_id`),
    INDEX `FK_BB503B25993BE739`(`tipo_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_archivos_manual_puesto` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` LONGTEXT NOT NULL,
    `type` VARCHAR(25) NOT NULL,
    `extension` VARCHAR(25) NOT NULL,
    `manual_puesto_id` INT NOT NULL,
    `original_name` LONGTEXT NOT NULL,
    INDEX `e_archivos_manual_puesto_manual_puesto_id_fkey`(`manual_puesto_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_archivos_producto_no_conforme` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` LONGTEXT NOT NULL,
    `type` VARCHAR(25) NOT NULL,
    `extension` VARCHAR(25) NOT NULL,
    `pnc_id` INT NOT NULL,
    `original_name` LONGTEXT NOT NULL,
    INDEX `e_archivos_producto_no_conforme_pnc_id_fkey`(`pnc_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_capacitacion_empleado` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `capacitacion_id` INT NOT NULL,
    `empleado_id` INT NOT NULL,
    INDEX `e_capacitacion_empleado_capacitacion_id_fkey`(`capacitacion_id`),
    INDEX `e_capacitacion_empleado_empleado_id_fkey`(`empleado_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_capacitacion_puesto` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `capacitacion_id` INT NOT NULL,
    `puesto_id` INT NOT NULL,
    INDEX `e_capacitacion_puesto_capacitacion_id_fkey`(`capacitacion_id`),
    INDEX `e_capacitacion_puesto_puesto_id_fkey`(`puesto_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_control_documento_entregado_cliente` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cliente_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `fecha` DATE NOT NULL,
    `nombre_oficial_entrega` VARCHAR(255) NOT NULL,
    `nombre_oficial_recibe` VARCHAR(255) NOT NULL,
    `tipo_documento` VARCHAR(255) NOT NULL,
    `descripcion` LONGTEXT NOT NULL,
    `firma_representante_cliente` LONGTEXT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `empresa_id` INT NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `puesto_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    `division_id` INT NOT NULL DEFAULT 0,
    INDEX `e_control_documento_entregado_cliente_cliente_id_fkey`(`cliente_id`),
    INDEX `e_control_documento_entregado_cliente_corpo_id_fkey`(`corpo_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_empleado_visualizacion_archivos` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` LONGTEXT NOT NULL,
    `type` VARCHAR(25) NOT NULL,
    `extension` VARCHAR(25) NOT NULL,
    `visualizacion_id` INT NOT NULL,
    `original_name` LONGTEXT NOT NULL,
    INDEX `e_archivos_empleado_visualizacion_id_fkey`(`visualizacion_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_empleado_visualizacion_manual_puesto` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `empleado_id` INT NOT NULL,
    `manual_puesto_id` INT NOT NULL,
    `nombre_empleado` LONGTEXT NOT NULL,
    `firma_empleado` LONGTEXT NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `quiz_answear` LONGTEXT NULL,
    `updated_at` DATETIME(0) NOT NULL,
    `approved` TINYINT(1) NULL,
    INDEX `e_empleado_visualizacion_manual_puesto_empleado_id_fkey`(`empleado_id`),
    INDEX `e_empleado_visualizacion_manual_puesto_manual_puesto_id_fkey`(`manual_puesto_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_llave` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cliente_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `puesto_id` INT NOT NULL,
    `lugar_abre` VARCHAR(255) NOT NULL,
    `cantidad_copias` INT NOT NULL,
    `observaciones` LONGTEXT NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `created_by` INT NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `empresa_id` INT NOT NULL DEFAULT 0,
    `division_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `numero_llave` VARCHAR(50) NOT NULL DEFAULT '0',
    INDEX `e_llave_cliente_id_fkey`(`cliente_id`),
    INDEX `e_llave_corpo_id_fkey`(`corpo_id`),
    INDEX `e_llave_puesto_id_fkey`(`puesto_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_llave_en_llavero` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `llave_id` INT NOT NULL,
    `llavero_id` INT NOT NULL,
    INDEX `e_llave_en_llavero_llave_id_fkey`(`llave_id`),
    INDEX `e_llave_en_llavero_llavero_id_fkey`(`llavero_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_llavero` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cliente_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `puesto_id` INT NOT NULL,
    `observaciones` LONGTEXT NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `created_by` INT NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `nombre_llavero` VARCHAR(50) NOT NULL,
    `empresa_id` INT NOT NULL DEFAULT 0,
    `division_id` INT NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 0,
    `numero_llavero` VARCHAR(50) NOT NULL DEFAULT '0',
    INDEX `e_llavero_cliente_id_fkey`(`cliente_id`),
    INDEX `e_llavero_corpo_id_fkey`(`corpo_id`),
    INDEX `e_llavero_puesto_id_fkey`(`puesto_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_manual_puesto` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `title` LONGTEXT NOT NULL,
    `description` LONGTEXT NOT NULL,
    `firma` LONGTEXT NOT NULL,
    `puesto_id` INT NOT NULL,
    `created_by` VARCHAR(191) NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `quiz` LONGTEXT NULL,
    `empresa_id` INT NOT NULL,
    `cliente_id` INT NOT NULL,
    `division_id` INT NOT NULL,
    `contrato_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `isActive` TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_movimiento_llave` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `llave_id` INT NOT NULL,
    `nombre_persona_recibe` VARCHAR(255) NOT NULL,
    `nombre_persona_entrega` VARCHAR(255) NOT NULL,
    `departamento` VARCHAR(255) NOT NULL,
    `telefono` VARCHAR(20) NOT NULL,
    `fecha` DATE NOT NULL,
    `hora` TIME(0) NOT NULL,
    `firma_entrega` LONGTEXT NULL,
    `firma_recibe` LONGTEXT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    INDEX `e_movimiento_llave_llave_id_fkey`(`llave_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_movimiento_llavero` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `llavero_id` INT NOT NULL,
    `nombre_persona_recibe` VARCHAR(255) NOT NULL,
    `nombre_persona_entrega` VARCHAR(255) NOT NULL,
    `departamento` VARCHAR(255) NOT NULL,
    `telefono` VARCHAR(20) NOT NULL,
    `fecha` DATE NOT NULL,
    `hora` TIME(0) NOT NULL,
    `firma_entrega` LONGTEXT NULL,
    `firma_recibe` LONGTEXT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    INDEX `e_movimiento_llavero_llavero_id_fkey`(`llavero_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_mutuos_acuerdos` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cliente_id` INT NOT NULL DEFAULT 0,
    `corpo_id` INT NOT NULL DEFAULT 0,
    `ejecutivo_cuenta` INT NOT NULL,
    `motivo` LONGTEXT NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `created_by` INT NOT NULL,
    `firma_ejecutivo_cuenta_digital` LONGTEXT NOT NULL,
    `ausente_acepta` TINYINT(1) NOT NULL,
    `empleadoAusente_id` INT NOT NULL,
    `empleadoReemplaza_id` INT NOT NULL,
    `firma_ejecutivo_cuenta_manual` LONGTEXT NULL,
    `marcaDiaAusente_id` INT NOT NULL,
    `marcaDiaReemplaza_id` INT NOT NULL,
    `plazaAusente_id` INT NOT NULL,
    `plazaReemplaza_id` INT NOT NULL,
    `reemplaza_acepta` TINYINT(1) NOT NULL,
    `cambio_guardia_id` INT NULL,
    `ausente_acepta_at` DATETIME(0) NULL,
    `reemplaza_acepta_at` DATETIME(0) NULL,
    `file_name` VARCHAR(255) NULL,
    `estado` VARCHAR(15) NOT NULL DEFAULT 'pendiente',
    `empresa_id` INT NOT NULL DEFAULT 0,
    `division_id` INT NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `puesto_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    `firma_ausente_manual` LONGTEXT NULL,
    `firma_reemplaza_manual` LONGTEXT NULL,
    UNIQUE INDEX `UNIQ_285F04335FB34B5B`(`marcaDiaAusente_id`),
    UNIQUE INDEX `UNIQ_285F043315ABD58`(`marcaDiaReemplaza_id`),
    INDEX `e_mutuos_acuerdos_cliente_id_fkey`(`cliente_id`),
    INDEX `e_mutuos_acuerdos_corpo_id_fkey`(`corpo_id`),
    INDEX `e_mutuos_acuerdos_ejecutivo_cuenta_fkey`(`ejecutivo_cuenta`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_puestos_manual_puesto` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `manual_puesto_id` INT NOT NULL,
    `puesto_id` INT NOT NULL,
    INDEX `e_puestos_manual_puesto_manual_puesto_id_fkey`(`manual_puesto_id`),
    INDEX `e_puestos_manual_puesto_puesto_id_fkey`(`puesto_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_registro_capacitaciones` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `empresa_id` INT NOT NULL,
    `cliente_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `titulo` LONGTEXT NOT NULL,
    `descripcion` LONGTEXT NOT NULL,
    `resultado` VARCHAR(15) NULL,
    `observaciones` LONGTEXT NOT NULL,
    `nombre_responsable` LONGTEXT NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `cedula_responsable` VARCHAR(25) NOT NULL,
    `responsable_id` INT NOT NULL,
    `fecha` DATE NOT NULL,
    `file` LONGTEXT NULL,
    `tipo` VARCHAR(15) NOT NULL,
    `division_id` INT NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `puesto_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    INDEX `e_registro_capacitaciones_cliente_id_fkey`(`cliente_id`),
    INDEX `e_registro_capacitaciones_corpo_id_fkey`(`corpo_id`),
    INDEX `e_registro_capacitaciones_empresa_id_fkey`(`empresa_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_registro_entrega_puesto` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cliente_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `puesto_id` INT NOT NULL,
    `oficial_entrega` VARCHAR(255) NULL,
    `fecha_entrada_entrega` DATE NULL,
    `fecha_salida_entrega` DATE NULL,
    `hora_entrada_entrega` TIME(0) NULL,
    `hora_salida_entrega` TIME(0) NULL,
    `turno_entrega` VARCHAR(55) NULL,
    `marca_entrega_id` INT NULL,
    `oficial_recibe` VARCHAR(255) NOT NULL,
    `fecha_entrada_recibe` DATE NOT NULL,
    `fecha_salida_recibe` DATE NOT NULL,
    `hora_entrada_recibe` TIME(0) NOT NULL,
    `hora_salida_recibe` TIME(0) NOT NULL,
    `turno_recibe` VARCHAR(55) NOT NULL,
    `marca_recibe_id` INT NULL,
    `articulos_puesto` LONGTEXT NOT NULL,
    `observaciones` LONGTEXT NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `created_by` INT NOT NULL,
    `firma_entrega` LONGTEXT NULL,
    `firma_recibe` LONGTEXT NOT NULL,
    INDEX `e_registro_entrega_puesto_cliente_id_fkey`(`cliente_id`),
    INDEX `e_registro_entrega_puesto_corpo_id_fkey`(`corpo_id`),
    INDEX `e_registro_entrega_puesto_puesto_id_fkey`(`puesto_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_registro_personas` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cliente_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `puesto_id` INT NOT NULL,
    `nombre` VARCHAR(75) NOT NULL,
    `cedula` VARCHAR(30) NOT NULL,
    `hora_entrada` DATETIME(0) NOT NULL,
    `hora_salida` DATETIME(0) NULL,
    `razon_visita` VARCHAR(75) NOT NULL,
    `responsable_id` INT NOT NULL,
    `es_funcionario` TINYINT(1) NOT NULL,
    `observaciones` VARCHAR(255) NULL,
    `tipo_accion` VARCHAR(15) NULL,
    `created_at` DATETIME(0) NOT NULL,
    `updated_at` DATETIME(0) NOT NULL,
    `foto_cedula` LONGTEXT NULL,
    `pers_autoriza_salida` VARCHAR(255) NULL,
    `dep_pers_visita` VARCHAR(75) NULL,
    `empresa_id` INT NOT NULL,
    `division_id` INT NOT NULL,
    `contrato_id` INT NOT NULL,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    `firma_visitante` LONGTEXT NULL,
    INDEX `FK_BB503B25992BE730`(`responsable_id`),
    INDEX `FK_BB603B25953BE730`(`cliente_id`),
    INDEX `FK_BB703B25954BE730`(`corpo_id`),
    INDEX `FK_BB803B25955BE730`(`puesto_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_registro_vehiculos` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `cliente_id` INT NOT NULL,
    `corpo_id` INT NOT NULL,
    `puesto_id` INT NOT NULL,
    `tipo` VARCHAR(20) NOT NULL,
    `placa` VARCHAR(30) NOT NULL,
    `nombre` VARCHAR(75) NOT NULL,
    `cedula` VARCHAR(30) NOT NULL,
    `hora_entrada` DATETIME(0) NOT NULL,
    `hora_salida` DATETIME(0) NULL,
    `razon_visita` LONGTEXT NOT NULL,
    `responsable_id` INT NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `updated_at` DATETIME(0) NOT NULL,
    `file_name` LONGTEXT NULL,
    `departamento_visita` VARCHAR(255) NULL,
    `persona_visita` VARCHAR(255) NULL,
    `empresa_id` INT NOT NULL DEFAULT 0,
    `division_id` INT NOT NULL DEFAULT 0,
    `contrato_id` INT NOT NULL DEFAULT 0,
    `isActive` TINYINT(1) NOT NULL DEFAULT 1,
    INDEX `FK_BB503B25952BE730`(`responsable_id`),
    INDEX `FK_BB503B25953BE730`(`cliente_id`),
    INDEX `FK_BB503B25954BE730`(`corpo_id`),
    INDEX `FK_BB503B25955BE730`(`puesto_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_tipo_documento` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `n_clasificacion_incidente` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre` VARCHAR(255) NOT NULL,
    UNIQUE INDEX `UNIQ_92DE8E473A988126`(`nombre`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `n_ejecutivo_cuenta_coordinador` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `ejecutivo_cuenta_id` INT NOT NULL,
    `coordinador_id` INT NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `n_novedades_categoria` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre` VARCHAR(191) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `n_tipo_activo_visitas` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre` VARCHAR(255) NOT NULL,
    UNIQUE INDEX `UNIQ_92DE8E473A989126`(`nombre`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `n_tipo_mantenimiento_articulo` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `articulo_id` INT NOT NULL,
    `nombre` VARCHAR(255) NOT NULL,
    INDEX `n_tipo_mantenimiento_articulo_articulo_id_fkey`(`articulo_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `n_tipo_cliente_quejas` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre` LONGTEXT NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `n_tipo_quejas` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre` LONGTEXT NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `n_tipo_entrega` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre` LONGTEXT NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `n_mobile_variables` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `variable_name` VARCHAR(100) NOT NULL,
    `slug` VARCHAR(100) NOT NULL,
    `created_at` DATETIME(0) NOT NULL,
    `updated_at` DATETIME(0) NOT NULL,
    `variable_value` LONGTEXT NOT NULL,
    `variable_type` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `refresh_token` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `token` VARCHAR(64) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `expiresAt` DATETIME(3) NOT NULL,
    `revoked` TINYINT(1) NOT NULL DEFAULT 0,
    `empleadoId` INT NOT NULL,
    `sessionId` VARCHAR(36) NOT NULL,
    `device` LONGTEXT NULL,
    UNIQUE INDEX `refresh_token_token_key`(`token`),
    INDEX `refresh_token_empleadoId_idx`(`empleadoId`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_archivos_adjuntos_capacitaciones` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` LONGTEXT NOT NULL,
    `original_name` LONGTEXT NOT NULL,
    `type` VARCHAR(25) NOT NULL,
    `extension` VARCHAR(25) NOT NULL,
    `capacitacion_id` INT NOT NULL,
    INDEX `c_archivos_adjuntos_capacitaciones_fkey`(`capacitacion_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `c_imagenes_boleta_apreciacion_vulnerabilidad` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` LONGTEXT NOT NULL,
    `boleta_id` INT NOT NULL,
    `original_name` LONGTEXT NOT NULL,
    INDEX `c_imagenes_boleta_apreciacion_vulnerabilidad_id_fkey`(`boleta_id`),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `e_reportes_mobile` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre` LONGTEXT NOT NULL,
    `numero` VARCHAR(100) NOT NULL,
    `nomenclatura` VARCHAR(100) NOT NULL,
    `descripcion` LONGTEXT NULL,
    `modulo` VARCHAR(100) NOT NULL,
    `tipo_reporte` VARCHAR(15) NOT NULL,
    `created_by` INT NOT NULL,
    `estado` VARCHAR(15) NOT NULL,
    `filters` LONGTEXT NOT NULL,
    `order_by` LONGTEXT NOT NULL,
    `firma_responsable` LONGTEXT NOT NULL,
    `created_at` DATETIME(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
    `attemps` INT NULL,
    `max_attempts` INT NULL,
    `started_at` DATETIME(0) NULL,
    `finished_at` DATETIME(0) NULL,
    `locked_at` DATETIME(0) NULL,
    `locked_by` VARCHAR(55) NULL,
    `error_message` LONGTEXT NULL,
    `progress` INT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
-- =============================
-- Relaciones (FK) — solo entre tablas creadas
-- =============================
ALTER TABLE `c_anexos_quejas` ADD CONSTRAINT `c_anexos_quejas_queja_id_fkey` FOREIGN KEY (`queja_id`) REFERENCES `c_maestro_quejas`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `c_archivos_adjuntos_articulo_mantenimiento` ADD CONSTRAINT `c_archivos_adjuntos_articulo_mantenimiento_activo_mantenimi_fkey` FOREIGN KEY (`activo_mantenimiento_id`) REFERENCES `c_articulo_mantenimiento`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `c_archivos_aporte_incidente` ADD CONSTRAINT `c_archivos_aporte_incidente_contribucion_id_fkey` FOREIGN KEY (`contribucion_id`) REFERENCES `c_contribucion_incidente`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `c_archivos_incidente` ADD CONSTRAINT `c_archivos_incidente_incidente_id_fkey` FOREIGN KEY (`incidente_id`) REFERENCES `c_incidente`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `c_contribucion_incidente` ADD CONSTRAINT `c_contribucion_incidente_incidente_id_fkey` FOREIGN KEY (`incidente_id`) REFERENCES `c_incidente`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `c_empleado_notification` ADD CONSTRAINT `c_empleado_notification_notificationId_fkey` FOREIGN KEY (`notificationId`) REFERENCES `c_notifications`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `c_imagenes_acta_entrega_producto` ADD CONSTRAINT `c_imagenes_acta_entrega_producto_acta_id_fkey` FOREIGN KEY (`acta_id`) REFERENCES `c_acta_entre_producto`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `c_imagenes_apertura_cierre_puesto` ADD CONSTRAINT `c_imagenes_apertura_cierre_puesto_apetura_cierre_id_fkey` FOREIGN KEY (`apetura_cierre_id`) REFERENCES `c_apertura_cierre_puesto`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `c_imagenes_control_asistencia` ADD CONSTRAINT `c_imagenes_control_asistencia_control_id_fkey` FOREIGN KEY (`control_id`) REFERENCES `c_control_asistencia`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `c_imagenes_vehiculos_corporativos` ADD CONSTRAINT `c_imagenes_vehiculos_corporativos_vehiculo_id_fkey` FOREIGN KEY (`vehiculo_id`) REFERENCES `c_vehiculos_corporativos`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `c_incidente` ADD CONSTRAINT `c_incidente_clasificacion_fkey` FOREIGN KEY (`clasificacion`) REFERENCES `n_clasificacion_incidente`(`id`) ON DELETE NO ACTION ON UPDATE CASCADE;
ALTER TABLE `c_mantenimiento_vehiculos_corporativos` ADD CONSTRAINT `c_mantenimiento_vehiculos_corporativos_vehiculo_id_fkey` FOREIGN KEY (`vehiculo_id`) REFERENCES `c_vehiculos_corporativos`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `c_plaza_notification` ADD CONSTRAINT `c_plaza_notification_notificationId_fkey` FOREIGN KEY (`notificationId`) REFERENCES `c_notifications`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `c_usos_vehiculos_corporativos` ADD CONSTRAINT `c_usos_vehiculos_corporativos_vehiculo_id_fkey` FOREIGN KEY (`vehiculo_id`) REFERENCES `c_vehiculos_corporativos`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `e_activo_visitante` ADD CONSTRAINT `FK_BB503B25992BE739` FOREIGN KEY (`visitante_id`) REFERENCES `e_registro_personas`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `e_activo_visitante` ADD CONSTRAINT `FK_BB503B25993BE739` FOREIGN KEY (`tipo_id`) REFERENCES `n_tipo_activo_visitas`(`id`) ON DELETE NO ACTION ON UPDATE CASCADE;
ALTER TABLE `e_archivos_manual_puesto` ADD CONSTRAINT `e_archivos_manual_puesto_manual_puesto_id_fkey` FOREIGN KEY (`manual_puesto_id`) REFERENCES `e_manual_puesto`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `e_archivos_producto_no_conforme` ADD CONSTRAINT `e_archivos_producto_no_conforme_pnc_id_fkey` FOREIGN KEY (`pnc_id`) REFERENCES `c_producto_no_conforme`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `e_capacitacion_empleado` ADD CONSTRAINT `e_capacitacion_empleado_capacitacion_id_fkey` FOREIGN KEY (`capacitacion_id`) REFERENCES `e_registro_capacitaciones`(`id`) ON DELETE NO ACTION ON UPDATE CASCADE;
ALTER TABLE `e_capacitacion_puesto` ADD CONSTRAINT `e_capacitacion_puesto_capacitacion_id_fkey` FOREIGN KEY (`capacitacion_id`) REFERENCES `e_registro_capacitaciones`(`id`) ON DELETE NO ACTION ON UPDATE CASCADE;
ALTER TABLE `e_empleado_visualizacion_archivos` ADD CONSTRAINT `e_empleado_visualizacion_archivos_visualizacion_id_fkey` FOREIGN KEY (`visualizacion_id`) REFERENCES `e_empleado_visualizacion_manual_puesto`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `e_empleado_visualizacion_manual_puesto` ADD CONSTRAINT `e_empleado_visualizacion_manual_puesto_manual_puesto_id_fkey` FOREIGN KEY (`manual_puesto_id`) REFERENCES `e_manual_puesto`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `e_llave_en_llavero` ADD CONSTRAINT `e_llave_en_llavero_llave_id_fkey` FOREIGN KEY (`llave_id`) REFERENCES `e_llave`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `e_llave_en_llavero` ADD CONSTRAINT `e_llave_en_llavero_llavero_id_fkey` FOREIGN KEY (`llavero_id`) REFERENCES `e_llavero`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `e_movimiento_llave` ADD CONSTRAINT `e_movimiento_llave_llave_id_fkey` FOREIGN KEY (`llave_id`) REFERENCES `e_llave`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `e_movimiento_llavero` ADD CONSTRAINT `e_movimiento_llavero_llavero_id_fkey` FOREIGN KEY (`llavero_id`) REFERENCES `e_llavero`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `e_puestos_manual_puesto` ADD CONSTRAINT `e_puestos_manual_puesto_manual_puesto_id_fkey` FOREIGN KEY (`manual_puesto_id`) REFERENCES `e_manual_puesto`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `c_imagenes_registro_induccion_general` ADD CONSTRAINT `c_imagenes_registro_induccion_general_registro_id_fkey` FOREIGN KEY (`registro_id`) REFERENCES `c_registro_induccion_general`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `e_actividades_puesto` ADD CONSTRAINT `e_actividades_puesto_actividad_id_fkey` FOREIGN KEY (`actividad_id`) REFERENCES `e_actividades`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `e_actividades_puesto_plaza` ADD CONSTRAINT `e_actividades_puesto_plaza_actividad_puesto_id_fkey` FOREIGN KEY (`actividad_puesto_id`) REFERENCES `e_actividades_puesto`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `c_imagenes_checklist_supervision` ADD CONSTRAINT `c_imagenes_checklist_supervision_checklist_id_fkey` FOREIGN KEY (`checklist_id`) REFERENCES `c_checklist_supervision`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `c_imagenes_puesto_notas` ADD CONSTRAINT `c_imagenes_puesto_notas_nota_id_fkey` FOREIGN KEY (`nota_id`) REFERENCES `c_puesto_notas`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `c_archivos_solicitud_permiso` ADD CONSTRAINT `c_archivos_solicitud_permiso_solicitud_id_fkey` FOREIGN KEY (`solicitud_id`) REFERENCES `c_solicitud_permiso`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `c_archivos_adjuntos_capacitaciones` ADD CONSTRAINT `fk_capacitaciones` FOREIGN KEY (`capacitacion_id`) REFERENCES `e_registro_capacitaciones`(`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `c_imagenes_boleta_apreciacion_vulnerabilidad` ADD CONSTRAINT `fk_boleta_apreciacion_vulnerabilidad` FOREIGN KEY (`boleta_id`) REFERENCES `c_boleta_apreciacion_vulnerabilidad`(`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE `c_control_asistencia_empleado_firmas` ADD CONSTRAINT `fk_control_asistencia` FOREIGN KEY (`control_id`) REFERENCES `c_control_asistencia`(`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
SET FOREIGN_KEY_CHECKS = 1;
