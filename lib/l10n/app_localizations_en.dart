// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kothabhada';

  @override
  String get navHome => 'Home';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navPayments => 'Payments';

  @override
  String get navSettings => 'Settings';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSaveChanges => 'Save changes';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonDone => 'Done';

  @override
  String get commonRequired => 'Required';

  @override
  String get commonAll => 'All';

  @override
  String get commonNone => 'None';

  @override
  String get commonComingSoon =>
      'This screen is coming soon in the next build phase.';

  @override
  String get loadingPortfolio => 'Loading your offline portfolio…';

  @override
  String get somethingWrong => 'Something went wrong';

  @override
  String get onbTagline => 'Rent, tracked — even offline';

  @override
  String get onbIntro1Title => '100% Offline';

  @override
  String get onbIntro1Body =>
      'Your houses, tenants and rent records live entirely on your device. No account, no internet needed.';

  @override
  String get onbIntro2Title => 'Rent & bills in one place';

  @override
  String get onbIntro2Body =>
      'Track rent, electricity and utilities per room, and see who has paid at a glance.';

  @override
  String get onbGetStarted => 'Get started';

  @override
  String get onbNameTitle => 'What should we call you?';

  @override
  String get onbNameBody =>
      'We\'ll use your name to greet you on the dashboard. It stays on this device.';

  @override
  String get onbNameHint => 'Your name';

  @override
  String get onbCreatePin => 'Create a PIN';

  @override
  String get onbCreatePinSub => 'Secure your rent records with a 4-digit PIN';

  @override
  String get onbConfirmPin => 'Confirm your PIN';

  @override
  String get onbConfirmPinSub => 'Enter the same PIN once more';

  @override
  String get onbPinMismatch => 'PINs didn\'t match — try again';

  @override
  String get onbFasterUnlock => 'Faster unlock';

  @override
  String get onbBiometricBody =>
      'Use your fingerprint or face to unlock Kothabhada instantly. You can change this anytime in Settings.';

  @override
  String get onbEnableBiometrics => 'Enable biometrics';

  @override
  String get onbMaybeLater => 'Maybe later';

  @override
  String get lockWelcomeBack => 'Welcome back';

  @override
  String get lockEnterPin => 'Enter your PIN to unlock';

  @override
  String get lockIncorrectPin => 'Incorrect PIN — try again';

  @override
  String get dashGreeting => 'Namaste';

  @override
  String get dashCollectedThisMonth => 'Collected this month';

  @override
  String dashOfExpected(String amount) {
    return 'of $amount expected';
  }

  @override
  String get dashHouses => 'Houses';

  @override
  String get dashRooms => 'Rooms';

  @override
  String get dashDue => 'Due';

  @override
  String get dashYourHouses => 'Your houses';

  @override
  String get dashSeeAll => 'See all';

  @override
  String get dashAddHouse => 'Add house';

  @override
  String get dashNoHousesTitle => 'No houses yet';

  @override
  String get dashNoHousesBody =>
      'Add your first house to start tracking rooms, tenants and rent — all offline.';

  @override
  String roomsCount(int count) {
    return '$count rooms';
  }

  @override
  String get houseAdd => 'Add House';

  @override
  String get houseEdit => 'Edit House';

  @override
  String get houseNameLabel => 'House name';

  @override
  String get houseNameHint => 'e.g. Sunrise Apartment';

  @override
  String get houseAddressLabel => 'Address';

  @override
  String get houseAddressHint => 'Area, City';

  @override
  String get houseRateLabel => 'Electricity rate (Rs / unit)';

  @override
  String get houseRateHint => '12';

  @override
  String get houseSave => 'Save house';

  @override
  String get houseInvalidRate => 'Enter a valid rate';

  @override
  String get houseAdded => 'House added';

  @override
  String get houseUpdated => 'House updated';

  @override
  String houseRatePerUnit(String rate) {
    return 'Rs $rate/unit';
  }

  @override
  String houseOccupiedOf(int occupied, int total) {
    return '$occupied of $total occupied';
  }

  @override
  String houseDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get houseDeleteBody =>
      'This removes the house and all its rooms, tenants, readings and payments. This cannot be undone.';

  @override
  String get houseMenuEdit => 'Edit house';

  @override
  String get houseMenuDelete => 'Delete house';

  @override
  String get houseNoRoomsTitle => 'No rooms added';

  @override
  String get houseNoRoomsBody =>
      'Add rooms to this house so you can assign tenants and track rent.';

  @override
  String get houseAddRoom => 'Add room';

  @override
  String get roomAdd => 'Add Room';

  @override
  String get roomEdit => 'Edit Room';

  @override
  String get roomNumberLabel => 'Room number / name';

  @override
  String get roomNumberHint => 'e.g. 105';

  @override
  String get roomRentLabel => 'Monthly rent (Rs)';

  @override
  String get roomRentHint => '8,000';

  @override
  String get roomTenantInfo =>
      'You can assign a tenant right after creating the room.';

  @override
  String get roomSave => 'Save room';

  @override
  String get roomInvalidRent => 'Enter a valid rent';

  @override
  String get roomAdded => 'Room added';

  @override
  String get roomUpdated => 'Room updated';

  @override
  String roomTitle(String number) {
    return 'Room $number';
  }

  @override
  String roomPerMonth(String amount) {
    return '$amount / month';
  }

  @override
  String roomPerMonthShort(String amount) {
    return '$amount/mo';
  }

  @override
  String get roomMenuEdit => 'Edit room';

  @override
  String get roomMenuDelete => 'Delete room';

  @override
  String roomDeleteTitle(String number) {
    return 'Delete room $number?';
  }

  @override
  String get roomDeleteBody =>
      'This removes the room and its tenant history, readings and payments.';

  @override
  String get statusVacant => 'Vacant';

  @override
  String get statusOccupied => 'Occupied';

  @override
  String get statusRentDue => 'Rent due';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusPartial => 'Partial';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusDue => 'Due';

  @override
  String get labelEmpty => 'Empty';

  @override
  String get tabElectricity => 'Electricity';

  @override
  String get tabUtilities => 'Utilities';

  @override
  String get tabPayments => 'Payments';

  @override
  String get roomNoTenant => 'No tenant assigned';

  @override
  String tenantMoveOutTitle(String name) {
    return 'Move out $name?';
  }

  @override
  String get tenantMoveOutBody =>
      'The room becomes vacant. The tenant record is kept in history.';

  @override
  String get tenantMoveOut => 'Move out';

  @override
  String get tenantMovedOut => 'Tenant moved out';

  @override
  String elecNewReading(String month) {
    return 'New reading · $month';
  }

  @override
  String get elecPrevious => 'Previous';

  @override
  String get elecCurrent => 'Current';

  @override
  String get elecUnitsConsumed => 'Units consumed';

  @override
  String elecAmountAtRate(String rate) {
    return 'Amount @ Rs $rate';
  }

  @override
  String get elecSaveReading => 'Save reading';

  @override
  String get elecRecentReadings => 'Recent readings';

  @override
  String get elecReadingSaved => 'Reading saved';

  @override
  String elecUnitsAmount(String units, String amount) {
    return '$units units · $amount';
  }

  @override
  String get utilChargeType => 'Charge type';

  @override
  String get utilAmount => 'Amount (Rs)';

  @override
  String get utilAddCharge => 'Add charge';

  @override
  String get utilChargeAdded => 'Charge added';

  @override
  String get utilHistory => 'This month & history';

  @override
  String get utilInternet => 'Internet';

  @override
  String get utilWater => 'Water';

  @override
  String get utilGarbage => 'Garbage';

  @override
  String get utilOther => 'Other';

  @override
  String get payNoPaymentsYet => 'No payments yet';

  @override
  String get payMarkPaid => 'Mark paid';

  @override
  String get payPaymentRecorded => 'Payment recorded';

  @override
  String payOfTotal(String paid, String total) {
    return '$paid of $total';
  }

  @override
  String get tenantAdd => 'Add Tenant';

  @override
  String get tenantFullName => 'Full name';

  @override
  String get tenantFullNameHint => 'e.g. Priya Sharma';

  @override
  String get tenantPhone => 'Phone';

  @override
  String get tenantPhoneHint => '+977 98XX-XXXXXX';

  @override
  String get tenantMoveInDate => 'Move-in date';

  @override
  String get tenantCitizenship => 'Citizenship / ID no. (optional)';

  @override
  String get tenantCitizenshipHint => 'e.g. 12-34-56-78901';

  @override
  String get tenantEmergency => 'Emergency contact (optional)';

  @override
  String get tenantEmergencyHint => 'Name / phone';

  @override
  String get tenantSave => 'Save tenant';

  @override
  String get tenantAdded => 'Tenant added';

  @override
  String get tenantEdit => 'Edit tenant';

  @override
  String get tenantCall => 'Call';

  @override
  String get tenantMessage => 'Message';

  @override
  String get tenantCouldNotOpen => 'Could not open';

  @override
  String get tenantInfoPhone => 'Phone';

  @override
  String get tenantInfoMoveIn => 'Move-in date';

  @override
  String get tenantInfoCitizenship => 'Citizenship / ID';

  @override
  String get tenantInfoEmergency => 'Emergency contact';

  @override
  String get tenantInfoRent => 'Monthly rent';

  @override
  String get tenantDocuments => 'Documents';

  @override
  String get tenantNoDocuments => 'No documents tagged to this tenant.';

  @override
  String get tenantMoveOutAction => 'Move out tenant';

  @override
  String tenantRoomHouse(String room, String house) {
    return 'Room $room · $house';
  }

  @override
  String get tenantNoPhone => 'No phone';

  @override
  String tenantInSince(String phone, String date) {
    return '$phone · In $date';
  }

  @override
  String get paymentsTitle => 'Payments';

  @override
  String get payFilterAll => 'All';

  @override
  String get payFilterDue => 'Due';

  @override
  String get payFilterPartial => 'Partial';

  @override
  String get payFilterPaid => 'Paid';

  @override
  String get payNothingHere => 'Nothing here';

  @override
  String get payNoneAll => 'No payments in this period.';

  @override
  String payNoneStatus(String status) {
    return 'No $status payments in this period.';
  }

  @override
  String get payFilterTitle => 'Filter payments';

  @override
  String get payPeriod => 'Period';

  @override
  String get payPeriod2W => '2W';

  @override
  String get payPeriod1M => '1M';

  @override
  String get payPeriod3M => '3M';

  @override
  String get payPeriod6M => '6M';

  @override
  String get payPeriod1Y => '1Y';

  @override
  String get payPeriodCustom => 'Custom';

  @override
  String get payMarkAsPaid => 'Mark as Paid';

  @override
  String payMarkAsPaidSub(String name, String room, String amount) {
    return '$name · Room $room · Due $amount';
  }

  @override
  String get payFullPayment => 'Full payment';

  @override
  String get payPartial => 'Partial';

  @override
  String get payAmountReceived => 'Amount received';

  @override
  String get payEnterAmount => 'Enter an amount';

  @override
  String get payAmountExceeds => 'Amount exceeds the pending total.';

  @override
  String get payRecordedTitle => 'Payment recorded';

  @override
  String payRecordedBody(String amount, String name, String room) {
    return '$amount marked as paid for\n$name · Room $room';
  }

  @override
  String get payTagFull => 'Full payment';

  @override
  String get payTagPartial => 'Partial payment';

  @override
  String payAmountPaid(String amount) {
    return '$amount paid';
  }

  @override
  String payAmountDue(String amount) {
    return '$amount due';
  }

  @override
  String get payUnassigned => 'Unassigned';

  @override
  String payOverdueCount(int count) {
    return '$count overdue';
  }

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String analyticsIncomeMonth(String month) {
    return 'Income · $month';
  }

  @override
  String get analyticsCollectionRate => 'Collection rate';

  @override
  String get analyticsMonthlyIncome => 'Monthly income';

  @override
  String get analyticsPerHouse => 'Per-house collection';

  @override
  String get analyticsPaidPct => 'Paid';

  @override
  String get analyticsPartialPct => 'Partial';

  @override
  String get analyticsDuePct => 'Due';

  @override
  String get analyticsAddHousesHint =>
      'Add houses to see collection breakdowns.';

  @override
  String get analyticsClear => 'Clear';

  @override
  String get docsTitle => 'Documents';

  @override
  String get docsAll => 'All';

  @override
  String get docsAgreements => 'Agreements';

  @override
  String get docsIds => 'IDs';

  @override
  String get docsOther => 'Other';

  @override
  String get docsNoTitle => 'No documents yet';

  @override
  String get docsNoBody =>
      'Keep leases, IDs and deeds safely on your device, tagged to each tenant or house.';

  @override
  String get docsAdd => 'Add document';

  @override
  String get docsUploadFile => 'Upload a file';

  @override
  String get docsFileTypes => 'PDF, JPG or PNG';

  @override
  String get docsCamera => 'Camera';

  @override
  String get docsFiles => 'Files';

  @override
  String get docsNameLabel => 'Document name';

  @override
  String get docsNameHint => 'e.g. Lease Agreement';

  @override
  String get docsCategory => 'Category';

  @override
  String get docsCatAgreement => 'Agreement';

  @override
  String get docsCatId => 'ID';

  @override
  String get docsCatOther => 'Other';

  @override
  String get docsTagTo => 'Tag to';

  @override
  String get docsSelectOwner => 'Select tenant or house';

  @override
  String get docsTenants => 'Tenants';

  @override
  String get docsHouses => 'Houses';

  @override
  String get docsSave => 'Save document';

  @override
  String get docsSaved => 'Document saved';

  @override
  String get docsDeleteTitle => 'Delete document?';

  @override
  String docsDeleteBody(String title) {
    return 'This removes \"$title\" from this device.';
  }

  @override
  String get docsDeleted => 'Document deleted';

  @override
  String docsAddedOn(String date) {
    return 'Added $date';
  }

  @override
  String get docsTypeAgreement => 'Agreement';

  @override
  String get docsTypeId => 'ID';

  @override
  String get docsTypeFile => 'File';

  @override
  String get docsUnassigned => 'Unassigned';

  @override
  String get settingsTitle => 'Settings';

  @override
  String settingsHousesRooms(int houses, int rooms) {
    return '$houses houses · $rooms rooms';
  }

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsDocuments => 'Documents';

  @override
  String get settingsBackup => 'Backup & Restore';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsLockApp => 'Lock app';

  @override
  String get settingsYourName => 'Your name';

  @override
  String get langTitle => 'Language';

  @override
  String get langEnglish => 'English';

  @override
  String get langDefault => 'Default';

  @override
  String get langNepali => 'नेपाली';

  @override
  String get langNepaliEn => 'Nepali';

  @override
  String get langInfo =>
      'All labels, amounts and dates switch instantly — works fully offline.';

  @override
  String get secTitle => 'Security';

  @override
  String get secAppLock => 'App lock (PIN)';

  @override
  String get secRequiredEveryOpen => 'Required on every open';

  @override
  String get secBiometric => 'Biometric unlock';

  @override
  String get secFingerprintFace => 'Fingerprint / Face';

  @override
  String get secNotAvailable => 'Not available on this device';

  @override
  String get secChangePin => 'Change PIN';

  @override
  String get secPinDeviceOnly =>
      'Your PIN is stored only on this device and never leaves it.';

  @override
  String get secEnterNewPin => 'Enter new PIN';

  @override
  String get secConfirmNewPin => 'Confirm new PIN';

  @override
  String get secChoosePinSub => 'Choose a 4-digit PIN';

  @override
  String get secPinUpdated => 'PIN updated';

  @override
  String get backupTitle => 'Backup & Restore';

  @override
  String get backupLast => 'Last backup';

  @override
  String get backupNone => 'No backups yet';

  @override
  String get backupExport => 'Export data';

  @override
  String get backupImport => 'Import data';

  @override
  String get backupHint =>
      'Backups are saved as a single file you control. Store it anywhere — Drive, SD card or PC.';

  @override
  String get backupOverwriteTitle => 'Overwrite all data?';

  @override
  String get backupOverwriteBody =>
      'Importing this backup will replace your current houses, tenants and payments. Export a backup first if unsure.';

  @override
  String get backupOverwrite => 'Overwrite';

  @override
  String get backupExported => 'Backup exported';

  @override
  String get backupRestored => 'Backup restored';

  @override
  String backupImportFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutOffline =>
      'Fully offline — no account, no servers, no tracking.';

  @override
  String get aboutData =>
      'Your data stays on this device and is only shared when you export a backup.';

  @override
  String get aboutMade =>
      'Made for landlords managing rooms and rent in Nepal.';

  @override
  String get aboutCopyright => '© 2026 Kothabhada';

  @override
  String get aboutPrivacy => 'Privacy Policy';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privacyUpdated => 'Last updated: 23 July 2026';

  @override
  String get privacyS1Title => 'No data leaves your device';

  @override
  String get privacyS1Body =>
      'Kothabhada is a fully offline app. It has no account, no servers and no analytics. Every house, room, tenant, reading, payment and document you enter is stored only in the app\'s private storage on this device.';

  @override
  String get privacyS2Title => 'Camera & photos';

  @override
  String get privacyS2Body =>
      'The camera and file access are used solely to attach meter photos and documents that you choose. These images are saved on-device and are never uploaded anywhere.';

  @override
  String get privacyS3Title => 'Notifications';

  @override
  String get privacyS3Body =>
      'Rent reminders are scheduled locally on your device. No reminder information is sent over the internet.';

  @override
  String get privacyS4Title => 'Backups you control';

  @override
  String get privacyS4Body =>
      'When you export a backup, a single file is created that you choose where to share or store. The app does not transmit this file on its own — you are fully in control of it.';

  @override
  String get privacyS5Title => 'Security';

  @override
  String get privacyS5Body =>
      'Your PIN is stored only on this device as a salted hash and never leaves it. Biometric unlock is handled by your device\'s operating system.';

  @override
  String get privacyS6Title => 'Deleting your data';

  @override
  String get privacyS6Body =>
      'Uninstalling the app removes all of its data from your device. There is nothing stored elsewhere to delete.';

  @override
  String get privacyFooter =>
      'Because Kothabhada does not collect or transmit any personal data, there is no data to request, correct or delete from any server.';
}
