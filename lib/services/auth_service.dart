import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Current logged-in user
  User? get currentUser => _auth.currentUser;

  // Stream for auth changes
  Stream<User?> get userChanges => _auth.authStateChanges();

  // Register new user
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

        await _db.collection('users').doc(user.uid).set(userModel.toMap());
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");
      rethrow;
    }
  }

  // Login user
  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print("Login FirebaseAuthException: ${e.code} - ${e.message}");
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
