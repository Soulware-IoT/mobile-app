import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Shown when a request fails because the device is offline
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNoConnection;

  /// Shown when API_GATEWAY_URL is empty
  ///
  /// In en, this message translates to:
  /// **'API gateway URL is not configured'**
  String get errorGatewayNotConfigured;

  /// Fallback message for unexpected errors
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Generic retry button on error views
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Generic cancel button
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// Save button on edit forms
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// Drawer action to log out
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Drawer section header listing the user's organizations
  ///
  /// In en, this message translates to:
  /// **'My organizations'**
  String get myOrganizationsTitle;

  /// Drawer empty state for the organizations list
  ///
  /// In en, this message translates to:
  /// **'You don\'t belong to any organization'**
  String get noOrganizationsDrawer;

  /// Organization screen empty state when the user has no memberships
  ///
  /// In en, this message translates to:
  /// **'You don\'t belong to any organization yet.'**
  String get emptyOrganizations;

  /// Snackbar shown after accepting an invitation
  ///
  /// In en, this message translates to:
  /// **'Invitation accepted'**
  String get invitationAccepted;

  /// Snackbar shown after declining an invitation
  ///
  /// In en, this message translates to:
  /// **'Invitation declined'**
  String get invitationDeclined;

  /// Email text field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// Validation error when the email field is empty
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEmailRequired;

  /// Validation error when the email is malformed
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get authEmailInvalid;

  /// Password text field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// Login validation error when the password field is empty
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordRequired;

  /// Register validation error when the password field is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get authPasswordCreateRequired;

  /// Register validation error when the password is too short
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get authPasswordMinLength;

  /// Confirm-password text field label
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// Validation error when the confirm-password field is empty
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get authConfirmPasswordRequired;

  /// Validation error when password and confirmation differ
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordsDoNotMatch;

  /// Caption under the brand header on the login screen
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginCaption;

  /// Submit button on the login form
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// Caption under the brand header on the register screen
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerCaption;

  /// Submit button on the register form
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerButton;

  /// Prompt before the sign-up link on the login screen
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccountQuestion;

  /// Link to the register screen
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registerLink;

  /// Prompt before the sign-in link on the register screen
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get haveAccountQuestion;

  /// Link to the login screen
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginLink;

  /// Divider label between the form and the OAuth buttons
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get oauthDividerOr;

  /// App bar title on the Devices tab
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devicesTitle;

  /// Section header for the device list
  ///
  /// In en, this message translates to:
  /// **'Device inventory'**
  String get devicesInventoryTitle;

  /// Empty state when the organization has no devices
  ///
  /// In en, this message translates to:
  /// **'No devices.'**
  String get devicesEmpty;

  /// Title on the devices error view
  ///
  /// In en, this message translates to:
  /// **'Could not load devices.'**
  String get devicesLoadError;

  /// Shown when no organization is selected
  ///
  /// In en, this message translates to:
  /// **'Select an organization to see its devices.'**
  String get devicesSelectOrganization;

  /// Summary tile label for the total device count
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devicesSummaryDevices;

  /// Summary tile label for the active device count
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get devicesSummaryActive;

  /// Summary tile label for the edge gateway status
  ///
  /// In en, this message translates to:
  /// **'Edge gateway'**
  String get devicesSummaryEdge;

  /// Summary value when there is no edge gateway
  ///
  /// In en, this message translates to:
  /// **'No gateway'**
  String get devicesSummaryNoGateway;

  /// Section title for the device thresholds card
  ///
  /// In en, this message translates to:
  /// **'Thresholds'**
  String get deviceThresholdsTitle;

  /// Shown when a device has no thresholds set
  ///
  /// In en, this message translates to:
  /// **'No thresholds configured'**
  String get deviceThresholdsEmpty;

  /// Row label for the temperature warning threshold
  ///
  /// In en, this message translates to:
  /// **'Temp. warning'**
  String get deviceTempWarn;

  /// Row label for the temperature critical threshold
  ///
  /// In en, this message translates to:
  /// **'Temp. critical'**
  String get deviceTempCrit;

  /// Row label for the gas warning threshold
  ///
  /// In en, this message translates to:
  /// **'Gas warning'**
  String get deviceGasWarn;

  /// Row label for the gas critical threshold
  ///
  /// In en, this message translates to:
  /// **'Gas critical'**
  String get deviceGasCrit;

  /// Section title for the device metadata card
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get deviceMetadataTitle;

  /// Row label for the device status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get deviceStatusFieldLabel;

  /// Row label for the device creation date
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get deviceCreatedLabel;

  /// Row label for the device last-updated date
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get deviceUpdatedLabel;

  /// Device status pill: provisioned
  ///
  /// In en, this message translates to:
  /// **'Provisioned'**
  String get deviceStatusProvisioned;

  /// Device status pill: active
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get deviceStatusActive;

  /// Device status pill: inactive
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get deviceStatusInactive;

  /// Tooltip on the edit-organization action
  ///
  /// In en, this message translates to:
  /// **'Edit organization'**
  String get editOrganizationTooltip;

  /// Tooltip on the invitations action
  ///
  /// In en, this message translates to:
  /// **'My invitations'**
  String get myInvitationsTooltip;

  /// Section title for the members list
  ///
  /// In en, this message translates to:
  /// **'Members management'**
  String get membersManagementTitle;

  /// Button to invite a new member
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get addMember;

  /// Empty state for the members list
  ///
  /// In en, this message translates to:
  /// **'No members in this organization yet.'**
  String get noMembers;

  /// Section title for pending invitations
  ///
  /// In en, this message translates to:
  /// **'Pending invitations'**
  String get pendingInvitations;

  /// Title on the organization error view
  ///
  /// In en, this message translates to:
  /// **'Could not load the organization.'**
  String get organizationLoadError;

  /// App bar title on the invitations screen
  ///
  /// In en, this message translates to:
  /// **'My invitations'**
  String get myInvitationsTitle;

  /// Empty state for the invitations list
  ///
  /// In en, this message translates to:
  /// **'You have no invitations.'**
  String get noInvitations;

  /// Title on the invitations error view
  ///
  /// In en, this message translates to:
  /// **'Could not load your invitations.'**
  String get myInvitationsLoadError;

  /// App bar title on the member detail screen
  ///
  /// In en, this message translates to:
  /// **'Member details'**
  String get memberDetailsTitle;

  /// Button / title to edit a member's permissions
  ///
  /// In en, this message translates to:
  /// **'Edit permissions'**
  String get editPermissions;

  /// Button to return to the organization screen
  ///
  /// In en, this message translates to:
  /// **'Back to organization'**
  String get backToOrganization;

  /// Uppercase section header above the permission cards
  ///
  /// In en, this message translates to:
  /// **'ACCESS PERMISSIONS'**
  String get accessPermissionsHeader;

  /// Permission domain: security
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get permissionSecurity;

  /// Permission domain: organizations
  ///
  /// In en, this message translates to:
  /// **'Organizations'**
  String get permissionOrganization;

  /// Permission domain: internal control
  ///
  /// In en, this message translates to:
  /// **'Internal control'**
  String get permissionInternalControl;

  /// Snackbar after saving member permissions
  ///
  /// In en, this message translates to:
  /// **'Permissions updated'**
  String get permissionsUpdated;

  /// Snackbar when the active organization is unknown
  ///
  /// In en, this message translates to:
  /// **'Could not determine the organization'**
  String get organizationNotDetermined;

  /// App bar title on the edit-organization screen
  ///
  /// In en, this message translates to:
  /// **'Edit organization'**
  String get editOrganizationTitle;

  /// Snackbar after saving the organization
  ///
  /// In en, this message translates to:
  /// **'Organization updated'**
  String get organizationUpdated;

  /// Disabled placeholder button for image upload
  ///
  /// In en, this message translates to:
  /// **'Upload new image'**
  String get uploadNewImage;

  /// Label for the organization name field
  ///
  /// In en, this message translates to:
  /// **'Organization name'**
  String get organizationNameLabel;

  /// Validation error when the organization name is empty
  ///
  /// In en, this message translates to:
  /// **'Enter the organization name'**
  String get organizationNameRequired;

  /// Label for the organization address field
  ///
  /// In en, this message translates to:
  /// **'Physical location / Address'**
  String get physicalLocationLabel;

  /// Label for the access notes field
  ///
  /// In en, this message translates to:
  /// **'Directions & access notes'**
  String get directionsNotesLabel;

  /// Title of the invite-member dialog
  ///
  /// In en, this message translates to:
  /// **'Invite member'**
  String get inviteMemberTitle;

  /// Snackbar after sending an invitation
  ///
  /// In en, this message translates to:
  /// **'Invitation sent'**
  String get invitationSent;

  /// Validation error in the invite dialog when the email is empty
  ///
  /// In en, this message translates to:
  /// **'Enter an email'**
  String get inviteEmailRequired;

  /// Submit button in the invite-member dialog
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// Decline an invitation
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// Accept an invitation
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Title of an invitation card
  ///
  /// In en, this message translates to:
  /// **'Organization invitation'**
  String get invitationToOrganization;

  /// Uppercase label for the address row
  ///
  /// In en, this message translates to:
  /// **'ADDRESS'**
  String get addressHeader;

  /// Shown when an organization has no address
  ///
  /// In en, this message translates to:
  /// **'No address on file'**
  String get noAddressRegistered;

  /// Uppercase label for the reference-point row
  ///
  /// In en, this message translates to:
  /// **'REFERENCE POINT'**
  String get referencePointHeader;

  /// Invitation status pill: pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get invitationStatusPending;

  /// Invitation status pill: accepted
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get invitationStatusAccepted;

  /// Invitation status pill: declined
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get invitationStatusDeclined;

  /// App bar title on the Processes tab
  ///
  /// In en, this message translates to:
  /// **'Processes'**
  String get processesTitle;

  /// Generic confirm button on dialogs
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get confirm;

  /// Generic create button on dialogs
  ///
  /// In en, this message translates to:
  /// **'CREATE'**
  String get create;

  /// Tooltip of the pencil icon on the device header
  ///
  /// In en, this message translates to:
  /// **'Rename device'**
  String get deviceRenameTooltip;

  /// Title of the rename-device dialog
  ///
  /// In en, this message translates to:
  /// **'Rename device'**
  String get deviceRenameTitle;

  /// Label of the device name field
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get deviceNameLabel;

  /// Validation error when the device name is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a device name'**
  String get deviceNameRequired;

  /// Section title of the device controls card
  ///
  /// In en, this message translates to:
  /// **'Operational controls'**
  String get deviceControlsTitle;

  /// Shown instead of controls while the device is PROVISIONED
  ///
  /// In en, this message translates to:
  /// **'This device hasn\'t been claimed yet, so it can\'t be operated.'**
  String get deviceControlsProvisioned;

  /// Button that re-activates an inactive device
  ///
  /// In en, this message translates to:
  /// **'ACTIVATE DEVICE'**
  String get deviceActivate;

  /// Button that deactivates an active device
  ///
  /// In en, this message translates to:
  /// **'STOP DEVICE'**
  String get deviceDeactivate;

  /// Confirm dialog title before activating
  ///
  /// In en, this message translates to:
  /// **'Activate device?'**
  String get deviceActivateConfirmTitle;

  /// Confirm dialog body before activating
  ///
  /// In en, this message translates to:
  /// **'The device will come back into service and the edge gateway will trust it again.'**
  String get deviceActivateConfirmBody;

  /// Confirm dialog title before deactivating
  ///
  /// In en, this message translates to:
  /// **'Stop device?'**
  String get deviceDeactivateConfirmTitle;

  /// Confirm dialog body before deactivating
  ///
  /// In en, this message translates to:
  /// **'The device will be disabled and the edge gateway will stop trusting it.'**
  String get deviceDeactivateConfirmBody;

  /// Tooltip of the edit icon on the thresholds card
  ///
  /// In en, this message translates to:
  /// **'Edit thresholds'**
  String get deviceThresholdsEditTooltip;

  /// Validation error when crit <= warn
  ///
  /// In en, this message translates to:
  /// **'Critical must be above warning'**
  String get deviceThresholdCritAboveWarn;

  /// Uppercase section label at the top of the Processes tab
  ///
  /// In en, this message translates to:
  /// **'INTERNAL CONTROL'**
  String get processesHeaderLabel;

  /// Label of the process selector
  ///
  /// In en, this message translates to:
  /// **'Control processes'**
  String get processesSectionProcesses;

  /// Label of the format selector
  ///
  /// In en, this message translates to:
  /// **'Document formats'**
  String get processesSectionFormats;

  /// Uppercase header of the registries list
  ///
  /// In en, this message translates to:
  /// **'RECENT LOGS'**
  String get processesRecentLogs;

  /// Empty state when the org has no processes
  ///
  /// In en, this message translates to:
  /// **'No control processes yet.'**
  String get processesEmpty;

  /// Hint under the empty state
  ///
  /// In en, this message translates to:
  /// **'Create the first process to start tracking internal controls.'**
  String get processesCreateFirst;

  /// Action to create a control process
  ///
  /// In en, this message translates to:
  /// **'New process'**
  String get processesNewProcess;

  /// Label of the process name field
  ///
  /// In en, this message translates to:
  /// **'Process name'**
  String get processesProcessNameLabel;

  /// Validation error when a name field is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get processesNameRequired;

  /// Action to create a format
  ///
  /// In en, this message translates to:
  /// **'New format'**
  String get processesNewFormat;

  /// Label of the format name field
  ///
  /// In en, this message translates to:
  /// **'Format name'**
  String get processesFormatNameLabel;

  /// Checkbox to seed a new format with example fields
  ///
  /// In en, this message translates to:
  /// **'Start with sample fields'**
  String get processesSampleFields;

  /// Empty state when a process has no formats
  ///
  /// In en, this message translates to:
  /// **'This process has no formats yet.'**
  String get processesNoFormats;

  /// Empty state when a format has no registries
  ///
  /// In en, this message translates to:
  /// **'No records filed yet.'**
  String get processesNoRegistries;

  /// Snackbar after filing a registry
  ///
  /// In en, this message translates to:
  /// **'Record saved'**
  String get processesRegistryCreated;

  /// Shown when trying to file into a non-active format
  ///
  /// In en, this message translates to:
  /// **'The format must be active to file new records.'**
  String get processesFormatNotActive;

  /// Format status pill: draft
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get formatStatusDraft;

  /// Format status pill: active
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get formatStatusActive;

  /// Format status pill: suspended
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get formatStatusSuspended;

  /// Format status pill: ceased
  ///
  /// In en, this message translates to:
  /// **'Ceased'**
  String get formatStatusCeased;

  /// Format lifecycle action: activate
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get formatActionActivate;

  /// Format lifecycle action: suspend
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get formatActionSuspend;

  /// Format lifecycle action: resume
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get formatActionResume;

  /// Format lifecycle action: cease (permanent)
  ///
  /// In en, this message translates to:
  /// **'Cease'**
  String get formatActionCease;

  /// App bar title of the fill-format screen
  ///
  /// In en, this message translates to:
  /// **'New record'**
  String get newRegistryTitle;

  /// Submit button of the fill-format screen
  ///
  /// In en, this message translates to:
  /// **'SAVE RECORD'**
  String get registrySubmit;

  /// Hint of a DATE field before a date is picked
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get fieldDateHint;

  /// Generic required-field validation error
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get validationRequired;

  /// Validation error for non-numeric input
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get validationNumberRequired;

  /// Validation error when a decimal is given to an integer field
  ///
  /// In en, this message translates to:
  /// **'Must be a whole number'**
  String get validationNumberInteger;

  /// Validation error below the minimum
  ///
  /// In en, this message translates to:
  /// **'Must be at least {min}'**
  String validationNumberMin(String min);

  /// Validation error above the maximum
  ///
  /// In en, this message translates to:
  /// **'Must be at most {max}'**
  String validationNumberMax(String max);

  /// Validation error below the minimum length
  ///
  /// In en, this message translates to:
  /// **'At least {min} characters'**
  String validationTextMinLength(String min);

  /// Validation error above the maximum length
  ///
  /// In en, this message translates to:
  /// **'At most {max} characters'**
  String validationTextMaxLength(String max);

  /// Validation error when input doesn't match the pattern
  ///
  /// In en, this message translates to:
  /// **'Invalid format'**
  String get validationPattern;

  /// Validation error when no option is selected
  ///
  /// In en, this message translates to:
  /// **'Select an option'**
  String get validationSelectRequired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
