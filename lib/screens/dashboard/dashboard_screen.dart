import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../add_transaction/add_income_screen.dart';
import '../add_transaction/add_expense_screen.dart';
import '../add_transaction/receipt_scanner.dart';
import '../analytics/analytics_screen.dart';
import '../setting/setting.dart';
import '../budget/budget_setup_screen.dart';
// 1. ADD NEW IMPORT FOR THE TRANSACTION SCREEN
import '../transactions/transactions_screen.dart'; // <--- ASSUMED PATH

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
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Main Scrollable Content
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
                      // FINAL OVERFLOW FIX: Set to 160px to guarantee clearance
                      const SizedBox(height: 160),
                    ],
                  ),
                ),
              ],
            ),

            // 2. Expanded Speed Dial Overlay (Hidden when not expanded)
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

            // 3. Bottom Navigation Bar (Fixed Position)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNavigationBar(),
            ),

            // 4. Floating Action Button (Fixed Position)
            Positioned(
              bottom: 30,
              left: (MediaQuery.of(context).size.width / 2) - 30,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF6C63FF),
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Icon(isExpanded ? Icons.close : Icons.add, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET DEFINITIONS ---

// 1. UPDATED: _buildAppBar to stream profile photo and name
Widget _buildAppBar(String userId) {
    return SliverAppBar(
      expandedHeight: 110,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF6C63FF),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        // StreamBuilder listens to the 'users' document for real-time profile updates
        background: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('users').doc(userId).snapshots(),
          builder: (context, snapshot) {
            String displayName = "User";
            String? photoUrl;

            // Check if data is available and exists
            if (snapshot.hasData && snapshot.data!.exists) {
              final userData = snapshot.data!.data() as Map<String, dynamic>?;
              // Safely access fields. 'name' is the user name.
              displayName = userData?['name'] ?? "User";
              // 'profilePhoto' is the photo URL, updated from the Edit Profile screen.
              photoUrl = userData?['profilePhoto']; 
            }
            
            // Handle loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
               // Optionally show a basic placeholder while loading
               displayName = "Loading...";
            }


            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
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
                      // PROFILE PHOTO LOGIC
                      CircleAvatar(
                        radius: 25,
                        // Use NetworkImage if photoUrl is available and valid
                        backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) 
                            ? NetworkImage(photoUrl) 
                            : null,
                        backgroundColor: Colors.white24,
                        // Fallback icon if no photoUrl
                        child: (photoUrl == null || photoUrl.isEmpty) 
                            ? const Icon(Icons.person, color: Colors.white) 
                            : null,
                      ),
                      const SizedBox(width: 9),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          // Display the fetched user name
                          Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String userId) {
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
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data?.data() == null) {
          // Handles the "Balance Data Missing" scenario
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
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
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
                '\$${totalBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
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
                      Colors.green,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white24),
                  Expanded(
                    child: _buildBalanceItem(
                      'Expenses',
                      monthlyExpense,
                      Icons.arrow_downward,
                      Colors.red,
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

  Widget _buildBalanceItem(
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
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
          '\$${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
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
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🛑 $title',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
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
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Categories',
                  '8',
                  Icons.category,
                  const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pending Bills',
                  '2',
                  Icons.pending_actions,
                  const Color(0xFFF44336),
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
            color: Colors.black.withOpacity(0.05),
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
              color: Color(0xFF2D3748),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 19),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  color: Color(0xFF2D3748),
                ),
              ),
              DropdownButton<String>(
                value: selectedPeriod,
                underline: const SizedBox(),
                items: ['Week', 'Month', 'Year'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
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
          SizedBox(height: 200, child: _buildPieChart(userId)),
        ],
      ),
    );
  }

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
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading chart data (Permission Denied).'),
          );
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No expense data available'));
        }

        Map<String, double> categoryTotals = {};
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
          final category = data['category'] ?? 'Other';

          categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
        }

        List<PieChartSectionData> sections = [];
        List<Color> colors = [
          const Color(0xFFFF6384),
          const Color(0xFF36A2EB),
          const Color(0xFFFFCE56),
          const Color(0xFF4BC0C0),
          const Color(0xFF9966FF),
          const Color(0xFFFF9F40),
        ];

        double total = categoryTotals.values.fold(
          0,
          (sum, amount) => sum + amount,
        );
        int index = 0;
        categoryTotals.forEach((category, amount) {
          sections.add(
            PieChartSectionData(
              value: amount,
              title: total > 0
                  ? '${(amount / total * 100).toStringAsFixed(0)}%'
                  : '0%',
              color: colors[index % colors.length],
              radius: 60,
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
            sectionsSpace: 2,
            centerSpaceRadius: 40,
          ),
        );
      },
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      {
        'name': 'Food',
        'icon': Icons.restaurant,
        'color': const Color(0xFFFF6384),
      },
      {
        'name': 'Transport',
        'icon': Icons.directions_car,
        'color': const Color(0xFF36A2EB),
      },
      {
        'name': 'Shopping',
        'icon': Icons.shopping_bag,
        'color': const Color(0xFFFFCE56),
      },
      {
        'name': 'Bills',
        'icon': Icons.receipt,
        'color': const Color(0xFF4BC0C0),
      },
      {
        'name': 'Entertain',
        'icon': Icons.movie,
        'color': const Color(0xFF9966FF),
      },
      {
        'name': 'Health',
        'icon': Icons.local_hospital,
        'color': const Color(0xFFFF9F40),
      },
      {
        'name': 'Education',
        'icon': Icons.school,
        'color': const Color(0xFF4CAF50),
      },
      {
        'name': 'Other',
        'icon': Icons.more_horiz,
        'color': const Color(0xFF9E9E9E),
      },
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
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
              childAspectRatio: 1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to category details
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (category['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: category['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF718096),
                        ),
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

  // 2. UPDATED: _buildRecentTransactions to navigate to TransactionScreen on 'View All'
  Widget _buildRecentTransactions(String userId) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to the TransactionScreen when 'View All' is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionsScreen(),
                    ),
                  );
                },
                child: const Text('View All'),
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
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.data!.docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'No transactions yet',
                      style: TextStyle(color: Color(0xFF718096)),
                    ),
                  ),
                );
              }
              return ListView.builder(
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    String category,
    String description,
    DateTime date,
    double amount,
    bool isIncome,
  ) {
    IconData icon;
    Color color;
    switch (category.toLowerCase()) {
      case 'food':
        icon = Icons.restaurant;
        color = const Color(0xFFFF6384);
        break;
      case 'transport':
        icon = Icons.directions_car;
        color = const Color(0xFF36A2EB);
        break;
      case 'shopping':
        icon = Icons.shopping_bag;
        color = const Color(0xFFFFCE56);
        break;
      default:
        icon = Icons.category;
        color = const Color(0xFF9E9E9E);
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isIncome
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFF44336),
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
        // 🚀 ADD EXPENSE NAVIGATION
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
        // ⬆️ ADD INCOME NAVIGATION (Was already present)
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
        // 📸 SCAN RECEIPT NAVIGATION
        _buildSpeedDialOption(
          Icons.camera_alt,
          'Scan Receipt',
          const Color(0xFF2196F3),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReceiptScannerScreen(),
              ),
            );
          },
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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          heroTag: label,
          mini: true,
          backgroundColor: color,
          onPressed: () {
            // Close the speed dial first
            if (isExpanded) {
              setState(() {
                isExpanded = false;
              });
            }
            // Execute the provided navigation function
            onTap?.call();
          },
          child: Icon(icon, size: 20),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnalyticsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 48), // Spacer for the FAB
            IconButton(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BudgetSetupScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// NOTE: You must create the TransactionScreen class for the 'View All'
// functionality to work without errors.
/*
class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions')),
      body: const Center(child: Text('This is the dedicated Transaction Screen')),
    );
  }
}
*/