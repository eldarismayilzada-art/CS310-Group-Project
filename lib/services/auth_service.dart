import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ─── Sign Up ───────────────────────────────────────────────
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String username,
    required String role,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        id: cred.user!.uid,
        username: username,
        email: email,
        bio: '',
        interests: [],
        createdAt: DateTime.now(),
        role: role,
        onboardingComplete: false,
      );

      await _db.collection('users').doc(cred.user!.uid).set(user.toFirestore());
      await _storeToken(cred.user!);
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'An unexpected error occurred during sign up.';
    }
  }

  // ─── Sign In ───────────────────────────────────────────────
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _storeToken(cred.user!);

      final userModel = await getCurrentUserModel();
      if (userModel == null) throw 'User data not found.';
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      rethrow;
    }
  }

  // ─── Sign Out ──────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ─── Get current user from Firestore ──────────────────────
  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // ─── Save interests after onboarding ──────────────────────
  Future<void> saveInterests(String uid, List<String> interests) async {
    await _db.collection('users').doc(uid).update({
      'interests': interests,
      'onboardingComplete': true,
    });
  }

  // ─── Check if onboarding is done ──────────────────────────
  Future<bool> hasCompletedOnboarding() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return false;
    return doc.data()?['onboardingComplete'] ?? false;
  }

  // ─── Save full onboarding data (bio + interests) ───────────
  Future<void> saveOnboarding({
    required String uid,
    required List<String> interests,
    required String bio,
  }) async {
    await _db.collection('users').doc(uid).update({
      'interests': interests,
      'bio': bio,
      'onboardingComplete': true,
    });
  }

  // ─── Store token locally ───────────────────────────────────
  Future<void> _storeToken(User user) async {
    final token = await user.getIdToken();
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    }
  }

  // ─── Error handler ─────────────────────────────────────────
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Try again later.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}