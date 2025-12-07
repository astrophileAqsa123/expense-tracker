import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection("users").doc(uid).get();
    return doc.data();
  }

  Future<void> updateUserProfile({
    required String name,
    required String bio,
    required String imageUrl,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db.collection("users").doc(uid).update({
      "name": name,
      "bio": bio,
      "imageUrl": imageUrl,
    });
  }
}
