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
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

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

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No transactions yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final transactions = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final doc = transactions[index];
              final data = doc.data() as Map<String, dynamic>?;

              if (data == null) return const SizedBox.shrink();

              // SAFE FIELD EXTRACTION
              final String title = data['title']?.toString() ?? 'Untitled';
              final String category =
                  data['category']?.toString() ?? 'No Category';
              final String type = data['type']?.toString() ?? 'expense';
              final String amount = data['amount']?.toString() ?? '0';
              final Timestamp? date = data['date'];
              final bool isExpense = type == 'expense';
              final String id = doc.id;

              return Dismissible(
                key: Key(id),
                background: _editBackground(),
                secondaryBackground: _deleteBackground(),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // SWIPE RIGHT → EDIT
                    Future.microtask(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditTransactionScreen(
                            transactionId: id,
                          ),
                        ),
                      );
                    });
                    return false;
                  } else {
                    // SWIPE LEFT → DELETE
                    return await _confirmDelete(context, id, uid);
                  }
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    onTap: () {
                      // PASS FULL DATA TO DETAILS SCREEN
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionDetailsScreen(
                            transactionId: id,
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: isExpense
                          ? Colors.redAccent.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      child: Icon(
                        isExpense
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
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
                    subtitle: Text(
                      "$category • ${_safeDate(date)}",
                    ),
                    trailing: Text(
                      "${isExpense ? '-' : '+'} ₹$amount",
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

  // EDIT BACKGROUND
  Widget _editBackground() {
    return Container(
      color: Colors.blue,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: const Icon(Icons.edit, color: Colors.white, size: 28),
    );
  }

  // DELETE BACKGROUND
  Widget _deleteBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white, size: 28),
    );
  }

  // DELETE CONFIRM
  Future<bool> _confirmDelete(
      BuildContext context, String id, String uid) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete Transaction?"),
            content:
                const Text("Are you sure you want to delete this entry?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
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
        ) ??
        false;
  }

  // SAFE DATE FORMAT
  String _safeDate(Timestamp? date) {
    if (date == null) return "No date";
    final d = date.toDate();
    return "${d.day}/${d.month}/${d.year}";
  }
}
