import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../provider/currency_provider.dart';
import '../../l10n/app_localizations.dart';

import '../add_transaction/add_income_screen.dart';
import '../add_transaction/add_expense_screen.dart';
import '../add_transaction/receipt_scanner.dart';
import '../analytics/analytics_screen.dart';
import '../setting/setting.dart';
import '../budget/budget_setup_screen.dart';
import '../transactions/transactions_screen.dart';
import '../budget/your_budget_screen.dart';
import '../pdf/pdf.dart';
import '../notification/notification_screen.dart';

const Color kStormyTeal = Color(0xFF156064);
const Color kMintLeaf = Color(0xFF00C49A);
const Color kCoralGlow = Color(0xFFFB8F67);

// Background and Accent Colors for this screen
const Color _kBackgroundColor = Color(0xFFFAFAFA); // Off-White
const Color _kAccentColor = kStormyTeal;
const Color _kDangerColor = kCoralGlow;
const Color _kSuccessColor = kMintLeaf;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Keep internal values in English for logic/queries
  /// UI will show localized labels.
  String selectedPeriod = 'Month';

  bool isExpanded = false;

  String _categoryLabel(AppLocalizations t, String rawCategory) {
    final c = rawCategory.trim().toLowerCase();
    switch (c) {
      case 'food':
        return t.food;
      case 'transport':
        return t.transport;
      case 'shopping':
        return t.shopping;
      case 'bills':
        return t.bills;
      case 'entertain':
      case 'entertainment':
        return t.entertainment;
      case 'health':
        return t.health;
      case 'education':
        return t.education;
      case 'other':
      default:
        return t.other;
    }
  }

  String _periodLabel(AppLocalizations t, String value) {
    switch (value) {
      case 'Week':
        return t.weekly;
      case 'Month':
        return t.monthly;
      case 'Year':
        return t.yearly;
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = _auth.currentUser;
    final userId = user?.uid;

    if (userId == null) {
      return Scaffold(body: Center(child: Text(t.userNotLoggedIn)));
    }

    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildAppBar(userId),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildBalanceCard(userId),
                      const SizedBox(height: 20),
                      _buildQuickStats(userId),
                      const SizedBox(height: 20),
                      _buildChartsSection(userId),
                      const SizedBox(height: 20),
                      _buildCategoriesGrid(),
                      const SizedBox(height: 20),
                      _buildRecentTransactions(userId),
                      const SizedBox(height: 24),
                      _buildYourBudgetCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 80,
              right: 20,
              left: 20,
              child: AnimatedOpacity(
                opacity: isExpanded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !isExpanded,
                  child: _buildSpeedDialOverlay(),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNavigationBar(),
            ),
            Positioned(
              bottom: 30,
              left: (MediaQuery.of(context).size.width / 2) - 30,
              child: FloatingActionButton(
                backgroundColor: _kAccentColor,
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Icon(
                  isExpanded ? Icons.close : Icons.add,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(String userId) {
    final t = AppLocalizations.of(context)!;

    return SliverAppBar(
      expandedHeight: 110,
      floating: false,
      pinned: true,
      backgroundColor: _kAccentColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('users').doc(userId).snapshots(),
          builder: (context, snapshot) {
            String displayName = t.user;
            String? photoUrl;

            final authUser = _auth.currentUser;

            if (snapshot.connectionState == ConnectionState.waiting) {
              displayName = t.loading;
            }

            if (snapshot.hasData && snapshot.data!.exists) {
              final userData = snapshot.data!.data();

              displayName =
                  (userData?['name'] as String?) ?? (authUser?.displayName ?? t.user);

              final String? dbPhotoUrl = userData?['imageUrl'] as String?;
              final photoUpdatedAt = userData?['photoUpdatedAt'];

              if (dbPhotoUrl != null && dbPhotoUrl.isNotEmpty) {
                photoUrl = dbPhotoUrl;
                if (photoUpdatedAt != null) {
                  photoUrl = "$photoUrl?v=${photoUpdatedAt.toString()}";
                }
              } else {
                photoUrl = authUser?.photoURL;
              }
            }

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_kAccentColor, _kAccentColor.withOpacity(0.9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                            ? NetworkImage(photoUrl)
                            : null,
                        backgroundColor: Colors.white24,
                        child: (photoUrl == null || photoUrl.isEmpty)
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 9),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            t.welcomeBack,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                        tooltip: t.downloadPdfReport,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PdfGenerateScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _firestore
                            .collection('users')
                            .doc(userId)
                            .collection('alerts')
                            .where('resolved', isEqualTo: false)
                            .snapshots(),
                        builder: (context, alertSnap) {
                          final unreadCount = alertSnap.data?.docs.length ?? 0;

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                tooltip: t.notifications,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const NotificationScreen(),
                                    ),
                                  );
                                },
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _kDangerColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    child: Center(
                                      child: Text(
                                        unreadCount > 99 ? "99+" : "$unreadCount",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ✅ UPDATED: prevents bottom overflow in Arabic/large fonts
  Widget _buildBalanceCard(String userId) {
    final t = AppLocalizations.of(context)!;
    final currency = context.watch<CurrencyProvider>();

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (snapshot.error.toString().contains('permission-denied')) {
            return _buildErrorCard(
              t.permissionDeniedTitle,
              t.permissionDeniedMessage(snapshot.error!),
            );
          }
          return Center(
            child: Text('${t.errorLoadingBalance}: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: _kAccentColor),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data?.data() == null) {
          return _buildErrorCard(
            t.balanceDataMissingTitle,
            t.balanceDataMissingMessage(snapshot.error ?? ''),
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final balance = data?['balance'] as Map<String, dynamic>?;

        final totalBalance = (balance?['totalBalance'] as num?)?.toDouble() ?? 0.0;
        final monthlyIncome = (balance?['monthlyIncome'] as num?)?.toDouble() ?? 0.0;
        final monthlyExpense = (balance?['monthlyExpense'] as num?)?.toDouble() ?? 0.0;

        final savingsRate = monthlyIncome > 0
            ? ((monthlyIncome - monthlyExpense) / monthlyIncome * 100)
            : 0.0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_kAccentColor, _kAccentColor.withOpacity(0.9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _kAccentColor.withOpacity(0.35),
                blurRadius: 25,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  t.totalBalance,
                  maxLines: 1,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),

              // ✅ also safe for large fonts
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${currency.symbol}${totalBalance.toStringAsFixed(2)}',
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ✅ FIX: scale-down + no wrap => no bottom overflow
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceItem(
                      t.income,
                      monthlyIncome,
                      Icons.arrow_upward,
                      _kSuccessColor,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white24),
                  Expanded(
                    child: _buildBalanceItem(
                      t.expenses,
                      monthlyExpense,
                      Icons.arrow_downward,
                      _kDangerColor,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white24),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            t.savings,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${savingsRate.toStringAsFixed(1)}%',
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ UPDATED: prevents wrapping and overflow for labels/values
  Widget _buildBalanceItem(
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    final currency = context.watch<CurrencyProvider>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${currency.symbol}${amount.toStringAsFixed(0)}',
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String title, String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kDangerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _kDangerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🛑 $title',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _kDangerColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(String userId) {
    final t = AppLocalizations.of(context)!;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where(
            'date',
            isGreaterThan: DateTime.now().subtract(const Duration(days: 30)),
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              t.errorLoadingStatsPermissionDenied(snapshot.error!),
              style: const TextStyle(color: _kDangerColor),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 100);
        }

        final transactions = snapshot.data?.docs ?? [];
        final transactionCount = transactions.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  t.transactions,
                  transactionCount.toString(),
                  Icons.receipt_long,
                  _kAccentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  t.categories,
                  '8',
                  Icons.category,
                  _kSuccessColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  t.pendingBills,
                  '0',
                  Icons.pending_actions,
                  _kDangerColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(String userId) {
    final t = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.spendingOverview,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              DropdownButton<String>(
                value: selectedPeriod,
                underline: const SizedBox(),
                style: const TextStyle(color: _kAccentColor, fontSize: 14),
                icon: const Icon(Icons.arrow_drop_down, color: _kAccentColor),
                items: const ['Week', 'Month', 'Year']
                    .map((v) => DropdownMenuItem<String>(
                          value: v,
                          child: Text(
                            v,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ))
                    .toList()
                    .map((item) {
                      return DropdownMenuItem<String>(
                        value: item.value,
                        child: Text(
                          _periodLabel(t, item.value!),
                          style: const TextStyle(color: Colors.black87),
                        ),
                      );
                    })
                    .toList(),
                onChanged: (String? newValue) {
                  if (newValue == null) return;
                  setState(() => selectedPeriod = newValue);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 200, child: _buildPieChart(userId)),
        ],
      ),
    );
  }

  Widget _buildPieChart(String userId) {
    final t = AppLocalizations.of(context)!;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('type', isEqualTo: 'expense')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _kAccentColor));
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              t.errorLoadingChartData,
              style: const TextStyle(color: _kDangerColor),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              t.noExpenseDataAvailable,
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        final Map<String, double> categoryTotals = {};
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
          final category = (data['category'] as String?) ?? 'Other';
          categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
        }

        final List<Color> themePalette = [
          _kAccentColor,
          _kSuccessColor,
          _kDangerColor,
          const Color(0xFFF8E16C),
          const Color(0xFF2D3748),
          const Color(0xFFCBD5E0),
        ];

        final total = categoryTotals.values.fold<double>(0, (sum, a) => sum + a);
        int index = 0;

        final List<PieChartSectionData> sections = [];
        categoryTotals.forEach((category, amount) {
          sections.add(
            PieChartSectionData(
              value: amount,
              title: total > 0 ? '${(amount / total * 100).toStringAsFixed(0)}%' : '0%',
              color: themePalette[index % themePalette.length],
              radius: 55,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
          index++;
        });

        return PieChart(
          PieChartData(
            sections: sections,
            sectionsSpace: 3,
            centerSpaceRadius: 45,
          ),
        );
      },
    );
  }

  Widget _buildCategoriesGrid() {
    final t = AppLocalizations.of(context)!;

    final categories = [
      {'key': 'food', 'name': t.food, 'icon': Icons.restaurant, 'color': _kAccentColor},
      {'key': 'transport', 'name': t.transport, 'icon': Icons.directions_car, 'color': _kSuccessColor},
      {'key': 'shopping', 'name': t.shopping, 'icon': Icons.shopping_bag, 'color': _kDangerColor},
      {'key': 'bills', 'name': t.bills, 'icon': Icons.receipt, 'color': const Color(0xFFF8E16C)},
      {'key': 'entertainment', 'name': t.entertainment, 'icon': Icons.movie, 'color': const Color(0xFF6B46C1)},
      {'key': 'health', 'name': t.health, 'icon': Icons.local_hospital, 'color': const Color(0xFFE53E3E)},
      {'key': 'education', 'name': t.education, 'icon': Icons.school, 'color': const Color(0xFF3182CE)},
      {'key': 'other', 'name': t.other, 'icon': Icons.more_horiz, 'color': const Color(0xFF718096)},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.categories,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final Color catColor = category['color'] as Color;

              return GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: catColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category['name'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A5568),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(String userId) {
    final t = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.recentTransactions,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                  );
                },
                child: Text(
                  t.viewAll,
                  style: const TextStyle(
                    color: _kAccentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .doc(userId)
                .collection('transactions')
                .orderBy('date', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: _kAccentColor));
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    t.errorLoadingTransactions,
                    style: const TextStyle(color: _kDangerColor),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          t.noTransactionsYet,
                          style: const TextStyle(color: Color(0xFF718096)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildYourBudgetCard(),
                  ],
                );
              }

              return Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final rawCategory = (data['category'] as String?) ?? 'Other';
                      final displayCategory = _categoryLabel(t, rawCategory);

                      return _buildTransactionItem(
                        rawCategory,
                        displayCategory,
                        (data['description'] as String?) ?? t.transaction,
                        (data['date'] as Timestamp).toDate(),
                        (data['amount'] as num?)?.toDouble() ?? 0.0,
                        data['type'] == 'income',
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildYourBudgetCard(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildYourBudgetCard() {
    final t = AppLocalizations.of(context)!;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const YourBudgetsScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.yourBudgets,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Icon(Icons.chevron_right, color: _kAccentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String rawCategory,
    String displayCategory,
    String description,
    DateTime date,
    double amount,
    bool isIncome,
  ) {
    IconData icon;
    Color color;
    final currency = context.watch<CurrencyProvider>();

    switch (rawCategory.toLowerCase()) {
      case 'food':
        icon = Icons.restaurant;
        color = _kDangerColor;
        break;
      case 'transport':
        icon = Icons.directions_car;
        color = _kAccentColor;
        break;
      case 'shopping':
        icon = Icons.shopping_bag;
        color = const Color(0xFFF8E16C);
        break;
      case 'income':
        icon = Icons.attach_money;
        color = _kSuccessColor;
        break;
      default:
        icon = Icons.category;
        color = const Color(0xFF718096);
    }

    final amountColor = isIncome ? _kSuccessColor : _kDangerColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${displayCategory} • ${DateFormat('MMM dd, yyyy').format(date)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${currency.symbol}${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedDialOverlay() {
    if (!isExpanded) return const SizedBox.shrink();
    final t = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildSpeedDialOption(
          Icons.add,
          t.addExpense,
          const Color(0xFFF44336),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _buildSpeedDialOption(
          Icons.arrow_upward,
          t.addIncome,
          const Color(0xFF4CAF50),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddIncomeScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _buildSpeedDialOption(
          Icons.camera_alt,
          t.scanReceipt,
          const Color(0xFF2196F3),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReceiptScannerScreen()),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSpeedDialOption(
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          heroTag: label,
          mini: true,
          backgroundColor: color,
          foregroundColor: Colors.white,
          onPressed: onTap,
          child: Icon(icon, size: 20),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    const int currentIndex = 0;

    return BottomAppBar(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: currentIndex == 0 ? _kAccentColor : Colors.grey.shade600,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.bar_chart,
                color: currentIndex == 1 ? _kAccentColor : Colors.grey.shade600,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              ),
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: Icon(
                Icons.account_balance_wallet_outlined,
                color: currentIndex == 2 ? _kAccentColor : Colors.grey.shade600,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BudgetSetupScreen()),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.settings,
                color: currentIndex == 3 ? _kAccentColor : Colors.grey.shade600,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
