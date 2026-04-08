import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  BetFlixUser? _currentUser;
  bool _isLoading = false;
  bool _hasInitializedAuth = false;
  String? _errorMessage;

  BetFlixUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get hasInitializedAuth => _hasInitializedAuth;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Demo Sign In (sin Firebase)
  Future<bool> signInDemo({
    required String email,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final auth = FirebaseAuth.instance;
      User? firebaseUser = auth.currentUser;

      // En modo demo necesitamos un usuario autenticado en Firebase
      // para que Firestore permita crear partidos y apuestas.
      if (firebaseUser == null) {
        final credential = await auth.signInAnonymously();
        firebaseUser = credential.user;
      }

      if (firebaseUser == null) {
        throw 'No se pudo iniciar sesión demo. Reintenta.';
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set({
        'id': firebaseUser.uid,
        'name': name,
        'email': email,
        'coins': 5000,
        'winStreak': 0,
        'totalBets': 0,
        'correctBets': 0,
        'level': 1,
        'joinDate': DateTime.now().toIso8601String(),
        'profileImageUrl': name.isNotEmpty ? name[0].toUpperCase() : '?',
        'isDemo': true,
      }, SetOptions(merge: true));

      _currentUser = BetFlixUser(
        id: firebaseUser.uid,
        name: name,
        email: email,
        profileImageUrl: name.isNotEmpty ? name[0].toUpperCase() : '?',
        coins: 5000,
        winStreak: 0,
        totalBets: 0,
        correctBets: 0,
        level: 1,
        joinDate: DateTime.now(),
      );

      _hasInitializedAuth = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final raw = e.toString();
      if (raw.contains('operation-not-allowed') || raw.contains('admin-restricted-operation')) {
        _errorMessage =
            'Activa Anonymous en Firebase Authentication para usar usuarios demo.';
      } else if (raw.contains('permission-denied')) {
        _errorMessage =
            'Firestore bloquea escrituras. Revisa reglas o usa login con cuenta Firebase.';
      } else {
        _errorMessage = raw.startsWith('Exception: ')
            ? raw.replaceFirst('Exception: ', '')
            : raw;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign Up
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.registerUser(
        email: email,
        password: password,
        username: username,
      );
      _hasInitializedAuth = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final raw = e.toString();
      final clean = raw.startsWith('Exception: ')
        ? raw.replaceFirst('Exception: ', '')
        : raw;
      _errorMessage = clean.trim().isEmpty
        ? 'Registro falló. Revisa Firebase Authentication (Email/Password) y la configuración Web.'
        : clean;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign In
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.loginUser(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      final raw = e.toString();
      _errorMessage = raw.startsWith('Exception: ')
          ? raw.replaceFirst('Exception: ', '')
          : raw;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _authService.logoutUser();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Load Current User
  Future<void> loadCurrentUser() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _hasInitializedAuth = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update coins
  Future<void> updateCoins(int newCoins) async {
    if (_currentUser != null) {
      await _authService.updateUserCoins(_currentUser!.id, newCoins);
      _currentUser = _currentUser!.copyWith(coins: newCoins);
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String profileImageUrl,
  }) async {
    if (_currentUser == null) {
      _errorMessage = 'No hay sesión activa.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updateUserProfile(
        userId: _currentUser!.id,
        name: name,
        profileImageUrl: profileImageUrl,
      );

      _currentUser = _currentUser!.copyWith(
        name: name,
        profileImageUrl: profileImageUrl,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final raw = e.toString();
      _errorMessage = raw.startsWith('Exception: ')
          ? raw.replaceFirst('Exception: ', '')
          : raw;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
