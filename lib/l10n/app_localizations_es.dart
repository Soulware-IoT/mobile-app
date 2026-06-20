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
  String get signOut => 'Cerrar sesión';

  @override
  String get myOrganizationsTitle => 'Mis organizaciones';

  @override
  String get noOrganizationsDrawer => 'No perteneces a ninguna organización';

  @override
  String get emptyOrganizations =>
      'Todavía no perteneces a ninguna organización.';
}
