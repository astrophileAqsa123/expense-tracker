// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get general => 'सामान्य';

  @override
  String get account => 'अकाउंट';

  @override
  String get accountSubtitle => 'प्रोफ़ाइल, पासवर्ड';

  @override
  String get language => 'भाषा';

  @override
  String get currency => 'मुद्रा';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get appearance => 'दिखावट';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get budgetFeatures => 'बजट फीचर्स';

  @override
  String get advancedBudgetSetup => 'एडवांस बजट सेटअप';

  @override
  String get advancedBudgetSubtitle => 'AI अनुमान और ऑटो-कैटेगरी';

  @override
  String get security => 'सुरक्षा';

  @override
  String get privacySecurity => 'प्राइवेसी और सुरक्षा';

  @override
  String get privacySecuritySubtitle => 'ऐप लॉक, परमिशन';

  @override
  String get about => 'परिचय';

  @override
  String get aboutApp => 'ऐप के बारे में';

  @override
  String get dashboard => 'डैशबोर्ड';

  @override
  String get analytics => 'एनालिटिक्स';

  @override
  String get analysis => 'विश्लेषण';

  @override
  String get graphs => 'ग्राफ़';

  @override
  String get graph => 'ग्राफ़';

  @override
  String get charts => 'चार्ट्स';

  @override
  String get chart => 'चार्ट';

  @override
  String get spendingTrends => 'खर्च के रुझान';

  @override
  String get incomeVsExpense => 'आय बनाम खर्च';

  @override
  String get categoryBreakdown => 'कैटेगरी अनुसार विभाजन';

  @override
  String get overview => 'ओवरव्यू';

  @override
  String get report => 'रिपोर्ट';

  @override
  String get exportReport => 'रिपोर्ट एक्सपोर्ट करें';

  @override
  String get noData => 'कोई डेटा उपलब्ध नहीं';

  @override
  String get selectRange => 'रेंज चुनें';

  @override
  String get filter => 'फ़िल्टर';

  @override
  String get reset => 'रीसेट';

  @override
  String get weekly => 'साप्ताहिक';

  @override
  String get monthly => 'मासिक';

  @override
  String get yearly => 'वार्षिक';

  @override
  String get userNotLoggedIn =>
      'यूज़र लॉग इन नहीं है। डैशबोर्ड देखने के लिए लॉग इन करें।';

  @override
  String get user => 'यूज़र';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get welcomeBack => 'वापसी पर स्वागत है,';

  @override
  String get downloadPdfReport => 'PDF रिपोर्ट डाउनलोड करें';

  @override
  String get notifications => 'नोटिफिकेशन';

  @override
  String get permissionDeniedTitle => 'अनुमति अस्वीकृत';

  @override
  String permissionDeniedMessage(Object userId) {
    return 'अपने Firebase Firestore Security Rules जांचें (users/$userId).';
  }

  @override
  String get errorLoadingBalance => 'बैलेंस लोड करने में त्रुटि';

  @override
  String get balanceDataMissingTitle => 'बैलेंस डेटा नहीं मिला';

  @override
  String balanceDataMissingMessage(Object userId) {
    return 'सुनिश्चित करें कि users/$userId पर डॉक्यूमेंट मौजूद है और उसमें balance map फील्ड है।';
  }

  @override
  String errorLoadingStatsPermissionDenied(Object transactionId) {
    return 'स्टैट्स लोड करने में त्रुटि (Permission Denied). transactions/$transactionId के नियम जांचें।';
  }

  @override
  String get totalBalance => 'कुल बैलेंस';

  @override
  String get income => 'आय';

  @override
  String get expenses => 'खर्च';

  @override
  String get expense => 'खर्च';

  @override
  String get savings => 'बचत';

  @override
  String get transactions => 'लेन-देन';

  @override
  String get categories => 'कैटेगरी';

  @override
  String get pendingBills => 'बकाया बिल';

  @override
  String get spendingOverview => 'खर्च का ओवरव्यू';

  @override
  String get errorLoadingChartData => 'चार्ट डेटा लोड करने में त्रुटि।';

  @override
  String get noExpenseDataAvailable => 'कोई खर्च डेटा उपलब्ध नहीं';

  @override
  String get recentTransactions => 'हाल के लेन-देन';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String get errorLoadingTransactions => 'लेन-देन लोड करने में त्रुटि';

  @override
  String get noTransactionsYet => 'अभी कोई लेन-देन नहीं';

  @override
  String get transaction => 'लेन-देन';

  @override
  String get yourBudgets => 'आपके बजट';

  @override
  String get addExpense => 'खर्च जोड़ें';

  @override
  String get addIncome => 'आय जोड़ें';

  @override
  String get scanReceipt => 'रसीद स्कैन करें';

  @override
  String get title => 'शीर्षक';

  @override
  String get amount => 'राशि';

  @override
  String get category => 'कैटेगरी';

  @override
  String get notesOptional => 'नोट्स (वैकल्पिक)';

  @override
  String get descriptionOptional => 'विवरण (वैकल्पिक)';

  @override
  String get enterTitle => 'शीर्षक दर्ज करें';

  @override
  String get enterAmount => 'राशि दर्ज करें';

  @override
  String get invalidNumber => 'अमान्य संख्या';

  @override
  String get amountMustBeGreaterThanZero => 'राशि 0 से बड़ी होनी चाहिए';

  @override
  String get expenseFailedTitle => 'खर्च असफल';

  @override
  String expenseOverBalanceMessage(
    Object balance,
    Object expense,
    Object diff,
  ) {
    return 'आपका खर्च उपलब्ध बैलेंस से अधिक है।\n\nउपलब्ध बैलेंस: $balance\nखर्च: $expense\nकमी: $diff\n\nकृपया खर्च कम करें या पहले आय जोड़ें।';
  }

  @override
  String get ok => 'ठीक है';

  @override
  String get expenseAddedSuccessfully => 'खर्च सफलतापूर्वक जोड़ा गया';

  @override
  String get failedToAddExpense => 'खर्च जोड़ने में विफल';

  @override
  String get incomeAddedSuccessfully => 'आय सफलतापूर्वक जोड़ी गई!';

  @override
  String get failedToAddIncome => 'आय जोड़ने में विफल';

  @override
  String get food => 'खाना';

  @override
  String get transport => 'परिवहन';

  @override
  String get shopping => 'खरीदारी';

  @override
  String get bills => 'बिल';

  @override
  String get entertainment => 'मनोरंजन';

  @override
  String get health => 'स्वास्थ्य';

  @override
  String get education => 'शिक्षा';

  @override
  String get other => 'अन्य';

  @override
  String get rent => 'किराया';

  @override
  String get travel => 'यात्रा';

  @override
  String get salary => 'वेतन';

  @override
  String get freelance => 'फ्रीलांस';

  @override
  String get business => 'व्यवसाय';

  @override
  String get bonus => 'बोनस';

  @override
  String get gift => 'उपहार';

  @override
  String get expenseByCategory => 'कैटेगरी अनुसार खर्च';

  @override
  String get dailyExpenseTrend => 'दैनिक खर्च ट्रेंड';

  @override
  String get netSavings => 'कुल बचत';

  @override
  String get noDailyExpenseData => 'दैनिक खर्च डेटा उपलब्ध नहीं।';

  @override
  String get dayOfMonth => 'महीने का दिन';

  @override
  String get need => 'ज़रूरत';

  @override
  String get want => 'चाहत';

  @override
  String get saving => 'बचत';

  @override
  String get notEnoughPastData =>
      'प्रीडिक्ट करने के लिए पर्याप्त पुराना डेटा नहीं!';

  @override
  String predictedUsing(Object count) {
    return 'पिछले $count बजट के आधार पर अनुमान लगाया गया';
  }

  @override
  String errorPredicting(Object error) {
    return 'अनुमान में त्रुटि: $error';
  }

  @override
  String get budgetSavedSuccessfully => 'बजट सफलतापूर्वक सेव हो गया!';

  @override
  String get dynamicBudgetsTitle =>
      'डायनामिक बजट (बैलेंस के अनुसार ऑटो-एडजस्ट)';

  @override
  String get auto => 'ऑटो';

  @override
  String get predictFromHistory => 'हिस्ट्री से अनुमान';

  @override
  String get overBudgetReduce => 'बजट से ज्यादा! खर्च कम करें';

  @override
  String get applyAndSaveBudget => 'लागू करें और बजट सेव करें';

  @override
  String get balanceIsZeroHint =>
      'डैशबोर्ड का कुल बैलेंस 0 है। सुझाव पाने के लिए आय जोड़ें।';

  @override
  String usingDashboardBalanceHint(Object uid) {
    return 'डैशबोर्ड कुल बैलेंस (users/$uid.balance.totalBalance) पर 50/30/20 और कैटेगरी सुझाव लागू किए जा रहे हैं।';
  }

  @override
  String totalBalanceDashboard(Object currency, Object amount) {
    return 'कुल बैलेंस (डैशबोर्ड): $currency $amount';
  }

  @override
  String needsTarget(Object amount) {
    return 'ज़रूरतें (लक्ष्य: $amount)';
  }

  @override
  String wantsTarget(Object amount) {
    return 'चाहतें (लक्ष्य: $amount)';
  }

  @override
  String savingsTarget(Object amount) {
    return 'बचत (लक्ष्य: $amount)';
  }

  @override
  String get budgetDocNotFound =>
      'त्रुटि: एडिट के लिए बजट डॉक्यूमेंट नहीं मिला।';

  @override
  String editingBudget(Object periodKey) {
    return 'बजट एडिट हो रहा है: $periodKey';
  }

  @override
  String get enterAtLeastOneCategoryBudget =>
      'कम से कम एक कैटेगरी बजट दर्ज करें';

  @override
  String get budgetAlreadyExistsLoadToEdit =>
      'इस अवधि का बजट पहले से मौजूद है। एडिट के लिए लोड करें।';

  @override
  String get budgetUpdated => 'बजट अपडेट हो गया';

  @override
  String get budgetCreated => 'बजट बना दिया गया';

  @override
  String get budgetDeleted => 'बजट हटाया गया';

  @override
  String get editBudget => 'बजट एडिट करें';

  @override
  String get setBudget => 'बजट सेट करें';

  @override
  String get categoryBudgets => 'कैटेगरी बजट';

  @override
  String get updateBudget => 'बजट अपडेट करें';

  @override
  String get saveBudget => 'बजट सेव करें';

  @override
  String get deleteBudget => 'बजट हटाएं';

  @override
  String get viewEditOldBudgets => 'पुराने बजट देखें/एडिट करें';

  @override
  String get budgetPeriod => 'बजट अवधि';

  @override
  String get daily => 'दैनिक';

  @override
  String get customDays => 'कस्टम दिन';

  @override
  String get numberOfDays => 'दिनों की संख्या';

  @override
  String get currencyPrefix => 'Rs ';

  @override
  String get budgetDeletedSuccessfully => 'बजट सफलतापूर्वक हटाया गया!';

  @override
  String failedToDeleteBudget(Object error) {
    return 'बजट हटाने में विफल: $error';
  }

  @override
  String get confirmDeletion => 'हटाने की पुष्टि';

  @override
  String confirmDeleteBudgetMessage(Object periodKey) {
    return 'क्या आप वाकई $periodKey के बजट को हटाना चाहते हैं? यह वापस नहीं होगा।';
  }

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get close => 'बंद करें';

  @override
  String editBudgetPlaceholder(Object periodKey) {
    return '$periodKey बजट के लिए एडिट फीचर बनाना बाकी है। आमतौर पर यहाँ फॉर्म पर जाते हैं।';
  }

  @override
  String get noBudgetsFound => 'कोई बजट नहीं मिला';

  @override
  String get createFirstBudgetHint => 'शुरू करने के लिए अपना पहला बजट बनाएं।';

  @override
  String get edit => 'एडिट';

  @override
  String get total => 'कुल';

  @override
  String get tapToApplyBudget => 'इस बजट को लागू करने के लिए टैप करें';
}
