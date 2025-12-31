import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ur.dart';

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
    Locale('ur'),
    Locale('hi'),
    Locale('es'),
    Locale('ar'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get general;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Profile, password'**
  String get accountSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @budgetFeatures.
  ///
  /// In en, this message translates to:
  /// **'BUDGET FEATURES'**
  String get budgetFeatures;

  /// No description provided for @advancedBudgetSetup.
  ///
  /// In en, this message translates to:
  /// **'Advanced Budget Setup'**
  String get advancedBudgetSetup;

  /// No description provided for @advancedBudgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI predictions & auto-category'**
  String get advancedBudgetSubtitle;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get security;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @privacySecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'App lock, permissions'**
  String get privacySecuritySubtitle;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get about;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysis;

  /// No description provided for @graphs.
  ///
  /// In en, this message translates to:
  /// **'Graphs'**
  String get graphs;

  /// No description provided for @graph.
  ///
  /// In en, this message translates to:
  /// **'Graph'**
  String get graph;

  /// No description provided for @charts.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get charts;

  /// No description provided for @chart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get chart;

  /// No description provided for @spendingTrends.
  ///
  /// In en, this message translates to:
  /// **'Spending Trends'**
  String get spendingTrends;

  /// No description provided for @incomeVsExpense.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expense'**
  String get incomeVsExpense;

  /// No description provided for @categoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Category Breakdown'**
  String get categoryBreakdown;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @exportReport.
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get exportReport;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @selectRange.
  ///
  /// In en, this message translates to:
  /// **'Select Range'**
  String get selectRange;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in. Please log in to view the dashboard.'**
  String get userNotLoggedIn;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @downloadPdfReport.
  ///
  /// In en, this message translates to:
  /// **'Download PDF Report'**
  String get downloadPdfReport;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @permissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDeniedTitle;

  /// No description provided for @permissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your Firebase Firestore Security Rules (users/{userId}).'**
  String permissionDeniedMessage(Object userId);

  /// No description provided for @errorLoadingBalance.
  ///
  /// In en, this message translates to:
  /// **'Error loading balance'**
  String get errorLoadingBalance;

  /// No description provided for @balanceDataMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Balance Data Missing'**
  String get balanceDataMissingTitle;

  /// No description provided for @balanceDataMissingMessage.
  ///
  /// In en, this message translates to:
  /// **'Ensure a document exists at users/{userId} and contains a balance map field.'**
  String balanceDataMissingMessage(Object userId);

  /// No description provided for @errorLoadingStatsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Error loading stats (Permission Denied). Check rules for transactions/{transactionId}.'**
  String errorLoadingStatsPermissionDenied(Object transactionId);

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @pendingBills.
  ///
  /// In en, this message translates to:
  /// **'Pending Bills'**
  String get pendingBills;

  /// No description provided for @spendingOverview.
  ///
  /// In en, this message translates to:
  /// **'Spending Overview'**
  String get spendingOverview;

  /// No description provided for @errorLoadingChartData.
  ///
  /// In en, this message translates to:
  /// **'Error loading chart data.'**
  String get errorLoadingChartData;

  /// No description provided for @noExpenseDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No expense data available'**
  String get noExpenseDataAvailable;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @errorLoadingTransactions.
  ///
  /// In en, this message translates to:
  /// **'Error loading transactions'**
  String get errorLoadingTransactions;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// No description provided for @yourBudgets.
  ///
  /// In en, this message translates to:
  /// **'Your Budgets'**
  String get yourBudgets;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @addIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncome;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get scanReceipt;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter title'**
  String get enterTitle;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @amountMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be > 0'**
  String get amountMustBeGreaterThanZero;

  /// No description provided for @expenseFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense Failed'**
  String get expenseFailedTitle;

  /// No description provided for @expenseOverBalanceMessage.
  ///
  /// In en, this message translates to:
  /// **'Your expense is greater than your available balance.\n\nAvailable Balance: {balance}\nExpense: {expense}\nShort by: {diff}\n\nPlease reduce expense or add income first.'**
  String expenseOverBalanceMessage(Object balance, Object expense, Object diff);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @expenseAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Expense added successfully'**
  String get expenseAddedSuccessfully;

  /// No description provided for @failedToAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Failed to add expense'**
  String get failedToAddExpense;

  /// No description provided for @incomeAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Income added successfully!'**
  String get incomeAddedSuccessfully;

  /// No description provided for @failedToAddIncome.
  ///
  /// In en, this message translates to:
  /// **'Failed to add income'**
  String get failedToAddIncome;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @bills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get bills;

  /// No description provided for @entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rent;

  /// No description provided for @travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travel;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @freelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get freelance;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @bonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get bonus;

  /// No description provided for @gift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get gift;

  /// No description provided for @expenseByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense by Category'**
  String get expenseByCategory;

  /// No description provided for @dailyExpenseTrend.
  ///
  /// In en, this message translates to:
  /// **'Daily Expense Trend'**
  String get dailyExpenseTrend;

  /// No description provided for @netSavings.
  ///
  /// In en, this message translates to:
  /// **'Net Savings'**
  String get netSavings;

  /// No description provided for @noDailyExpenseData.
  ///
  /// In en, this message translates to:
  /// **'No daily expense data.'**
  String get noDailyExpenseData;

  /// No description provided for @dayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day of Month'**
  String get dayOfMonth;

  /// No description provided for @need.
  ///
  /// In en, this message translates to:
  /// **'Need'**
  String get need;

  /// No description provided for @want.
  ///
  /// In en, this message translates to:
  /// **'Want'**
  String get want;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get saving;

  /// No description provided for @notEnoughPastData.
  ///
  /// In en, this message translates to:
  /// **'Not enough past data to predict!'**
  String get notEnoughPastData;

  /// No description provided for @predictedUsing.
  ///
  /// In en, this message translates to:
  /// **'Predicted using last {count} budgets'**
  String predictedUsing(Object count);

  /// No description provided for @errorPredicting.
  ///
  /// In en, this message translates to:
  /// **'Error predicting: {error}'**
  String errorPredicting(Object error);

  /// No description provided for @budgetSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Budget saved successfully!'**
  String get budgetSavedSuccessfully;

  /// No description provided for @dynamicBudgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Dynamic Budgets (auto-adjust based on balance)'**
  String get dynamicBudgetsTitle;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @predictFromHistory.
  ///
  /// In en, this message translates to:
  /// **'Predict from History'**
  String get predictFromHistory;

  /// No description provided for @overBudgetReduce.
  ///
  /// In en, this message translates to:
  /// **'Over Budget! Reduce Spending'**
  String get overBudgetReduce;

  /// No description provided for @applyAndSaveBudget.
  ///
  /// In en, this message translates to:
  /// **'Apply & Save Budget'**
  String get applyAndSaveBudget;

  /// No description provided for @balanceIsZeroHint.
  ///
  /// In en, this message translates to:
  /// **'Dashboard total balance is 0. Add income to get recommendations.'**
  String get balanceIsZeroHint;

  /// No description provided for @usingDashboardBalanceHint.
  ///
  /// In en, this message translates to:
  /// **'Using Dashboard Total Balance (users/{uid}.balance.totalBalance) and applying 50/30/20 with category recommendations.'**
  String usingDashboardBalanceHint(Object uid);

  /// No description provided for @totalBalanceDashboard.
  ///
  /// In en, this message translates to:
  /// **'Total Balance (Dashboard): {currency} {amount}'**
  String totalBalanceDashboard(Object currency, Object amount);

  /// No description provided for @needsTarget.
  ///
  /// In en, this message translates to:
  /// **'Needs (Target: {amount})'**
  String needsTarget(Object amount);

  /// No description provided for @wantsTarget.
  ///
  /// In en, this message translates to:
  /// **'Wants (Target: {amount})'**
  String wantsTarget(Object amount);

  /// No description provided for @savingsTarget.
  ///
  /// In en, this message translates to:
  /// **'Savings (Target: {amount})'**
  String savingsTarget(Object amount);

  /// No description provided for @budgetDocNotFound.
  ///
  /// In en, this message translates to:
  /// **'Error: Budget document not found for editing.'**
  String get budgetDocNotFound;

  /// No description provided for @editingBudget.
  ///
  /// In en, this message translates to:
  /// **'Editing budget: {periodKey}'**
  String editingBudget(Object periodKey);

  /// No description provided for @enterAtLeastOneCategoryBudget.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least one category budget'**
  String get enterAtLeastOneCategoryBudget;

  /// No description provided for @budgetAlreadyExistsLoadToEdit.
  ///
  /// In en, this message translates to:
  /// **'Budget for this period already exists. Load it to edit.'**
  String get budgetAlreadyExistsLoadToEdit;

  /// No description provided for @budgetUpdated.
  ///
  /// In en, this message translates to:
  /// **'Budget updated'**
  String get budgetUpdated;

  /// No description provided for @budgetCreated.
  ///
  /// In en, this message translates to:
  /// **'Budget created'**
  String get budgetCreated;

  /// No description provided for @budgetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Budget deleted'**
  String get budgetDeleted;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @setBudget.
  ///
  /// In en, this message translates to:
  /// **'Set Budget'**
  String get setBudget;

  /// No description provided for @categoryBudgets.
  ///
  /// In en, this message translates to:
  /// **'Category Budgets'**
  String get categoryBudgets;

  /// No description provided for @updateBudget.
  ///
  /// In en, this message translates to:
  /// **'Update Budget'**
  String get updateBudget;

  /// No description provided for @saveBudget.
  ///
  /// In en, this message translates to:
  /// **'Save Budget'**
  String get saveBudget;

  /// No description provided for @deleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get deleteBudget;

  /// No description provided for @viewEditOldBudgets.
  ///
  /// In en, this message translates to:
  /// **'View/Edit Old Budgets'**
  String get viewEditOldBudgets;

  /// No description provided for @budgetPeriod.
  ///
  /// In en, this message translates to:
  /// **'Budget Period'**
  String get budgetPeriod;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @customDays.
  ///
  /// In en, this message translates to:
  /// **'Custom Days'**
  String get customDays;

  /// No description provided for @numberOfDays.
  ///
  /// In en, this message translates to:
  /// **'Number of days'**
  String get numberOfDays;

  /// No description provided for @currencyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Rs '**
  String get currencyPrefix;

  /// No description provided for @budgetDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Budget deleted successfully!'**
  String get budgetDeletedSuccessfully;

  /// No description provided for @failedToDeleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete budget: {error}'**
  String failedToDeleteBudget(Object error);

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @confirmDeleteBudgetMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the budget for {periodKey}? This action cannot be undone.'**
  String confirmDeleteBudgetMessage(Object periodKey);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @editBudgetPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Implementing edit for budget {periodKey}. You would typically navigate to a form here.'**
  String editBudgetPlaceholder(Object periodKey);

  /// No description provided for @noBudgetsFound.
  ///
  /// In en, this message translates to:
  /// **'No budgets found'**
  String get noBudgetsFound;

  /// No description provided for @createFirstBudgetHint.
  ///
  /// In en, this message translates to:
  /// **'Create your first budget to get started.'**
  String get createFirstBudgetHint;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @tapToApplyBudget.
  ///
  /// In en, this message translates to:
  /// **'Tap to apply this budget'**
  String get tapToApplyBudget;
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
      <String>['ar', 'en', 'es', 'hi', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hi':
      return AppLocalizationsHi();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
