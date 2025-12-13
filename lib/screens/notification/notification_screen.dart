import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    final uid = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("alerts")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }

          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No notifications yet ✅",
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data();

              final type = (data["type"] ?? "").toString();
              final resolved = (data["resolved"] ?? false) as bool;

              if (type == "overspend") {
                final category = (data["category"] ?? "Other").toString();
                final spent = (data["spent"] as num?)?.toDouble() ?? 0;
                final recommended = (data["recommended"] as num?)?.toDouble() ?? 0;
                final overBy = (data["overBy"] as num?)?.toDouble() ?? (spent - recommended);

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(
                      resolved ? Icons.check_circle : Icons.warning_amber_rounded,
                      color: resolved ? Colors.green : Colors.red,
                    ),
                    title: Text("Overspent in $category"),
                    subtitle: Text(
                      "Spent: ${spent.toStringAsFixed(0)} | Budget: ${recommended.toStringAsFixed(0)}\nOver by: ${overBy.toStringAsFixed(0)}",
                    ),
                    isThreeLine: true,
                    trailing: resolved
                        ? const Text("Done", style: TextStyle(color: Colors.green))
                        : TextButton(
                            child: const Text("Mark read"),
                            onPressed: () async {
                              await doc.reference.update({"resolved": true});
                            },
                          ),
                  ),
                );
              }

              // Default alert
              return Card(
                child: ListTile(
                  title: Text("Alert: $type"),
                  subtitle: Text(data.toString()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
