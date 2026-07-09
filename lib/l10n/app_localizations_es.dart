// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get errorNoConnection => 'Sin conexión a internet';

  @override
  String get errorGatewayNotConfigured =>
      'La URL del API gateway no está configurada';

  @override
  String get errorGeneric => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get retry => 'Reintentar';

  @override
  String get cancel => 'CANCELAR';

  @override
  String get delete => 'ELIMINAR';

  @override
  String get remove => 'QUITAR';

  @override
  String get saveChanges => 'GUARDAR CAMBIOS';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get myOrganizationsTitle => 'Mis organizaciones';

  @override
  String get noOrganizationsDrawer => 'No perteneces a ninguna organización';

  @override
  String get emptyOrganizations =>
      'Todavía no perteneces a ninguna organización.';

  @override
  String get invitationAccepted => 'Invitación aceptada';

  @override
  String get invitationDeclined => 'Invitación rechazada';

  @override
  String get authEmailLabel => 'Correo electrónico';

  @override
  String get authEmailRequired => 'Ingresa tu correo';

  @override
  String get authEmailInvalid => 'Correo inválido';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authPasswordRequired => 'Ingresa tu contraseña';

  @override
  String get authPasswordCreateRequired => 'Ingresa una contraseña';

  @override
  String get authPasswordMinLength => 'Mínimo 6 caracteres';

  @override
  String get authConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get authConfirmPasswordRequired => 'Confirma tu contraseña';

  @override
  String get authPasswordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get loginCaption => 'Inicia sesión para continuar';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get registerCaption => 'Crea tu cuenta';

  @override
  String get registerButton => 'Crear cuenta';

  @override
  String get noAccountQuestion => '¿No tienes cuenta? ';

  @override
  String get registerLink => 'Regístrate';

  @override
  String get haveAccountQuestion => '¿Ya tienes cuenta? ';

  @override
  String get loginLink => 'Inicia sesión';

  @override
  String get oauthDividerOr => 'o continúa con';

  @override
  String get devicesTitle => 'Dispositivos';

  @override
  String get devicesInventoryTitle => 'Inventario de dispositivos';

  @override
  String get devicesEmpty => 'No hay dispositivos.';

  @override
  String get claimDeviceTitle => 'Registrar dispositivo';

  @override
  String get claimDeviceIntro =>
      'Ingresa el código impreso en el dispositivo para agregarlo a esta organización.';

  @override
  String get claimDeviceCodeLabel => 'Código del dispositivo';

  @override
  String get claimDeviceCustomThresholds => 'Definir umbrales personalizados';

  @override
  String get claimDeviceDefaultThresholdsHint =>
      'Desactivado usa los valores estándar (35/50 °C, 1000/3000 PPM)';

  @override
  String get claimDeviceSubmit => 'REGISTRAR';

  @override
  String get claimEdgeDeviceTitle => 'Registrar edge gateway';

  @override
  String get claimEdgeDeviceIntro =>
      'Ingresa el código impreso en el edge gateway para agregarlo a esta organización.';

  @override
  String get devicesLoadError => 'No se pudieron cargar los dispositivos.';

  @override
  String get devicesSelectOrganization =>
      'Selecciona una organización para ver sus dispositivos.';

  @override
  String get devicesSummaryDevices => 'Dispositivos';

  @override
  String get devicesSummaryActive => 'Activos';

  @override
  String get devicesSummaryEdge => 'Edge gateway';

  @override
  String get devicesSummaryNoGateway => 'Sin gateway';

  @override
  String get deviceThresholdsTitle => 'Umbrales';

  @override
  String get deviceThresholdsEmpty => 'Sin umbrales configurados';

  @override
  String get deviceTempWarn => 'Temp. aviso';

  @override
  String get deviceTempCrit => 'Temp. crítica';

  @override
  String get deviceGasWarn => 'Gas aviso';

  @override
  String get deviceGasCrit => 'Gas crítico';

  @override
  String get deviceMetadataTitle => 'Información';

  @override
  String get deviceStatusFieldLabel => 'Estado';

  @override
  String get deviceCreatedLabel => 'Creado';

  @override
  String get deviceUpdatedLabel => 'Actualizado';

  @override
  String get deviceStatusProvisioned => 'Aprovisionado';

  @override
  String get deviceStatusActive => 'Activo';

  @override
  String get deviceStatusInactive => 'Inactivo';

  @override
  String get editOrganizationTooltip => 'Editar organización';

  @override
  String get myInvitationsTooltip => 'Mis invitaciones';

  @override
  String get membersManagementTitle => 'Gestión de miembros';

  @override
  String get addMember => 'Agregar miembro';

  @override
  String get noMembers => 'Aún no hay miembros en esta organización.';

  @override
  String get pendingInvitations => 'Invitaciones pendientes';

  @override
  String get organizationLoadError => 'No se pudo cargar la organización.';

  @override
  String get myInvitationsTitle => 'Mis invitaciones';

  @override
  String get noInvitations => 'No tienes invitaciones.';

  @override
  String get myInvitationsLoadError =>
      'No se pudieron cargar tus invitaciones.';

  @override
  String get memberDetailsTitle => 'Detalles del miembro';

  @override
  String get editPermissions => 'Editar permisos';

  @override
  String get backToOrganization => 'Volver a la organización';

  @override
  String get accessPermissionsHeader => 'PERMISOS DE ACCESO';

  @override
  String get permissionSecurity => 'Seguridad';

  @override
  String get permissionOrganization => 'Organizaciones';

  @override
  String get permissionInternalControl => 'Control interno';

  @override
  String get permissionsUpdated => 'Permisos actualizados';

  @override
  String get organizationNotDetermined =>
      'No se pudo determinar la organización';

  @override
  String get createOrganizationTitle => 'Crear organización';

  @override
  String get organizationCreated => 'Organización creada';

  @override
  String get deleteOrganizationTitle => 'Eliminar organización';

  @override
  String get deleteOrganizationConfirmTitle => '¿Eliminar organización?';

  @override
  String deleteOrganizationConfirmBody(String name) {
    return 'Esto elimina permanentemente \"$name\" y todo su contenido. No se puede deshacer.';
  }

  @override
  String get organizationDeleted => 'Organización eliminada';

  @override
  String get removeMember => 'Quitar miembro';

  @override
  String get removeMemberConfirmTitle => '¿Quitar miembro?';

  @override
  String removeMemberConfirmBody(String name) {
    return '$name perderá el acceso a esta organización.';
  }

  @override
  String get editOrganizationTitle => 'Editar organización';

  @override
  String get organizationUpdated => 'Organización actualizada';

  @override
  String get uploadNewImage => 'Subir nueva imagen';

  @override
  String get organizationNameLabel => 'Nombre de la organización';

  @override
  String get organizationNameRequired => 'Ingresa el nombre de la organización';

  @override
  String get physicalLocationLabel => 'Ubicación física / Dirección';

  @override
  String get directionsNotesLabel => 'Indicaciones y notas de acceso';

  @override
  String get inviteMemberTitle => 'Invitar miembro';

  @override
  String get invitationSent => 'Invitación enviada';

  @override
  String get inviteEmailRequired => 'Ingresa un correo';

  @override
  String get invite => 'Invitar';

  @override
  String get decline => 'Declinar';

  @override
  String get accept => 'Aceptar';

  @override
  String get invitationToOrganization => 'Invitación a una organización';

  @override
  String invitedByLabel(String name) {
    return 'Invitado por $name';
  }

  @override
  String get addressHeader => 'DIRECCIÓN';

  @override
  String get noAddressRegistered => 'Sin dirección registrada';

  @override
  String get referencePointHeader => 'PUNTO DE REFERENCIA';

  @override
  String get invitationStatusPending => 'Pendiente';

  @override
  String get invitationStatusAccepted => 'Aceptada';

  @override
  String get invitationStatusDeclined => 'Rechazada';

  @override
  String get processesTitle => 'Procesos';

  @override
  String get confirm => 'CONFIRMAR';

  @override
  String get create => 'CREAR';

  @override
  String get deviceRenameTooltip => 'Renombrar dispositivo';

  @override
  String get deviceRenameTitle => 'Renombrar dispositivo';

  @override
  String get deviceNameLabel => 'Nombre del dispositivo';

  @override
  String get deviceNameRequired => 'Ingresa un nombre';

  @override
  String get deviceControlsTitle => 'Controles operativos';

  @override
  String get deviceControlsProvisioned =>
      'Este dispositivo aún no ha sido reclamado, no puede operarse.';

  @override
  String get deviceActivate => 'ACTIVAR DISPOSITIVO';

  @override
  String get deviceDeactivate => 'DETENER DISPOSITIVO';

  @override
  String get deviceActivateConfirmTitle => '¿Activar dispositivo?';

  @override
  String get deviceActivateConfirmBody =>
      'El dispositivo volverá a estar en servicio y el edge volverá a confiar en él.';

  @override
  String get deviceDeactivateConfirmTitle => '¿Detener dispositivo?';

  @override
  String get deviceDeactivateConfirmBody =>
      'El dispositivo quedará deshabilitado y el edge dejará de confiar en él.';

  @override
  String get deviceThresholdsEditTooltip => 'Editar umbrales';

  @override
  String get deviceThresholdCritAboveWarn =>
      'El crítico debe ser mayor que la advertencia';

  @override
  String get edgeRenameTooltip => 'Renombrar edge gateway';

  @override
  String get edgeRenameTitle => 'Renombrar edge gateway';

  @override
  String get edgeControlsProvisioned =>
      'Este edge gateway aún no ha sido reclamado, no puede operarse.';

  @override
  String get edgeActivate => 'ACTIVAR EDGE GATEWAY';

  @override
  String get edgeDeactivate => 'DETENER EDGE GATEWAY';

  @override
  String get edgeActivateConfirmTitle => '¿Activar edge gateway?';

  @override
  String get edgeActivateConfirmBody =>
      'El edge gateway volverá a estar en servicio y podrá reenviar lecturas de sus dispositivos.';

  @override
  String get edgeDeactivateConfirmTitle => '¿Detener edge gateway?';

  @override
  String get edgeDeactivateConfirmBody =>
      'El edge gateway quedará deshabilitado y dejará de reenviar lecturas de sus dispositivos.';

  @override
  String get processesHeaderLabel => 'CONTROL INTERNO';

  @override
  String get processesSectionProcesses => 'Procesos de control';

  @override
  String get processesSectionFormats => 'Formatos de documento';

  @override
  String get processesRecentLogs => 'REGISTROS RECIENTES';

  @override
  String get processesEmpty => 'Aún no hay procesos de control.';

  @override
  String get processesCreateFirst =>
      'Crea el primer proceso para empezar a llevar el control interno.';

  @override
  String get processesNewProcess => 'Nuevo proceso';

  @override
  String get processesProcessNameLabel => 'Nombre del proceso';

  @override
  String get processesNameRequired => 'Ingresa un nombre';

  @override
  String get processesNewFormat => 'Nuevo formato';

  @override
  String get processesFormatNameLabel => 'Nombre del formato';

  @override
  String get processesSampleFields => 'Empezar con campos de ejemplo';

  @override
  String get processesNoFormats => 'Este proceso aún no tiene formatos.';

  @override
  String get processesNoRegistries => 'Aún no hay registros.';

  @override
  String get processesRegistryCreated => 'Registro guardado';

  @override
  String get processesFormatNotActive =>
      'El formato debe estar activo para llenar registros.';

  @override
  String get formatStatusDraft => 'Borrador';

  @override
  String get formatStatusActive => 'Activo';

  @override
  String get formatStatusSuspended => 'Suspendido';

  @override
  String get formatStatusCeased => 'Cesado';

  @override
  String get formatActionActivate => 'Activar';

  @override
  String get formatActionSuspend => 'Suspender';

  @override
  String get formatActionResume => 'Reanudar';

  @override
  String get formatActionCease => 'Cesar';

  @override
  String get newRegistryTitle => 'Nuevo registro';

  @override
  String get registrySubmit => 'GUARDAR REGISTRO';

  @override
  String get fieldDateHint => 'Selecciona una fecha';

  @override
  String get validationRequired => 'Obligatorio';

  @override
  String get validationNumberRequired => 'Ingresa un número válido';

  @override
  String get validationNumberInteger => 'Debe ser un número entero';

  @override
  String validationNumberMin(String min) {
    return 'Debe ser al menos $min';
  }

  @override
  String validationNumberMax(String max) {
    return 'Debe ser como máximo $max';
  }

  @override
  String validationTextMinLength(String min) {
    return 'Mínimo $min caracteres';
  }

  @override
  String validationTextMaxLength(String max) {
    return 'Máximo $max caracteres';
  }

  @override
  String get validationPattern => 'Formato inválido';

  @override
  String get validationSelectRequired => 'Selecciona una opción';

  @override
  String get subscriptionTitle => 'Suscripción';

  @override
  String get subscriptionCurrentPlanLabel => 'PLAN ACTUAL';

  @override
  String get subscriptionPlanFree => 'Gratis';

  @override
  String get subscriptionPlanBasic => 'Básico';

  @override
  String get subscriptionPlanProfessional => 'Profesional';

  @override
  String get subscriptionUnlimitedDevices => 'Dispositivos ilimitados';

  @override
  String subscriptionDeviceLimit(int limit) {
    return 'Hasta $limit dispositivos';
  }

  @override
  String subscriptionRenewsOn(String date) {
    return 'Se renueva el $date';
  }

  @override
  String subscriptionOwnedBy(String name) {
    return 'Propiedad de $name';
  }

  @override
  String subscriptionPendingPlanScheduled(String plan, String date) {
    return 'Esta suscripción pasará a $plan el $date.';
  }

  @override
  String get subscriptionCurrentPlanTag => 'Plan actual';

  @override
  String subscriptionPlanMonthlyPrice(String price) {
    return '$price / mes';
  }

  @override
  String get subscriptionUpgradeImmediate =>
      'Se aplica de inmediato con cargo prorrateado';

  @override
  String get subscriptionDowngradeAtPeriodEnd =>
      'Se aplica al final del período actual';

  @override
  String get subscriptionChangePlanTitle => 'Cambiar plan';

  @override
  String get subscriptionDowngrade => 'Bajar a Gratis';

  @override
  String get subscriptionResume => 'Mantener plan actual';

  @override
  String get subscriptionDowngradeConfirmTitle => '¿Bajar a Gratis?';

  @override
  String get subscriptionDowngradeConfirmBody =>
      'Tu plan sigue activo hasta el final del período actual de facturación, luego pasa a Gratis.';

  @override
  String get subscriptionCardLabel => 'Datos de la tarjeta';

  @override
  String get subscriptionCardIncomplete =>
      'Ingresa los datos completos de la tarjeta';

  @override
  String get subscriptionStripeNotConfigured =>
      'Los pagos no están configurados en esta compilación';

  @override
  String get paymentSheetTotalToPay => 'Total a pagar';

  @override
  String get paymentSheetTabCard => 'Tarjeta';

  @override
  String get paymentSheetTabBank => 'Banco';

  @override
  String get paymentSheetCardholderNameLabel => 'Nombre del titular';

  @override
  String get paymentSheetCardholderNameHint => 'Como aparece en la tarjeta';

  @override
  String get paymentSheetCountryLabel => 'País';

  @override
  String get paymentSheetPostalCodeLabel => 'C.P.';

  @override
  String get paymentSheetBankAccountHolderLabel => 'Titular de la cuenta';

  @override
  String get paymentSheetClabeLabel => 'CLABE';

  @override
  String get paymentSheetClabeHint => '18 dígitos';

  @override
  String get paymentSheetClabeInvalid => 'La CLABE debe tener 18 dígitos';

  @override
  String get paymentSheetDirectDebitNotice =>
      'Al confirmar autorizas un cargo por domiciliación a esta cuenta.';

  @override
  String get paymentSheetBankUnavailable =>
      'El pago por transferencia bancaria aún no está disponible. Usa una tarjeta para continuar.';

  @override
  String paymentSheetPayButton(String amount) {
    return 'Pagar $amount';
  }

  @override
  String get paymentSheetSecurityNotice =>
      'Pago cifrado · Procesado por Stripe';

  @override
  String get paymentSheetProcessingTitle => 'Procesando pago…';

  @override
  String get paymentSheetProcessingSubtitle => 'No cierres esta ventana';

  @override
  String get paymentSheetSuccessTitle => '¡Pago exitoso!';

  @override
  String paymentSheetSuccessBody(String amount) {
    return 'Se cobraron $amount. Enviamos el recibo a tu correo.';
  }

  @override
  String get paymentSheetDone => 'Listo';

  @override
  String get paymentSheetCardholderNameRequired =>
      'Ingresa el nombre del titular';

  @override
  String get invoicesTitle => 'Facturas';

  @override
  String get invoicesEmpty => 'Aún no hay facturas';

  @override
  String get invoiceOpenError => 'No se pudo abrir la factura';

  @override
  String get invoiceStatusPaid => 'Pagada';

  @override
  String get invoiceStatusOpen => 'Pendiente';

  @override
  String get invoiceStatusDraft => 'Borrador';

  @override
  String get invoiceStatusVoid => 'Anulada';

  @override
  String get invoiceStatusUncollectible => 'Incobrable';

  @override
  String get liveReadingsTitle => 'Lecturas en vivo';

  @override
  String get liveReadingsSelectDevice =>
      'Selecciona un dispositivo para monitorear';

  @override
  String get liveReadingsNoDevices =>
      'Esta organización aún no tiene dispositivos IoT';

  @override
  String get liveReadingsWaiting => 'Esperando lecturas…';

  @override
  String get liveReadingsReconnecting => 'Reconectando…';

  @override
  String get liveReadingsOnline => 'En línea';

  @override
  String get liveReadingsOffline => 'Desconectado';

  @override
  String get liveReadingsNoSignal => 'Sin señal';

  @override
  String get servoStart => 'Iniciar';

  @override
  String get servoStop => 'Detener';

  @override
  String get chartTemperatureTitle => 'Temperatura (°C)';

  @override
  String get chartGasTitle => 'Gas (PPM)';

  @override
  String get severitySafe => 'Seguro';

  @override
  String get severityWarning => 'Advertencia';

  @override
  String get severityCritical => 'Crítico';
}
