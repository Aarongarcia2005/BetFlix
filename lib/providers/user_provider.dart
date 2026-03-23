import 'package:flutter/material.dart';
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

    _currentUser = BetFlixUser(
      id: 'demo-${email.hashCode.abs()}',
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
      _errorMessage = raw.startsWith('Exception: ')
          ? raw.replaceFirst('Exception: ', '')
          : raw;
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

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
