import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime _parseJoinDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  BetFlixUser _fallbackUserFromAuth(User user, {String? nameOverride}) {
    final displayName = (nameOverride ?? user.displayName ?? '').trim();
    final safeName = displayName.isNotEmpty ? displayName : 'Usuario';
    final safeEmail = user.email ?? '';

    return BetFlixUser(
      id: user.uid,
      name: safeName,
      email: safeEmail,
      profileImageUrl: safeName.isNotEmpty ? safeName[0].toUpperCase() : '?',
      coins: 5000,
      winStreak: 0,
      totalBets: 0,
      correctBets: 0,
      level: 1,
      joinDate: DateTime.now(),
    );
  }

  /// Sign Up con email y password
  Future<BetFlixUser?> registerUser({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = result.user;
      if (firebaseUser == null) {
        throw 'No se pudo crear la cuenta. Inténtalo de nuevo.';
      }

      await firebaseUser.updateDisplayName(username);

      // Crear documento del usuario en Firestore
      BetFlixUser newUser = BetFlixUser(
        id: firebaseUser.uid,
        name: username,
        email: email,
        profileImageUrl: username.isNotEmpty ? username[0].toUpperCase() : '?',
        coins: 5000,
        winStreak: 0,
        totalBets: 0,
        correctBets: 0,
        level: 1,
        joinDate: DateTime.now(),
      );

      // Si Firestore falla, no bloqueamos el alta de usuario en Auth.
      try {
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'id': firebaseUser.uid,
          'name': username,
          'email': email,
          'isDemo': false,
          'coins': 5000,
          'winStreak': 0,
          'totalBets': 0,
          'correctBets': 0,
          'level': 1,
          'joinDate': DateTime.now().toIso8601String(),
          'profileImageUrl': newUser.profileImageUrl,
        }, SetOptions(merge: true));
      } on FirebaseException {
        // No-op: permitimos continuar con el perfil local de fallback.
      }

      return newUser;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw 'Ese correo ya está registrado.';
        case 'invalid-email':
          throw 'El formato del correo no es válido.';
        case 'weak-password':
          throw 'La contraseña es demasiado débil (mínimo 6 caracteres).';
        case 'operation-not-allowed':
          throw 'Email/Password no está habilitado en Firebase Authentication.';
        case 'invalid-api-key':
          throw 'API key inválida en Firebase. Revisa firebase_options.dart.';
        case 'app-not-authorized':
          throw 'App no autorizada para Firebase. Revisa la configuración Web del proyecto.';
        case 'network-request-failed':
          throw 'Sin conexión. Revisa internet e inténtalo de nuevo.';
        case 'too-many-requests':
          throw 'Demasiados intentos. Espera un momento e inténtalo de nuevo.';
        default:
          throw (e.message?.isNotEmpty == true)
              ? '${e.message} (code: ${e.code})'
              : 'Error en registro (code: ${e.code})';
      }
    } catch (e) {
      final raw = e.toString();
      throw raw.startsWith('Exception: ')
          ? raw.replaceFirst('Exception: ', '')
          : 'No se pudo completar el registro. Detalle: $raw';
    }
  }

  /// Sign In con email y password
  Future<BetFlixUser?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = result.user;
      if (firebaseUser == null) {
        throw 'No se pudo iniciar sesión. Inténtalo de nuevo.';
      }

      // Obtener datos del usuario desde Firestore
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          return BetFlixUser(
            id: firebaseUser.uid,
            name: data['name'] ?? firebaseUser.displayName ?? 'Usuario',
            email: data['email'] ?? firebaseUser.email ?? '',
            profileImageUrl: data['profileImageUrl'] ?? '?',
            coins: data['coins'] ?? 5000,
            winStreak: data['winStreak'] ?? 0,
            totalBets: data['totalBets'] ?? 0,
            correctBets: data['correctBets'] ?? 0,
            level: data['level'] ?? 1,
            joinDate: _parseJoinDate(data['joinDate']),
          );
        }

        final fallbackUser = _fallbackUserFromAuth(firebaseUser);
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'id': fallbackUser.id,
          'name': fallbackUser.name,
          'email': fallbackUser.email,
          'isDemo': false,
          'coins': fallbackUser.coins,
          'winStreak': fallbackUser.winStreak,
          'totalBets': fallbackUser.totalBets,
          'correctBets': fallbackUser.correctBets,
          'level': fallbackUser.level,
          'joinDate': fallbackUser.joinDate.toIso8601String(),
          'profileImageUrl': fallbackUser.profileImageUrl,
        }, SetOptions(merge: true));
        return fallbackUser;
      } on FirebaseException {
        return _fallbackUserFromAuth(firebaseUser);
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw 'El formato del correo no es válido.';
        case 'user-not-found':
          throw 'No existe una cuenta con ese correo.';
        case 'wrong-password':
        case 'invalid-credential':
          throw 'Correo o contraseña incorrectos.';
        case 'too-many-requests':
          throw 'Demasiados intentos. Inténtalo de nuevo más tarde.';
        default:
          throw e.message ?? 'Error en login';
      }
    } catch (_) {
      throw 'No se pudo iniciar sesión. Revisa tu conexión e inténtalo de nuevo.';
    }
  }

  /// Sign Out
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  /// Get Current User
  User? get currentUser => _auth.currentUser;

  /// Stream de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Obtener usuario actual
  Future<BetFlixUser?> getCurrentUser() async {
    if (_auth.currentUser != null) {
      final firebaseUser = _auth.currentUser!;
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          return BetFlixUser(
            id: firebaseUser.uid,
            name: data['name'] ?? firebaseUser.displayName ?? 'Usuario',
            email: data['email'] ?? firebaseUser.email ?? '',
            profileImageUrl: data['profileImageUrl'] ?? '?',
            coins: data['coins'] ?? 5000,
            winStreak: data['winStreak'] ?? 0,
            totalBets: data['totalBets'] ?? 0,
            correctBets: data['correctBets'] ?? 0,
            level: data['level'] ?? 1,
            joinDate: _parseJoinDate(data['joinDate']),
          );
        }

        final fallbackUser = _fallbackUserFromAuth(firebaseUser);
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'id': fallbackUser.id,
          'name': fallbackUser.name,
          'email': fallbackUser.email,
          'isDemo': false,
          'coins': fallbackUser.coins,
          'winStreak': fallbackUser.winStreak,
          'totalBets': fallbackUser.totalBets,
          'correctBets': fallbackUser.correctBets,
          'level': fallbackUser.level,
          'joinDate': fallbackUser.joinDate.toIso8601String(),
          'profileImageUrl': fallbackUser.profileImageUrl,
        }, SetOptions(merge: true));
        return fallbackUser;
      } on FirebaseException {
        return _fallbackUserFromAuth(firebaseUser);
      }
    }
    return null;
  }

  /// Actualizar monedas del usuario
  Future<void> updateUserCoins(String userId, int newCoins) async {
    await _firestore.collection('users').doc(userId).update({
      'coins': newCoins,
    });
  }

  /// Actualizar perfil del usuario
  Future<void> updateUserProfile({
    required String userId,
    required String name,
    required String profileImageUrl,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'name': name,
      'profileImageUrl': profileImageUrl,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    final user = _auth.currentUser;
    if (user != null && user.uid == userId && name.trim().isNotEmpty) {
      await user.updateDisplayName(name.trim());
    }
  }
}
