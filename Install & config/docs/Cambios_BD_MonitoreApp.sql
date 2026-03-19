-- Motor objetivo: MySQL (InnoDB, utf8mb4)
-- Ejecutar sobre una base ya existente con tablas originales.
SET FOREIGN_KEY_CHECKS = 0;

-- =============================
-- Cambios en tablas existentes
-- =============================
ALTER TABLE `c_accion_personal` ADD COLUMN `mobile_upload` BOOLEAN NULL;
ALTER TABLE `c_cambio_guardia` ADD COLUMN `mobile_upload` BOOLEAN NULL;
ALTER TABLE `c_empleado` ADD COLUMN `firma_manual` LONGTEXT NULL;
ALTER TABLE `c_empleado` ADD COLUMN `ingresado` BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE `c_marca_dia` ADD COLUMN `usuarioMarcaEntrada` VARCHAR(191) NULL;
ALTER TABLE `c_marca_dia` ADD COLUMN `salida_anticipada_id` INT NULL;
ALTER TABLE `c_salida_anticipada` ADD COLUMN `empleado_id` INT NULL;
ALTER TABLE `c_salida_anticipada` ADD COLUMN `motivo` LONGTEXT NULL;
ALTER TABLE `e_estructura_puesto` ADD COLUMN `coordenadas_gpslat` VARCHAR(255) NULL;
ALTER TABLE `e_estructura_puesto` ADD COLUMN `coordenadas_gpslng` VARCHAR(255) NULL;
CREATE INDEX `c_salida_anticipada_empleado_id_fkey` ON `c_salida_anticipada` (`empleado_id`);
ALTER TABLE `c_salida_anticipada` ADD CONSTRAINT `c_salida_anticipada_empleado_id_fkey` FOREIGN KEY (`empleado_id`) REFERENCES `c_empleado`(`id`) ON DELETE CASCADE;
CREATE INDEX `idx_c_marca_dia_salida_anticipada_id` ON `c_marca_dia` (`salida_anticipada_id`);
ALTER TABLE `c_marca_dia` ADD CONSTRAINT `fk_c_marca_dia_salida_anticipada` FOREIGN KEY (`salida_anticipada_id`) REFERENCES `c_salida_anticipada`(`id`) ON DELETE CASCADE;

-- =============================
-- Tablas nuevas
-- =============================
CREATE TABLE IF NOT EXISTS `a_recovery_password_token` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `expira_en` INT NOT NULL,
  `creacion` DATETIME(0) NOT NULL,
  `token` VARCHAR(255) NOT NULL,
  `empleadoId` INT NOT NULL,
  KEY `FK_E35A23BC952BE730` (`empleadoId`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_acta_entre_producto` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `empresa_id` INT NOT NULL,
  `cliente_id` INT NOT NULL,
  `contrato_id` INT NOT NULL,
  `corpo_id` INT NOT NULL,
  `fecha` DATETIME NOT NULL,
  `tipo_entrega` LONGTEXT NOT NULL,
  `mensual` LONGTEXT NOT NULL,
  `division` VARCHAR(25) NOT NULL,
  `detalle` LONGTEXT NOT NULL,
  `observaciones` LONGTEXT NOT NULL,
  `nombre_entrega` LONGTEXT NOT NULL,
  `cedula_entrega` VARCHAR(30) NOT NULL,
  `fecha_entrega` DATETIME NOT NULL,
  `firma_entrega` LONGTEXT NULL,
  `nombre_recibe` LONGTEXT NOT NULL,
  `cedula_recibe` VARCHAR(30) NOT NULL,
  `fecha_recibe` DATETIME NOT NULL,
  `firma_recibe` LONGTEXT NULL,
  `firma_responsable` LONGTEXT NOT NULL,
  `division_id` INT NOT NULL,
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
  `created_at` DATETIME NOT NULL,
  `created_by` VARCHAR(191) NOT NULL,
  `temas_a_tratar` LONGTEXT NULL,
  KEY `c_agenda_minuta_cliente_id_fkey` (`cliente_id`),
  KEY `c_agenda_minuta_corpo_id_fkey` (`corpo_id`),
  KEY `c_agenda_minuta_puesto_id_fkey` (`puesto_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_anexos_quejas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` LONGTEXT NOT NULL,
  `original_name` LONGTEXT NOT NULL,
  `type` VARCHAR(25) NOT NULL,
  `extension` VARCHAR(25) NOT NULL,
  `queja_id` INT NOT NULL,
  KEY `c_anexos_quejas_queja_id_fkey` (`queja_id`),
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
  `created_at` DATETIME NOT NULL,
  `created_by` INT NOT NULL,
  `fecha` DATETIME NOT NULL,
  `firma_representante_empresa_entrante` LONGTEXT NULL,
  `firma_representante_empresa_saliente` LONGTEXT NULL,
  `firma_responsable` LONGTEXT NOT NULL,
  `nombre_representante_empresa_entrante` VARCHAR(255) NOT NULL,
  `nombre_representante_empresa_saliente` VARCHAR(255) NOT NULL,
  `firma_representante_cliente` LONGTEXT NULL,
  `division_id` INT NOT NULL,
  KEY `c_apertura_cierre_puesto_cliente_id_fkey` (`cliente_id`),
  KEY `c_apertura_cierre_puesto_corpo_id_fkey` (`corpo_id`),
  KEY `c_apertura_cierre_puesto_division_id_fkey` (`division_id`),
  KEY `c_apertura_cierre_puesto_puesto_id_fkey` (`puesto_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_archivos_adjuntos_articulo_mantenimiento` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` LONGTEXT NOT NULL,
  `original_name` LONGTEXT NOT NULL,
  `type` VARCHAR(25) NOT NULL,
  `extension` VARCHAR(25) NOT NULL,
  `activo_mantenimiento_id` INT NOT NULL,
  KEY `c_archivos_adjuntos_articulo_mantenimiento_activo_mantenimi_fkey` (`activo_mantenimiento_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_archivos_aporte_incidente` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` LONGTEXT NOT NULL,
  `original_name` LONGTEXT NOT NULL,
  `type` VARCHAR(25) NOT NULL,
  `extension` VARCHAR(25) NOT NULL,
  `contribucion_id` INT NOT NULL,
  KEY `c_archivos_aporte_incidente_contribucion_id_fkey` (`contribucion_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_archivos_incidente` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` LONGTEXT NOT NULL,
  `original_name` LONGTEXT NOT NULL,
  `type` VARCHAR(25) NOT NULL,
  `extension` VARCHAR(25) NOT NULL,
  `incidente_id` INT NOT NULL,
  KEY `c_archivos_incidente_incidente_id_fkey` (`incidente_id`),
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
  `reincidencia_treinta_dias` BOOLEAN NULL,
  `tipo_mant_art_reincid` LONGTEXT NULL,
  `created_at` DATETIME(0) NOT NULL,
  `updated_at` DATETIME(0) NOT NULL,
  KEY `c_articulo_mantenimiento_articulo_asignado_id_fkey` (`articulo_asignado_id`),
  KEY `c_articulo_mantenimiento_articulo_plan_id_fkey` (`articulo_plan_id`),
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
  KEY `c_boleta_apreciacion_vulnerabilidad_cliente_id_fkey` (`cliente_id`),
  KEY `c_boleta_apreciacion_vulnerabilidad_corpo_id_fkey` (`corpo_id`),
  KEY `c_boleta_apreciacion_vulnerabilidad_puesto_id_fkey` (`puesto_id`),
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
  KEY `c_checklist_supervision_cliente_id_fkey` (`cliente_id`),
  KEY `c_checklist_supervision_corpo_id_fkey` (`corpo_id`),
  KEY `c_checklist_supervision_puesto_id_fkey` (`puesto_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_imagenes_checklist_supervision` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` LONGTEXT NOT NULL,
  `checklist_id` INT NOT NULL,
  `original_name` LONGTEXT NOT NULL,
  KEY `c_imagenes_checklist_supervision_id_fkey` (`checklist_id`),
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
  KEY `c_contribucion_incidente_empleado_id_fkey` (`empleado_id`),
  KEY `c_contribucion_incidente_incidente_id_fkey` (`incidente_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_control_asistencia` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `empresa_id` INT NOT NULL,
  `contrato_id` INT NOT NULL,
  `corpo_id` INT NOT NULL,
  `fecha` DATETIME(0) NOT NULL,
  `turno` VARCHAR(191) NOT NULL,
  `total_presentes` INT NOT NULL,
  `colaboradores` LONGTEXT NOT NULL,
  `created_at` DATETIME NOT NULL,
  `created_by` INT NOT NULL,
  `firma_responsable` LONGTEXT NOT NULL,
  `division_id` INT NOT NULL,
  `cliente_id` INT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_empleado_almuerzo` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `empleadoId` INT NOT NULL,
  `empleado_nombre` LONGTEXT NOT NULL,
  `cedula_empleado` LONGTEXT NOT NULL,
  `minutos_almuerzo` DOUBLE NOT NULL,
  `firma_empleado` LONGTEXT NOT NULL,
  `pausas` LONGTEXT NOT NULL,
  `inicio` DATETIME(0) NOT NULL,
  `fin` DATETIME(0) NOT NULL,
  `es_manual` BOOLEAN NOT NULL DEFAULT FALSE,
  KEY `empleadoId_almuerzo_fkey` (`empleadoId`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_empleado_notification` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `empleadoId` INT NOT NULL,
  `notificationId` INT NOT NULL,
  `watched` BOOLEAN NOT NULL DEFAULT FALSE,
  KEY `c_empleado_notification_notificationId_fkey` (`notificationId`),
  KEY `c_plaza_notification_empleadoId_fkey` (`empleadoId`),
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
  KEY `c_encuesta_cliente_cliente_id_fkey` (`cliente_id`),
  KEY `c_encuesta_cliente_corpo_id_fkey` (`corpo_id`),
  KEY `c_encuesta_cliente_division_id_fkey` (`division_id`),
  KEY `c_encuesta_cliente_empresa_id_fkey` (`empresa_id`),
  KEY `c_encuesta_cliente_puesto_id_fkey` (`puesto_id`),
  KEY `c_encuesta_cliente_responsable_id_fkey` (`responsable_id`),
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
  KEY `c_evaluacion_empleado_corpo_id_fkey` (`corpo_id`),
  KEY `c_evaluacion_empleado_plaza_id_fkey` (`plaza_id`),
  KEY `c_evaluacion_empleado_puesto_id_fkey` (`puesto_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_imagenes_acta_entrega_producto` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` LONGTEXT NOT NULL,
  `acta_id` INT NOT NULL,
  KEY `c_imagenes_acta_entrega_producto_acta_id_fkey` (`acta_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_imagenes_apertura_cierre_puesto` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` LONGTEXT NOT NULL,
  `apetura_cierre_id` INT NOT NULL,
  `original_name` LONGTEXT NOT NULL,
  KEY `c_imagenes_apertura_cierre_puesto_apetura_cierre_id_fkey` (`apetura_cierre_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_imagenes_control_asistencia` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` LONGTEXT NOT NULL,
  `control_id` INT NOT NULL,
  `original_name` LONGTEXT NOT NULL,
  KEY `c_imagenes_control_asistencia_control_id_fkey` (`control_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_imagenes_registro_induccion_general` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` LONGTEXT NOT NULL,
  `registro_id` INT NOT NULL,
  KEY `c_imagenes_registro_induccion_general_id_fkey` (`registro_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_imagenes_vehiculos_corporativos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` LONGTEXT NOT NULL,
  `vehiculo_id` INT NOT NULL,
  KEY `c_imagenes_vehiculos_corporativos_vehiculo_id_fkey` (`vehiculo_id`),
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
  `cliente_id` INT NOT NULL,
  `empresa_id` INT NOT NULL,
  `estado` BOOLEAN NOT NULL,
  `created_at` DATETIME(0) NOT NULL,
  `created_by` INT NOT NULL,
  KEY `c_incidente_clasificacion_fkey` (`clasificacion`),
  KEY `c_incidente_cliente_id_fkey` (`cliente_id`),
  KEY `c_incidente_corpo_id_fkey` (`corpo_id`),
  KEY `c_incidente_ejecutivo_cuenta_fkey` (`ejecutivo_cuenta`),
  KEY `c_incidente_empresa_id_fkey` (`empresa_id`),
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
  `tipo_queja` VARCHAR(191) NOT NULL,
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
  `created_at` DATETIME NOT NULL,
  `created_by` VARCHAR(191) NOT NULL,
  `firma_responsable` LONGTEXT NOT NULL,
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
  KEY `c_mantenimiento_vehiculos_corporativos_vehiculo_id_fkey` (`vehiculo_id`),
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
  KEY `c_movimientos_articulo_mantenimiento_articulo_asignado_id_fkey` (`articulo_asignado_id`),
  KEY `c_movimientos_articulo_mantenimiento_articulo_plan_id_fkey` (`articulo_plan_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_notifications` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title` LONGTEXT NOT NULL,
  `description` LONGTEXT NOT NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_plaza_notification` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `plazaId` INT NOT NULL,
  `notificationId` INT NOT NULL,
  `watched` BOOLEAN NOT NULL DEFAULT FALSE,
  KEY `c_plaza_notification_notificationId_fkey` (`notificationId`),
  KEY `c_plaza_notification_plazaId_fkey` (`plazaId`),
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
  `created_at` DATETIME NOT NULL,
  `created_by` VARCHAR(191) NOT NULL,
  `firma_persona_identifico_pnc` LONGTEXT NULL,
  `firma_persona_origino_pnc` LONGTEXT NULL,
  `firma_responsable` LONGTEXT NOT NULL,
  KEY `c_producto_no_conforme_cliente_id_fkey` (`cliente_id`),
  KEY `c_producto_no_conforme_corpo_id_fkey` (`corpo_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_puesto_notas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `titulo` VARCHAR(255) NOT NULL,
  `description` LONGTEXT NOT NULL,
  `categoria_id` INT NULL,
  `puesto_id` INT NOT NULL,
  `firma_responsable` LONGTEXT NOT NULL,
  `firma_manual_responsable` LONGTEXT NULL,
  `is_modified` BOOLEAN NOT NULL DEFAULT FALSE,
  `created_at` DATETIME(0) NOT NULL,
  `updated_at` DATETIME(0) NOT NULL,
  `relevancia` VARCHAR(16) NULL,
  KEY `puesto_id_notas_fkey` (`puesto_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_imagenes_puesto_notas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` LONGTEXT NOT NULL,
  `nota_id` INT NOT NULL,
  KEY `c_imagenes_puesto_notas_id_fkey` (`nota_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_registro_induccion_general` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `empresa_id` INT NOT NULL,
  `cliente_id` INT NOT NULL,
  `corpo_id` INT NOT NULL,
  `division` VARCHAR(50) NOT NULL,
  `fecha` DATETIME NOT NULL,
  `temas_a_tratar` LONGTEXT NOT NULL,
  `colaboradores` LONGTEXT NOT NULL,
  `capacitadores` LONGTEXT NOT NULL,
  `firma_responsable` LONGTEXT NOT NULL,
  `created_at` DATETIME NOT NULL,
  `created_by` VARCHAR(191) NOT NULL,
  KEY `c_registro_induccion_general_cliente_id_fkey` (`cliente_id`),
  KEY `c_registro_induccion_general_corpo_id_fkey` (`corpo_id`),
  KEY `c_registro_induccion_general_empresa_id_fkey` (`empresa_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_registro_induccion_recorrido` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `empresa_id` INT NOT NULL,
  `cliente_id` INT NOT NULL,
  `contrato_id` INT NOT NULL,
  `corpo_id` INT NOT NULL,
  `puesto_id` INT NOT NULL,
  `plaza_id` INT NOT NULL,
  `fecha` DATETIME NOT NULL,
  `renglon_edificio` VARCHAR(191) NOT NULL,
  `supervisor_cliente` VARCHAR(191) NULL,
  `supervisor_corporacion` VARCHAR(191) NOT NULL,
  `temas_desarrollados` LONGTEXT NOT NULL,
  `aspectos_especificos` LONGTEXT NOT NULL,
  `participantes` LONGTEXT NOT NULL,
  `firma_supervisor` LONGTEXT NULL,
  `created_at` DATETIME NOT NULL,
  `created_by` VARCHAR(191) NOT NULL,
  `division` VARCHAR(191) NOT NULL,
  `firma_responsable` LONGTEXT NOT NULL,
  `empleado_id` INT NOT NULL,
  `firma_empleado` LONGTEXT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_solicitud_permiso` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `empleado_id` INT NOT NULL,
  `plaza_id` INT NOT NULL,
  `tipo` VARCHAR(15) NOT NULL,
  `fecha_inicio` DATETIME(0) NOT NULL,
  `fecha_fin` DATETIME(0) NOT NULL,
  `ejecutivo_cuenta` INT NOT NULL,
  `comentarios` LONGTEXT NULL,
  `reemplazo_obligatorio` INT NULL,
  `turnos` LONGTEXT NOT NULL,
  `firma_responsable` LONGTEXT NOT NULL,
  `firma_ejecutivo_cuenta_digital` LONGTEXT NULL,
  `firma_ejecutivo_cuenta_manual` LONGTEXT NULL,
  `accionPersonal_id` INT NULL,
  `created_at` DATETIME NOT NULL,
  `created_by` INT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_archivos_solicitud_permiso` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` LONGTEXT NOT NULL,
  `type` VARCHAR(25) NOT NULL,
  `extension` VARCHAR(25) NOT NULL,
  `solicitud_id` INT NOT NULL,
  `original_name` LONGTEXT NOT NULL,
  `is_main` BOOLEAN NOT NULL DEFAULT FALSE,
  KEY `e_archivos_solicitud_permiso_id_fkey` (`solicitud_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_tipos_producto_no_conforme` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(255) NOT NULL,
  UNIQUE KEY `UNIQ_92DE8E473A988126` (`nombre`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_usos_vehiculos_corporativos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `bitacora_id` INT NULL,
  `vehiculo_id` INT NOT NULL,
  `nombre_conductor` VARCHAR(55) NOT NULL,
  `codigo_conductor` VARCHAR(55) NOT NULL,
  `fecha` DATETIME(0) NOT NULL,
  `inicio` DATETIME(0) NOT NULL,
  `fin` DATETIME(0) NOT NULL,
  `combustible_inicio` LONGTEXT NOT NULL,
  `combustible_fin` LONGTEXT NOT NULL,
  `km_inicio` INT NOT NULL,
  `km_fin` INT NOT NULL,
  `motivo` LONGTEXT NOT NULL,
  `firma_conductor` LONGTEXT NULL,
  `firma_responsable` LONGTEXT NOT NULL,
  KEY `c_usos_vehiculos_corporativos_vehiculo_id_fkey` (`vehiculo_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `c_vehiculos_corporativos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cliente_id` INT NOT NULL,
  `sucursal_id` INT NOT NULL,
  `placa` VARCHAR(52) NOT NULL,
  `tipo` VARCHAR(52) NOT NULL,
  `tipo_autoria` VARCHAR(52) NOT NULL,
  `kilometraje` INT NOT NULL,
  `prox_cambio_aceite` INT NOT NULL,
  `modelo` VARCHAR(52) NOT NULL,
  `anno` INT NOT NULL,
  `descripcion` LONGTEXT NOT NULL,
  `titulo_propiedad` BOOLEAN NOT NULL DEFAULT TRUE,
  `rtv` BOOLEAN NOT NULL DEFAULT TRUE,
  `marchamo` BOOLEAN NOT NULL DEFAULT TRUE,
  `firma_responsable` LONGTEXT NOT NULL,
  `created_by` INT NOT NULL,
  `created_at` DATETIME(0) NOT NULL,
  `estado` VARCHAR(25) NOT NULL,
  `empresa_id` INT NOT NULL,
  KEY `c_vehiculos_corporativos_cliente_id_fkey` (`cliente_id`),
  KEY `c_vehiculos_corporativos_sucursal_id_fkey` (`sucursal_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `e_actividades` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nombre_actividad` VARCHAR(255) NOT NULL,
  `fecha_inicio` DATE NOT NULL,
  `fecha_fin` DATE NULL,
  `frecuencia` LONGTEXT NOT NULL,
  `es_revision_equipo` BOOLEAN NOT NULL,
  `descripcion_actividad` LONGTEXT NOT NULL,
  `firma_responsable` LONGTEXT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `e_actividades_puesto` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `actividad_id` INT NOT NULL,
  `puesto_id` INT NOT NULL,
  KEY `e_actividad_id_fkey` (`actividad_id`),
  KEY `e_actividad_puesto_id_fkey` (`puesto_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `e_actividades_puesto_plaza` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `actividad_puesto_id` INT NOT NULL,
  `plaza_id` INT NOT NULL,
  `bitacora` LONGTEXT NOT NULL,
  `file_name` LONGTEXT NULL,
  `articles` LONGTEXT NULL,
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NOT NULL,
  `marcada` BOOLEAN NOT NULL DEFAULT FALSE,
  KEY `e_actividad_actividad_puesto_id_fkey` (`actividad_puesto_id`),
  KEY `e_actividad_puesto_plaza_id_fkey` (`plaza_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `e_activo_visitante` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `visitante_id` INT NOT NULL,
  `tipo_id` INT NOT NULL,
  `nombre` VARCHAR(50) NOT NULL,
  `detalles` LONGTEXT NOT NULL,
  `numero_id` VARCHAR(50) NOT NULL,
  `numero_activo` VARCHAR(50) NULL,
  KEY `FK_BB503B25992BE739` (`visitante_id`),
  KEY `FK_BB503B25993BE739` (`tipo_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `e_archivos_manual_puesto` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` LONGTEXT NOT NULL,
  `type` VARCHAR(25) NOT NULL,
  `extension` VARCHAR(25) NOT NULL,
  `manual_puesto_id` INT NOT NULL,
  `original_name` LONGTEXT NOT NULL,
  KEY `e_archivos_manual_puesto_manual_puesto_id_fkey` (`manual_puesto_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `e_archivos_producto_no_conforme` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` LONGTEXT NOT NULL,
  `type` VARCHAR(25) NOT NULL,
  `extension` VARCHAR(25) NOT NULL,
  `pnc_id` INT NOT NULL,
  `original_name` LONGTEXT NOT NULL,
  KEY `e_archivos_producto_no_conforme_pnc_id_fkey` (`pnc_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `e_capacitacion_empleado` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `capacitacion_id` INT NOT NULL,
  `empleado_id` INT NOT NULL,
  KEY `e_capacitacion_empleado_capacitacion_id_fkey` (`capacitacion_id`),
  KEY `e_capacitacion_empleado_empleado_id_fkey` (`empleado_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `e_capacitacion_puesto` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `capacitacion_id` INT NOT NULL,
  `puesto_id` INT NOT NULL,
  KEY `e_capacitacion_puesto_capacitacion_id_fkey` (`capacitacion_id`),
  KEY `e_capacitacion_puesto_puesto_id_fkey` (`puesto_id`),
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
  KEY `e_control_documento_entregado_cliente_cliente_id_fkey` (`cliente_id`),
  KEY `e_control_documento_entregado_cliente_corpo_id_fkey` (`corpo_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `e_empleado_visualizacion_archivos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` LONGTEXT NOT NULL,
  `type` VARCHAR(25) NOT NULL,
  `extension` VARCHAR(25) NOT NULL,
  `visualizacion_id` INT NOT NULL,
  `original_name` LONGTEXT NOT NULL,
  KEY `e_archivos_empleado_visualizacion_id_fkey` (`visualizacion_id`),
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
  `approved` BOOLEAN NULL,
  KEY `e_empleado_visualizacion_manual_puesto_empleado_id_fkey` (`empleado_id`),
  KEY `e_empleado_visualizacion_manual_puesto_manual_puesto_id_fkey` (`manual_puesto_id`),
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
  KEY `e_llave_cliente_id_fkey` (`cliente_id`),
  KEY `e_llave_corpo_id_fkey` (`corpo_id`),
  KEY `e_llave_puesto_id_fkey` (`puesto_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `e_llave_en_llavero` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `llave_id` INT NOT NULL,
  `llavero_id` INT NOT NULL,
  KEY `e_llave_en_llavero_llave_id_fkey` (`llave_id`),
  KEY `e_llave_en_llavero_llavero_id_fkey` (`llavero_id`),
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
  KEY `e_llavero_cliente_id_fkey` (`cliente_id`),
  KEY `e_llavero_corpo_id_fkey` (`corpo_id`),
  KEY `e_llavero_puesto_id_fkey` (`puesto_id`),
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
  KEY `e_movimiento_llave_llave_id_fkey` (`llave_id`),
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
  KEY `e_movimiento_llavero_llavero_id_fkey` (`llavero_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `e_mutuos_acuerdos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cliente_id` INT NOT NULL,
  `corpo_id` INT NOT NULL,
  `ejecutivo_cuenta` INT NOT NULL,
  `empleadoReemplaza_id` INT NOT NULL,
  `plazaReemplaza_id` INT NOT NULL,
  `marcaDiaReemplaza_id` INT NOT NULL,
  `reemplaza_acepta` BOOLEAN NOT NULL,
  `reemplaza_acepta_at` DATETIME(0) NULL,
  `empleadoAusente_id` INT NOT NULL,
  `plazaAusente_id` INT NOT NULL,
  `marcaDiaAusente_id` INT NOT NULL,
  `ausente_acepta` BOOLEAN NOT NULL,
  `ausente_acepta_at` DATETIME(0) NULL,
  `motivo` LONGTEXT NOT NULL,
  `firma_ejecutivo_cuenta_manual` LONGTEXT NULL,
  `firma_ejecutivo_cuenta_digital` LONGTEXT NOT NULL,
  `firma_responsable` LONGTEXT NOT NULL,
  `cambio_guardia_id` INT NULL,
  `file_name` VARCHAR(255) NULL,
  `created_at` DATETIME(0) NOT NULL,
  `created_by` INT NOT NULL,
  UNIQUE KEY `UNIQ_285F043315ABD58` (`marcaDiaReemplaza_id`),
  UNIQUE KEY `UNIQ_285F04335FB34B5B` (`marcaDiaAusente_id`),
  KEY `e_mutuos_acuerdos_cliente_id_fkey` (`cliente_id`),
  KEY `e_mutuos_acuerdos_corpo_id_fkey` (`corpo_id`),
  KEY `e_mutuos_acuerdos_ejecutivo_cuenta_fkey` (`ejecutivo_cuenta`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `e_puestos_manual_puesto` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `manual_puesto_id` INT NOT NULL,
  `puesto_id` INT NOT NULL,
  KEY `e_puestos_manual_puesto_manual_puesto_id_fkey` (`manual_puesto_id`),
  KEY `e_puestos_manual_puesto_puesto_id_fkey` (`puesto_id`),
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
  KEY `e_registro_capacitaciones_cliente_id_fkey` (`cliente_id`),
  KEY `e_registro_capacitaciones_corpo_id_fkey` (`corpo_id`),
  KEY `e_registro_capacitaciones_empresa_id_fkey` (`empresa_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `e_registro_entrega_puesto` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `cliente_id` INT NOT NULL,
  `corpo_id` INT NOT NULL,
  `puesto_id` INT NOT NULL,
  `oficial_entrega` VARCHAR(255) NOT NULL,
  `fecha_entrada_entrega` DATE NOT NULL,
  `fecha_salida_entrega` DATE NOT NULL,
  `hora_entrada_entrega` TIME(0) NOT NULL,
  `hora_salida_entrega` TIME(0) NOT NULL,
  `turno_entrega` VARCHAR(55) NOT NULL,
  `oficial_recibe` VARCHAR(255) NOT NULL,
  `fecha_entrada_recibe` DATE NOT NULL,
  `fecha_salida_recibe` DATE NOT NULL,
  `hora_entrada_recibe` TIME(0) NOT NULL,
  `hora_salida_recibe` TIME(0) NOT NULL,
  `turno_recibe` VARCHAR(55) NOT NULL,
  `articulos_puesto` LONGTEXT NOT NULL,
  `observaciones` LONGTEXT NOT NULL,
  `firma_recibe` LONGTEXT NOT NULL,
  `firma_entrega` LONGTEXT NULL,
  `firma_responsable` LONGTEXT NOT NULL,
  `created_at` DATETIME(0) NOT NULL,
  `created_by` INT NOT NULL,
  KEY `e_registro_entrega_puesto_cliente_id_fkey` (`cliente_id`),
  KEY `e_registro_entrega_puesto_corpo_id_fkey` (`corpo_id`),
  KEY `e_registro_entrega_puesto_puesto_id_fkey` (`puesto_id`),
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
  `dep_pers_visita` VARCHAR(75) NULL,
  `responsable_id` INT NOT NULL,
  `es_funcionario` BOOLEAN NOT NULL,
  `observaciones` VARCHAR(255) NULL,
  `tipo_accion` VARCHAR(15) NULL,
  `created_at` DATETIME(0) NOT NULL,
  `updated_at` DATETIME(0) NOT NULL,
  `foto_cedula` LONGTEXT NULL,
  `pers_autoriza_salida` VARCHAR(255) NULL,
  KEY `FK_BB503B25992BE730` (`responsable_id`),
  KEY `FK_BB603B25953BE730` (`cliente_id`),
  KEY `FK_BB703B25954BE730` (`corpo_id`),
  KEY `FK_BB803B25955BE730` (`puesto_id`),
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
  `departamento_visita` VARCHAR(255) NULL,
  `persona_visita` VARCHAR(255) NULL,
  `razon_visita` LONGTEXT NOT NULL,
  `responsable_id` INT NOT NULL,
  `created_at` DATETIME(0) NOT NULL,
  `updated_at` DATETIME(0) NOT NULL,
  `file_name` LONGTEXT NULL,
  KEY `FK_BB503B25952BE730` (`responsable_id`),
  KEY `FK_BB503B25953BE730` (`cliente_id`),
  KEY `FK_BB503B25954BE730` (`corpo_id`),
  KEY `FK_BB503B25955BE730` (`puesto_id`),
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
  UNIQUE KEY `UNIQ_92DE8E473A988126` (`nombre`),
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
  UNIQUE KEY `UNIQ_92DE8E473A989126` (`nombre`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `n_tipo_mantenimiento_articulo` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `articulo_id` INT NOT NULL,
  `nombre` VARCHAR(255) NOT NULL,
  KEY `n_tipo_mantenimiento_articulo_articulo_id_fkey` (`articulo_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS `refresh_token` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `token` VARCHAR(64) NOT NULL,
  `createdAt` DATETIME NOT NULL,
  `expiresAt` DATETIME NOT NULL,
  `revoked` BOOLEAN NOT NULL DEFAULT FALSE,
  `empleadoId` INT NOT NULL,
  `sessionId` VARCHAR(36) NOT NULL,
  UNIQUE KEY `uq_refresh_token_token` (`token`),
  KEY `idx_refresh_token_empleadoId` (`empleadoId`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================
-- Relaciones (FK) tablas nuevas
-- =============================
ALTER TABLE `a_recovery_password_token` ADD CONSTRAINT `FK_E35A23BC952BE730` FOREIGN KEY (`empleadoId`) REFERENCES `c_empleado` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE `c_agenda_minuta` ADD CONSTRAINT `fk_c_agenda_minuta_cliente_id` FOREIGN KEY (`cliente_id`) REFERENCES `e_estructura_cliente` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_agenda_minuta` ADD CONSTRAINT `fk_c_agenda_minuta_corpo_id` FOREIGN KEY (`corpo_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_agenda_minuta` ADD CONSTRAINT `fk_c_agenda_minuta_puesto_id` FOREIGN KEY (`puesto_id`) REFERENCES `e_estructura_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_anexos_quejas` ADD CONSTRAINT `fk_c_anexos_quejas_queja_id` FOREIGN KEY (`queja_id`) REFERENCES `c_maestro_quejas` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_apertura_cierre_puesto` ADD CONSTRAINT `fk_c_apertura_cierre_puesto_cliente_id` FOREIGN KEY (`cliente_id`) REFERENCES `e_estructura_cliente` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_apertura_cierre_puesto` ADD CONSTRAINT `fk_c_apertura_cierre_puesto_corpo_id` FOREIGN KEY (`corpo_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_apertura_cierre_puesto` ADD CONSTRAINT `fk_c_apertura_cierre_puesto_division_id` FOREIGN KEY (`division_id`) REFERENCES `n_division` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_apertura_cierre_puesto` ADD CONSTRAINT `fk_c_apertura_cierre_puesto_puesto_id` FOREIGN KEY (`puesto_id`) REFERENCES `e_estructura_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_archivos_adjuntos_articulo_mantenimiento` ADD CONSTRAINT `fk_c_archivos_ad_art_mant_activo_mantenimiento_id` FOREIGN KEY (`activo_mantenimiento_id`) REFERENCES `c_articulo_mantenimiento` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_archivos_aporte_incidente` ADD CONSTRAINT `fk_c_archivos_aporte_incidente_contribucion_id` FOREIGN KEY (`contribucion_id`) REFERENCES `c_contribucion_incidente` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_archivos_incidente` ADD CONSTRAINT `fk_c_archivos_incidente_incidente_id` FOREIGN KEY (`incidente_id`) REFERENCES `c_incidente` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_articulo_mantenimiento` ADD CONSTRAINT `fk_c_articulo_mantenimiento_articulo_asignado_id` FOREIGN KEY (`articulo_asignado_id`) REFERENCES `e_estructura_articulo_corpo_puesto_entrega` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_articulo_mantenimiento` ADD CONSTRAINT `fk_c_articulo_mantenimiento_articulo_plan_id` FOREIGN KEY (`articulo_plan_id`) REFERENCES `e_estructura_articulo_corpo_puesto_plan` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_boleta_apreciacion_vulnerabilidad` ADD CONSTRAINT `fk_c_boleta_apreciacion_vulnerabilidad_cliente_id` FOREIGN KEY (`cliente_id`) REFERENCES `e_estructura_cliente` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_boleta_apreciacion_vulnerabilidad` ADD CONSTRAINT `fk_c_boleta_apreciacion_vulnerabilidad_corpo_id` FOREIGN KEY (`corpo_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_boleta_apreciacion_vulnerabilidad` ADD CONSTRAINT `fk_c_boleta_apreciacion_vulnerabilidad_puesto_id` FOREIGN KEY (`puesto_id`) REFERENCES `e_estructura_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_checklist_supervision` ADD CONSTRAINT `fk_c_checklist_supervision_cliente_id` FOREIGN KEY (`cliente_id`) REFERENCES `e_estructura_cliente` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_checklist_supervision` ADD CONSTRAINT `fk_c_checklist_supervision_corpo_id` FOREIGN KEY (`corpo_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_checklist_supervision` ADD CONSTRAINT `fk_c_checklist_supervision_puesto_id` FOREIGN KEY (`puesto_id`) REFERENCES `e_estructura_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_imagenes_checklist_supervision` ADD CONSTRAINT `fk_c_imagenes_checklist_supervision_checklist_id` FOREIGN KEY (`checklist_id`) REFERENCES `c_checklist_supervision` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_contribucion_incidente` ADD CONSTRAINT `fk_c_contribucion_incidente_empleado_id` FOREIGN KEY (`empleado_id`) REFERENCES `c_empleado` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_contribucion_incidente` ADD CONSTRAINT `fk_c_contribucion_incidente_incidente_id` FOREIGN KEY (`incidente_id`) REFERENCES `c_incidente` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_empleado_almuerzo` ADD CONSTRAINT `fk_c_empleado_almuerzo_empleadoId` FOREIGN KEY (`empleadoId`) REFERENCES `c_empleado` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_empleado_notification` ADD CONSTRAINT `fk_c_empleado_notification_empleadoId` FOREIGN KEY (`empleadoId`) REFERENCES `c_empleado` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_empleado_notification` ADD CONSTRAINT `fk_c_empleado_notification_notificationId` FOREIGN KEY (`notificationId`) REFERENCES `c_notifications` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_encuesta_cliente` ADD CONSTRAINT `fk_c_encuesta_cliente_cliente_id` FOREIGN KEY (`cliente_id`) REFERENCES `e_estructura_cliente` (`id`) ON DELETE NO ACTION;
ALTER TABLE `c_encuesta_cliente` ADD CONSTRAINT `fk_c_encuesta_cliente_corpo_id` FOREIGN KEY (`corpo_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE NO ACTION;
ALTER TABLE `c_encuesta_cliente` ADD CONSTRAINT `fk_c_encuesta_cliente_division_id` FOREIGN KEY (`division_id`) REFERENCES `n_division` (`id`) ON DELETE NO ACTION;
ALTER TABLE `c_encuesta_cliente` ADD CONSTRAINT `fk_c_encuesta_cliente_empresa_id` FOREIGN KEY (`empresa_id`) REFERENCES `e_estructura_empresa` (`id`) ON DELETE NO ACTION;
ALTER TABLE `c_encuesta_cliente` ADD CONSTRAINT `fk_c_encuesta_cliente_puesto_id` FOREIGN KEY (`puesto_id`) REFERENCES `e_estructura_puesto` (`id`) ON DELETE NO ACTION;
ALTER TABLE `c_encuesta_cliente` ADD CONSTRAINT `fk_c_encuesta_cliente_responsable_id` FOREIGN KEY (`responsable_id`) REFERENCES `c_empleado` (`id`) ON DELETE NO ACTION;
ALTER TABLE `c_evaluacion_empleado` ADD CONSTRAINT `fk_c_evaluacion_empleado_corpo_id` FOREIGN KEY (`corpo_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE NO ACTION;
ALTER TABLE `c_evaluacion_empleado` ADD CONSTRAINT `fk_c_evaluacion_empleado_plaza_id` FOREIGN KEY (`plaza_id`) REFERENCES `e_estructura_plazas` (`id`) ON DELETE NO ACTION;
ALTER TABLE `c_evaluacion_empleado` ADD CONSTRAINT `fk_c_evaluacion_empleado_puesto_id` FOREIGN KEY (`puesto_id`) REFERENCES `e_estructura_puesto` (`id`) ON DELETE NO ACTION;
ALTER TABLE `c_imagenes_acta_entrega_producto` ADD CONSTRAINT `fk_c_imagenes_acta_entrega_producto_acta_id` FOREIGN KEY (`acta_id`) REFERENCES `c_acta_entre_producto` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_imagenes_apertura_cierre_puesto` ADD CONSTRAINT `fk_c_imagenes_apertura_cierre_puesto_apetura_cierre_id` FOREIGN KEY (`apetura_cierre_id`) REFERENCES `c_apertura_cierre_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_imagenes_control_asistencia` ADD CONSTRAINT `fk_c_imagenes_control_asistencia_control_id` FOREIGN KEY (`control_id`) REFERENCES `c_control_asistencia` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_imagenes_registro_induccion_general` ADD CONSTRAINT `fk_c_imagenes_registro_induccion_general_registro_id` FOREIGN KEY (`registro_id`) REFERENCES `c_registro_induccion_general` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_imagenes_vehiculos_corporativos` ADD CONSTRAINT `fk_c_imagenes_vehiculos_corporativos_vehiculo_id` FOREIGN KEY (`vehiculo_id`) REFERENCES `c_vehiculos_corporativos` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_incidente` ADD CONSTRAINT `fk_c_incidente_clasificacion` FOREIGN KEY (`clasificacion`) REFERENCES `n_clasificacion_incidente` (`id`) ON DELETE NO ACTION;
ALTER TABLE `c_incidente` ADD CONSTRAINT `fk_c_incidente_cliente_id` FOREIGN KEY (`cliente_id`) REFERENCES `e_estructura_cliente` (`id`) ON DELETE NO ACTION;
ALTER TABLE `c_incidente` ADD CONSTRAINT `fk_c_incidente_corpo_id` FOREIGN KEY (`corpo_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE NO ACTION;
ALTER TABLE `c_incidente` ADD CONSTRAINT `fk_c_incidente_ejecutivo_cuenta` FOREIGN KEY (`ejecutivo_cuenta`) REFERENCES `n_ejecutivo_cuenta` (`id`) ON DELETE NO ACTION;
ALTER TABLE `c_incidente` ADD CONSTRAINT `fk_c_incidente_empresa_id` FOREIGN KEY (`empresa_id`) REFERENCES `e_estructura_empresa` (`id`) ON DELETE NO ACTION;
ALTER TABLE `c_mantenimiento_vehiculos_corporativos` ADD CONSTRAINT `fk_c_mantenimiento_vehiculos_corporativos_vehiculo_id` FOREIGN KEY (`vehiculo_id`) REFERENCES `c_vehiculos_corporativos` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_movimientos_articulo_mantenimiento` ADD CONSTRAINT `fk_c_movimientos_articulo_mantenimiento_articulo_asignado_id` FOREIGN KEY (`articulo_asignado_id`) REFERENCES `e_estructura_articulo_corpo_puesto_entrega` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_movimientos_articulo_mantenimiento` ADD CONSTRAINT `fk_c_movimientos_articulo_mantenimiento_articulo_plan_id` FOREIGN KEY (`articulo_plan_id`) REFERENCES `e_estructura_articulo_corpo_puesto_plan` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_plaza_notification` ADD CONSTRAINT `fk_c_plaza_notification_notificationId` FOREIGN KEY (`notificationId`) REFERENCES `c_notifications` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_plaza_notification` ADD CONSTRAINT `fk_c_plaza_notification_plazaId` FOREIGN KEY (`plazaId`) REFERENCES `e_estructura_plazas` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_producto_no_conforme` ADD CONSTRAINT `fk_c_producto_no_conforme_cliente_id` FOREIGN KEY (`cliente_id`) REFERENCES `e_estructura_cliente` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_producto_no_conforme` ADD CONSTRAINT `fk_c_producto_no_conforme_corpo_id` FOREIGN KEY (`corpo_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_puesto_notas` ADD CONSTRAINT `fk_c_puesto_notas_puesto_id` FOREIGN KEY (`puesto_id`) REFERENCES `e_estructura_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_imagenes_puesto_notas` ADD CONSTRAINT `fk_c_imagenes_puesto_notas_nota_id` FOREIGN KEY (`nota_id`) REFERENCES `c_puesto_notas` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_registro_induccion_general` ADD CONSTRAINT `fk_c_registro_induccion_general_cliente_id` FOREIGN KEY (`cliente_id`) REFERENCES `e_estructura_cliente` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_registro_induccion_general` ADD CONSTRAINT `fk_c_registro_induccion_general_corpo_id` FOREIGN KEY (`corpo_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_registro_induccion_general` ADD CONSTRAINT `fk_c_registro_induccion_general_empresa_id` FOREIGN KEY (`empresa_id`) REFERENCES `e_estructura_empresa` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_solicitud_permiso` ADD CONSTRAINT `fk_c_solicitud_permiso_empleado_id` FOREIGN KEY (`empleado_id`) REFERENCES `c_empleado` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_archivos_solicitud_permiso` ADD CONSTRAINT `fk_c_archivos_solicitud_permiso_solicitud_id` FOREIGN KEY (`solicitud_id`) REFERENCES `c_solicitud_permiso` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_usos_vehiculos_corporativos` ADD CONSTRAINT `fk_c_usos_vehiculos_corporativos_vehiculo_id` FOREIGN KEY (`vehiculo_id`) REFERENCES `c_vehiculos_corporativos` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_vehiculos_corporativos` ADD CONSTRAINT `fk_c_vehiculos_corporativos_cliente_id` FOREIGN KEY (`cliente_id`) REFERENCES `e_estructura_cliente` (`id`) ON DELETE CASCADE;
ALTER TABLE `c_vehiculos_corporativos` ADD CONSTRAINT `fk_c_vehiculos_corporativos_sucursal_id` FOREIGN KEY (`sucursal_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_actividades_puesto` ADD CONSTRAINT `fk_e_actividades_puesto_actividad_id` FOREIGN KEY (`actividad_id`) REFERENCES `e_actividades` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_actividades_puesto` ADD CONSTRAINT `fk_e_actividades_puesto_puesto_id` FOREIGN KEY (`puesto_id`) REFERENCES `e_estructura_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_actividades_puesto_plaza` ADD CONSTRAINT `fk_e_actividades_puesto_plaza_actividad_puesto_id` FOREIGN KEY (`actividad_puesto_id`) REFERENCES `e_actividades_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_actividades_puesto_plaza` ADD CONSTRAINT `fk_e_actividades_puesto_plaza_plaza_id` FOREIGN KEY (`plaza_id`) REFERENCES `e_estructura_plazas` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_activo_visitante` ADD CONSTRAINT `FK_BB503B25992BE739` FOREIGN KEY (`visitante_id`) REFERENCES `e_registro_personas` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_activo_visitante` ADD CONSTRAINT `FK_BB503B25993BE739` FOREIGN KEY (`tipo_id`) REFERENCES `n_tipo_activo_visitas` (`id`) ON DELETE NO ACTION;
ALTER TABLE `e_archivos_manual_puesto` ADD CONSTRAINT `fk_e_archivos_manual_puesto_manual_puesto_id` FOREIGN KEY (`manual_puesto_id`) REFERENCES `e_manual_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_archivos_producto_no_conforme` ADD CONSTRAINT `fk_e_archivos_producto_no_conforme_pnc_id` FOREIGN KEY (`pnc_id`) REFERENCES `c_producto_no_conforme` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_capacitacion_empleado` ADD CONSTRAINT `fk_e_capacitacion_empleado_capacitacion_id` FOREIGN KEY (`capacitacion_id`) REFERENCES `e_registro_capacitaciones` (`id`) ON DELETE NO ACTION;
ALTER TABLE `e_capacitacion_empleado` ADD CONSTRAINT `fk_e_capacitacion_empleado_empleado_id` FOREIGN KEY (`empleado_id`) REFERENCES `c_empleado` (`id`) ON DELETE NO ACTION;
ALTER TABLE `e_capacitacion_puesto` ADD CONSTRAINT `fk_e_capacitacion_puesto_capacitacion_id` FOREIGN KEY (`capacitacion_id`) REFERENCES `e_registro_capacitaciones` (`id`) ON DELETE NO ACTION;
ALTER TABLE `e_capacitacion_puesto` ADD CONSTRAINT `fk_e_capacitacion_puesto_puesto_id` FOREIGN KEY (`puesto_id`) REFERENCES `e_estructura_puesto` (`id`) ON DELETE NO ACTION;
ALTER TABLE `e_control_documento_entregado_cliente` ADD CONSTRAINT `fk_e_control_documento_entregado_cliente_cliente_id` FOREIGN KEY (`cliente_id`) REFERENCES `e_estructura_cliente` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_control_documento_entregado_cliente` ADD CONSTRAINT `fk_e_control_documento_entregado_cliente_corpo_id` FOREIGN KEY (`corpo_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_empleado_visualizacion_archivos` ADD CONSTRAINT `fk_e_empleado_visualizacion_archivos_visualizacion_id` FOREIGN KEY (`visualizacion_id`) REFERENCES `e_empleado_visualizacion_manual_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_empleado_visualizacion_manual_puesto` ADD CONSTRAINT `fk_e_empleado_visualizacion_manual_puesto_empleado_id` FOREIGN KEY (`empleado_id`) REFERENCES `c_empleado` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_empleado_visualizacion_manual_puesto` ADD CONSTRAINT `fk_e_empleado_visualizacion_manual_puesto_manual_puesto_id` FOREIGN KEY (`manual_puesto_id`) REFERENCES `e_manual_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_llave` ADD CONSTRAINT `fk_e_llave_cliente_id` FOREIGN KEY (`cliente_id`) REFERENCES `e_estructura_cliente` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_llave` ADD CONSTRAINT `fk_e_llave_corpo_id` FOREIGN KEY (`corpo_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_llave` ADD CONSTRAINT `fk_e_llave_puesto_id` FOREIGN KEY (`puesto_id`) REFERENCES `e_estructura_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_llave_en_llavero` ADD CONSTRAINT `fk_e_llave_en_llavero_llave_id` FOREIGN KEY (`llave_id`) REFERENCES `e_llave` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_llave_en_llavero` ADD CONSTRAINT `fk_e_llave_en_llavero_llavero_id` FOREIGN KEY (`llavero_id`) REFERENCES `e_llavero` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_llavero` ADD CONSTRAINT `fk_e_llavero_cliente_id` FOREIGN KEY (`cliente_id`) REFERENCES `e_estructura_cliente` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_llavero` ADD CONSTRAINT `fk_e_llavero_corpo_id` FOREIGN KEY (`corpo_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_llavero` ADD CONSTRAINT `fk_e_llavero_puesto_id` FOREIGN KEY (`puesto_id`) REFERENCES `e_estructura_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_movimiento_llave` ADD CONSTRAINT `fk_e_movimiento_llave_llave_id` FOREIGN KEY (`llave_id`) REFERENCES `e_llave` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_movimiento_llavero` ADD CONSTRAINT `fk_e_movimiento_llavero_llavero_id` FOREIGN KEY (`llavero_id`) REFERENCES `e_llavero` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_mutuos_acuerdos` ADD CONSTRAINT `fk_e_mutuos_acuerdos_cliente_id` FOREIGN KEY (`cliente_id`) REFERENCES `e_estructura_cliente` (`id`) ON DELETE NO ACTION;
ALTER TABLE `e_mutuos_acuerdos` ADD CONSTRAINT `fk_e_mutuos_acuerdos_corpo_id` FOREIGN KEY (`corpo_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE NO ACTION;
ALTER TABLE `e_mutuos_acuerdos` ADD CONSTRAINT `fk_e_mutuos_acuerdos_ejecutivo_cuenta` FOREIGN KEY (`ejecutivo_cuenta`) REFERENCES `n_ejecutivo_cuenta` (`id`) ON DELETE NO ACTION;
ALTER TABLE `e_puestos_manual_puesto` ADD CONSTRAINT `fk_e_puestos_manual_puesto_manual_puesto_id` FOREIGN KEY (`manual_puesto_id`) REFERENCES `e_manual_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_puestos_manual_puesto` ADD CONSTRAINT `fk_e_puestos_manual_puesto_puesto_id` FOREIGN KEY (`puesto_id`) REFERENCES `e_estructura_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_registro_capacitaciones` ADD CONSTRAINT `fk_e_registro_capacitaciones_cliente_id` FOREIGN KEY (`cliente_id`) REFERENCES `e_estructura_cliente` (`id`) ON DELETE NO ACTION;
ALTER TABLE `e_registro_capacitaciones` ADD CONSTRAINT `fk_e_registro_capacitaciones_corpo_id` FOREIGN KEY (`corpo_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE NO ACTION;
ALTER TABLE `e_registro_capacitaciones` ADD CONSTRAINT `fk_e_registro_capacitaciones_empresa_id` FOREIGN KEY (`empresa_id`) REFERENCES `e_estructura_empresa` (`id`) ON DELETE NO ACTION;
ALTER TABLE `e_registro_entrega_puesto` ADD CONSTRAINT `fk_e_registro_entrega_puesto_cliente_id` FOREIGN KEY (`cliente_id`) REFERENCES `e_estructura_cliente` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_registro_entrega_puesto` ADD CONSTRAINT `fk_e_registro_entrega_puesto_corpo_id` FOREIGN KEY (`corpo_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_registro_entrega_puesto` ADD CONSTRAINT `fk_e_registro_entrega_puesto_puesto_id` FOREIGN KEY (`puesto_id`) REFERENCES `e_estructura_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_registro_personas` ADD CONSTRAINT `FK_BB503B25992BE730` FOREIGN KEY (`responsable_id`) REFERENCES `c_empleado` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_registro_personas` ADD CONSTRAINT `FK_BB603B25953BE730` FOREIGN KEY (`cliente_id`) REFERENCES `e_estructura_cliente` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_registro_personas` ADD CONSTRAINT `FK_BB703B25954BE730` FOREIGN KEY (`corpo_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_registro_personas` ADD CONSTRAINT `FK_BB803B25955BE730` FOREIGN KEY (`puesto_id`) REFERENCES `e_estructura_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_registro_vehiculos` ADD CONSTRAINT `FK_BB503B25952BE730` FOREIGN KEY (`responsable_id`) REFERENCES `c_empleado` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_registro_vehiculos` ADD CONSTRAINT `FK_BB503B25953BE730` FOREIGN KEY (`cliente_id`) REFERENCES `e_estructura_cliente` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_registro_vehiculos` ADD CONSTRAINT `FK_BB503B25954BE730` FOREIGN KEY (`corpo_id`) REFERENCES `e_estructura_sucursal` (`id`) ON DELETE CASCADE;
ALTER TABLE `e_registro_vehiculos` ADD CONSTRAINT `FK_BB503B25955BE730` FOREIGN KEY (`puesto_id`) REFERENCES `e_estructura_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `n_tipo_mantenimiento_articulo` ADD CONSTRAINT `fk_n_tipo_mantenimiento_articulo_articulo_id` FOREIGN KEY (`articulo_id`) REFERENCES `n_articulo_corpo_puesto` (`id`) ON DELETE CASCADE;
ALTER TABLE `refresh_token` ADD CONSTRAINT `fk_refresh_token_empleadoId` FOREIGN KEY (`empleadoId`) REFERENCES `c_empleado` (`id`) ON DELETE CASCADE;

SET FOREIGN_KEY_CHECKS = 1;
