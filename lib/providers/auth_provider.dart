import 'dart:async';
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

  // Real-time Firestore stream subscription
  StreamSubscription<DocumentSnapshot>? _userModelSubscription;

  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isClub => _userModel?.role == 'club';
  bool get isStudent => _userModel?.role == 'student';

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
    // Fallback: if still unknown after 5 seconds, set unauthenticated
    Future.delayed(const Duration(seconds: 5), () {
      if (_status == AuthStatus.unknown) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    });
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;

    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _userModel = null;
      // Cancel existing stream subscription
      _userModelSubscription?.cancel();
      _userModelSubscription = null;
    } else {
      _status = AuthStatus.authenticated;
      // Subscribe to real-time updates for this user's Firestore document
      _subscribeToUserModel(user.uid);
    }

    notifyListeners();
  }

  /// Listens to the user's Firestore document in real time.
  /// When any field changes (bio, username, interests, avatarUrl…),
  /// _userModel is updated and the UI rebuilds automatically.
  void _subscribeToUserModel(String uid) {
    _userModelSubscription?.cancel();
    _userModelSubscription = _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        _userModel = UserModel.fromFirestore(doc);
        notifyListeners();
      }
    }, onError: (e) {
      debugPrint('UserModel stream error: $e');
    });
  }

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
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final newUser = UserModel(
        id: credential.user!.uid,
        username: username,
        email: email,
        bio: '',
        interests: [],
        createdAt: DateTime.now(),
        role: role,
      );

      await _db
          .collection('users')
          .doc(newUser.id)
          .set(newUser.toFirestore());

      _userModel = newUser;
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
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
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
    _userModelSubscription?.cancel();
    _userModelSubscription = null;
    await FirebaseAuth.instance.signOut();
    _status = AuthStatus.unauthenticated;
    _userModel = null;
    notifyListeners();
  }

  Future<bool> hasCompletedOnboarding() async {
    if (_firebaseUser == null) return false;
    if (_userModel != null) return _userModel!.interests.isNotEmpty;
    return false;
  }

  Future<void> saveOnboarding({
    required List<String> interests,
    required String bio,
  }) async {
    if (_firebaseUser == null) return;
    // Writing to Firestore triggers _subscribeToUserModel → UI updates automatically
    await _db.collection('users').doc(_firebaseUser!.uid).update({
      'interests': interests,
      'bio': bio,
    });
  }

  /// Update basic profile fields (username, dateOfBirth, bio).
  /// The real-time stream picks up the change and refreshes _userModel.
  Future<void> updateProfile({
    required String username,
    required String bio,
    String? dateOfBirth,
  }) async {
    if (_firebaseUser == null) return;
    await _db.collection('users').doc(_firebaseUser!.uid).update({
      'username': username,
      'bio': bio,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    });
    // No manual notifyListeners needed — stream handles it
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _userModelSubscription?.cancel();
    super.dispose();
  }
}
