import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/models.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  BetFlixUser? _currentUser;
  bool _isLoading = false;
  bool _hasInitializedAuth = false;
  String? _errorMessage;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;

  BetFlixUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get hasInitializedAuth => _hasInitializedAuth;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  void _attachUserDocListener(String userId) {
    _userDocSub?.cancel();
    _userDocSub = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;
      final data = snapshot.data();
      if (data == null) return;

      final existing = _currentUser;
      final joinDateRaw = data['joinDate'];
      DateTime joinDate = DateTime.now();
      if (joinDateRaw is Timestamp) {
        joinDate = joinDateRaw.toDate();
      } else if (joinDateRaw is String) {
        joinDate = DateTime.tryParse(joinDateRaw) ?? DateTime.now();
      } else if (existing != null) {
        joinDate = existing.joinDate;
      }

      _currentUser = BetFlixUser(
        id: userId,
        name: data['name'] ?? existing?.name ?? 'Usuario',
        email: data['email'] ?? existing?.email ?? '',
        profileImageUrl: data['profileImageUrl'] ?? existing?.profileImageUrl ?? '?',
        coins: (data['coins'] as num?)?.toInt() ?? existing?.coins ?? 0,
        winStreak: (data['winStreak'] as num?)?.toInt() ?? existing?.winStreak ?? 0,
        totalBets: (data['totalBets'] as num?)?.toInt() ?? existing?.totalBets ?? 0,
        correctBets: (data['correctBets'] as num?)?.toInt() ?? existing?.correctBets ?? 0,
        level: (data['level'] as num?)?.toInt() ?? existing?.level ?? 1,
        joinDate: joinDate,
      );

      notifyListeners();
    });
  }

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
      const demoFallbackPassword = 'BetFlixDemo#2026';

      // En modo demo necesitamos un usuario autenticado en Firebase
      // para que Firestore permita crear partidos y apuestas.
      if (firebaseUser == null) {
        try {
          final credential = await auth.signInAnonymously();
          firebaseUser = credential.user;
        } on FirebaseAuthException catch (e) {
          // Si Anonymous está deshabilitado en Firebase,
          // hacemos fallback automático a Email/Password demo.
          if (e.code == 'operation-not-allowed' ||
              e.code == 'admin-restricted-operation') {
            try {
              final demoLogin = await auth.signInWithEmailAndPassword(
                email: email,
                password: demoFallbackPassword,
              );
              firebaseUser = demoLogin.user;
            } on FirebaseAuthException catch (loginError) {
              if (loginError.code == 'user-not-found' ||
                  loginError.code == 'invalid-credential') {
                final demoRegister = await auth.createUserWithEmailAndPassword(
                  email: email,
                  password: demoFallbackPassword,
                );
                firebaseUser = demoRegister.user;
                await firebaseUser?.updateDisplayName(name);
              } else {
                rethrow;
              }
            }
          } else {
            rethrow;
          }
        }
      }

      if (firebaseUser == null) {
        throw 'No se pudo iniciar sesión demo. Reintenta.';
      }

      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid);
      final existingDoc = await userDocRef.get();
      final existingData = existingDoc.data();
      final existingCoins = (existingData?['coins'] as num?)?.toInt();
      final existingTotalBets = (existingData?['totalBets'] as num?)?.toInt();
      final existingCorrectBets = (existingData?['correctBets'] as num?)?.toInt();
      final existingWinStreak = (existingData?['winStreak'] as num?)?.toInt();
      final existingLevel = (existingData?['level'] as num?)?.toInt();

      await userDocRef.set({
        'id': firebaseUser.uid,
        'name': name,
        'email': email,
        'coins': existingCoins ?? 5000,
        'winStreak': existingWinStreak ?? 0,
        'totalBets': existingTotalBets ?? 0,
        'correctBets': existingCorrectBets ?? 0,
        'level': existingLevel ?? 1,
        'joinDate': DateTime.now().toIso8601String(),
        'profileImageUrl': name.isNotEmpty ? name[0].toUpperCase() : '?',
        'isDemo': true,
      }, SetOptions(merge: true));

      _currentUser = BetFlixUser(
        id: firebaseUser.uid,
        name: name,
        email: email,
        profileImageUrl: name.isNotEmpty ? name[0].toUpperCase() : '?',
        coins: existingCoins ?? 5000,
        winStreak: existingWinStreak ?? 0,
        totalBets: existingTotalBets ?? 0,
        correctBets: existingCorrectBets ?? 0,
        level: existingLevel ?? 1,
        joinDate: DateTime.now(),
      );
      _attachUserDocListener(firebaseUser.uid);

      _hasInitializedAuth = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final raw = e.toString();
      if (raw.contains('operation-not-allowed') ||
          raw.contains('admin-restricted-operation')) {
        _errorMessage =
            'No se pudo autenticar el usuario demo. Activa Anonymous o Email/Password en Firebase Authentication.';
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
      if (_currentUser != null) {
        _attachUserDocListener(_currentUser!.id);
      }
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
      if (_currentUser != null) {
        _attachUserDocListener(_currentUser!.id);
      }
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
    await _userDocSub?.cancel();
    _userDocSub = null;
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
      if (_currentUser != null) {
        _attachUserDocListener(_currentUser!.id);
      }
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
