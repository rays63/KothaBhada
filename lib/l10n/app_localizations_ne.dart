// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appTitle => 'कोठाभाडा';

  @override
  String get navHome => 'गृह';

  @override
  String get navAnalytics => 'विश्लेषण';

  @override
  String get navPayments => 'भुक्तानी';

  @override
  String get navSettings => 'सेटिङ';

  @override
  String get commonSave => 'सुरक्षित गर्नुहोस्';

  @override
  String get commonSaveChanges => 'परिवर्तन सुरक्षित गर्नुहोस्';

  @override
  String get commonCancel => 'रद्द गर्नुहोस्';

  @override
  String get commonDelete => 'मेट्नुहोस्';

  @override
  String get commonConfirm => 'पुष्टि गर्नुहोस्';

  @override
  String get commonAdd => 'थप्नुहोस्';

  @override
  String get commonApply => 'लागू गर्नुहोस्';

  @override
  String get commonContinue => 'जारी राख्नुहोस्';

  @override
  String get commonNext => 'अर्को';

  @override
  String get commonSkip => 'छोड्नुहोस्';

  @override
  String get commonDone => 'भयो';

  @override
  String get commonRequired => 'आवश्यक';

  @override
  String get commonAll => 'सबै';

  @override
  String get commonNone => 'कुनै पनि होइन';

  @override
  String get commonComingSoon => 'यो स्क्रिन अर्को चरणमा आउँदैछ।';

  @override
  String get loadingPortfolio => 'तपाईंको अफलाइन पोर्टफोलियो लोड हुँदैछ…';

  @override
  String get somethingWrong => 'केही गडबड भयो';

  @override
  String get onbTagline => 'भाडा, अफलाइनमा पनि — व्यवस्थित';

  @override
  String get onbIntro1Title => '१००% अफलाइन';

  @override
  String get onbIntro1Body =>
      'तपाईंका घर, भाडावाल र भाडाका रेकर्ड सम्पूर्ण रूपमा तपाईंकै यन्त्रमा रहन्छन्। खाता वा इन्टरनेट आवश्यक छैन।';

  @override
  String get onbIntro2Title => 'भाडा र बिल एकै ठाउँमा';

  @override
  String get onbIntro2Body =>
      'प्रत्येक कोठाको भाडा, बिजुली र सुविधा शुल्क ट्र्याक गर्नुहोस्, र कसले तिरेको छ एकै नजरमा हेर्नुहोस्।';

  @override
  String get onbGetStarted => 'सुरु गर्नुहोस्';

  @override
  String get onbNameTitle => 'तपाईंलाई के भनेर बोलाउने?';

  @override
  String get onbNameBody =>
      'ड्यासबोर्डमा अभिवादन गर्न तपाईंको नाम प्रयोग गरिनेछ। यो यही यन्त्रमा रहन्छ।';

  @override
  String get onbNameHint => 'तपाईंको नाम';

  @override
  String get onbCreatePin => 'पिन बनाउनुहोस्';

  @override
  String get onbCreatePinSub =>
      'आफ्ना भाडा रेकर्ड ४-अंकको पिनले सुरक्षित गर्नुहोस्';

  @override
  String get onbConfirmPin => 'पिन पुष्टि गर्नुहोस्';

  @override
  String get onbConfirmPinSub => 'उही पिन फेरि एकपटक हाल्नुहोस्';

  @override
  String get onbPinMismatch => 'पिन मिलेन — फेरि प्रयास गर्नुहोस्';

  @override
  String get onbFasterUnlock => 'छिटो अनलक';

  @override
  String get onbBiometricBody =>
      'कोठाभाडा तुरुन्तै अनलक गर्न फिंगरप्रिन्ट वा फेस प्रयोग गर्नुहोस्। यो सेटिङमा जहिले पनि बदल्न सकिन्छ।';

  @override
  String get onbEnableBiometrics => 'बायोमेट्रिक सक्षम गर्नुहोस्';

  @override
  String get onbMaybeLater => 'पछि गर्दा हुन्छ';

  @override
  String get lockWelcomeBack => 'पुनः स्वागत छ';

  @override
  String get lockEnterPin => 'अनलक गर्न पिन हाल्नुहोस्';

  @override
  String get lockIncorrectPin => 'गलत पिन — फेरि प्रयास गर्नुहोस्';

  @override
  String get dashGreeting => 'नमस्ते';

  @override
  String get dashCollectedThisMonth => 'यस महिना संकलित';

  @override
  String dashOfExpected(String amount) {
    return 'अपेक्षित $amount मध्ये';
  }

  @override
  String get dashHouses => 'घरहरू';

  @override
  String get dashRooms => 'कोठाहरू';

  @override
  String get dashDue => 'बाँकी';

  @override
  String get dashYourHouses => 'तपाईंका घरहरू';

  @override
  String get dashSeeAll => 'सबै हेर्नुहोस्';

  @override
  String get dashAddHouse => 'घर थप्नुहोस्';

  @override
  String get dashNoHousesTitle => 'अहिलेसम्म कुनै घर छैन';

  @override
  String get dashNoHousesBody =>
      'कोठा, भाडावाल र भाडा ट्र्याक गर्न आफ्नो पहिलो घर थप्नुहोस् — सबै अफलाइन।';

  @override
  String roomsCount(int count) {
    return '$count कोठा';
  }

  @override
  String get houseAdd => 'घर थप्नुहोस्';

  @override
  String get houseEdit => 'घर सम्पादन गर्नुहोस्';

  @override
  String get houseNameLabel => 'घरको नाम';

  @override
  String get houseNameHint => 'जस्तै सनराइज अपार्टमेन्ट';

  @override
  String get houseAddressLabel => 'ठेगाना';

  @override
  String get houseAddressHint => 'क्षेत्र, सहर';

  @override
  String get houseRateLabel => 'बिजुली दर (रु / युनिट)';

  @override
  String get houseRateHint => '१२';

  @override
  String get houseSave => 'घर सुरक्षित गर्नुहोस्';

  @override
  String get houseInvalidRate => 'मान्य दर हाल्नुहोस्';

  @override
  String get houseAdded => 'घर थपियो';

  @override
  String get houseUpdated => 'घर अद्यावधिक भयो';

  @override
  String houseRatePerUnit(String rate) {
    return 'रु $rate/युनिट';
  }

  @override
  String houseOccupiedOf(int occupied, int total) {
    return '$total मध्ये $occupied भरिएको';
  }

  @override
  String houseDeleteTitle(String name) {
    return '$name मेट्ने?';
  }

  @override
  String get houseDeleteBody =>
      'यसले घर र यसका सबै कोठा, भाडावाल, रिडिङ र भुक्तानी हटाउँछ। यो फिर्ता गर्न सकिँदैन।';

  @override
  String get houseMenuEdit => 'घर सम्पादन गर्नुहोस्';

  @override
  String get houseMenuDelete => 'घर मेट्नुहोस्';

  @override
  String get houseNoRoomsTitle => 'कुनै कोठा थपिएको छैन';

  @override
  String get houseNoRoomsBody =>
      'भाडावाल तोक्न र भाडा ट्र्याक गर्न यस घरमा कोठा थप्नुहोस्।';

  @override
  String get houseAddRoom => 'कोठा थप्नुहोस्';

  @override
  String get roomAdd => 'कोठा थप्नुहोस्';

  @override
  String get roomEdit => 'कोठा सम्पादन गर्नुहोस्';

  @override
  String get roomNumberLabel => 'कोठा नम्बर / नाम';

  @override
  String get roomNumberHint => 'जस्तै १०५';

  @override
  String get roomRentLabel => 'मासिक भाडा (रु)';

  @override
  String get roomRentHint => '८,०००';

  @override
  String get roomTenantInfo => 'कोठा बनाएपछि तुरुन्तै भाडावाल तोक्न सकिन्छ।';

  @override
  String get roomSave => 'कोठा सुरक्षित गर्नुहोस्';

  @override
  String get roomInvalidRent => 'मान्य भाडा हाल्नुहोस्';

  @override
  String get roomAdded => 'कोठा थपियो';

  @override
  String get roomUpdated => 'कोठा अद्यावधिक भयो';

  @override
  String roomTitle(String number) {
    return 'कोठा $number';
  }

  @override
  String roomPerMonth(String amount) {
    return '$amount / महिना';
  }

  @override
  String roomPerMonthShort(String amount) {
    return '$amount/महिना';
  }

  @override
  String get roomMenuEdit => 'कोठा सम्पादन गर्नुहोस्';

  @override
  String get roomMenuDelete => 'कोठा मेट्नुहोस्';

  @override
  String roomDeleteTitle(String number) {
    return 'कोठा $number मेट्ने?';
  }

  @override
  String get roomDeleteBody =>
      'यसले कोठा र यसको भाडावाल इतिहास, रिडिङ र भुक्तानी हटाउँछ।';

  @override
  String get statusVacant => 'खाली';

  @override
  String get statusOccupied => 'भरिएको';

  @override
  String get statusRentDue => 'भाडा बाँकी';

  @override
  String get statusOverdue => 'म्याद नाघेको';

  @override
  String get statusPartial => 'आंशिक';

  @override
  String get statusPaid => 'भुक्तान भयो';

  @override
  String get statusDue => 'बाँकी';

  @override
  String get labelEmpty => 'खाली';

  @override
  String get tabElectricity => 'बिजुली';

  @override
  String get tabUtilities => 'सुविधा';

  @override
  String get tabPayments => 'भुक्तानी';

  @override
  String get roomNoTenant => 'कुनै भाडावाल तोकिएको छैन';

  @override
  String tenantMoveOutTitle(String name) {
    return '$name लाई निकाल्ने?';
  }

  @override
  String get tenantMoveOutBody =>
      'कोठा खाली हुनेछ। भाडावालको रेकर्ड इतिहासमा राखिन्छ।';

  @override
  String get tenantMoveOut => 'निकाल्नुहोस्';

  @override
  String get tenantMovedOut => 'भाडावाल निस्किए';

  @override
  String elecNewReading(String month) {
    return 'नयाँ रिडिङ · $month';
  }

  @override
  String get elecPrevious => 'अघिल्लो';

  @override
  String get elecCurrent => 'हालको';

  @override
  String get elecUnitsConsumed => 'खपत युनिट';

  @override
  String elecAmountAtRate(String rate) {
    return 'रकम @ रु $rate';
  }

  @override
  String get elecSaveReading => 'रिडिङ सुरक्षित गर्नुहोस्';

  @override
  String get elecRecentReadings => 'हालैका रिडिङ';

  @override
  String get elecReadingSaved => 'रिडिङ सुरक्षित भयो';

  @override
  String elecUnitsAmount(String units, String amount) {
    return '$units युनिट · $amount';
  }

  @override
  String get utilChargeType => 'शुल्कको प्रकार';

  @override
  String get utilAmount => 'रकम (रु)';

  @override
  String get utilAddCharge => 'शुल्क थप्नुहोस्';

  @override
  String get utilChargeAdded => 'शुल्क थपियो';

  @override
  String get utilHistory => 'यस महिना र इतिहास';

  @override
  String get utilInternet => 'इन्टरनेट';

  @override
  String get utilWater => 'पानी';

  @override
  String get utilGarbage => 'फोहोर';

  @override
  String get utilOther => 'अन्य';

  @override
  String get payNoPaymentsYet => 'अहिलेसम्म कुनै भुक्तानी छैन';

  @override
  String get payMarkPaid => 'भुक्तान भएको चिन्ह लगाउनुहोस्';

  @override
  String get payPaymentRecorded => 'भुक्तानी रेकर्ड भयो';

  @override
  String payOfTotal(String paid, String total) {
    return '$total मध्ये $paid';
  }

  @override
  String get tenantAdd => 'भाडावाल थप्नुहोस्';

  @override
  String get tenantFullName => 'पूरा नाम';

  @override
  String get tenantFullNameHint => 'जस्तै प्रिया शर्मा';

  @override
  String get tenantPhone => 'फोन';

  @override
  String get tenantPhoneHint => '+९७७ ९८XX-XXXXXX';

  @override
  String get tenantMoveInDate => 'बस्न आएको मिति';

  @override
  String get tenantCitizenship => 'नागरिकता / परिचय नं. (वैकल्पिक)';

  @override
  String get tenantCitizenshipHint => 'जस्तै १२-३४-५६-७८९०१';

  @override
  String get tenantEmergency => 'आपतकालीन सम्पर्क (वैकल्पिक)';

  @override
  String get tenantEmergencyHint => 'नाम / फोन';

  @override
  String get tenantSave => 'भाडावाल सुरक्षित गर्नुहोस्';

  @override
  String get tenantAdded => 'भाडावाल थपियो';

  @override
  String get tenantEdit => 'भाडावाल सम्पादन गर्नुहोस्';

  @override
  String get tenantCall => 'कल';

  @override
  String get tenantMessage => 'सन्देश';

  @override
  String get tenantCouldNotOpen => 'खोल्न सकिएन';

  @override
  String get tenantInfoPhone => 'फोन';

  @override
  String get tenantInfoMoveIn => 'बस्न आएको मिति';

  @override
  String get tenantInfoCitizenship => 'नागरिकता / परिचय';

  @override
  String get tenantInfoEmergency => 'आपतकालीन सम्पर्क';

  @override
  String get tenantInfoRent => 'मासिक भाडा';

  @override
  String get tenantDocuments => 'कागजातहरू';

  @override
  String get tenantNoDocuments => 'यस भाडावालसँग कुनै कागजात जोडिएको छैन।';

  @override
  String get tenantMoveOutAction => 'भाडावाल निकाल्नुहोस्';

  @override
  String tenantRoomHouse(String room, String house) {
    return 'कोठा $room · $house';
  }

  @override
  String get tenantNoPhone => 'फोन छैन';

  @override
  String tenantInSince(String phone, String date) {
    return '$phone · $date देखि';
  }

  @override
  String get paymentsTitle => 'भुक्तानी';

  @override
  String get payFilterAll => 'सबै';

  @override
  String get payFilterDue => 'बाँकी';

  @override
  String get payFilterPartial => 'आंशिक';

  @override
  String get payFilterPaid => 'भुक्तान भयो';

  @override
  String get payNothingHere => 'यहाँ केही छैन';

  @override
  String get payNoneAll => 'यस अवधिमा कुनै भुक्तानी छैन।';

  @override
  String payNoneStatus(String status) {
    return 'यस अवधिमा $status भुक्तानी छैन।';
  }

  @override
  String get payFilterTitle => 'भुक्तानी फिल्टर गर्नुहोस्';

  @override
  String get payPeriod => 'अवधि';

  @override
  String get payPeriod2W => '२ हप्ता';

  @override
  String get payPeriod1M => '१ महिना';

  @override
  String get payPeriod3M => '३ महिना';

  @override
  String get payPeriod6M => '६ महिना';

  @override
  String get payPeriod1Y => '१ वर्ष';

  @override
  String get payPeriodCustom => 'अनुकूल';

  @override
  String get payMarkAsPaid => 'भुक्तान भएको चिन्ह लगाउनुहोस्';

  @override
  String payMarkAsPaidSub(String name, String room, String amount) {
    return '$name · कोठा $room · बाँकी $amount';
  }

  @override
  String get payFullPayment => 'पूर्ण भुक्तानी';

  @override
  String get payPartial => 'आंशिक';

  @override
  String get payAmountReceived => 'प्राप्त रकम';

  @override
  String get payEnterAmount => 'रकम हाल्नुहोस्';

  @override
  String get payAmountExceeds => 'रकम बाँकी जम्मा भन्दा बढी छ।';

  @override
  String get payRecordedTitle => 'भुक्तानी रेकर्ड भयो';

  @override
  String payRecordedBody(String amount, String name, String room) {
    return '$name · कोठा $room का लागि\n$amount भुक्तान भएको चिन्ह लगाइयो';
  }

  @override
  String get payTagFull => 'पूर्ण भुक्तानी';

  @override
  String get payTagPartial => 'आंशिक भुक्तानी';

  @override
  String payAmountPaid(String amount) {
    return '$amount भुक्तान भयो';
  }

  @override
  String payAmountDue(String amount) {
    return '$amount बाँकी';
  }

  @override
  String get payUnassigned => 'नतोकिएको';

  @override
  String payOverdueCount(int count) {
    return '$count म्याद नाघेको';
  }

  @override
  String get analyticsTitle => 'विश्लेषण';

  @override
  String analyticsIncomeMonth(String month) {
    return 'आय · $month';
  }

  @override
  String get analyticsCollectionRate => 'संकलन दर';

  @override
  String get analyticsMonthlyIncome => 'मासिक आय';

  @override
  String get analyticsPerHouse => 'घर अनुसार संकलन';

  @override
  String get analyticsPaidPct => 'भुक्तान';

  @override
  String get analyticsPartialPct => 'आंशिक';

  @override
  String get analyticsDuePct => 'बाँकी';

  @override
  String get analyticsAddHousesHint => 'संकलन विवरण हेर्न घरहरू थप्नुहोस्।';

  @override
  String get analyticsClear => 'हटाउनुहोस्';

  @override
  String get docsTitle => 'कागजातहरू';

  @override
  String get docsAll => 'सबै';

  @override
  String get docsAgreements => 'सम्झौता';

  @override
  String get docsIds => 'परिचयपत्र';

  @override
  String get docsOther => 'अन्य';

  @override
  String get docsNoTitle => 'अहिलेसम्म कुनै कागजात छैन';

  @override
  String get docsNoBody =>
      'करार, परिचयपत्र र लालपुर्जा प्रत्येक भाडावाल वा घरसँग जोडेर आफ्नै यन्त्रमा सुरक्षित राख्नुहोस्।';

  @override
  String get docsAdd => 'कागजात थप्नुहोस्';

  @override
  String get docsUploadFile => 'फाइल अपलोड गर्नुहोस्';

  @override
  String get docsFileTypes => 'PDF, JPG वा PNG';

  @override
  String get docsCamera => 'क्यामेरा';

  @override
  String get docsFiles => 'फाइल';

  @override
  String get docsNameLabel => 'कागजातको नाम';

  @override
  String get docsNameHint => 'जस्तै करार सम्झौता';

  @override
  String get docsCategory => 'वर्ग';

  @override
  String get docsCatAgreement => 'सम्झौता';

  @override
  String get docsCatId => 'परिचयपत्र';

  @override
  String get docsCatOther => 'अन्य';

  @override
  String get docsTagTo => 'यसमा जोड्नुहोस्';

  @override
  String get docsSelectOwner => 'भाडावाल वा घर छान्नुहोस्';

  @override
  String get docsTenants => 'भाडावालहरू';

  @override
  String get docsHouses => 'घरहरू';

  @override
  String get docsSave => 'कागजात सुरक्षित गर्नुहोस्';

  @override
  String get docsSaved => 'कागजात सुरक्षित भयो';

  @override
  String get docsDeleteTitle => 'कागजात मेट्ने?';

  @override
  String docsDeleteBody(String title) {
    return 'यसले \"$title\" यस यन्त्रबाट हटाउँछ।';
  }

  @override
  String get docsDeleted => 'कागजात मेटियो';

  @override
  String docsAddedOn(String date) {
    return '$date मा थपिएको';
  }

  @override
  String get docsTypeAgreement => 'सम्झौता';

  @override
  String get docsTypeId => 'परिचयपत्र';

  @override
  String get docsTypeFile => 'फाइल';

  @override
  String get docsUnassigned => 'नतोकिएको';

  @override
  String get settingsTitle => 'सेटिङ';

  @override
  String settingsHousesRooms(int houses, int rooms) {
    return '$houses घर · $rooms कोठा';
  }

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsSecurity => 'सुरक्षा';

  @override
  String get settingsDarkMode => 'डार्क मोड';

  @override
  String get settingsDocuments => 'कागजातहरू';

  @override
  String get settingsBackup => 'ब्याकअप र पुनर्स्थापना';

  @override
  String get settingsAbout => 'बारेमा';

  @override
  String get settingsLockApp => 'एप लक गर्नुहोस्';

  @override
  String get settingsYourName => 'तपाईंको नाम';

  @override
  String get langTitle => 'भाषा';

  @override
  String get langEnglish => 'English';

  @override
  String get langDefault => 'पूर्वनिर्धारित';

  @override
  String get langNepali => 'नेपाली';

  @override
  String get langNepaliEn => 'Nepali';

  @override
  String get langInfo =>
      'सबै लेबल, रकम र मिति तुरुन्तै परिवर्तन हुन्छन् — पूर्ण रूपमा अफलाइन काम गर्छ।';

  @override
  String get secTitle => 'सुरक्षा';

  @override
  String get secAppLock => 'एप लक (पिन)';

  @override
  String get secRequiredEveryOpen => 'प्रत्येक पटक खोल्दा आवश्यक';

  @override
  String get secBiometric => 'बायोमेट्रिक अनलक';

  @override
  String get secFingerprintFace => 'फिंगरप्रिन्ट / फेस';

  @override
  String get secNotAvailable => 'यस यन्त्रमा उपलब्ध छैन';

  @override
  String get secChangePin => 'पिन परिवर्तन गर्नुहोस्';

  @override
  String get secPinDeviceOnly =>
      'तपाईंको पिन यही यन्त्रमा मात्र राखिन्छ र कहिल्यै बाहिर जाँदैन।';

  @override
  String get secEnterNewPin => 'नयाँ पिन हाल्नुहोस्';

  @override
  String get secConfirmNewPin => 'नयाँ पिन पुष्टि गर्नुहोस्';

  @override
  String get secChoosePinSub => '४-अंकको पिन छान्नुहोस्';

  @override
  String get secPinUpdated => 'पिन अद्यावधिक भयो';

  @override
  String get backupTitle => 'ब्याकअप र पुनर्स्थापना';

  @override
  String get backupLast => 'पछिल्लो ब्याकअप';

  @override
  String get backupNone => 'अहिलेसम्म कुनै ब्याकअप छैन';

  @override
  String get backupExport => 'डाटा निर्यात गर्नुहोस्';

  @override
  String get backupImport => 'डाटा आयात गर्नुहोस्';

  @override
  String get backupHint =>
      'ब्याकअप तपाईंको नियन्त्रणमा रहने एउटै फाइलमा सुरक्षित हुन्छ। जहाँ मन लाग्यो त्यहाँ राख्नुहोस् — ड्राइभ, SD कार्ड वा PC।';

  @override
  String get backupOverwriteTitle => 'सबै डाटा प्रतिस्थापन गर्ने?';

  @override
  String get backupOverwriteBody =>
      'यो ब्याकअप आयात गर्दा तपाईंका हालका घर, भाडावाल र भुक्तानी प्रतिस्थापन हुनेछन्। अनिश्चित भए पहिले ब्याकअप निर्यात गर्नुहोस्।';

  @override
  String get backupOverwrite => 'प्रतिस्थापन गर्नुहोस्';

  @override
  String get backupExported => 'ब्याकअप निर्यात भयो';

  @override
  String get backupRestored => 'ब्याकअप पुनर्स्थापना भयो';

  @override
  String backupImportFailed(String error) {
    return 'आयात असफल: $error';
  }

  @override
  String aboutVersion(String version) {
    return 'संस्करण $version';
  }

  @override
  String get aboutOffline =>
      'पूर्ण अफलाइन — खाता छैन, सर्भर छैन, ट्र्याकिङ छैन।';

  @override
  String get aboutData =>
      'तपाईंको डाटा यही यन्त्रमा रहन्छ र ब्याकअप निर्यात गर्दा मात्र साझा हुन्छ।';

  @override
  String get aboutMade =>
      'नेपालमा कोठा र भाडा व्यवस्थापन गर्ने घरधनीहरूका लागि बनाइएको।';

  @override
  String get aboutCopyright => '© २०२६ कोठाभाडा';

  @override
  String get aboutPrivacy => 'गोपनीयता नीति';

  @override
  String get privacyTitle => 'गोपनीयता नीति';

  @override
  String get privacyUpdated => 'पछिल्लो अद्यावधिक: २३ जुलाई २०२६';

  @override
  String get privacyS1Title => 'कुनै डाटा यन्त्रबाट बाहिर जाँदैन';

  @override
  String get privacyS1Body =>
      'कोठाभाडा पूर्ण रूपमा अफलाइन एप हो। यसमा खाता, सर्भर वा एनालिटिक्स छैन। तपाईंले हालेका हरेक घर, कोठा, भाडावाल, रिडिङ, भुक्तानी र कागजात यही यन्त्रको निजी भण्डारणमा मात्र रहन्छन्।';

  @override
  String get privacyS2Title => 'क्यामेरा र फोटो';

  @override
  String get privacyS2Body =>
      'क्यामेरा र फाइल पहुँच तपाईंले छानेका मिटर फोटो र कागजात जोड्न मात्र प्रयोग हुन्छ। यी तस्बिरहरू यन्त्रमै सुरक्षित हुन्छन् र कहीँ अपलोड हुँदैनन्।';

  @override
  String get privacyS3Title => 'सूचनाहरू';

  @override
  String get privacyS3Body =>
      'भाडा रिमाइन्डरहरू तपाईंको यन्त्रमै स्थानीय रूपमा तय गरिन्छन्। कुनै रिमाइन्डर जानकारी इन्टरनेटमार्फत पठाइँदैन।';

  @override
  String get privacyS4Title => 'तपाईंको नियन्त्रणमा ब्याकअप';

  @override
  String get privacyS4Body =>
      'तपाईंले ब्याकअप निर्यात गर्दा एउटै फाइल बन्छ जुन कहाँ साझा वा भण्डारण गर्ने तपाईं आफैं छान्नुहुन्छ। एपले यो फाइल आफैं कहीँ पठाउँदैन।';

  @override
  String get privacyS5Title => 'सुरक्षा';

  @override
  String get privacyS5Body =>
      'तपाईंको पिन यही यन्त्रमा साल्टेड ह्यासको रूपमा मात्र राखिन्छ र कहिल्यै बाहिर जाँदैन। बायोमेट्रिक अनलक तपाईंको यन्त्रको अपरेटिङ सिस्टमले सम्हाल्छ।';

  @override
  String get privacyS6Title => 'तपाईंको डाटा मेट्ने';

  @override
  String get privacyS6Body =>
      'एप अनइन्स्टल गर्दा यसका सबै डाटा तपाईंको यन्त्रबाट हट्छन्। अन्यत्र केही भण्डारण गरिएको हुँदैन।';

  @override
  String get privacyFooter =>
      'कोठाभाडाले कुनै व्यक्तिगत डाटा संकलन वा प्रसारण नगर्ने भएकाले कुनै सर्भरबाट माग्न, सच्याउन वा मेट्न कुनै डाटा हुँदैन।';
}
