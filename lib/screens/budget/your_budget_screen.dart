import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/budget_model.dart';
import '../../provider/currency_provider.dart';

// --- THEME COLOR DEFINITIONS ---
const Color kStormyTeal = Color(0xFF156064);
const Color kLightTeal = Color(0xFFE0F2F1);
const Color kBackground = Color(0xFFF5F7FA);
// -------------------------------

class YourBudgetsScreen extends StatelessWidget {
  const YourBudgetsScreen({super.key});

  // Function to handle budget deletion
  void _deleteBudget(BuildContext context, String docId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final firestore = FirebaseFirestore.instance;

    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(docId)
          .delete();
      
      // Optionally show a confirmation to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget deleted successfully!')),
      );
    } catch (e) {
      // Show error to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete budget: $e')),
      );
    }
  }

  // Dialog to confirm deletion
  void _confirmDelete(BuildContext context, BudgetModel budget) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete the budget for ${budget.periodKey}? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                _deleteBudget(context, budget.docId!); // Perform deletion
              },
            ),
          ],
        );
      },
    );
  }

  // Placeholder for the Edit Dialog/Screen
  void _editBudget(BuildContext context, BudgetModel budget) {
    // Implement your navigation to the edit screen or show an edit dialog here.
    // For a simple placeholder, we'll show a basic alert.
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Budget'),
          content: Text(
              'Implementing edit for budget ${budget.periodKey}. You would typically navigate to a form here.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text(
          'Your Budgets',
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: kStormyTeal),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('users')
            .doc(userId)
            .collection('budgets')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: kStormyTeal));
          }

          if (snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final budgets = snapshot.data!.docs
              .map((doc) => BudgetModel.fromMap(doc.data() as Map<String, dynamic>)
                  .copyWith(docId: doc.id))
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: budgets.length,
            separatorBuilder: (ctx, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return _BudgetCardWithActions(
                budget: budget,
                currencySymbol: currency.symbol,
                onEdit: () => _editBudget(context, budget),
                onDelete: () => _confirmDelete(context, budget),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No budgets found',
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first budget to get started.',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// --- NEW WIDGET TO WRAP THE CARD WITH ACTIONS ---
class _BudgetCardWithActions extends StatelessWidget {
  final BudgetModel budget;
  final String currencySymbol;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BudgetCardWithActions({
    required this.budget,
    required this.currencySymbol,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _BudgetCard(budget: budget, currencySymbol: currencySymbol),
        // Position the actions button
        Positioned(
          top: 8,
          right: 8,
          child: PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'edit') {
                onEdit();
              } else if (result == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit, color: kStormyTeal),
                  title: Text('Edit'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete'),
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ],
    );
  }
}
// ------------------------------------------------

class _BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final String currencySymbol;

  const _BudgetCard({required this.budget, required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    // 1. Calculate Total
    final double totalAmount =
        budget.categoryBudget.values.fold(0.0, (sum, item) => sum + item);

    // 2. Format Date (Assuming key is YYYY-MM)
    String displayDate = budget.periodKey;
    try {
      if (budget.periodKey.contains('-') && budget.periodKey.length >= 7) {
        final parts = budget.periodKey.split('-');
        final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
        displayDate = DateFormat('MMMM yyyy').format(dt);
      }
    } catch (e) {
      // Fallback if parsing fails
      displayDate = budget.periodKey;
    }

    return GestureDetector(
      onTap: () {if (budget.docId != null) {
            Navigator.pop(context, budget.docId);
          } else {
            // Fallback/Warning if docId is somehow missing
            debugPrint('Error: docId missing for budget ${budget.periodKey}');
            Navigator.pop(context, budget.periodKey); 
          }},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // --- HEADER (Date & Total) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: kStormyTeal,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        budget.periodType.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '$currencySymbol ${totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- BODY (Categories) ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ...budget.categoryBudget.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kLightTeal,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getCategoryIcon(e.key),
                              size: 16,
                              color: kStormyTeal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e.key,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87),
                            ),
                          ),
                          Text(
                            '$currencySymbol ${e.value.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.touch_app, size: 16, color: Colors.grey),
                        SizedBox(width: 5),
                        Text(
                          "Tap to apply this budget",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to give icons to categories dynamically
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'bills':
        return Icons.receipt_long;
      case 'shopping':
        return Icons.shopping_bag;
      case 'savings':
        return Icons.savings;
      case 'health':
        return Icons.medical_services;
      default:
        return Icons.category;
    }
  }
}