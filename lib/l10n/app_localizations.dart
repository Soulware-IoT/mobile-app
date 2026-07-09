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

  /// Generic destructive delete button on confirm dialogs
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;

  /// Generic destructive remove button on confirm dialogs
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get remove;

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

  /// App bar title on the claim-device screen, and the FAB tooltip that opens it
  ///
  /// In en, this message translates to:
  /// **'Register device'**
  String get claimDeviceTitle;

  /// Intro text on the claim-device screen
  ///
  /// In en, this message translates to:
  /// **'Enter the code printed on the device to add it to this organization.'**
  String get claimDeviceIntro;

  /// Label of the device/edge code field
  ///
  /// In en, this message translates to:
  /// **'Device code'**
  String get claimDeviceCodeLabel;

  /// Switch to reveal the calibration threshold fields on the claim-device screen
  ///
  /// In en, this message translates to:
  /// **'Set custom thresholds'**
  String get claimDeviceCustomThresholds;

  /// Subtitle explaining what happens when custom thresholds are off
  ///
  /// In en, this message translates to:
  /// **'Off uses the standard defaults (35/50 °C, 1000/3000 PPM)'**
  String get claimDeviceDefaultThresholdsHint;

  /// Submit button on the claim-device and claim-edge-device screens
  ///
  /// In en, this message translates to:
  /// **'REGISTER'**
  String get claimDeviceSubmit;

  /// App bar title on the claim-edge-device screen, and the button that opens it
  ///
  /// In en, this message translates to:
  /// **'Register edge gateway'**
  String get claimEdgeDeviceTitle;

  /// Intro text on the claim-edge-device screen
  ///
  /// In en, this message translates to:
  /// **'Enter the code printed on the edge gateway to add it to this organization.'**
  String get claimEdgeDeviceIntro;

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

  /// App bar title on the create-organization screen, and the button that opens it
  ///
  /// In en, this message translates to:
  /// **'Create organization'**
  String get createOrganizationTitle;

  /// Snackbar after creating an organization
  ///
  /// In en, this message translates to:
  /// **'Organization created'**
  String get organizationCreated;

  /// Danger-zone button on the edit-organization screen, owner only
  ///
  /// In en, this message translates to:
  /// **'Delete organization'**
  String get deleteOrganizationTitle;

  /// Confirm dialog title before deleting an organization
  ///
  /// In en, this message translates to:
  /// **'Delete organization?'**
  String get deleteOrganizationConfirmTitle;

  /// Confirm dialog body before deleting an organization
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes \"{name}\" and everything in it. This cannot be undone.'**
  String deleteOrganizationConfirmBody(String name);

  /// Snackbar after deleting an organization
  ///
  /// In en, this message translates to:
  /// **'Organization deleted'**
  String get organizationDeleted;

  /// Danger-zone button on the member-detail screen
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get removeMember;

  /// Confirm dialog title before removing a member
  ///
  /// In en, this message translates to:
  /// **'Remove member?'**
  String get removeMemberConfirmTitle;

  /// Confirm dialog body before removing a member
  ///
  /// In en, this message translates to:
  /// **'{name} will lose access to this organization.'**
  String removeMemberConfirmBody(String name);

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

  /// Shows who sent the invitation, on the my-invitations card
  ///
  /// In en, this message translates to:
  /// **'Invited by {name}'**
  String invitedByLabel(String name);

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

  /// Tooltip on the edge device detail page's rename icon button
  ///
  /// In en, this message translates to:
  /// **'Rename edge gateway'**
  String get edgeRenameTooltip;

  /// Title of the edge device rename dialog
  ///
  /// In en, this message translates to:
  /// **'Rename edge gateway'**
  String get edgeRenameTitle;

  /// Shown instead of the activate/deactivate button while the edge device is still PROVISIONED
  ///
  /// In en, this message translates to:
  /// **'This edge gateway hasn\'t been claimed yet, it cannot be operated.'**
  String get edgeControlsProvisioned;

  /// Button label to activate an inactive edge device
  ///
  /// In en, this message translates to:
  /// **'ACTIVATE EDGE GATEWAY'**
  String get edgeActivate;

  /// Button label to deactivate an active edge device
  ///
  /// In en, this message translates to:
  /// **'STOP EDGE GATEWAY'**
  String get edgeDeactivate;

  /// Confirm dialog title before activating the edge device
  ///
  /// In en, this message translates to:
  /// **'Activate edge gateway?'**
  String get edgeActivateConfirmTitle;

  /// Confirm dialog body before activating the edge device
  ///
  /// In en, this message translates to:
  /// **'The edge gateway will be back in service and able to forward its devices\' readings.'**
  String get edgeActivateConfirmBody;

  /// Confirm dialog title before deactivating the edge device
  ///
  /// In en, this message translates to:
  /// **'Stop edge gateway?'**
  String get edgeDeactivateConfirmTitle;

  /// Confirm dialog body before deactivating the edge device
  ///
  /// In en, this message translates to:
  /// **'The edge gateway will be disabled and stop forwarding its devices\' readings.'**
  String get edgeDeactivateConfirmBody;

  /// Uppercase section label at the top of the Processes tab
  ///
  /// In en, this message translates to:
  /// **'INTERNAL CONTROL'**
  String get processesHeaderLabel;

  /// Empty-state message on the Processes tab when no organization is active
  ///
  /// In en, this message translates to:
  /// **'Select an organization to see its control processes.'**
  String get processesSelectOrganization;

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

  /// Section header on the Edit Organization screen, above the plan card
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscriptionTitle;

  /// Uppercase label above the plan name on the Subscription screen
  ///
  /// In en, this message translates to:
  /// **'CURRENT PLAN'**
  String get subscriptionCurrentPlanLabel;

  /// FREE plan display name
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get subscriptionPlanFree;

  /// BASIC plan display name
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get subscriptionPlanBasic;

  /// PROFESSIONAL plan display name
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get subscriptionPlanProfessional;

  /// Device limit line for the unlimited (Professional) plan
  ///
  /// In en, this message translates to:
  /// **'Unlimited devices'**
  String get subscriptionUnlimitedDevices;

  /// Device limit line for FREE/BASIC plans
  ///
  /// In en, this message translates to:
  /// **'Up to {limit} devices'**
  String subscriptionDeviceLimit(int limit);

  /// Billing period end line, shown for paid plans
  ///
  /// In en, this message translates to:
  /// **'Renews on {date}'**
  String subscriptionRenewsOn(String date);

  /// Shows the organization owner's name on the plan card
  ///
  /// In en, this message translates to:
  /// **'Owned by {name}'**
  String subscriptionOwnedBy(String name);

  /// Warning banner when a downgrade (to Free or a cheaper paid plan) is scheduled
  ///
  /// In en, this message translates to:
  /// **'This subscription will move to {plan} on {date}.'**
  String subscriptionPendingPlanScheduled(String plan, String date);

  /// Subtitle tag on the disabled current-plan option in the plan picker
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get subscriptionCurrentPlanTag;

  /// Monthly price line in the plan picker, e.g. $5.00 / month
  ///
  /// In en, this message translates to:
  /// **'{price} / month'**
  String subscriptionPlanMonthlyPrice(String price);

  /// Timing note under an upgrade option in the plan picker
  ///
  /// In en, this message translates to:
  /// **'Applies immediately with a prorated charge'**
  String get subscriptionUpgradeImmediate;

  /// Timing note under a paid-to-paid downgrade option in the plan picker
  ///
  /// In en, this message translates to:
  /// **'Applies at the end of the current period'**
  String get subscriptionDowngradeAtPeriodEnd;

  /// Button that opens the plan-change dialog, and its title
  ///
  /// In en, this message translates to:
  /// **'Change plan'**
  String get subscriptionChangePlanTitle;

  /// Button that schedules a downgrade to Free at period end
  ///
  /// In en, this message translates to:
  /// **'Downgrade to Free'**
  String get subscriptionDowngrade;

  /// Button that cancels a scheduled downgrade
  ///
  /// In en, this message translates to:
  /// **'Keep current plan'**
  String get subscriptionResume;

  /// Confirm dialog title before scheduling a downgrade
  ///
  /// In en, this message translates to:
  /// **'Downgrade to Free?'**
  String get subscriptionDowngradeConfirmTitle;

  /// Confirm dialog body before scheduling a downgrade
  ///
  /// In en, this message translates to:
  /// **'Your plan stays active until the end of the current billing period, then moves to Free.'**
  String get subscriptionDowngradeConfirmBody;

  /// Label above the Stripe CardField in the plan-change dialog
  ///
  /// In en, this message translates to:
  /// **'Card details'**
  String get subscriptionCardLabel;

  /// Validation error when the card field is incomplete on submit
  ///
  /// In en, this message translates to:
  /// **'Enter complete card details'**
  String get subscriptionCardIncomplete;

  /// Shown when STRIPE_PUBLISHABLE_KEY is missing and the user tries to pay
  ///
  /// In en, this message translates to:
  /// **'Payments are not configured on this build'**
  String get subscriptionStripeNotConfigured;

  /// Label above the amount in the payment bottom sheet header
  ///
  /// In en, this message translates to:
  /// **'Total to pay'**
  String get paymentSheetTotalToPay;

  /// Segmented control option for the card payment mode
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentSheetTabCard;

  /// Segmented control option for the bank payment mode
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get paymentSheetTabBank;

  /// Label for the cardholder name field
  ///
  /// In en, this message translates to:
  /// **'Cardholder name'**
  String get paymentSheetCardholderNameLabel;

  /// Hint text for the cardholder name field
  ///
  /// In en, this message translates to:
  /// **'As it appears on the card'**
  String get paymentSheetCardholderNameHint;

  /// Label for the billing country field
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get paymentSheetCountryLabel;

  /// Label for the billing postal code field
  ///
  /// In en, this message translates to:
  /// **'ZIP'**
  String get paymentSheetPostalCodeLabel;

  /// Label for the bank account holder field
  ///
  /// In en, this message translates to:
  /// **'Account holder'**
  String get paymentSheetBankAccountHolderLabel;

  /// Label for the CLABE (Mexican bank account) field
  ///
  /// In en, this message translates to:
  /// **'CLABE'**
  String get paymentSheetClabeLabel;

  /// Hint text for the CLABE field
  ///
  /// In en, this message translates to:
  /// **'18 digits'**
  String get paymentSheetClabeHint;

  /// Validation error for an incomplete/invalid CLABE
  ///
  /// In en, this message translates to:
  /// **'CLABE must be 18 digits'**
  String get paymentSheetClabeInvalid;

  /// Notice shown under the bank fields
  ///
  /// In en, this message translates to:
  /// **'By confirming you authorize a direct debit charge to this account.'**
  String get paymentSheetDirectDebitNotice;

  /// Shown when the user tries to pay from the bank tab, which has no backend support yet
  ///
  /// In en, this message translates to:
  /// **'Bank transfer payment isn\'t available yet. Use a card to continue.'**
  String get paymentSheetBankUnavailable;

  /// Submit button label, with the formatted amount e.g. $5.00
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String paymentSheetPayButton(String amount);

  /// Security notice shown below the pay button
  ///
  /// In en, this message translates to:
  /// **'Encrypted payment · Processed by Stripe'**
  String get paymentSheetSecurityNotice;

  /// Title shown in the loading state of the payment sheet
  ///
  /// In en, this message translates to:
  /// **'Processing payment…'**
  String get paymentSheetProcessingTitle;

  /// Subtitle shown in the loading state of the payment sheet
  ///
  /// In en, this message translates to:
  /// **'Don\'t close this window'**
  String get paymentSheetProcessingSubtitle;

  /// Title shown in the success state of the payment sheet
  ///
  /// In en, this message translates to:
  /// **'Payment successful!'**
  String get paymentSheetSuccessTitle;

  /// Body text shown in the success state of the payment sheet
  ///
  /// In en, this message translates to:
  /// **'{amount} was charged. We sent the receipt to your email.'**
  String paymentSheetSuccessBody(String amount);

  /// Button that closes the sheet after a successful payment
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get paymentSheetDone;

  /// Validation error when the cardholder name field is empty on submit
  ///
  /// In en, this message translates to:
  /// **'Enter the cardholder name'**
  String get paymentSheetCardholderNameRequired;

  /// Header of the invoice-history section on the Edit Organization screen
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoicesTitle;

  /// Shown when the organization has no invoices
  ///
  /// In en, this message translates to:
  /// **'No invoices yet'**
  String get invoicesEmpty;

  /// Snackbar when launching the hosted invoice URL fails
  ///
  /// In en, this message translates to:
  /// **'Could not open the invoice'**
  String get invoiceOpenError;

  /// Invoice status chip: Stripe 'paid'
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get invoiceStatusPaid;

  /// Invoice status chip: Stripe 'open' (awaiting payment)
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get invoiceStatusOpen;

  /// Invoice status chip: Stripe 'draft'
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get invoiceStatusDraft;

  /// Invoice status chip: Stripe 'void'
  ///
  /// In en, this message translates to:
  /// **'Void'**
  String get invoiceStatusVoid;

  /// Invoice status chip: Stripe 'uncollectible'
  ///
  /// In en, this message translates to:
  /// **'Uncollectible'**
  String get invoiceStatusUncollectible;

  /// AppBar title of the real-time sensor monitoring page
  ///
  /// In en, this message translates to:
  /// **'Live readings'**
  String get liveReadingsTitle;

  /// Hint shown below the device selector before a device is chosen
  ///
  /// In en, this message translates to:
  /// **'Select a device to monitor'**
  String get liveReadingsSelectDevice;

  /// Shown on the live readings page when the org has no devices
  ///
  /// In en, this message translates to:
  /// **'This organization has no IoT devices yet'**
  String get liveReadingsNoDevices;

  /// Status strip placeholder before the first reading arrives
  ///
  /// In en, this message translates to:
  /// **'Waiting for readings…'**
  String get liveReadingsWaiting;

  /// Banner shown while an SSE stream is retrying its connection
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get liveReadingsReconnecting;

  /// Presence pill when the device is online
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get liveReadingsOnline;

  /// Presence pill when the device is offline
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get liveReadingsOffline;

  /// Presence pill when no presence record has arrived for the device
  ///
  /// In en, this message translates to:
  /// **'No signal'**
  String get liveReadingsNoSignal;

  /// Button that sends the servo start command
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get servoStart;

  /// Button that sends the servo stop command
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get servoStop;

  /// Title above the temperature line chart
  ///
  /// In en, this message translates to:
  /// **'Temperature (°C)'**
  String get chartTemperatureTitle;

  /// Title above the gas line chart
  ///
  /// In en, this message translates to:
  /// **'Gas (PPM)'**
  String get chartGasTitle;

  /// Reading severity label: within thresholds
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get severitySafe;

  /// Reading severity label: above the warn threshold
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get severityWarning;

  /// Reading severity label: above the crit threshold
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get severityCritical;
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
