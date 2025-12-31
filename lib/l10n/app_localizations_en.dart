// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get general => 'GENERAL';

  @override
  String get account => 'Account';

  @override
  String get accountSubtitle => 'Profile, password';

  @override
  String get language => 'Language';

  @override
  String get currency => 'Currency';

  @override
  String get logout => 'Logout';

  @override
  String get appearance => 'APPEARANCE';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get budgetFeatures => 'BUDGET FEATURES';

  @override
  String get advancedBudgetSetup => 'Advanced Budget Setup';

  @override
  String get advancedBudgetSubtitle => 'AI predictions & auto-category';

  @override
  String get security => 'SECURITY';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get privacySecuritySubtitle => 'App lock, permissions';

  @override
  String get about => 'ABOUT';

  @override
  String get aboutApp => 'About App';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get analytics => 'Analytics';

  @override
  String get analysis => 'Analysis';

  @override
  String get graphs => 'Graphs';

  @override
  String get graph => 'Graph';

  @override
  String get charts => 'Charts';

  @override
  String get chart => 'Chart';

  @override
  String get spendingTrends => 'Spending Trends';

  @override
  String get incomeVsExpense => 'Income vs Expense';

  @override
  String get categoryBreakdown => 'Category Breakdown';

  @override
  String get overview => 'Overview';

  @override
  String get report => 'Report';

  @override
  String get exportReport => 'Export Report';

  @override
  String get noData => 'No data available';

  @override
  String get selectRange => 'Select Range';

  @override
  String get filter => 'Filter';

  @override
  String get reset => 'Reset';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get userNotLoggedIn =>
      'User not logged in. Please log in to view the dashboard.';

  @override
  String get user => 'User';

  @override
  String get loading => 'Loading...';

  @override
  String get welcomeBack => 'Welcome back,';

  @override
  String get downloadPdfReport => 'Download PDF Report';

  @override
  String get notifications => 'Notifications';

  @override
  String get permissionDeniedTitle => 'Permission Denied';

  @override
  String permissionDeniedMessage(Object userId) {
    return 'Check your Firebase Firestore Security Rules (users/$userId).';
  }

  @override
  String get errorLoadingBalance => 'Error loading balance';

  @override
  String get balanceDataMissingTitle => 'Balance Data Missing';

  @override
  String balanceDataMissingMessage(Object userId) {
    return 'Ensure a document exists at users/$userId and contains a balance map field.';
  }

  @override
  String errorLoadingStatsPermissionDenied(Object transactionId) {
    return 'Error loading stats (Permission Denied). Check rules for transactions/$transactionId.';
  }

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get expense => 'Expense';

  @override
  String get savings => 'Savings';

  @override
  String get transactions => 'Transactions';

  @override
  String get categories => 'Categories';

  @override
  String get pendingBills => 'Pending Bills';

  @override
  String get spendingOverview => 'Spending Overview';

  @override
  String get errorLoadingChartData => 'Error loading chart data.';

  @override
  String get noExpenseDataAvailable => 'No expense data available';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get viewAll => 'View All';

  @override
  String get seeAll => 'See All';

  @override
  String get errorLoadingTransactions => 'Error loading transactions';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get transaction => 'Transaction';

  @override
  String get yourBudgets => 'Your Budgets';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get addIncome => 'Add Income';

  @override
  String get scanReceipt => 'Scan Receipt';

  @override
  String get title => 'Title';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get enterTitle => 'Enter title';

  @override
  String get enterAmount => 'Enter amount';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get amountMustBeGreaterThanZero => 'Amount must be > 0';

  @override
  String get expenseFailedTitle => 'Expense Failed';

  @override
  String expenseOverBalanceMessage(
    Object balance,
    Object expense,
    Object diff,
  ) {
    return 'Your expense is greater than your available balance.\n\nAvailable Balance: $balance\nExpense: $expense\nShort by: $diff\n\nPlease reduce expense or add income first.';
  }

  @override
  String get ok => 'OK';

  @override
  String get expenseAddedSuccessfully => 'Expense added successfully';

  @override
  String get failedToAddExpense => 'Failed to add expense';

  @override
  String get incomeAddedSuccessfully => 'Income added successfully!';

  @override
  String get failedToAddIncome => 'Failed to add income';

  @override
  String get food => 'Food';

  @override
  String get transport => 'Transport';

  @override
  String get shopping => 'Shopping';

  @override
  String get bills => 'Bills';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get health => 'Health';

  @override
  String get education => 'Education';

  @override
  String get other => 'Other';

  @override
  String get rent => 'Rent';

  @override
  String get travel => 'Travel';

  @override
  String get salary => 'Salary';

  @override
  String get freelance => 'Freelance';

  @override
  String get business => 'Business';

  @override
  String get bonus => 'Bonus';

  @override
  String get gift => 'Gift';

  @override
  String get expenseByCategory => 'Expense by Category';

  @override
  String get dailyExpenseTrend => 'Daily Expense Trend';

  @override
  String get netSavings => 'Net Savings';

  @override
  String get noDailyExpenseData => 'No daily expense data.';

  @override
  String get dayOfMonth => 'Day of Month';

  @override
  String get need => 'Need';

  @override
  String get want => 'Want';

  @override
  String get saving => 'Saving';

  @override
  String get notEnoughPastData => 'Not enough past data to predict!';

  @override
  String predictedUsing(Object count) {
    return 'Predicted using last $count budgets';
  }

  @override
  String errorPredicting(Object error) {
    return 'Error predicting: $error';
  }

  @override
  String get budgetSavedSuccessfully => 'Budget saved successfully!';

  @override
  String get dynamicBudgetsTitle =>
      'Dynamic Budgets (auto-adjust based on balance)';

  @override
  String get auto => 'Auto';

  @override
  String get predictFromHistory => 'Predict from History';

  @override
  String get overBudgetReduce => 'Over Budget! Reduce Spending';

  @override
  String get applyAndSaveBudget => 'Apply & Save Budget';

  @override
  String get balanceIsZeroHint =>
      'Dashboard total balance is 0. Add income to get recommendations.';

  @override
  String usingDashboardBalanceHint(Object uid) {
    return 'Using Dashboard Total Balance (users/$uid.balance.totalBalance) and applying 50/30/20 with category recommendations.';
  }

  @override
  String totalBalanceDashboard(Object currency, Object amount) {
    return 'Total Balance (Dashboard): $currency $amount';
  }

  @override
  String needsTarget(Object amount) {
    return 'Needs (Target: $amount)';
  }

  @override
  String wantsTarget(Object amount) {
    return 'Wants (Target: $amount)';
  }

  @override
  String savingsTarget(Object amount) {
    return 'Savings (Target: $amount)';
  }

  @override
  String get budgetDocNotFound =>
      'Error: Budget document not found for editing.';

  @override
  String editingBudget(Object periodKey) {
    return 'Editing budget: $periodKey';
  }

  @override
  String get enterAtLeastOneCategoryBudget =>
      'Please enter at least one category budget';

  @override
  String get budgetAlreadyExistsLoadToEdit =>
      'Budget for this period already exists. Load it to edit.';

  @override
  String get budgetUpdated => 'Budget updated';

  @override
  String get budgetCreated => 'Budget created';

  @override
  String get budgetDeleted => 'Budget deleted';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get setBudget => 'Set Budget';

  @override
  String get categoryBudgets => 'Category Budgets';

  @override
  String get updateBudget => 'Update Budget';

  @override
  String get saveBudget => 'Save Budget';

  @override
  String get deleteBudget => 'Delete Budget';

  @override
  String get viewEditOldBudgets => 'View/Edit Old Budgets';

  @override
  String get budgetPeriod => 'Budget Period';

  @override
  String get daily => 'Daily';

  @override
  String get customDays => 'Custom Days';

  @override
  String get numberOfDays => 'Number of days';

  @override
  String get currencyPrefix => 'Rs ';

  @override
  String get budgetDeletedSuccessfully => 'Budget deleted successfully!';

  @override
  String failedToDeleteBudget(Object error) {
    return 'Failed to delete budget: $error';
  }

  @override
  String get confirmDeletion => 'Confirm Deletion';

  @override
  String confirmDeleteBudgetMessage(Object periodKey) {
    return 'Are you sure you want to delete the budget for $periodKey? This action cannot be undone.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String editBudgetPlaceholder(Object periodKey) {
    return 'Implementing edit for budget $periodKey. You would typically navigate to a form here.';
  }

  @override
  String get noBudgetsFound => 'No budgets found';

  @override
  String get createFirstBudgetHint =>
      'Create your first budget to get started.';

  @override
  String get edit => 'Edit';

  @override
  String get total => 'Total';

  @override
  String get tapToApplyBudget => 'Tap to apply this budget';
}
