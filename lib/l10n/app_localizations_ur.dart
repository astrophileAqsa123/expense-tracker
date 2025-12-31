// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get settings => 'سیٹنگز';

  @override
  String get general => 'عمومی';

  @override
  String get account => 'اکاؤنٹ';

  @override
  String get accountSubtitle => 'پروفائل، پاس ورڈ';

  @override
  String get language => 'زبان';

  @override
  String get currency => 'کرنسی';

  @override
  String get logout => 'لاگ آؤٹ';

  @override
  String get appearance => 'ظاہری شکل';

  @override
  String get darkMode => 'ڈارک موڈ';

  @override
  String get budgetFeatures => 'بجٹ فیچرز';

  @override
  String get advancedBudgetSetup => 'ایڈوانس بجٹ سیٹ اپ';

  @override
  String get advancedBudgetSubtitle => 'AI پیشن گوئی اور آٹو کیٹیگری';

  @override
  String get security => 'سیکیورٹی';

  @override
  String get privacySecurity => 'پرائیویسی اور سیکیورٹی';

  @override
  String get privacySecuritySubtitle => 'ایپ لاک، پرمیشنز';

  @override
  String get about => 'متعلق';

  @override
  String get aboutApp => 'ایپ کے بارے میں';

  @override
  String get dashboard => 'ڈیش بورڈ';

  @override
  String get analytics => 'اینالیٹکس';

  @override
  String get analysis => 'تجزیہ';

  @override
  String get graphs => 'گراف';

  @override
  String get graph => 'گراف';

  @override
  String get charts => 'چارٹس';

  @override
  String get chart => 'چارٹ';

  @override
  String get spendingTrends => 'خرچ کے رجحانات';

  @override
  String get incomeVsExpense => 'آمدنی بمقابلہ خرچ';

  @override
  String get categoryBreakdown => 'کیٹیگری کے لحاظ سے تقسیم';

  @override
  String get overview => 'جائزہ';

  @override
  String get report => 'رپورٹ';

  @override
  String get exportReport => 'رپورٹ ایکسپورٹ کریں';

  @override
  String get noData => 'کوئی ڈیٹا دستیاب نہیں';

  @override
  String get selectRange => 'رینج منتخب کریں';

  @override
  String get filter => 'فلٹر';

  @override
  String get reset => 'ری سیٹ';

  @override
  String get weekly => 'ہفتہ وار';

  @override
  String get monthly => 'ماہانہ';

  @override
  String get yearly => 'سالانہ';

  @override
  String get userNotLoggedIn =>
      'یوزر لاگ اِن نہیں ہے۔ ڈیش بورڈ دیکھنے کے لیے لاگ اِن کریں۔';

  @override
  String get user => 'یوزر';

  @override
  String get loading => 'لوڈ ہو رہا ہے...';

  @override
  String get welcomeBack => 'خوش آمدید،';

  @override
  String get downloadPdfReport => 'پی ڈی ایف رپورٹ ڈاؤن لوڈ کریں';

  @override
  String get notifications => 'نوٹیفکیشنز';

  @override
  String get permissionDeniedTitle => 'اجازت مسترد';

  @override
  String permissionDeniedMessage(Object userId) {
    return 'اپنے Firebase Firestore سیکیورٹی رولز چیک کریں (users/$userId).';
  }

  @override
  String get errorLoadingBalance => 'بیلنس لوڈ کرنے میں خرابی';

  @override
  String get balanceDataMissingTitle => 'بیلنس ڈیٹا موجود نہیں';

  @override
  String balanceDataMissingMessage(Object userId) {
    return 'یقینی بنائیں کہ users/$userId پر ڈاکیومنٹ موجود ہے اور اس میں balance map فیلڈ موجود ہے۔';
  }

  @override
  String errorLoadingStatsPermissionDenied(Object transactionId) {
    return 'اعداد و شمار لوڈ کرنے میں خرابی (Permission Denied). transactions/$transactionId کے رولز چیک کریں۔';
  }

  @override
  String get totalBalance => 'کل بیلنس';

  @override
  String get income => 'آمدنی';

  @override
  String get expenses => 'اخراجات';

  @override
  String get expense => 'خرچ';

  @override
  String get savings => 'بچت';

  @override
  String get transactions => 'لین دین';

  @override
  String get categories => 'کیٹیگریز';

  @override
  String get pendingBills => 'زیرِ التواء بلز';

  @override
  String get spendingOverview => 'اخراجات کا جائزہ';

  @override
  String get errorLoadingChartData => 'چارٹ ڈیٹا لوڈ کرنے میں خرابی۔';

  @override
  String get noExpenseDataAvailable => 'کوئی خرچ ڈیٹا دستیاب نہیں';

  @override
  String get recentTransactions => 'حالیہ لین دین';

  @override
  String get viewAll => 'سب دیکھیں';

  @override
  String get seeAll => 'سب دیکھیں';

  @override
  String get errorLoadingTransactions => 'لین دین لوڈ کرنے میں خرابی';

  @override
  String get noTransactionsYet => 'ابھی کوئی لین دین نہیں';

  @override
  String get transaction => 'لین دین';

  @override
  String get yourBudgets => 'آپ کے بجٹس';

  @override
  String get addExpense => 'خرچ شامل کریں';

  @override
  String get addIncome => 'آمدنی شامل کریں';

  @override
  String get scanReceipt => 'رسید اسکین کریں';

  @override
  String get title => 'عنوان';

  @override
  String get amount => 'رقم';

  @override
  String get category => 'کیٹیگری';

  @override
  String get notesOptional => 'نوٹس (اختیاری)';

  @override
  String get descriptionOptional => 'تفصیل (اختیاری)';

  @override
  String get enterTitle => 'عنوان درج کریں';

  @override
  String get enterAmount => 'رقم درج کریں';

  @override
  String get invalidNumber => 'غلط نمبر';

  @override
  String get amountMustBeGreaterThanZero => 'رقم 0 سے زیادہ ہونی چاہیے';

  @override
  String get expenseFailedTitle => 'خرچ ناکام';

  @override
  String expenseOverBalanceMessage(
    Object balance,
    Object expense,
    Object diff,
  ) {
    return 'آپ کا خرچ دستیاب بیلنس سے زیادہ ہے۔\n\nدستیاب بیلنس: $balance\nخرچ: $expense\nکمی: $diff\n\nبراہ کرم خرچ کم کریں یا پہلے آمدنی شامل کریں۔';
  }

  @override
  String get ok => 'ٹھیک ہے';

  @override
  String get expenseAddedSuccessfully => 'خرچ کامیابی سے شامل ہوگیا';

  @override
  String get failedToAddExpense => 'خرچ شامل کرنے میں ناکامی';

  @override
  String get incomeAddedSuccessfully => 'آمدنی کامیابی سے شامل ہوگئی!';

  @override
  String get failedToAddIncome => 'آمدنی شامل کرنے میں ناکامی';

  @override
  String get food => 'کھانا';

  @override
  String get transport => 'ٹرانسپورٹ';

  @override
  String get shopping => 'خریداری';

  @override
  String get bills => 'بلز';

  @override
  String get entertainment => 'تفریح';

  @override
  String get health => 'صحت';

  @override
  String get education => 'تعلیم';

  @override
  String get other => 'دیگر';

  @override
  String get rent => 'کرایہ';

  @override
  String get travel => 'سفر';

  @override
  String get salary => 'تنخواہ';

  @override
  String get freelance => 'فری لانس';

  @override
  String get business => 'کاروبار';

  @override
  String get bonus => 'بونس';

  @override
  String get gift => 'تحفہ';

  @override
  String get expenseByCategory => 'کیٹیگری کے لحاظ سے خرچ';

  @override
  String get dailyExpenseTrend => 'روزانہ خرچ کا رجحان';

  @override
  String get netSavings => 'خالص بچت';

  @override
  String get noDailyExpenseData => 'روزانہ خرچ کا کوئی ڈیٹا نہیں۔';

  @override
  String get dayOfMonth => 'مہینے کا دن';

  @override
  String get need => 'ضرورت';

  @override
  String get want => 'خواہش';

  @override
  String get saving => 'بچت';

  @override
  String get notEnoughPastData => 'پیش گوئی کے لیے کافی پرانا ڈیٹا نہیں!';

  @override
  String predictedUsing(Object count) {
    return 'پچھلے $count بجٹس کی بنیاد پر پیش گوئی کی گئی';
  }

  @override
  String errorPredicting(Object error) {
    return 'پیش گوئی میں خرابی: $error';
  }

  @override
  String get budgetSavedSuccessfully => 'بجٹ کامیابی سے محفوظ ہوگیا!';

  @override
  String get dynamicBudgetsTitle =>
      'ڈائنامک بجٹس (بیلنس کے مطابق خودکار ایڈجسٹ)';

  @override
  String get auto => 'آٹو';

  @override
  String get predictFromHistory => 'ہسٹری سے پیش گوئی';

  @override
  String get overBudgetReduce => 'بجٹ سے زیادہ! خرچ کم کریں';

  @override
  String get applyAndSaveBudget => 'اپلائی اور بجٹ محفوظ کریں';

  @override
  String get balanceIsZeroHint =>
      'ڈیش بورڈ کا کل بیلنس 0 ہے۔ سفارشات کے لیے آمدنی شامل کریں۔';

  @override
  String usingDashboardBalanceHint(Object uid) {
    return 'ڈیش بورڈ کے کل بیلنس (users/$uid.balance.totalBalance) پر 50/30/20 اور کیٹیگری سفارشات لاگو کی جا رہی ہیں۔';
  }

  @override
  String totalBalanceDashboard(Object currency, Object amount) {
    return 'کل بیلنس (ڈیش بورڈ): $currency $amount';
  }

  @override
  String needsTarget(Object amount) {
    return 'ضروریات (ہدف: $amount)';
  }

  @override
  String wantsTarget(Object amount) {
    return 'خواہشات (ہدف: $amount)';
  }

  @override
  String savingsTarget(Object amount) {
    return 'بچت (ہدف: $amount)';
  }

  @override
  String get budgetDocNotFound => 'خرابی: ایڈٹ کے لیے بجٹ ڈاکیومنٹ نہیں ملا۔';

  @override
  String editingBudget(Object periodKey) {
    return 'بجٹ ایڈٹ ہو رہا ہے: $periodKey';
  }

  @override
  String get enterAtLeastOneCategoryBudget =>
      'کم از کم ایک کیٹیگری بجٹ درج کریں';

  @override
  String get budgetAlreadyExistsLoadToEdit =>
      'اس مدت کا بجٹ پہلے سے موجود ہے۔ ایڈٹ کے لیے لوڈ کریں۔';

  @override
  String get budgetUpdated => 'بجٹ اپڈیٹ ہوگیا';

  @override
  String get budgetCreated => 'بجٹ بن گیا';

  @override
  String get budgetDeleted => 'بجٹ حذف ہوگیا';

  @override
  String get editBudget => 'بجٹ ایڈٹ کریں';

  @override
  String get setBudget => 'بجٹ سیٹ کریں';

  @override
  String get categoryBudgets => 'کیٹیگری بجٹس';

  @override
  String get updateBudget => 'بجٹ اپڈیٹ کریں';

  @override
  String get saveBudget => 'بجٹ محفوظ کریں';

  @override
  String get deleteBudget => 'بجٹ حذف کریں';

  @override
  String get viewEditOldBudgets => 'پرانے بجٹس دیکھیں/ایڈٹ کریں';

  @override
  String get budgetPeriod => 'بجٹ کی مدت';

  @override
  String get daily => 'روزانہ';

  @override
  String get customDays => 'اپنی مرضی کے دن';

  @override
  String get numberOfDays => 'دنوں کی تعداد';

  @override
  String get currencyPrefix => 'Rs ';

  @override
  String get budgetDeletedSuccessfully => 'بجٹ کامیابی سے حذف ہوگیا!';

  @override
  String failedToDeleteBudget(Object error) {
    return 'بجٹ حذف کرنے میں ناکامی: $error';
  }

  @override
  String get confirmDeletion => 'حذف کرنے کی تصدیق';

  @override
  String confirmDeleteBudgetMessage(Object periodKey) {
    return 'کیا آپ واقعی $periodKey کے بجٹ کو حذف کرنا چاہتے ہیں؟ یہ عمل واپس نہیں ہوگا۔';
  }

  @override
  String get cancel => 'کینسل';

  @override
  String get delete => 'حذف کریں';

  @override
  String get close => 'بند کریں';

  @override
  String editBudgetPlaceholder(Object periodKey) {
    return '$periodKey کے بجٹ کی ایڈٹ فیچر ابھی بنانی ہے۔ عموماً یہاں فارم کی طرف جائیں گے۔';
  }

  @override
  String get noBudgetsFound => 'کوئی بجٹ نہیں ملا';

  @override
  String get createFirstBudgetHint => 'شروع کرنے کے لیے اپنا پہلا بجٹ بنائیں۔';

  @override
  String get edit => 'ایڈٹ';

  @override
  String get total => 'کل';

  @override
  String get tapToApplyBudget => 'یہ بجٹ لاگو کرنے کے لیے ٹیپ کریں';
}
