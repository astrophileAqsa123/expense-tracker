// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get settings => 'الإعدادات';

  @override
  String get general => 'عام';

  @override
  String get account => 'الحساب';

  @override
  String get accountSubtitle => 'الملف الشخصي، كلمة المرور';

  @override
  String get language => 'اللغة';

  @override
  String get currency => 'العملة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get appearance => 'المظهر';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get budgetFeatures => 'ميزات الميزانية';

  @override
  String get advancedBudgetSetup => 'إعداد الميزانية المتقدم';

  @override
  String get advancedBudgetSubtitle => 'توقعات بالذكاء الاصطناعي وتصنيف تلقائي';

  @override
  String get security => 'الأمان';

  @override
  String get privacySecurity => 'الخصوصية والأمان';

  @override
  String get privacySecuritySubtitle => 'قفل التطبيق، الأذونات';

  @override
  String get about => 'حول';

  @override
  String get aboutApp => 'حول التطبيق';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get analytics => 'التحليلات';

  @override
  String get analysis => 'تحليل';

  @override
  String get graphs => 'رسوم بيانية';

  @override
  String get graph => 'رسم بياني';

  @override
  String get charts => 'مخططات';

  @override
  String get chart => 'مخطط';

  @override
  String get spendingTrends => 'اتجاهات الإنفاق';

  @override
  String get incomeVsExpense => 'الدخل مقابل المصروف';

  @override
  String get categoryBreakdown => 'تفصيل حسب الفئة';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get report => 'تقرير';

  @override
  String get exportReport => 'تصدير التقرير';

  @override
  String get noData => 'لا توجد بيانات متاحة';

  @override
  String get selectRange => 'اختر النطاق';

  @override
  String get filter => 'تصفية';

  @override
  String get reset => 'إعادة ضبط';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get monthly => 'شهري';

  @override
  String get yearly => 'سنوي';

  @override
  String get userNotLoggedIn =>
      'المستخدم غير مسجل الدخول. يرجى تسجيل الدخول لعرض لوحة التحكم.';

  @override
  String get user => 'مستخدم';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get welcomeBack => 'مرحبًا بعودتك،';

  @override
  String get downloadPdfReport => 'تحميل تقرير PDF';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get permissionDeniedTitle => 'تم رفض الإذن';

  @override
  String permissionDeniedMessage(Object userId) {
    return 'تحقق من قواعد أمان Firebase Firestore (users/$userId).';
  }

  @override
  String get errorLoadingBalance => 'خطأ في تحميل الرصيد';

  @override
  String get balanceDataMissingTitle => 'بيانات الرصيد غير موجودة';

  @override
  String balanceDataMissingMessage(Object userId) {
    return 'تأكد من وجود مستند في users/$userId وأنه يحتوي على حقل balance من نوع map.';
  }

  @override
  String errorLoadingStatsPermissionDenied(Object transactionId) {
    return 'خطأ في تحميل الإحصائيات (Permission Denied). تحقق من القواعد لـ transactions/$transactionId.';
  }

  @override
  String get totalBalance => 'إجمالي الرصيد';

  @override
  String get income => 'الدخل';

  @override
  String get expenses => 'المصروفات';

  @override
  String get expense => 'مصروف';

  @override
  String get savings => 'الادخار';

  @override
  String get transactions => 'المعاملات';

  @override
  String get categories => 'الفئات';

  @override
  String get pendingBills => 'فواتير معلّقة';

  @override
  String get spendingOverview => 'نظرة عامة على الإنفاق';

  @override
  String get errorLoadingChartData => 'خطأ في تحميل بيانات المخطط.';

  @override
  String get noExpenseDataAvailable => 'لا توجد بيانات للمصروفات';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get errorLoadingTransactions => 'خطأ في تحميل المعاملات';

  @override
  String get noTransactionsYet => 'لا توجد معاملات بعد';

  @override
  String get transaction => 'معاملة';

  @override
  String get yourBudgets => 'ميزانياتك';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get addIncome => 'إضافة دخل';

  @override
  String get scanReceipt => 'مسح الإيصال';

  @override
  String get title => 'العنوان';

  @override
  String get amount => 'المبلغ';

  @override
  String get category => 'الفئة';

  @override
  String get notesOptional => 'ملاحظات (اختياري)';

  @override
  String get descriptionOptional => 'الوصف (اختياري)';

  @override
  String get enterTitle => 'أدخل العنوان';

  @override
  String get enterAmount => 'أدخل المبلغ';

  @override
  String get invalidNumber => 'رقم غير صالح';

  @override
  String get amountMustBeGreaterThanZero => 'يجب أن يكون المبلغ أكبر من 0';

  @override
  String get expenseFailedTitle => 'فشل المصروف';

  @override
  String expenseOverBalanceMessage(
    Object balance,
    Object expense,
    Object diff,
  ) {
    return 'مصروفك أكبر من الرصيد المتاح.\n\nالرصيد المتاح: $balance\nالمصروف: $expense\nالنقص: $diff\n\nقلل المصروف أو أضف دخلاً أولاً.';
  }

  @override
  String get ok => 'حسنًا';

  @override
  String get expenseAddedSuccessfully => 'تمت إضافة المصروف بنجاح';

  @override
  String get failedToAddExpense => 'فشل إضافة المصروف';

  @override
  String get incomeAddedSuccessfully => 'تمت إضافة الدخل بنجاح!';

  @override
  String get failedToAddIncome => 'فشل إضافة الدخل';

  @override
  String get food => 'طعام';

  @override
  String get transport => 'مواصلات';

  @override
  String get shopping => 'تسوق';

  @override
  String get bills => 'فواتير';

  @override
  String get entertainment => 'ترفيه';

  @override
  String get health => 'صحة';

  @override
  String get education => 'تعليم';

  @override
  String get other => 'أخرى';

  @override
  String get rent => 'إيجار';

  @override
  String get travel => 'سفر';

  @override
  String get salary => 'راتب';

  @override
  String get freelance => 'عمل حر';

  @override
  String get business => 'عمل/تجارة';

  @override
  String get bonus => 'مكافأة';

  @override
  String get gift => 'هدية';

  @override
  String get expenseByCategory => 'المصروف حسب الفئة';

  @override
  String get dailyExpenseTrend => 'اتجاه المصروف اليومي';

  @override
  String get netSavings => 'صافي الادخار';

  @override
  String get noDailyExpenseData => 'لا توجد بيانات للمصروف اليومي.';

  @override
  String get dayOfMonth => 'يوم الشهر';

  @override
  String get need => 'ضرورة';

  @override
  String get want => 'رغبة';

  @override
  String get saving => 'ادخار';

  @override
  String get notEnoughPastData => 'لا توجد بيانات سابقة كافية للتنبؤ!';

  @override
  String predictedUsing(Object count) {
    return 'تم التنبؤ باستخدام آخر $count ميزانيات';
  }

  @override
  String errorPredicting(Object error) {
    return 'خطأ في التنبؤ: $error';
  }

  @override
  String get budgetSavedSuccessfully => 'تم حفظ الميزانية بنجاح!';

  @override
  String get dynamicBudgetsTitle =>
      'ميزانيات ديناميكية (تعديل تلقائي حسب الرصيد)';

  @override
  String get auto => 'تلقائي';

  @override
  String get predictFromHistory => 'التنبؤ من السجل';

  @override
  String get overBudgetReduce => 'تجاوزت الميزانية! قلّل الإنفاق';

  @override
  String get applyAndSaveBudget => 'تطبيق وحفظ الميزانية';

  @override
  String get balanceIsZeroHint =>
      'إجمالي الرصيد في لوحة التحكم يساوي 0. أضف دخلاً للحصول على توصيات.';

  @override
  String usingDashboardBalanceHint(Object uid) {
    return 'استخدام إجمالي رصيد لوحة التحكم (users/$uid.balance.totalBalance) وتطبيق 50/30/20 مع توصيات حسب الفئة.';
  }

  @override
  String totalBalanceDashboard(Object currency, Object amount) {
    return 'إجمالي الرصيد (لوحة التحكم): $currency $amount';
  }

  @override
  String needsTarget(Object amount) {
    return 'الضروريات (الهدف: $amount)';
  }

  @override
  String wantsTarget(Object amount) {
    return 'الرغبات (الهدف: $amount)';
  }

  @override
  String savingsTarget(Object amount) {
    return 'الادخار (الهدف: $amount)';
  }

  @override
  String get budgetDocNotFound =>
      'خطأ: لم يتم العثور على مستند الميزانية للتعديل.';

  @override
  String editingBudget(Object periodKey) {
    return 'جارٍ تعديل الميزانية: $periodKey';
  }

  @override
  String get enterAtLeastOneCategoryBudget =>
      'يرجى إدخال ميزانية فئة واحدة على الأقل';

  @override
  String get budgetAlreadyExistsLoadToEdit =>
      'توجد ميزانية لهذه الفترة بالفعل. قم بتحميلها للتعديل.';

  @override
  String get budgetUpdated => 'تم تحديث الميزانية';

  @override
  String get budgetCreated => 'تم إنشاء الميزانية';

  @override
  String get budgetDeleted => 'تم حذف الميزانية';

  @override
  String get editBudget => 'تعديل الميزانية';

  @override
  String get setBudget => 'تعيين ميزانية';

  @override
  String get categoryBudgets => 'ميزانيات الفئات';

  @override
  String get updateBudget => 'تحديث الميزانية';

  @override
  String get saveBudget => 'حفظ الميزانية';

  @override
  String get deleteBudget => 'حذف الميزانية';

  @override
  String get viewEditOldBudgets => 'عرض/تعديل الميزانيات السابقة';

  @override
  String get budgetPeriod => 'فترة الميزانية';

  @override
  String get daily => 'يومي';

  @override
  String get customDays => 'أيام مخصصة';

  @override
  String get numberOfDays => 'عدد الأيام';

  @override
  String get currencyPrefix => 'Rs ';

  @override
  String get budgetDeletedSuccessfully => 'تم حذف الميزانية بنجاح!';

  @override
  String failedToDeleteBudget(Object error) {
    return 'فشل حذف الميزانية: $error';
  }

  @override
  String get confirmDeletion => 'تأكيد الحذف';

  @override
  String confirmDeleteBudgetMessage(Object periodKey) {
    return 'هل أنت متأكد أنك تريد حذف ميزانية $periodKey؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get close => 'إغلاق';

  @override
  String editBudgetPlaceholder(Object periodKey) {
    return 'يجري تنفيذ تعديل الميزانية $periodKey. عادةً ستنتقل إلى نموذج هنا.';
  }

  @override
  String get noBudgetsFound => 'لم يتم العثور على ميزانيات';

  @override
  String get createFirstBudgetHint => 'أنشئ أول ميزانية للبدء.';

  @override
  String get edit => 'تعديل';

  @override
  String get total => 'الإجمالي';

  @override
  String get tapToApplyBudget => 'اضغط لتطبيق هذه الميزانية';
}
