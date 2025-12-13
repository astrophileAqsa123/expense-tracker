import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  /// Current logged-in user
  User? get currentUser => _auth.currentUser;

  /// Stream for auth state changes
  Stream<User?> get userChanges => _auth.authStateChanges();

  // ------------------- REGISTER -------------------
  Future<User?> register({
    required String name,
    required String email,
    required String password,
    required double income,
    required String currency,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Create UserModel with safe defaults
        final userModel = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          income: income,
          currency: currency,
          budgetModel: '50/30/20',
          budget: null,
          createdAt: DateTime.now(),
        );

        // 🔹 Use merge: true to avoid overwriting in rare cases
        await _db
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap(), SetOptions(merge: true));
      }

      return user;
    } on FirebaseAuthException catch (e) {
      // 🔹 Throw with meaningful message
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Unknown registration error',
      );
    }
  }

  // ------------------- LOGIN -------------------
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Unknown login error',
      );
    }
  }

  // ------------------- LOGOUT -------------------
  Future<void> logout() async => await _auth.signOut();

  // ------------------- HELPER -------------------

  /// Safe check if user is logged in
  bool get isLoggedIn => currentUser != null;
}
