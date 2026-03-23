import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class BetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crear una nueva apuesta
  Future<void> createBet({
    required String userId,
    required String matchId,
    required BetType betType,
    required int amount,
    required double odds,
  }) async {
    try {
      await _firestore.collection('bets').add({
        'userId': userId,
        'matchId': matchId,
        'betType': betType.toString().split('.').last,
        'amount': amount,
        'odds': odds,
        'potentialWinnings': (amount * odds).toInt(),
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'pending',
      });
    } catch (e) {
      throw 'Error al crear apuesta: $e';
    }
  }

  /// Obtener todas las apuestas del usuario
  Future<List<Bet>> getUserBets(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('bets')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Bet(
          id: doc.id,
          userId: data['userId'],
          matchId: data['matchId'],
          betType: BetType.values.byName(data['betType']),
          amount: data['amount'],
          odds: data['odds'],
          createdAt: DateTime.parse(data['createdAt']),
          status: BetStatus.values.byName(data['status']),
          potentialWinnings: data['potentialWinnings'],
        );
      }).toList();
    } catch (e) {
      throw 'Error al obtener apuestas: $e';
    }
  }

  /// Resuelve apuestas de un partido acabado según su score
  Future<void> resolveBetsForMatch({
    required Match match,
  }) async {
    final winner = getMatchWinner(match);
    if (winner == null) return;

    final QuerySnapshot snapshot = await _firestore
        .collection('bets')
        .where('matchId', isEqualTo: match.id)
        .where('status', isEqualTo: 'pending')
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final betType = BetType.values.byName(data['betType']);
      final userId = data['userId'];
      final amount = data['amount'] as int;
      final potentialWinnings = data['potentialWinnings'] as int;

      final bool won = betType == winner;
      final status = won ? 'won' : 'lost';

      await _firestore.collection('bets').doc(doc.id).update({
        'status': status,
      });

      if (won) {
        final userDocRef = _firestore.collection('users').doc(userId);
        final userDoc = await userDocRef.get();
        if (userDoc.exists) {
          final currentCoins = (userDoc.data() as Map<String, dynamic>)['coins'] as int;
          await userDocRef.update({'coins': currentCoins + potentialWinnings});
        }
      }
    }
  }

  // Elige el tipo ganador según el score del partido
  BetType? getMatchWinner(Match match) {
    if (match.homeScore == null || match.awayScore == null) return null;
    if (match.homeScore! > match.awayScore!) return BetType.homeWin;
    if (match.homeScore! < match.awayScore!) return BetType.awayWin;
    return BetType.draw;
  }

  /// Crear apuesta aleatoria para un usuario en un partido dado
  Future<void> createRandomBetForUser({
    required String userId,
    required Match match,
  }) async {
    final random = Random();
    final betTypes = BetType.values;
    final betType = betTypes[random.nextInt(betTypes.length)];
    final amount = [100, 200, 300, 500, 750, 1000][random.nextInt(6)];
    final odds = (1.5 + random.nextDouble() * 3.5).clamp(1.1, 5.0);

    await createBet(
      userId: userId,
      matchId: match.id,
      betType: betType,
      amount: amount,
      odds: odds,
    );
  }

  /// Stream de apuestas activas
  Stream<List<Bet>> getActiveBetsStream(String userId) {
    return _firestore
        .collection('bets')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Bet(
          id: doc.id,
          userId: data['userId'],
          matchId: data['matchId'],
          betType: BetType.values.byName(data['betType']),
          amount: data['amount'],
          odds: data['odds'],
          createdAt: DateTime.parse(data['createdAt']),
          status: BetStatus.values.byName(data['status'] ?? 'pending'),
          potentialWinnings: data['potentialWinnings'],
        );
      }).toList();
    });
  }

  /// Obtener todas las apuestas para ranking
  Stream<List<RankingEntry>> getRankingStream() {
    return _firestore
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
          profileImageUrl: data['profileImageUrl'] ?? '?',
          coins: data['coins'] ?? 0,
          correctBets: data['correctBets'] ?? 0,
          totalBets: data['totalBets'] ?? 0,
          badges: data['badges'] ?? 0,
        ));
      }
      return entries;
    });
  }
}
