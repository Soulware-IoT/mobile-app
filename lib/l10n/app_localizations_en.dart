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
  String get retry => 'Retry';

  @override
  String get cancel => 'CANCEL';

  @override
  String get saveChanges => 'SAVE CHANGES';

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

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailRequired => 'Enter your email';

  @override
  String get authEmailInvalid => 'Invalid email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordRequired => 'Enter your password';

  @override
  String get authPasswordCreateRequired => 'Enter a password';

  @override
  String get authPasswordMinLength => 'At least 6 characters';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authConfirmPasswordRequired => 'Confirm your password';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get loginCaption => 'Sign in to continue';

  @override
  String get loginButton => 'Sign in';

  @override
  String get registerCaption => 'Create your account';

  @override
  String get registerButton => 'Create account';

  @override
  String get noAccountQuestion => 'Don\'t have an account? ';

  @override
  String get registerLink => 'Sign up';

  @override
  String get haveAccountQuestion => 'Already have an account? ';

  @override
  String get loginLink => 'Sign in';

  @override
  String get oauthDividerOr => 'or continue with';

  @override
  String get devicesTitle => 'Devices';

  @override
  String get devicesInventoryTitle => 'Device inventory';

  @override
  String get devicesEmpty => 'No devices.';

  @override
  String get devicesLoadError => 'Could not load devices.';

  @override
  String get devicesSelectOrganization =>
      'Select an organization to see its devices.';

  @override
  String get devicesSummaryDevices => 'Devices';

  @override
  String get devicesSummaryActive => 'Active';

  @override
  String get devicesSummaryEdge => 'Edge gateway';

  @override
  String get devicesSummaryNoGateway => 'No gateway';

  @override
  String get deviceThresholdsTitle => 'Thresholds';

  @override
  String get deviceThresholdsEmpty => 'No thresholds configured';

  @override
  String get deviceTempWarn => 'Temp. warning';

  @override
  String get deviceTempCrit => 'Temp. critical';

  @override
  String get deviceGasWarn => 'Gas warning';

  @override
  String get deviceGasCrit => 'Gas critical';

  @override
  String get deviceMetadataTitle => 'Information';

  @override
  String get deviceStatusFieldLabel => 'Status';

  @override
  String get deviceCreatedLabel => 'Created';

  @override
  String get deviceUpdatedLabel => 'Updated';

  @override
  String get deviceStatusProvisioned => 'Provisioned';

  @override
  String get deviceStatusActive => 'Active';

  @override
  String get deviceStatusInactive => 'Inactive';

  @override
  String get editOrganizationTooltip => 'Edit organization';

  @override
  String get myInvitationsTooltip => 'My invitations';

  @override
  String get membersManagementTitle => 'Members management';

  @override
  String get addMember => 'Add member';

  @override
  String get noMembers => 'No members in this organization yet.';

  @override
  String get pendingInvitations => 'Pending invitations';

  @override
  String get organizationLoadError => 'Could not load the organization.';

  @override
  String get myInvitationsTitle => 'My invitations';

  @override
  String get noInvitations => 'You have no invitations.';

  @override
  String get myInvitationsLoadError => 'Could not load your invitations.';

  @override
  String get memberDetailsTitle => 'Member details';

  @override
  String get editPermissions => 'Edit permissions';

  @override
  String get backToOrganization => 'Back to organization';

  @override
  String get accessPermissionsHeader => 'ACCESS PERMISSIONS';

  @override
  String get permissionSecurity => 'Security';

  @override
  String get permissionOrganization => 'Organizations';

  @override
  String get permissionInternalControl => 'Internal control';

  @override
  String get permissionsUpdated => 'Permissions updated';

  @override
  String get organizationNotDetermined =>
      'Could not determine the organization';

  @override
  String get editOrganizationTitle => 'Edit organization';

  @override
  String get organizationUpdated => 'Organization updated';

  @override
  String get uploadNewImage => 'Upload new image';

  @override
  String get organizationNameLabel => 'Organization name';

  @override
  String get organizationNameRequired => 'Enter the organization name';

  @override
  String get physicalLocationLabel => 'Physical location / Address';

  @override
  String get directionsNotesLabel => 'Directions & access notes';

  @override
  String get inviteMemberTitle => 'Invite member';

  @override
  String get invitationSent => 'Invitation sent';

  @override
  String get inviteEmailRequired => 'Enter an email';

  @override
  String get invite => 'Invite';

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get invitationToOrganization => 'Organization invitation';

  @override
  String get addressHeader => 'ADDRESS';

  @override
  String get noAddressRegistered => 'No address on file';

  @override
  String get referencePointHeader => 'REFERENCE POINT';

  @override
  String get invitationStatusPending => 'Pending';

  @override
  String get invitationStatusAccepted => 'Accepted';

  @override
  String get invitationStatusDeclined => 'Declined';

  @override
  String get processesTitle => 'Processes';

  @override
  String get processesComingSoon => 'Processes — coming soon';
}
