import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'transaction_details_screen.dart';
import 'edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("All Transactions")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("transactions")
            .orderBy("date", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data?.docs ?? [];

          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                "No transactions yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final doc = transactions[index];
              final data = doc.data() as Map<String, dynamic>?;

              if (data == null) return const SizedBox.shrink();

              final String title = data['title']?.toString() ?? 'Untitled';
              final String category = data['category']?.toString() ?? 'No Category';
              final String type = data['type']?.toString() ?? 'expense';
              final double amount = (data['amount'] is num) ? (data['amount'] as num).toDouble() : 0.0;
              final Timestamp? date = data['date'] as Timestamp?;
              final bool isExpense = type == 'expense';
              final String id = doc.id;

              return Dismissible(
                key: Key(id),
                background: _editBackground(),
                secondaryBackground: _deleteBackground(),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    _editTransaction(id);
                    return false;
                  } else {
                    return await _confirmDelete(context, id);
                  }
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    onTap: () => _openDetails(id),
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: isExpense
                          ? Colors.redAccent.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      child: Icon(
                        isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isExpense ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text("$category • ${_formatDate(date)}"),
                    trailing: Text(
                      "${isExpense ? '-' : '+'} ₹${amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isExpense ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ---------------- HELPERS ----------------

  void _editTransaction(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(transactionId: id),
      ),
    ).then((_) {
      setState(() {}); // Refresh after editing
    });
  }

  void _openDetails(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailsScreen(transactionId: id),
      ),
    ).then((_) => setState(() {}));
  }

  Widget _editBackground() {
    return Container(
      color: Colors.blue,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: const Icon(Icons.edit, color: Colors.white, size: 28),
    );
  }

  Widget _deleteBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white, size: 28),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String id) async {
    return (await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete Transaction?"),
            content: const Text("Are you sure you want to delete this entry?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(uid)
                      .collection("transactions")
                      .doc(id)
                      .delete();
                  Navigator.pop(context, true);
                },
                child: const Text("Delete"),
              ),
            ],
          ),
        )) ??
        false;
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "No date";
    final d = timestamp.toDate();
    return "${d.day}/${d.month}/${d.year}";
  }
}

