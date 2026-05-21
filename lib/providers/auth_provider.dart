import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/club_service.dart';

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
  // Safety: if still unknown after 5 seconds, set unauthenticated
  Future.delayed(const Duration(seconds: 5), () {
    if (_status == AuthStatus.unknown) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  });
}

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

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _userModel = null;
    } else {
      _status = AuthStatus.authenticated;
      await _loadUserModel(user.uid);
      ClubService().seedClubs();
    }
    notifyListeners();
  }

  Future<void> _loadUserModel(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromFirestore(doc);
      }
    } catch (_) {}
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        username: username,
      );
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

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<bool> hasCompletedOnboarding() async {
    if (_firebaseUser == null) return false;
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
    await _loadUserModel(_firebaseUser!.uid);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

