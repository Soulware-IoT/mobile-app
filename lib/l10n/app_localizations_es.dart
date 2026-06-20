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
  String get processesComingSoon => 'Procesos — próximamente';
}
