import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import '../models/user_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AuthStatus _status = AuthStatus.unknown;
  User? _firebaseUser;
  UserModel? _userModel;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);

    // Safety: if Firebase hasn't responded in 5 s, treat as unauthenticated
    Future.delayed(const Duration(seconds: 5), () {
      if (_status == AuthStatus.unknown) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    });
  }

  // ─────────────────────────────
  // AUTH STATE
  // ─────────────────────────────
  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;

    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _userModel = null;
      notifyListeners();
    } else {
      _isLoading = true;
      _status = AuthStatus.authenticated;
      notifyListeners();

      await loadCurrentUser();

      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────
  // LOAD USER FROM FIRESTORE
  // ─────────────────────────────
  Future<void> loadCurrentUser() async {
    if (_firebaseUser == null) return;

    try {
      final doc =
          await _db.collection('users').doc(_firebaseUser!.uid).get();

      if (doc.exists) {
        _userModel = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // ─────────────────────────────
  // SIGN UP
  // ─────────────────────────────
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        username: username,
        role: role, 
      );

      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        final newUserModel = UserModel(
          id: currentUser.uid, 
          email: email,
          username: username,
          role: role,
          interests: [],
          bio: '',
          onboardingComplete: role == 'club', 
        );

        await _db.collection('users').doc(currentUser.uid).set(newUserModel.toFirestore());
        _userModel = newUserModel;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────
  // SIGN IN
  // ─────────────────────────────
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────
  // RESET PASSWORD
  // ─────────────────────────────
  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────
  // SIGN OUT
  // ─────────────────────────────
  Future<void> signOut() async {
    _firebaseUser = null;
    _userModel = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
    await _authService.signOut();
  }

  // ─────────────────────────────
  // ONBOARDING
  // ─────────────────────────────
  Future<bool> hasCompletedOnboarding() async {
    if (_firebaseUser == null) return false;
    if (_userModel != null) return _userModel!.onboardingComplete;
    return _authService.hasCompletedOnboarding(_firebaseUser!.uid);
  }

  Future<void> saveOnboarding({
    required List<String> interests,
    required String bio,
  }) async {
    if (_firebaseUser == null) return;

    await _authService.saveOnboarding(
      uid: _firebaseUser!.uid,
      interests: interests,
      bio: bio,
    );

    await loadCurrentUser();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
