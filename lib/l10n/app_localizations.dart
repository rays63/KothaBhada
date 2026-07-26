import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ne'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kothabhada'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get navPayments;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get commonSaveChanges;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// No description provided for @commonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This screen is coming soon in the next build phase.'**
  String get commonComingSoon;

  /// No description provided for @loadingPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Loading your offline portfolio…'**
  String get loadingPortfolio;

  /// No description provided for @somethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWrong;

  /// No description provided for @onbTagline.
  ///
  /// In en, this message translates to:
  /// **'Rent, tracked — even offline'**
  String get onbTagline;

  /// No description provided for @onbIntro1Title.
  ///
  /// In en, this message translates to:
  /// **'100% Offline'**
  String get onbIntro1Title;

  /// No description provided for @onbIntro1Body.
  ///
  /// In en, this message translates to:
  /// **'Your houses, tenants and rent records live entirely on your device. No account, no internet needed.'**
  String get onbIntro1Body;

  /// No description provided for @onbIntro2Title.
  ///
  /// In en, this message translates to:
  /// **'Rent & bills in one place'**
  String get onbIntro2Title;

  /// No description provided for @onbIntro2Body.
  ///
  /// In en, this message translates to:
  /// **'Track rent, electricity and utilities per room, and see who has paid at a glance.'**
  String get onbIntro2Body;

  /// No description provided for @onbGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onbGetStarted;

  /// No description provided for @onbNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get onbNameTitle;

  /// No description provided for @onbNameBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use your name to greet you on the dashboard. It stays on this device.'**
  String get onbNameBody;

  /// No description provided for @onbNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get onbNameHint;

  /// No description provided for @onbCreatePin.
  ///
  /// In en, this message translates to:
  /// **'Create a PIN'**
  String get onbCreatePin;

  /// No description provided for @onbCreatePinSub.
  ///
  /// In en, this message translates to:
  /// **'Secure your rent records with a 4-digit PIN'**
  String get onbCreatePinSub;

  /// No description provided for @onbConfirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get onbConfirmPin;

  /// No description provided for @onbConfirmPinSub.
  ///
  /// In en, this message translates to:
  /// **'Enter the same PIN once more'**
  String get onbConfirmPinSub;

  /// No description provided for @onbPinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs didn\'t match — try again'**
  String get onbPinMismatch;

  /// No description provided for @onbFasterUnlock.
  ///
  /// In en, this message translates to:
  /// **'Faster unlock'**
  String get onbFasterUnlock;

  /// No description provided for @onbBiometricBody.
  ///
  /// In en, this message translates to:
  /// **'Use your fingerprint or face to unlock Kothabhada instantly. You can change this anytime in Settings.'**
  String get onbBiometricBody;

  /// No description provided for @onbEnableBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Enable biometrics'**
  String get onbEnableBiometrics;

  /// No description provided for @onbMaybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get onbMaybeLater;

  /// No description provided for @lockWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get lockWelcomeBack;

  /// No description provided for @lockEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to unlock'**
  String get lockEnterPin;

  /// No description provided for @lockIncorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN — try again'**
  String get lockIncorrectPin;

  /// No description provided for @dashGreeting.
  ///
  /// In en, this message translates to:
  /// **'Namaste'**
  String get dashGreeting;

  /// No description provided for @dashCollectedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Collected this month'**
  String get dashCollectedThisMonth;

  /// No description provided for @dashOfExpected.
  ///
  /// In en, this message translates to:
  /// **'of {amount} expected'**
  String dashOfExpected(String amount);

  /// No description provided for @dashHouses.
  ///
  /// In en, this message translates to:
  /// **'Houses'**
  String get dashHouses;

  /// No description provided for @dashRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get dashRooms;

  /// No description provided for @dashDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get dashDue;

  /// No description provided for @dashYourHouses.
  ///
  /// In en, this message translates to:
  /// **'Your houses'**
  String get dashYourHouses;

  /// No description provided for @dashSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get dashSeeAll;

  /// No description provided for @dashAddHouse.
  ///
  /// In en, this message translates to:
  /// **'Add house'**
  String get dashAddHouse;

  /// No description provided for @dashNoHousesTitle.
  ///
  /// In en, this message translates to:
  /// **'No houses yet'**
  String get dashNoHousesTitle;

  /// No description provided for @dashNoHousesBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first house to start tracking rooms, tenants and rent — all offline.'**
  String get dashNoHousesBody;

  /// No description provided for @roomsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} rooms'**
  String roomsCount(int count);

  /// No description provided for @houseAdd.
  ///
  /// In en, this message translates to:
  /// **'Add House'**
  String get houseAdd;

  /// No description provided for @houseEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit House'**
  String get houseEdit;

  /// No description provided for @houseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'House name'**
  String get houseNameLabel;

  /// No description provided for @houseNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sunrise Apartment'**
  String get houseNameHint;

  /// No description provided for @houseAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get houseAddressLabel;

  /// No description provided for @houseAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Area, City'**
  String get houseAddressHint;

  /// No description provided for @houseRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Electricity rate (Rs / unit)'**
  String get houseRateLabel;

  /// No description provided for @houseRateHint.
  ///
  /// In en, this message translates to:
  /// **'12'**
  String get houseRateHint;

  /// No description provided for @houseSave.
  ///
  /// In en, this message translates to:
  /// **'Save house'**
  String get houseSave;

  /// No description provided for @houseInvalidRate.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid rate'**
  String get houseInvalidRate;

  /// No description provided for @houseAdded.
  ///
  /// In en, this message translates to:
  /// **'House added'**
  String get houseAdded;

  /// No description provided for @houseUpdated.
  ///
  /// In en, this message translates to:
  /// **'House updated'**
  String get houseUpdated;

  /// No description provided for @houseRatePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Rs {rate}/unit'**
  String houseRatePerUnit(String rate);

  /// No description provided for @houseOccupiedOf.
  ///
  /// In en, this message translates to:
  /// **'{occupied} of {total} occupied'**
  String houseOccupiedOf(int occupied, int total);

  /// No description provided for @houseDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String houseDeleteTitle(String name);

  /// No description provided for @houseDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the house and all its rooms, tenants, readings and payments. This cannot be undone.'**
  String get houseDeleteBody;

  /// No description provided for @houseMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit house'**
  String get houseMenuEdit;

  /// No description provided for @houseMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete house'**
  String get houseMenuDelete;

  /// No description provided for @houseNoRoomsTitle.
  ///
  /// In en, this message translates to:
  /// **'No rooms added'**
  String get houseNoRoomsTitle;

  /// No description provided for @houseNoRoomsBody.
  ///
  /// In en, this message translates to:
  /// **'Add rooms to this house so you can assign tenants and track rent.'**
  String get houseNoRoomsBody;

  /// No description provided for @houseAddRoom.
  ///
  /// In en, this message translates to:
  /// **'Add room'**
  String get houseAddRoom;

  /// No description provided for @roomAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Room'**
  String get roomAdd;

  /// No description provided for @roomEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Room'**
  String get roomEdit;

  /// No description provided for @roomNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Room number / name'**
  String get roomNumberLabel;

  /// No description provided for @roomNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 105'**
  String get roomNumberHint;

  /// No description provided for @roomRentLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly rent (Rs)'**
  String get roomRentLabel;

  /// No description provided for @roomRentHint.
  ///
  /// In en, this message translates to:
  /// **'8,000'**
  String get roomRentHint;

  /// No description provided for @roomTenantInfo.
  ///
  /// In en, this message translates to:
  /// **'You can assign a tenant right after creating the room.'**
  String get roomTenantInfo;

  /// No description provided for @roomSave.
  ///
  /// In en, this message translates to:
  /// **'Save room'**
  String get roomSave;

  /// No description provided for @roomInvalidRent.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid rent'**
  String get roomInvalidRent;

  /// No description provided for @roomAdded.
  ///
  /// In en, this message translates to:
  /// **'Room added'**
  String get roomAdded;

  /// No description provided for @roomUpdated.
  ///
  /// In en, this message translates to:
  /// **'Room updated'**
  String get roomUpdated;

  /// No description provided for @roomTitle.
  ///
  /// In en, this message translates to:
  /// **'Room {number}'**
  String roomTitle(String number);

  /// No description provided for @roomPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{amount} / month'**
  String roomPerMonth(String amount);

  /// No description provided for @roomPerMonthShort.
  ///
  /// In en, this message translates to:
  /// **'{amount}/mo'**
  String roomPerMonthShort(String amount);

  /// No description provided for @roomMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit room'**
  String get roomMenuEdit;

  /// No description provided for @roomMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete room'**
  String get roomMenuDelete;

  /// No description provided for @roomDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete room {number}?'**
  String roomDeleteTitle(String number);

  /// No description provided for @roomDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the room and its tenant history, readings and payments.'**
  String get roomDeleteBody;

  /// No description provided for @statusVacant.
  ///
  /// In en, this message translates to:
  /// **'Vacant'**
  String get statusVacant;

  /// No description provided for @statusOccupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get statusOccupied;

  /// No description provided for @statusRentDue.
  ///
  /// In en, this message translates to:
  /// **'Rent due'**
  String get statusRentDue;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @statusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get statusPartial;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get statusDue;

  /// No description provided for @labelEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get labelEmpty;

  /// No description provided for @tabElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get tabElectricity;

  /// No description provided for @tabUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get tabUtilities;

  /// No description provided for @tabPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get tabPayments;

  /// No description provided for @roomNoTenant.
  ///
  /// In en, this message translates to:
  /// **'No tenant assigned'**
  String get roomNoTenant;

  /// No description provided for @tenantMoveOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Move out {name}?'**
  String tenantMoveOutTitle(String name);

  /// No description provided for @tenantMoveOutBody.
  ///
  /// In en, this message translates to:
  /// **'The room becomes vacant. The tenant record is kept in history.'**
  String get tenantMoveOutBody;

  /// No description provided for @tenantMoveOut.
  ///
  /// In en, this message translates to:
  /// **'Move out'**
  String get tenantMoveOut;

  /// No description provided for @tenantMovedOut.
  ///
  /// In en, this message translates to:
  /// **'Tenant moved out'**
  String get tenantMovedOut;

  /// No description provided for @elecNewReading.
  ///
  /// In en, this message translates to:
  /// **'New reading · {month}'**
  String elecNewReading(String month);

  /// No description provided for @elecPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get elecPrevious;

  /// No description provided for @elecCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get elecCurrent;

  /// No description provided for @elecUnitsConsumed.
  ///
  /// In en, this message translates to:
  /// **'Units consumed'**
  String get elecUnitsConsumed;

  /// No description provided for @elecAmountAtRate.
  ///
  /// In en, this message translates to:
  /// **'Amount @ Rs {rate}'**
  String elecAmountAtRate(String rate);

  /// No description provided for @elecSaveReading.
  ///
  /// In en, this message translates to:
  /// **'Save reading'**
  String get elecSaveReading;

  /// No description provided for @elecRecentReadings.
  ///
  /// In en, this message translates to:
  /// **'Recent readings'**
  String get elecRecentReadings;

  /// No description provided for @elecReadingSaved.
  ///
  /// In en, this message translates to:
  /// **'Reading saved'**
  String get elecReadingSaved;

  /// No description provided for @elecUnitsAmount.
  ///
  /// In en, this message translates to:
  /// **'{units} units · {amount}'**
  String elecUnitsAmount(String units, String amount);

  /// No description provided for @utilChargeType.
  ///
  /// In en, this message translates to:
  /// **'Charge type'**
  String get utilChargeType;

  /// No description provided for @utilAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (Rs)'**
  String get utilAmount;

  /// No description provided for @utilAddCharge.
  ///
  /// In en, this message translates to:
  /// **'Add charge'**
  String get utilAddCharge;

  /// No description provided for @utilChargeAdded.
  ///
  /// In en, this message translates to:
  /// **'Charge added'**
  String get utilChargeAdded;

  /// No description provided for @utilHistory.
  ///
  /// In en, this message translates to:
  /// **'This month & history'**
  String get utilHistory;

  /// No description provided for @utilInternet.
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get utilInternet;

  /// No description provided for @utilWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get utilWater;

  /// No description provided for @utilGarbage.
  ///
  /// In en, this message translates to:
  /// **'Garbage'**
  String get utilGarbage;

  /// No description provided for @utilOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get utilOther;

  /// No description provided for @payNoPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get payNoPaymentsYet;

  /// No description provided for @payMarkPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark paid'**
  String get payMarkPaid;

  /// No description provided for @payPaymentRecorded.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded'**
  String get payPaymentRecorded;

  /// No description provided for @payOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{paid} of {total}'**
  String payOfTotal(String paid, String total);

  /// No description provided for @tenantAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Tenant'**
  String get tenantAdd;

  /// No description provided for @tenantFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get tenantFullName;

  /// No description provided for @tenantFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Priya Sharma'**
  String get tenantFullNameHint;

  /// No description provided for @tenantPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get tenantPhone;

  /// No description provided for @tenantPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+977 98XX-XXXXXX'**
  String get tenantPhoneHint;

  /// No description provided for @tenantMoveInDate.
  ///
  /// In en, this message translates to:
  /// **'Move-in date'**
  String get tenantMoveInDate;

  /// No description provided for @tenantCitizenship.
  ///
  /// In en, this message translates to:
  /// **'Citizenship / ID no. (optional)'**
  String get tenantCitizenship;

  /// No description provided for @tenantCitizenshipHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 12-34-56-78901'**
  String get tenantCitizenshipHint;

  /// No description provided for @tenantEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact (optional)'**
  String get tenantEmergency;

  /// No description provided for @tenantEmergencyHint.
  ///
  /// In en, this message translates to:
  /// **'Name / phone'**
  String get tenantEmergencyHint;

  /// No description provided for @tenantSave.
  ///
  /// In en, this message translates to:
  /// **'Save tenant'**
  String get tenantSave;

  /// No description provided for @tenantAdded.
  ///
  /// In en, this message translates to:
  /// **'Tenant added'**
  String get tenantAdded;

  /// No description provided for @tenantEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit tenant'**
  String get tenantEdit;

  /// No description provided for @tenantCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get tenantCall;

  /// No description provided for @tenantMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get tenantMessage;

  /// No description provided for @tenantCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open'**
  String get tenantCouldNotOpen;

  /// No description provided for @tenantInfoPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get tenantInfoPhone;

  /// No description provided for @tenantInfoMoveIn.
  ///
  /// In en, this message translates to:
  /// **'Move-in date'**
  String get tenantInfoMoveIn;

  /// No description provided for @tenantInfoCitizenship.
  ///
  /// In en, this message translates to:
  /// **'Citizenship / ID'**
  String get tenantInfoCitizenship;

  /// No description provided for @tenantInfoEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get tenantInfoEmergency;

  /// No description provided for @tenantInfoRent.
  ///
  /// In en, this message translates to:
  /// **'Monthly rent'**
  String get tenantInfoRent;

  /// No description provided for @tenantDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get tenantDocuments;

  /// No description provided for @tenantNoDocuments.
  ///
  /// In en, this message translates to:
  /// **'No documents tagged to this tenant.'**
  String get tenantNoDocuments;

  /// No description provided for @tenantMoveOutAction.
  ///
  /// In en, this message translates to:
  /// **'Move out tenant'**
  String get tenantMoveOutAction;

  /// No description provided for @tenantRoomHouse.
  ///
  /// In en, this message translates to:
  /// **'Room {room} · {house}'**
  String tenantRoomHouse(String room, String house);

  /// No description provided for @tenantNoPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone'**
  String get tenantNoPhone;

  /// No description provided for @tenantInSince.
  ///
  /// In en, this message translates to:
  /// **'{phone} · In {date}'**
  String tenantInSince(String phone, String date);

  /// No description provided for @paymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsTitle;

  /// No description provided for @payFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get payFilterAll;

  /// No description provided for @payFilterDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get payFilterDue;

  /// No description provided for @payFilterPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get payFilterPartial;

  /// No description provided for @payFilterPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get payFilterPaid;

  /// No description provided for @payNothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get payNothingHere;

  /// No description provided for @payNoneAll.
  ///
  /// In en, this message translates to:
  /// **'No payments in this period.'**
  String get payNoneAll;

  /// No description provided for @payNoneStatus.
  ///
  /// In en, this message translates to:
  /// **'No {status} payments in this period.'**
  String payNoneStatus(String status);

  /// No description provided for @payFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter payments'**
  String get payFilterTitle;

  /// No description provided for @payPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get payPeriod;

  /// No description provided for @payPeriod2W.
  ///
  /// In en, this message translates to:
  /// **'2W'**
  String get payPeriod2W;

  /// No description provided for @payPeriod1M.
  ///
  /// In en, this message translates to:
  /// **'1M'**
  String get payPeriod1M;

  /// No description provided for @payPeriod3M.
  ///
  /// In en, this message translates to:
  /// **'3M'**
  String get payPeriod3M;

  /// No description provided for @payPeriod6M.
  ///
  /// In en, this message translates to:
  /// **'6M'**
  String get payPeriod6M;

  /// No description provided for @payPeriod1Y.
  ///
  /// In en, this message translates to:
  /// **'1Y'**
  String get payPeriod1Y;

  /// No description provided for @payPeriodCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get payPeriodCustom;

  /// No description provided for @payMarkAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get payMarkAsPaid;

  /// No description provided for @payMarkAsPaidSub.
  ///
  /// In en, this message translates to:
  /// **'{name} · Room {room} · Due {amount}'**
  String payMarkAsPaidSub(String name, String room, String amount);

  /// No description provided for @payFullPayment.
  ///
  /// In en, this message translates to:
  /// **'Full payment'**
  String get payFullPayment;

  /// No description provided for @payPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get payPartial;

  /// No description provided for @payAmountReceived.
  ///
  /// In en, this message translates to:
  /// **'Amount received'**
  String get payAmountReceived;

  /// No description provided for @payEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get payEnterAmount;

  /// No description provided for @payAmountExceeds.
  ///
  /// In en, this message translates to:
  /// **'Amount exceeds the pending total.'**
  String get payAmountExceeds;

  /// No description provided for @payRecordedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded'**
  String get payRecordedTitle;

  /// No description provided for @payRecordedBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} marked as paid for\n{name} · Room {room}'**
  String payRecordedBody(String amount, String name, String room);

  /// No description provided for @payTagFull.
  ///
  /// In en, this message translates to:
  /// **'Full payment'**
  String get payTagFull;

  /// No description provided for @payTagPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial payment'**
  String get payTagPartial;

  /// No description provided for @payAmountPaid.
  ///
  /// In en, this message translates to:
  /// **'{amount} paid'**
  String payAmountPaid(String amount);

  /// No description provided for @payAmountDue.
  ///
  /// In en, this message translates to:
  /// **'{amount} due'**
  String payAmountDue(String amount);

  /// No description provided for @payUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get payUnassigned;

  /// No description provided for @payOverdueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} overdue'**
  String payOverdueCount(int count);

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsIncomeMonth.
  ///
  /// In en, this message translates to:
  /// **'Income · {month}'**
  String analyticsIncomeMonth(String month);

  /// No description provided for @analyticsCollectionRate.
  ///
  /// In en, this message translates to:
  /// **'Collection rate'**
  String get analyticsCollectionRate;

  /// No description provided for @analyticsMonthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Monthly income'**
  String get analyticsMonthlyIncome;

  /// No description provided for @analyticsPerHouse.
  ///
  /// In en, this message translates to:
  /// **'Per-house collection'**
  String get analyticsPerHouse;

  /// No description provided for @analyticsPaidPct.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get analyticsPaidPct;

  /// No description provided for @analyticsPartialPct.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get analyticsPartialPct;

  /// No description provided for @analyticsDuePct.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get analyticsDuePct;

  /// No description provided for @analyticsAddHousesHint.
  ///
  /// In en, this message translates to:
  /// **'Add houses to see collection breakdowns.'**
  String get analyticsAddHousesHint;

  /// No description provided for @analyticsClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get analyticsClear;

  /// No description provided for @docsTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get docsTitle;

  /// No description provided for @docsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get docsAll;

  /// No description provided for @docsAgreements.
  ///
  /// In en, this message translates to:
  /// **'Agreements'**
  String get docsAgreements;

  /// No description provided for @docsIds.
  ///
  /// In en, this message translates to:
  /// **'IDs'**
  String get docsIds;

  /// No description provided for @docsOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get docsOther;

  /// No description provided for @docsNoTitle.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get docsNoTitle;

  /// No description provided for @docsNoBody.
  ///
  /// In en, this message translates to:
  /// **'Keep leases, IDs and deeds safely on your device, tagged to each tenant or house.'**
  String get docsNoBody;

  /// No description provided for @docsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add document'**
  String get docsAdd;

  /// No description provided for @docsUploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload a file'**
  String get docsUploadFile;

  /// No description provided for @docsFileTypes.
  ///
  /// In en, this message translates to:
  /// **'PDF, JPG or PNG'**
  String get docsFileTypes;

  /// No description provided for @docsCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get docsCamera;

  /// No description provided for @docsFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get docsFiles;

  /// No description provided for @docsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Document name'**
  String get docsNameLabel;

  /// No description provided for @docsNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Lease Agreement'**
  String get docsNameHint;

  /// No description provided for @docsCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get docsCategory;

  /// No description provided for @docsCatAgreement.
  ///
  /// In en, this message translates to:
  /// **'Agreement'**
  String get docsCatAgreement;

  /// No description provided for @docsCatId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get docsCatId;

  /// No description provided for @docsCatOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get docsCatOther;

  /// No description provided for @docsTagTo.
  ///
  /// In en, this message translates to:
  /// **'Tag to'**
  String get docsTagTo;

  /// No description provided for @docsSelectOwner.
  ///
  /// In en, this message translates to:
  /// **'Select tenant or house'**
  String get docsSelectOwner;

  /// No description provided for @docsTenants.
  ///
  /// In en, this message translates to:
  /// **'Tenants'**
  String get docsTenants;

  /// No description provided for @docsHouses.
  ///
  /// In en, this message translates to:
  /// **'Houses'**
  String get docsHouses;

  /// No description provided for @docsSave.
  ///
  /// In en, this message translates to:
  /// **'Save document'**
  String get docsSave;

  /// No description provided for @docsSaved.
  ///
  /// In en, this message translates to:
  /// **'Document saved'**
  String get docsSaved;

  /// No description provided for @docsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete document?'**
  String get docsDeleteTitle;

  /// No description provided for @docsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This removes \"{title}\" from this device.'**
  String docsDeleteBody(String title);

  /// No description provided for @docsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Document deleted'**
  String get docsDeleted;

  /// No description provided for @docsAddedOn.
  ///
  /// In en, this message translates to:
  /// **'Added {date}'**
  String docsAddedOn(String date);

  /// No description provided for @docsTypeAgreement.
  ///
  /// In en, this message translates to:
  /// **'Agreement'**
  String get docsTypeAgreement;

  /// No description provided for @docsTypeId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get docsTypeId;

  /// No description provided for @docsTypeFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get docsTypeFile;

  /// No description provided for @docsUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get docsUnassigned;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsHousesRooms.
  ///
  /// In en, this message translates to:
  /// **'{houses} houses · {rooms} rooms'**
  String settingsHousesRooms(int houses, int rooms);

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get settingsDocuments;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get settingsBackup;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsLockApp.
  ///
  /// In en, this message translates to:
  /// **'Lock app'**
  String get settingsLockApp;

  /// No description provided for @settingsYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get settingsYourName;

  /// No description provided for @langTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get langTitle;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get langDefault;

  /// No description provided for @langNepali.
  ///
  /// In en, this message translates to:
  /// **'नेपाली'**
  String get langNepali;

  /// No description provided for @langNepaliEn.
  ///
  /// In en, this message translates to:
  /// **'Nepali'**
  String get langNepaliEn;

  /// No description provided for @langInfo.
  ///
  /// In en, this message translates to:
  /// **'All labels, amounts and dates switch instantly — works fully offline.'**
  String get langInfo;

  /// No description provided for @secTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get secTitle;

  /// No description provided for @secAppLock.
  ///
  /// In en, this message translates to:
  /// **'App lock (PIN)'**
  String get secAppLock;

  /// No description provided for @secRequiredEveryOpen.
  ///
  /// In en, this message translates to:
  /// **'Required on every open'**
  String get secRequiredEveryOpen;

  /// No description provided for @secBiometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get secBiometric;

  /// No description provided for @secFingerprintFace.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint / Face'**
  String get secFingerprintFace;

  /// No description provided for @secNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get secNotAvailable;

  /// No description provided for @secChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get secChangePin;

  /// No description provided for @secPinDeviceOnly.
  ///
  /// In en, this message translates to:
  /// **'Your PIN is stored only on this device and never leaves it.'**
  String get secPinDeviceOnly;

  /// No description provided for @secEnterNewPin.
  ///
  /// In en, this message translates to:
  /// **'Enter new PIN'**
  String get secEnterNewPin;

  /// No description provided for @secConfirmNewPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm new PIN'**
  String get secConfirmNewPin;

  /// No description provided for @secChoosePinSub.
  ///
  /// In en, this message translates to:
  /// **'Choose a 4-digit PIN'**
  String get secChoosePinSub;

  /// No description provided for @secPinUpdated.
  ///
  /// In en, this message translates to:
  /// **'PIN updated'**
  String get secPinUpdated;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupTitle;

  /// No description provided for @backupLast.
  ///
  /// In en, this message translates to:
  /// **'Last backup'**
  String get backupLast;

  /// No description provided for @backupNone.
  ///
  /// In en, this message translates to:
  /// **'No backups yet'**
  String get backupNone;

  /// No description provided for @backupExport.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get backupExport;

  /// No description provided for @backupImport.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get backupImport;

  /// No description provided for @backupHint.
  ///
  /// In en, this message translates to:
  /// **'Backups are saved as a single file you control. Store it anywhere — Drive, SD card or PC.'**
  String get backupHint;

  /// No description provided for @backupOverwriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Overwrite all data?'**
  String get backupOverwriteTitle;

  /// No description provided for @backupOverwriteBody.
  ///
  /// In en, this message translates to:
  /// **'Importing this backup will replace your current houses, tenants and payments. Export a backup first if unsure.'**
  String get backupOverwriteBody;

  /// No description provided for @backupOverwrite.
  ///
  /// In en, this message translates to:
  /// **'Overwrite'**
  String get backupOverwrite;

  /// No description provided for @backupExported.
  ///
  /// In en, this message translates to:
  /// **'Backup exported'**
  String get backupExported;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get backupRestored;

  /// No description provided for @backupImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String backupImportFailed(String error);

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutOffline.
  ///
  /// In en, this message translates to:
  /// **'Fully offline — no account, no servers, no tracking.'**
  String get aboutOffline;

  /// No description provided for @aboutData.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on this device and is only shared when you export a backup.'**
  String get aboutData;

  /// No description provided for @aboutMade.
  ///
  /// In en, this message translates to:
  /// **'Made for landlords managing rooms and rent in Nepal.'**
  String get aboutMade;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Kothabhada'**
  String get aboutCopyright;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get aboutPrivacy;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privacyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: 23 July 2026'**
  String get privacyUpdated;

  /// No description provided for @privacyS1Title.
  ///
  /// In en, this message translates to:
  /// **'No data leaves your device'**
  String get privacyS1Title;

  /// No description provided for @privacyS1Body.
  ///
  /// In en, this message translates to:
  /// **'Kothabhada is a fully offline app. It has no account, no servers and no analytics. Every house, room, tenant, reading, payment and document you enter is stored only in the app\'s private storage on this device.'**
  String get privacyS1Body;

  /// No description provided for @privacyS2Title.
  ///
  /// In en, this message translates to:
  /// **'Camera & photos'**
  String get privacyS2Title;

  /// No description provided for @privacyS2Body.
  ///
  /// In en, this message translates to:
  /// **'The camera and file access are used solely to attach meter photos and documents that you choose. These images are saved on-device and are never uploaded anywhere.'**
  String get privacyS2Body;

  /// No description provided for @privacyS3Title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get privacyS3Title;

  /// No description provided for @privacyS3Body.
  ///
  /// In en, this message translates to:
  /// **'Rent reminders are scheduled locally on your device. No reminder information is sent over the internet.'**
  String get privacyS3Body;

  /// No description provided for @privacyS4Title.
  ///
  /// In en, this message translates to:
  /// **'Backups you control'**
  String get privacyS4Title;

  /// No description provided for @privacyS4Body.
  ///
  /// In en, this message translates to:
  /// **'When you export a backup, a single file is created that you choose where to share or store. The app does not transmit this file on its own — you are fully in control of it.'**
  String get privacyS4Body;

  /// No description provided for @privacyS5Title.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get privacyS5Title;

  /// No description provided for @privacyS5Body.
  ///
  /// In en, this message translates to:
  /// **'Your PIN is stored only on this device as a salted hash and never leaves it. Biometric unlock is handled by your device\'s operating system.'**
  String get privacyS5Body;

  /// No description provided for @privacyS6Title.
  ///
  /// In en, this message translates to:
  /// **'Deleting your data'**
  String get privacyS6Title;

  /// No description provided for @privacyS6Body.
  ///
  /// In en, this message translates to:
  /// **'Uninstalling the app removes all of its data from your device. There is nothing stored elsewhere to delete.'**
  String get privacyS6Body;

  /// No description provided for @privacyFooter.
  ///
  /// In en, this message translates to:
  /// **'Because Kothabhada does not collect or transmit any personal data, there is no data to request, correct or delete from any server.'**
  String get privacyFooter;
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
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
