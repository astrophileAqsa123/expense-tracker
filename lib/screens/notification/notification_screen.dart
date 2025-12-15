import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// --- THEME COLOR DEFINITIONS (From previous files) ---
class AppColors {
static const Color kStormyTeal = Color(0xFF156064); 
 static const Color primaryTeal = Color(0xFF00C896); // Bright Teal (Accent)
 static const Color primaryBlue = Color(0xFF0077B6); // Deep Blue (Primary)
 static const Color secondaryDark = Color(0xFF1D3557); // Dark Navy (Main Color)
 static const Color lightBackground = Color(0xFFF1FAEE); // Very Light Cream/Green
 static const Color midBackground = Color(0xFFE5E5E5); // Light Gray
}
// ---------------------------------------------------

class NotificationScreen extends StatelessWidget {
 const NotificationScreen({super.key});

 @override
 Widget build(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;
  final primaryColor = AppColors.kStormyTeal;
  final darkNavy = AppColors.midBackground;

  if (user == null) {
   return Scaffold(
    backgroundColor: darkNavy,
    body: const Center(
     child: Text(
      "User not logged in",
      style: TextStyle(color: Colors.white70),
     ),
    ),
   );
  }

  final uid = user.uid;

  return Scaffold(
   backgroundColor: darkNavy,
   appBar: AppBar(
    title: const Text("Alerts & Notifications", style: TextStyle(color: Colors.white)),
    backgroundColor: primaryColor, // Use primary blue for AppBar
    foregroundColor: Colors.white,
   ),
   body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("alerts")
      .orderBy("createdAt", descending: true)
      .snapshots(),
    builder: (context, snap) {
     if (snap.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
     }
     if (snap.hasError) {
      return Center(
       child: Text(
        "Error loading alerts: ${snap.error}",
        style: const TextStyle(color: Colors.redAccent),
       ),
      );
     }

     final docs = snap.data?.docs ?? [];
     if (docs.isEmpty) {
      return Center(
       child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         Icon(Icons.notifications_none, size: 60, color: primaryColor),
         const SizedBox(height: 10),
         const Text(
          "No notifications yet. You're on budget! ",
          style: TextStyle(color: Colors.white70, fontSize: 16),
         ),
        ],
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

        return Padding(
         padding: const EdgeInsets.only(bottom: 10.0),
         child: Card(
          color: darkNavy.withOpacity(0.8), // Dark navy card
          elevation: 4,
          shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(12),
           side: BorderSide(
            color: resolved ? primaryColor : Colors.redAccent,
            width: 1.5,
           ),
          ),
          child: ListTile(
           contentPadding: const EdgeInsets.all(16),
           leading: Icon(
            resolved ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: resolved ? AppColors.primaryTeal : Colors.redAccent, // Teal for resolved, Red for warning
            size: 30,
           ),
           title: Text(
            " Budget Alert: $category",
            style: TextStyle(
             color: resolved ? Colors.white : Colors.redAccent,
             fontWeight: FontWeight.bold,
            ),
           ),
           subtitle: Text(
            "You spent Rs ${spent.toStringAsFixed(0)}. Recommended budget was Rs ${recommended.toStringAsFixed(0)}. Over by Rs ${overBy.toStringAsFixed(0)}.",
            style: const TextStyle(color: Colors.white70),
           ),
           isThreeLine: true,
           trailing: resolved
            ? Text("RESOLVED", style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 12))
            : TextButton(
              style: TextButton.styleFrom(
               foregroundColor: AppColors.primaryTeal, // Use Teal accent color
              ),
              child: const Text("MARK READ"),
              onPressed: () async {
               await doc.reference.update({"resolved": true});
              },
             ),
          ),
         ),
        );
       }

       // Default alert (Themed as a generic system message)
       return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Card(
         color: darkNavy.withOpacity(0.85),
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
         child: ListTile(
          leading: Icon(Icons.info_outline, color: AppColors.primaryTeal),
          title: Text(
           "System Alert: ${type[0].toUpperCase()}${type.substring(1)}",
           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
           "Raw Data: ${data.keys.where((k) => k != "type" && k != "resolved" && k != "createdAt").map((k) => "$k: ${data[k]}").join(", ")}",
           style: const TextStyle(color: Colors.white54),
          ),
          isThreeLine: true,
         ),
        ),
       );
      },
     );
    },
   ),
  );
 }
}