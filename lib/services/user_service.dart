import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  UserService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Get current user UID
  String? get _uid => _auth.currentUser?.uid;

  /// ------------------- USER DATA -------------------

  /// Fetch user data safely
  Future<Map<String, dynamic>?> getUserData() async {
    final uid = _uid;
    if (uid == null) return null;

    final docSnap = await _db.collection("users").doc(uid).get();

    if (!docSnap.exists || docSnap.data() == null) return null;

    return docSnap.data();
  }

  /// Update user profile (partial update using merge)
  Future<void> updateUserProfile({
    String? name,
    String? bio,
    String? imageUrl,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final dataToUpdate = <String, dynamic>{};

    if (name != null) dataToUpdate['name'] = name;
    if (bio != null) dataToUpdate['bio'] = bio;
    if (imageUrl != null) dataToUpdate['imageUrl'] = imageUrl;

    if (dataToUpdate.isEmpty) return;

    await _db
        .collection("users")
        .doc(uid)
        .set(dataToUpdate, SetOptions(merge: true));
  }

  /// ------------------- STREAM USER DATA -------------------

  /// Real-time updates for current user
  Stream<Map<String, dynamic>?> streamUserData() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _db.collection("users").doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return snap.data();
    });
  }
}
