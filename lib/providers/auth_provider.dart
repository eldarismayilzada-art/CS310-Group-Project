import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get firebaseUser => _authService.currentUser;

  // Sign In — returns true on success
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    try {
      _userModel = await _authService.signIn(email: email, password: password);
      _errorMessage = null;
      return true;
    }  catch (e) {
  _errorMessage = e.toString();
  return false;
}finally {
      _setLoading(false);
    }
  }

  // Sign Up — returns true on success
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String role,
  }) async {
    _setLoading(true);
    try {
      _userModel = await _authService.signUp(
        email: email,
        password: password,
        username: username,
        role: role,
      );
      _errorMessage = null;
      return true;
    } on Exception catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Save interests
  Future<void> saveInterests(List<String> interests) async {
  if (_userModel == null) return;
  await _authService.saveInterests(_userModel!.id, interests); // uid → id
  _userModel = _userModel!.copyWith(
    interests: interests,
    onboardingComplete: true,
  );
  notifyListeners();
}

  // Check onboarding
  Future<bool> hasCompletedOnboarding() async {
    return await _authService.hasCompletedOnboarding();
  }

  // Load user on app start
  Future<void> loadCurrentUser() async {
    _userModel = await _authService.getCurrentUserModel();
    notifyListeners();
  }

  // Sign Out
  Future<void> signOut() async {
    _userModel = null;
    notifyListeners();
    await _authService.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _parseError(Exception e) {
    final msg = e.toString();
    if (msg.contains('user-not-found')) return 'No account found with this email.';
    if (msg.contains('wrong-password')) return 'Incorrect password.';
    if (msg.contains('email-already-in-use')) return 'An account already exists with this email.';
    if (msg.contains('weak-password')) return 'Password must be at least 6 characters.';
    if (msg.contains('invalid-email')) return 'Please enter a valid email.';
    return 'Something went wrong. Please try again.';
  }
}