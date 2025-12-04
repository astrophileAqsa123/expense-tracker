import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Register a new user + save profile
  Future<User?> register({
    required String name,
    required String email,
    required String password,
    required double income,
    required String currency,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user != null) {
      // Create UserModel
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

      // Save to Firestore
      await _db.collection('users').doc(user.uid).set(userModel.toMap());
    }

    return user;
  }

  // Login
  Future<User?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Current logged in user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get userChanges => _auth.authStateChanges();
}
