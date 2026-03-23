# 🔗 Guía de Integración de Backend - BetFlix

## Opciones de Backend Recomendadas

### Opción 1: Firebase (Recomendado para MVP)
Ideal para desarrollo rápido sin servidor de backend

### Opción 2: API REST Custom
Ideal para control total y flexibilidad

### Opción 3: Supabase
Backend tipo Firebase pero open-source

---

## 1️⃣ Firebase Integration

### Instalación

**1. Agregar dependencias** (`pubspec.yaml`)
```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_auth: ^4.13.0
  cloud_firestore: ^4.14.0
  firebase_messaging: ^14.6.0
```

**2. Ejecutar**
```bash
flutter pub get
```

**3. Configurar Firebase**
```bash
flutter pub global activate flutterfire_cli
flutterfire configure  # Sigue los prompts
```

### Implementación en main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

### Servicio de Autenticación

**Crear** `lib/services/auth_service.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Error de registro';
    }
  }

  // Sign In
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Error de inicio de sesión';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // Get Current User
  User? get currentUser => _auth.currentUser;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
```

### Servicio de Base de Datos

**Crear** `lib/services/database_service.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crear usuario
  Future<void> createUser(BetFlixUser user) async {
    try {
      await _db.collection('users').doc(user.id).set({
        'name': user.name,
        'email': user.email,
        'coins': user.coins,
        'level': user.level,
        'joinDate': user.joinDate.toIso8601String(),
      });
    } catch (e) {
      throw 'Error al crear usuario: $e';
    }
  }

  // Obtener usuario
  Future<BetFlixUser?> getUser(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return BetFlixUser(
          id: userId,
          name: data['name'],
          email: data['email'],
          profileImageUrl: data['profileInitial'] ?? '?',
          coins: data['coins'] ?? 5000,
          level: data['level'] ?? 1,
          joinDate: DateTime.parse(data['joinDate']),
        );
      }
    } catch (e) {
      throw 'Error al obtener usuario: $e';
    }
    return null;
  }

  // Crear apuesta
  Future<void> createBet(Bet bet) async {
    try {
      await _db.collection('bets').doc(bet.id).set({
        'userId': bet.userId,
        'matchId': bet.matchId,
        'betType': bet.betType.toString(),
        'amount': bet.amount,
        'odds': bet.odds,
        'createdAt': bet.createdAt.toIso8601String(),
        'status': bet.status.toString(),
      });
    } catch (e) {
      throw 'Error al crear apuesta: $e';
    }
  }

  // Obtener partidos en vivo
  Stream<List<Match>> getLiveMatches() {
    return _db
        .collection('matches')
        .where('status', isEqualTo: 'MatchStatus.live')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _matchFromFirestore(doc))
            .toList());
  }

  // Obtener ranking
  Stream<List<RankingEntry>> getRanking() {
    return _db
        .collection('users')
        .orderBy('coins', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      final entries = <RankingEntry>[];
      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        entries.add(RankingEntry(
          position: i + 1,
          userId: doc.id,
          userName: data['name'] ?? 'Anónimo',
          profileImageUrl: data['name']?[0] ?? '?',
          coins: data['coins'] ?? 0,
          correctBets: data['correctBets'] ?? 0,
          totalBets: data['totalBets'] ?? 0,
          badges: data['badges'] ?? 0,
        ));
      }
      return entries;
    });
  }

  Match _matchFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Match(
      id: doc.id,
      homeTeam: data['homeTeam'] ?? '',
      awayTeam: data['awayTeam'] ?? '',
      homeTeamLogo: data['homeTeamLogo'] ?? '⚽',
      awayTeamLogo: data['awayTeamLogo'] ?? '⚽',
      homeScore: data['homeScore'],
      awayScore: data['awayScore'],
      dateTime: DateTime.parse(data['dateTime']),
      status: MatchStatus.values.byName(data['status']),
      league: data['league'] ?? 'Local',
      isLocal: data['isLocal'] ?? false,
    );
  }
}
```

### Usar en Pantalla

```dart
import '../services/database_service.dart';

class HomeScreen extends StatelessWidget {
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Match>>(
        stream: _db.getLiveMatches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final matches = snapshot.data ?? [];
          
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              return MatchCard(
                homeTeam: matches[index].homeTeam,
                awayTeam: matches[index].awayTeam,
                league: matches[index].league,
                dateTime: matches[index].dateTime.toString(),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## 2️⃣ API REST Integration

### Configuración

**1. Agregar dependencia**
```yaml
dependencies:
  http: ^1.1.0
  dio: ^5.3.0  # Alternativa más potente
```

### Crear Cliente HTTP

**Archivo** `lib/services/api_client.dart`:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/models.dart';

class ApiClient {
  static const String baseUrl = 'https://api.betflix.com/api';

  // Headers por defecto
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // GET Request
  static Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      throw 'Error en GET: $e';
    }
  }

  // POST Request
  static Future<dynamic> post(String endpoint, 
    Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      throw 'Error en POST: $e';
    }
  }

  // PUT Request
  static Future<dynamic> put(String endpoint,
    Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Error ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error en PUT: $e';
    }
  }
}
```

### Servicios con API

**Archivo** `lib/services/bet_api_service.dart`:

```dart
import 'api_client.dart';
import '../models/models.dart';

class BetApiService {
  
  // Crear apuesta
  Future<void> createBet({
    required String userId,
    required String matchId,
    required BetType betType,
    required int amount,
  }) async {
    try {
      await ApiClient.post('/bets', {
        'userId': userId,
        'matchId': matchId,
        'betType': betType.toString().split('.').last,
        'amount': amount,
      });
    } catch (e) {
      throw 'Error al crear apuesta: $e';
    }
  }

  // Obtener partidos
  Future<List<Match>> getMatches() async {
    try {
      final response = await ApiClient.get('/matches');
      final List<dynamic> data = response['data'];
      
      return data.map((match) => Match(
        id: match['id'],
        homeTeam: match['homeTeam'],
        awayTeam: match['awayTeam'],
        homeTeamLogo: '⚽',
        awayTeamLogo: '⚽',
        homeScore: match['homeScore'],
        awayScore: match['awayScore'],
        dateTime: DateTime.parse(match['dateTime']),
        status: MatchStatus.values.byName(match['status']),
        league: match['league'],
        isLocal: match['isLocal'] ?? false,
      )).toList();
    } catch (e) {
      throw 'Error al obtener partidos: $e';
    }
  }

  // Obtener ranking
  Future<List<RankingEntry>> getRanking() async {
    try {
      final response = await ApiClient.get('/ranking');
      final List<dynamic> data = response['data'];
      
      return data.asMap().entries.map((entry) {
        final user = entry.value;
        return RankingEntry(
          position: entry.key + 1,
          userId: user['id'],
          userName: user['name'],
          profileImageUrl: user['name'][0],
          coins: user['coins'],
          correctBets: user['correctBets'],
          totalBets: user['totalBets'],
          badges: user['badges'] ?? 0,
        );
      }).toList();
    } catch (e) {
      throw 'Error al obtener ranking: $e';
    }
  }
}
```

### Usar en Pantalla

```dart
class RankingScreen extends StatefulWidget {
  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final BetApiService _api = BetApiService();
  late Future<List<RankingEntry>> _rankingFuture;

  @override
  void initState() {
    super.initState();
    _rankingFuture = _api.getRanking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ranking')),
      body: FutureBuilder<List<RankingEntry>>(
        future: _rankingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          
          final ranking = snapshot.data ?? [];
          return ListView.builder(
            itemCount: ranking.length,
            itemBuilder: (context, index) {
              final entry = ranking[index];
              return ListTile(
                leading: Text('${entry.position}'),
                title: Text(entry.userName),
                trailing: CoinWidget(amount: entry.coins),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## 3️⃣ State Management con Provider

### Instalación

```yaml
dependencies:
  provider: ^6.0.0
```

### Crear Providers

**Archivo** `lib/providers/user_provider.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class UserProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  BetFlixUser? _user;
  bool _isLoading = false;

  BetFlixUser? get user => _user;
  bool get isLoading => _isLoading;
  int get coins => _user?.coins ?? 0;

  Future<void> loadUser(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _user = await _db.getUser(userId);
    } catch (e) {
      print('Error loading user: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void updateCoins(int amount) {
    if (_user != null) {
      _user = BetFlixUser(
        id: _user!.id,
        name: _user!.name,
        email: _user!.email,
        profileImageUrl: _user!.profileImageUrl,
        coins: _user!.coins + amount,
        winStreak: _user!.winStreak,
        totalBets: _user!.totalBets,
        correctBets: _user!.correctBets,
        level: _user!.level,
        joinDate: _user!.joinDate,
      );
      notifyListeners();
    }
  }
}
```

### Usar en main.dart

```dart
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
```

### Usar en Pantalla

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          body: Center(
            child: CoinWidget(amount: userProvider.coins),
          ),
        );
      },
    );
  }
}
```

---

## 📊 Estructura de Base de Datos (Firestore)

```
betflix/
├── users/
│   └── {userId}
│       ├── name: string
│       ├── email: string
│       ├── coins: number
│       ├── level: number
│       ├── joinDate: timestamp
│       ├── correctBets: number
│       ├── totalBets: number
│       └── badges: number
├── matches/
│   └── {matchId}
│       ├── homeTeam: string
│       ├── awayTeam: string
│       ├── homeScore: number
│       ├── awayScore: number
│       ├── dateTime: timestamp
│       ├── status: string
│       ├── league: string
│       └── isLocal: boolean
├── bets/
│   └── {betId}
│       ├── userId: string
│       ├── matchId: string
│       ├── betType: string
│       ├── amount: number
│       ├── odds: double
│       ├── createdAt: timestamp
│       └── status: string
└── challenges/
    └── {challengeId}
        ├── title: string
        ├── icon: string
        ├── rewardCoins: number
        ├── deadline: timestamp
        └── type: string
```

---

## 🔐 Variables de Entorno

**Archivo** `.env`:
```
API_BASE_URL=https://api.betflix.com
API_KEY=YOUR_API_KEY
FIREBASE_PROJECT_ID=your-project-id
```

---

## 🧪 Testing API

### Testing Manual con Postman

```
POST /api/bets
Content-Type: application/json

{
  "userId": "user_123",
  "matchId": "match_456",
  "betType": "homeWin",
  "amount": 100
}
```

### Testing en Flutter

```dart
void testCreateBet() async {
  try {
    await betApiService.createBet(
      userId: 'test_user',
      matchId: 'test_match',
      betType: BetType.homeWin,
      amount: 100,
    );
    print('✅ Bet creation successful');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

---

**Conclusión**: ¡Ahora tienes opciones para conectar BetFlix a un backend real! 🚀
