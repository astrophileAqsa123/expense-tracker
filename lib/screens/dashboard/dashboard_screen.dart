import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/budget_model.dart';
import '../add_transaction/add_income_screen.dart';
import '../add_transaction/add_expense_screen.dart';
import '../add_transaction/receipt_scanner.dart';
import '../analytics/analytics_screen.dart';
import '../setting/setting.dart';
import '../budget/budget_setup_screen.dart';
import '../transactions/transactions_screen.dart';
import '../budget/your_budget_screen.dart';
import 'package:provider/provider.dart';
import '../../provider/currency_provider.dart';



//  PDF Screen Import (adjust path if needed)
import '../pdf/pdf.dart';

//  Notifications Screen Import (adjust path if needed)
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

  String selectedPeriod = 'Month';
  bool isExpanded = false;

 
  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>(); // Assuming CurrencyProvider is defined and imported
    final user = _auth.currentUser;
    final userId = user?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'User not logged in. Please log in to view the dashboard.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _kBackgroundColor, // Set base background to Off-White
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
                      _buildYourBudgetCard(), // Budget card moved outside transactions
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
                backgroundColor: _kAccentColor, // Changed FAB color to Stormy Teal
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Icon(isExpanded ? Icons.close : Icons.add, size: 32, color: Colors.white), // Ensure icon is white
              ),
            ),
          ],
        ),
      ),
    );
  }
  // - Notification icon navigates to NotificationScreen
  // - Shows badge with unread notifications count (resolved == false)
 // ✅ UPDATED APP BAR:
  Widget _buildAppBar(String userId) {
    return SliverAppBar(
      expandedHeight: 110,
      floating: false,
      pinned: true,
      backgroundColor: _kAccentColor, // Use Stormy Teal as the base
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('users').doc(userId).snapshots(),
          builder: (context, snapshot) {
            String displayName = "User";
            String? photoUrl;

            final authUser = _auth.currentUser;

            if (snapshot.connectionState == ConnectionState.waiting) {
              displayName = "Loading...";
            }

            if (snapshot.hasData && snapshot.data!.exists) {
              final userData = snapshot.data!.data();

              displayName =
                  (userData?['name'] as String?) ??
                  (authUser?.displayName ?? "User");

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
                // Using a gradient based on the Stormy Teal for a rich header look
                gradient: LinearGradient(
                  colors: [
                    _kAccentColor,
                    _kAccentColor.withOpacity(0.9), // Slightly lighter shade
                  ],
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
                        backgroundImage:
                            (photoUrl != null && photoUrl.isNotEmpty)
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
                          const Text(
                            'Welcome back,',
                            style: TextStyle(
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

                  // ✅ PDF + Notifications (with unread badge)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                        tooltip: "Download PDF Report",
                        onPressed: () {
                          // NOTE: Assuming PdfGenerateScreen is defined and imported
                          // Otherwise, this will cause an error
                          // ignore: unnecessary_null_comparison
                          if (const PdfGenerateScreen() != null) { 
                            // This check is mainly to suppress analysis warnings for missing definitions
                          }
                          // Remove the above check and use the original navigation:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (_) => const PdfGenerateScreen(),
                           ),
                           );
                        },
                      ),
                      const SizedBox(width: 4),

                      // ✅ Notification badge using alerts collection
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
                                tooltip: "Notifications",
                                onPressed: () {
                                  // NOTE: Assuming NotificationScreen is defined and imported
                                  // Otherwise, this will cause an error
                                  // ignore: unnecessary_null_comparison
                                  if (const NotificationScreen() != null) {
                                    // This check is mainly to suppress analysis warnings for missing definitions
                                  }
                                  // Remove the above check and use the original navigation:
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
                                      color: _kDangerColor, // Changed badge color to Coral Glow
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
// ... (The rest of the class methods will follow in the next steps)

// ✅ REFACTORED: Balance Card (using Stormy Teal gradient)
  Widget _buildBalanceCard(String userId) {
    final currency = context.watch<CurrencyProvider>();
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (snapshot.error.toString().contains('permission-denied')) {
            return _buildErrorCard(
              'Permission Denied',
              'Check your Firebase Firestore Security Rules (users/{userId}).',
            );
          }
          return Center(
            child: Text('Error loading balance: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: _kAccentColor), // Themed loader
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data?.data() == null) {
          return _buildErrorCard(
            'Balance Data Missing',
            'Ensure a document exists at "users/{$userId}" and contains a "balance" map field.',
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final balance = data?['balance'] as Map<String, dynamic>?;

        final totalBalance =
            (balance?['totalBalance'] as num?)?.toDouble() ?? 0.0;
        final monthlyIncome =
            (balance?['monthlyIncome'] as num?)?.toDouble() ?? 0.0;
        final monthlyExpense =
            (balance?['monthlyExpense'] as num?)?.toDouble() ?? 0.0;

        final savingsRate = monthlyIncome > 0
            ? ((monthlyIncome - monthlyExpense) / monthlyIncome * 100)
            : 0.0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            // 🔹 THEMED GRADIENT: Using Stormy Teal shades
            gradient: LinearGradient(
              colors: [
                _kAccentColor,
                _kAccentColor.withOpacity(0.9), // Darker shade of teal
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              // 🔹 THEMED SHADOW: Using Stormy Teal for the shadow effect
              BoxShadow(
                color: _kAccentColor.withOpacity(0.35),
                blurRadius: 25, // Increased blur for a softer lift
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '${currency.symbol}${totalBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceItem(
                      'Income',
                      monthlyIncome,
                      Icons.arrow_upward,
                      _kSuccessColor, // Mint Leaf
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white24),
                  Expanded(
                    child: _buildBalanceItem(
                      'Expenses',
                      monthlyExpense,
                      Icons.arrow_downward,
                      _kDangerColor, // Coral Glow
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white24),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Savings',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${savingsRate.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  // ✅ REFACTORED: Balance Item Helper (used by the Balance Card)
  Widget _buildBalanceItem(
    
    String label,
    double amount,
    IconData icon,
    Color color, // Will be _kSuccessColor (Mint Leaf) or _kDangerColor (Coral Glow)
    
  ) {
    final currency = context.watch<CurrencyProvider>(); 
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${currency.symbol}${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ✅ REFACTORED: Error Card (using Coral Glow)
  Widget _buildErrorCard(String title, String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kDangerColor.withOpacity(0.1), // Coral Glow tint
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _kDangerColor, width: 1), // Coral Glow border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🛑 $title',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _kDangerColor, // Coral Glow text
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
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Error loading stats (Permission Denied). Check rules for transactions/{transactionId}.',
              style: TextStyle(color: _kDangerColor),
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
                  'Transactions',
                  transactionCount.toString(),
                  Icons.receipt_long,
                  _kAccentColor, // 🔹 THEMED: Stormy Teal
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Categories',
                  '8', // Static value for example
                  Icons.category,
                  _kSuccessColor, // 🔹 THEMED: Mint Leaf
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pending Bills',
                  '0', // Static value for example
                  Icons.pending_actions,
                  _kDangerColor, // 🔹 THEMED: Coral Glow
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ REFACTORED: Stat Card (Flat style)
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
          // 🔹 THEMED SHADOW: Consistent soft shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon color comes from the caller (_buildQuickStats)
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87, // Dark text for high contrast
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF718096), // Subtler grey text
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ✅ REFACTORED: Charts Section (Container style update)
  Widget _buildChartsSection(String userId) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20), // Standardized margin
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // 🔹 THEMED SHADOW: Consistent soft shadow
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
              const Text(
                'Spending Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Darker text
                ),
              ),
              // 🔹 THEMED: Dropdown button
              DropdownButton<String>(
                value: selectedPeriod,
                underline: const SizedBox(),
                style: TextStyle(color: _kAccentColor, fontSize: 14), // Text style
                icon: const Icon(Icons.arrow_drop_down, color: _kAccentColor), // Icon color
                items: ['Week', 'Month', 'Year'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.black87), // Ensure dropdown items are readable
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPeriod = newValue!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // NOTE: _buildPieChart(userId) widget is assumed to be implemented separately
          // Ensure that the chart lines/colors inside _buildPieChart also use the theme palette.
          SizedBox(height: 200, child: _buildPieChart(userId)), 
        ],
      ),
    );
  }

// ✅ REFACTORED: Pie Chart with Theme Palette
  Widget _buildPieChart(String userId) {
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
          return const Center(
            child: Text('Error loading chart data.', style: TextStyle(color: _kDangerColor)),
          );
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No expense data available', style: TextStyle(color: Colors.grey)));
        }

        Map<String, double> categoryTotals = {};
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
          final category = data['category'] ?? 'Other';
          categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
        }

        // 🔹 THEMED CHART PALETTE
        List<Color> themePalette = [
          _kAccentColor,      // Stormy Teal
          _kSuccessColor,     // Mint Leaf
          _kDangerColor,      // Coral Glow
          const Color(0xFFF8E16C), // Royal Gold
          const Color(0xFF2D3748), // Deep Slate
          const Color(0xFFCBD5E0), // Cool Grey
        ];

        double total = categoryTotals.values.fold(0, (sum, amount) => sum + amount);
        int index = 0;

        List<PieChartSectionData> sections = [];
        categoryTotals.forEach((category, amount) {
          sections.add(
            PieChartSectionData(
              value: amount,
              title: total > 0 ? '${(amount / total * 100).toStringAsFixed(0)}%' : '0%',
              color: themePalette[index % themePalette.length],
              radius: 55, // Slightly slimmer for minimalist look
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
            sectionsSpace: 3, // Increased space for "flat" look
            centerSpaceRadius: 45,
          ),
        );
      },
    );
  }

  // ✅ REFACTORED: Categories Grid
  Widget _buildCategoriesGrid() {
    final categories = [
      {'name': 'Food', 'icon': Icons.restaurant, 'color': _kAccentColor},
      {'name': 'Transport', 'icon': Icons.directions_car, 'color': _kSuccessColor},
      {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': _kDangerColor},
      {'name': 'Bills', 'icon': Icons.receipt, 'color': const Color(0xFFF8E16C)}, // Gold
      {'name': 'Entertain', 'icon': Icons.movie, 'color': const Color(0xFF6B46C1)}, // Purple accent
      {'name': 'Health', 'icon': Icons.local_hospital, 'color': const Color(0xFFE53E3E)}, // Red
      {'name': 'Education', 'icon': Icons.school, 'color': const Color(0xFF3182CE)}, // Blue
      {'name': 'Other', 'icon': Icons.more_horiz, 'color': const Color(0xFF718096)}, // Grey
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9, // Adjusted for label fit
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
                          color: catColor.withOpacity(0.12), // Subtle tint
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // 🔹 THEMED: Dark text
                ),
              ),
              TextButton(
                onPressed: () {
                  // Assuming TransactionsScreen is defined
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen()));
                },
                child: const Text(
                  'View All',
                  style: TextStyle(color: _kAccentColor, fontWeight: FontWeight.w600), // 🔹 THEMED: Stormy Teal link
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Transactions list
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
                return const Center(child: CircularProgressIndicator(color: _kAccentColor)); // 🔹 THEMED: Loader color
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading transactions',
                    style: TextStyle(color: _kDangerColor), // 🔹 THEMED: Coral Glow error
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
                           // 🔹 THEMED: Consistent soft shadow
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'No transactions yet',
                          style: TextStyle(color: Color(0xFF718096)),
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

                      return _buildTransactionItem(
                        data['category'] ?? 'Other',
                        data['description'] ?? 'Transaction',
                        (data['date'] as Timestamp).toDate(),
                        (data['amount'] as num?)?.toDouble() ?? 0.0,
                        data['type'] == 'income',
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // 👇 YOUR BUDGET CARD
                  _buildYourBudgetCard(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }


  // ✅ REFACTORED: Your Budget Card (Themed link style)
  Widget _buildYourBudgetCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Assuming YourBudgetsScreen is defined
        Navigator.push(context, MaterialPageRoute(builder: (_) => const YourBudgetsScreen()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            // 🔹 THEMED: Consistent soft shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Your Budgets',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87, // Dark text
              ),
            ),
            Icon(Icons.chevron_right, color: _kAccentColor), // 🔹 THEMED: Stormy Teal Icon
          ],
        ),
      ),
    );
  }

  // ✅ REFACTORED: Transaction Item (Themed colors and flat style)
  Widget _buildTransactionItem(
    String category,
    String description,
    DateTime date,
    double amount,
    bool isIncome,
  ) {
    IconData icon;
    Color color;
    final currency = context.watch<CurrencyProvider>(); 

    // 🔹 THEMED: Use the primary/accent colors for categories
    switch (category.toLowerCase()) {
      case 'food':
        icon = Icons.restaurant;
        color = _kDangerColor; // Coral Glow
        break;
      case 'transport':
        icon = Icons.directions_car;
        color = _kAccentColor; // Stormy Teal
        break;
      case 'shopping':
        icon = Icons.shopping_bag;
        color = const Color(0xFFF8E16C); // Royal Gold
        break;
      case 'income': // Special handling for income transactions
        icon = Icons.attach_money;
        color = _kSuccessColor;
        break;
      default:
        icon = Icons.category;
        color = const Color(0xFF718096); // Grey
    }

    // Determine the color for the amount text
    final amountColor = isIncome ? _kSuccessColor : _kDangerColor; // Mint Leaf vs Coral Glow

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // 🔹 THEMED: Consistent soft shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12), // Subtle tint background
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          // Description and Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600, 
                    color: Colors.black87, // Dark text
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(date),
                  style: const TextStyle(
                    fontSize: 12, 
                    color: Color(0xFF718096), // Subtler grey text
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            '${isIncome ? '+' : '-'}${currency.symbol}${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: amountColor, // Themed color
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedDialOverlay() {
    if (!isExpanded) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildSpeedDialOption(
          Icons.add,
          'Add Expense',
          const Color(0xFFF44336),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildSpeedDialOption(
          Icons.arrow_upward,
          'Add Income',
          const Color(0xFF4CAF50),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddIncomeScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildSpeedDialOption(
          Icons.camera_alt,
          'Scan Receipt',
          const Color(0xFF2196F3),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReceiptScannerScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }


  // ✅ REFACTORED: Speed Dial Option (Themed shadow and label text)
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
              // 🔹 THEMED: Consistent soft shadow
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
              color: Colors.black87, // Dark text
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          heroTag: label,
          mini: true,
          backgroundColor: color, // Uses the themed color passed in
          foregroundColor: Colors.white,
          onPressed: () {
            // Toggle logic remains
            // if (isExpanded) {
            //   setState(() {
            //     isExpanded = false;
            //   });
            // }
            onTap?.call();
          },
          child: Icon(icon, size: 20),
        ),
      ],
    );
  }


  // ✅ REFACTORED: Bottom Navigation Bar (Themed primary color)
  Widget _buildBottomNavigationBar() {
    // Assuming a selectedIndex or similar state variable exists
    const int currentIndex = 0; // Assume 'Home' is selected for styling purposes

    return BottomAppBar(
      color: Colors.white, // Clean white background
      surfaceTintColor: Colors.transparent, // Prevents system tinting
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 5, // Light elevation for flat style
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home
            IconButton(
              icon: Icon(
                Icons.home, 
                // Set color based on index or just the primary theme color
                color: currentIndex == 0 ? _kAccentColor : Colors.grey.shade600,
              ), 
              onPressed: () {},
            ),
            // Analytics
            IconButton(
              icon: Icon(
                Icons.bar_chart,
                color: currentIndex == 1 ? _kAccentColor : Colors.grey.shade600,
              ),
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyticsScreen()));
              },
            ),
            const SizedBox(width: 48), // Space for FAB
            // Budgets
            IconButton(
              icon: Icon(
                Icons.account_balance_wallet_outlined,
                color: currentIndex == 2 ? _kAccentColor : Colors.grey.shade600,
              ),
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const BudgetSetupScreen()));
              },
            ),
            // Settings
            IconButton(
              icon: Icon(
                Icons.settings,
                color: currentIndex == 3 ? _kAccentColor : Colors.grey.shade600,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}