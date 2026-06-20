// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get errorNoConnection => 'No internet connection';

  @override
  String get errorGatewayNotConfigured => 'API gateway URL is not configured';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get signOut => 'Sign out';

  @override
  String get myOrganizationsTitle => 'My organizations';

  @override
  String get noOrganizationsDrawer => 'You don\'t belong to any organization';

  @override
  String get emptyOrganizations => 'You don\'t belong to any organization yet.';

  @override
  String get invitationAccepted => 'Invitation accepted';

  @override
  String get invitationDeclined => 'Invitation declined';
}
