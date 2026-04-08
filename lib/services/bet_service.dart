import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class BetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  MatchStatus _matchStatusFromString(String? value) {
    switch (value) {
      case 'live':
        return MatchStatus.live;
      case 'finished':
        return MatchStatus.finished;
      case 'cancelled':
        return MatchStatus.cancelled;
      case 'scheduled':
      default:
        return MatchStatus.scheduled;
    }
  }

  MatchSource _matchSourceFromString(String? value) {
    if (value == MatchSource.userCreated.name) {
      return MatchSource.userCreated;
    }
    return MatchSource.randomGenerated;
  }

  BetMarket _marketFromString(String? value) {
    if (value == null || value.isEmpty) return BetMarket.matchWinner;
    return BetMarket.values.firstWhere(
      (market) => market.name == value,
      orElse: () => BetMarket.matchWinner,
    );
  }

  BetType _betTypeFromString(String? value) {
    if (value == null || value.isEmpty) return BetType.homeWin;
    return BetType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => BetType.homeWin,
    );
  }

  Match _matchFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Match(
      id: doc.id,
      homeTeam: data['homeTeam'] ?? 'Equipo Local',
      awayTeam: data['awayTeam'] ?? 'Equipo Visitante',
      homeTeamLogo: data['homeTeamLogo'] ?? '⚽',
      awayTeamLogo: data['awayTeamLogo'] ?? '⚽',
      homeScore: data['homeScore'] as int?,
      awayScore: data['awayScore'] as int?,
      dateTime: _parseDateTime(data['dateTime']),
      status: _matchStatusFromString(data['status'] as String?),
      league: data['league'] ?? 'Liga de Barrio',
      isLocal: data['isLocal'] ?? true,
      createdByUserId: data['createdByUserId'] as String?,
      createdByName: data['createdByName'] as String?,
      source: _matchSourceFromString(data['source'] as String?),
      shotsOnTargetTotal: data['shotsOnTargetTotal'] as int?,
      firstScoringTeam: data['firstScoringTeam'] as String?,
      betsCount: (data['betsCount'] as int?) ?? 0,
    );
  }

  Future<String> createCustomMatch({
    required String ownerUserId,
    required String ownerName,
    required String homeTeam,
    required String awayTeam,
    required String league,
    required DateTime kickoff,
  }) async {
    try {
      final docRef = await _firestore.collection('matches').add({
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'homeTeamLogo': '🏠',
        'awayTeamLogo': '🚩',
        'homeScore': 0,
        'awayScore': 0,
        'shotsOnTargetTotal': 0,
        'firstScoringTeam': '',
        'dateTime': kickoff.toIso8601String(),
        'status': MatchStatus.scheduled.name,
        'league': league,
        'isLocal': true,
        'createdByUserId': ownerUserId,
        'createdByName': ownerName,
        'source': MatchSource.userCreated.name,
        'betsCount': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return docRef.id;
    } catch (e) {
      throw 'Error al crear partido personalizado: $e';
    }
  }

  Stream<List<Match>> getOpenMatchesStream() {
    return _firestore
        .collection('matches')
        .where('status', whereIn: [
          MatchStatus.scheduled.name,
          MatchStatus.live.name,
        ])
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_matchFromDoc).toList());
  }

  Future<void> seedRandomMatchesIfEmpty() async {
    final existing = await _firestore
        .collection('matches')
        .where('source', isEqualTo: MatchSource.randomGenerated.name)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;

    final random = Random();
    final teams = [
      'Atlético Ciudad',
      'Real Valle',
      'Unión Oeste',
      'Racing Pueblo',
      'Amistad FC',
      'Barrio Norte FC',
      'Libertad FC',
      'Estrella Dorada',
      'Tritones FC',
      'Fénix Rojos',
    ];

    for (int i = 0; i < 8; i++) {
      final home = teams[random.nextInt(teams.length)];
      String away = teams[random.nextInt(teams.length)];
      while (away == home) {
        away = teams[random.nextInt(teams.length)];
      }

      await _firestore.collection('matches').add({
        'homeTeam': home,
        'awayTeam': away,
        'homeTeamLogo': '⚽',
        'awayTeamLogo': '⚽',
        'homeScore': random.nextInt(2),
        'awayScore': random.nextInt(2),
        'shotsOnTargetTotal': 4 + random.nextInt(10),
        'firstScoringTeam': random.nextBool() ? home : away,
        'dateTime': DateTime.now().add(Duration(minutes: 25 * (i + 1))).toIso8601String(),
        'status': random.nextBool() ? MatchStatus.scheduled.name : MatchStatus.live.name,
        'league': 'Liga Open BetFlix',
        'isLocal': random.nextBool(),
        'createdByUserId': 'system',
        'createdByName': 'BetFlix Engine',
        'source': MatchSource.randomGenerated.name,
        'betsCount': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> updateCustomMatchStats({
    required String matchId,
    required String ownerUserId,
    required int homeScore,
    required int awayScore,
    required int shotsOnTargetTotal,
    required String firstScoringTeam,
    required MatchStatus status,
  }) async {
    final docRef = _firestore.collection('matches').doc(matchId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      throw 'El partido no existe.';
    }

    final data = snapshot.data() as Map<String, dynamic>;
    final createdByUserId = data['createdByUserId'] as String?;
    if (createdByUserId != ownerUserId) {
      throw 'Solo el creador del partido puede actualizar goles y estadísticas.';
    }

    await docRef.update({
      'homeScore': homeScore,
      'awayScore': awayScore,
      'shotsOnTargetTotal': shotsOnTargetTotal,
      'firstScoringTeam': firstScoringTeam,
      'status': status.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    if (status == MatchStatus.finished) {
      final updatedMatch = Match(
        id: matchId,
        homeTeam: data['homeTeam'] ?? 'Equipo Local',
        awayTeam: data['awayTeam'] ?? 'Equipo Visitante',
        homeTeamLogo: data['homeTeamLogo'] ?? '⚽',
        awayTeamLogo: data['awayTeamLogo'] ?? '⚽',
        dateTime: _parseDateTime(data['dateTime']),
        status: MatchStatus.finished,
        league: data['league'] ?? 'Liga de Barrio',
        isLocal: data['isLocal'] ?? true,
        homeScore: homeScore,
        awayScore: awayScore,
        createdByUserId: data['createdByUserId'] as String?,
        createdByName: data['createdByName'] as String?,
        source: _matchSourceFromString(data['source'] as String?),
        shotsOnTargetTotal: shotsOnTargetTotal,
        firstScoringTeam: firstScoringTeam,
        betsCount: (data['betsCount'] as int?) ?? 0,
      );
      await resolveBetsForMatch(match: updatedMatch);
    }
  }

  /// Crear una nueva apuesta
  Future<void> createBet({
    required String userId,
    required String matchId,
    required BetType betType,
    BetMarket market = BetMarket.matchWinner,
    String selection = '',
    String? matchTitle,
    String? createdByUserId,
    required int amount,
    required double odds,
  }) async {
    try {
      final batch = _firestore.batch();
      final betRef = _firestore.collection('bets').doc();

      batch.set(betRef, {
        'userId': userId,
        'matchId': matchId,
        'betType': betType.toString().split('.').last,
        'market': market.name,
        'selection': selection,
        'matchTitle': matchTitle,
        'createdByUserId': createdByUserId,
        'amount': amount,
        'odds': odds,
        'potentialWinnings': (amount * odds).toInt(),
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'pending',
      });

      final matchRef = _firestore.collection('matches').doc(matchId);
      batch.set(matchRef, {
        'betsCount': FieldValue.increment(1),
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      throw 'Error al crear apuesta: $e';
    }
  }

  Stream<List<Match>> getTrendingMatchesStream() {
    return _firestore
        .collection('matches')
        .where('status', whereIn: [
          MatchStatus.scheduled.name,
          MatchStatus.live.name,
          MatchStatus.finished.name,
        ])
        .orderBy('betsCount', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_matchFromDoc).toList());
  }

  Stream<List<NeighborhoodTeamStanding>> getNeighborhoodTournamentTableStream() {
    return _firestore
        .collection('matches')
        .where('source', isEqualTo: MatchSource.userCreated.name)
        .where('status', isEqualTo: MatchStatus.finished.name)
        .snapshots()
        .map((snapshot) {
      final Map<String, _TeamAccumulator> table = {};

      for (final doc in snapshot.docs) {
        final match = _matchFromDoc(doc);
        final homeGoals = match.homeScore ?? 0;
        final awayGoals = match.awayScore ?? 0;

        table.putIfAbsent(match.homeTeam, () => _TeamAccumulator());
        table.putIfAbsent(match.awayTeam, () => _TeamAccumulator());

        final home = table[match.homeTeam]!;
        final away = table[match.awayTeam]!;

        home.played++;
        away.played++;
        home.goalsFor += homeGoals;
        home.goalsAgainst += awayGoals;
        away.goalsFor += awayGoals;
        away.goalsAgainst += homeGoals;

        if (homeGoals > awayGoals) {
          home.won++;
          away.lost++;
          home.points += 3;
        } else if (homeGoals < awayGoals) {
          away.won++;
          home.lost++;
          away.points += 3;
        } else {
          home.draw++;
          away.draw++;
          home.points += 1;
          away.points += 1;
        }
      }

      final standings = table.entries
          .map((entry) => NeighborhoodTeamStanding(
                teamName: entry.key,
                played: entry.value.played,
                won: entry.value.won,
                draw: entry.value.draw,
                lost: entry.value.lost,
                goalsFor: entry.value.goalsFor,
                goalsAgainst: entry.value.goalsAgainst,
                points: entry.value.points,
              ))
          .toList();

      standings.sort((a, b) {
        if (b.points != a.points) return b.points.compareTo(a.points);
        if (b.goalDifference != a.goalDifference) {
          return b.goalDifference.compareTo(a.goalDifference);
        }
        return b.goalsFor.compareTo(a.goalsFor);
      });

      return standings;
    });
  }

  /// Obtener todas las apuestas del usuario
  Future<List<Bet>> getUserBets(String userId) async {
    try {
      final authUid = _auth.currentUser?.uid;
      final effectiveUserId = authUid ?? userId;
      QuerySnapshot snapshot = await _firestore
          .collection('bets')
          .where('userId', isEqualTo: effectiveUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Bet(
          id: doc.id,
          userId: data['userId'],
          matchId: data['matchId'],
          betType: _betTypeFromString(data['betType'] as String?),
          market: _marketFromString(data['market'] as String?),
          selection: (data['selection'] as String?) ?? '',
          matchTitle: data['matchTitle'] as String?,
          createdByUserId: data['createdByUserId'] as String?,
          amount: data['amount'],
          odds: (data['odds'] as num).toDouble(),
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
      final betType = _betTypeFromString(data['betType'] as String?);
      final market = _marketFromString(data['market'] as String?);
      final selection = (data['selection'] as String?) ?? '';
      final userId = data['userId'];
      final amount = data['amount'] as int;
      final potentialWinnings = data['potentialWinnings'] as int;

      final bool won = _isBetWon(
        market: market,
        selection: selection,
        betType: betType,
        winner: winner,
        match: match,
      );
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

  bool _isBetWon({
    required BetMarket market,
    required String selection,
    required BetType betType,
    required BetType winner,
    required Match match,
  }) {
    final totalGoals = (match.homeScore ?? 0) + (match.awayScore ?? 0);
    final totalShots = match.shotsOnTargetTotal ?? 0;

    switch (market) {
      case BetMarket.matchWinner:
        return betType == winner;
      case BetMarket.firstScoringTeam:
        return selection.toLowerCase() == (match.firstScoringTeam ?? '').toLowerCase();
      case BetMarket.overTwoGoals:
        return selection == 'Sí' ? totalGoals > 2 : totalGoals <= 2;
      case BetMarket.totalGoals:
        if (selection == '8+') return totalGoals >= 8;
        return int.tryParse(selection) == totalGoals;
      case BetMarket.totalShotsOnTarget:
        if (selection == '0-5') return totalShots <= 5;
        if (selection == '6-9') return totalShots >= 6 && totalShots <= 9;
        if (selection == '10+') return totalShots >= 10;
        return false;
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
    final betTypes = [BetType.homeWin, BetType.draw, BetType.awayWin];
    final betType = betTypes[random.nextInt(betTypes.length)];
    final amount = [100, 200, 300, 500, 750, 1000][random.nextInt(6)];
    final odds = (1.5 + random.nextDouble() * 3.5).clamp(1.1, 5.0);

    await createBet(
      userId: userId,
      matchId: match.id,
      betType: betType,
      market: BetMarket.matchWinner,
      selection: betType == BetType.homeWin
          ? match.homeTeam
          : betType == BetType.awayWin
              ? match.awayTeam
              : 'Empate',
      matchTitle: '${match.homeTeam} vs ${match.awayTeam}',
      createdByUserId: match.createdByUserId,
      amount: amount,
      odds: odds,
    );
  }

  /// Stream de apuestas activas
  Stream<List<Bet>> getActiveBetsStream(String userId) {
    final authUid = _auth.currentUser?.uid;
    final effectiveUserId = authUid ?? userId;
    return _firestore
        .collection('bets')
        .where('userId', isEqualTo: effectiveUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Bet(
          id: doc.id,
          userId: data['userId'],
          matchId: data['matchId'],
          betType: _betTypeFromString(data['betType'] as String?),
          market: _marketFromString(data['market'] as String?),
          selection: (data['selection'] as String?) ?? '',
          matchTitle: data['matchTitle'] as String?,
          createdByUserId: data['createdByUserId'] as String?,
          amount: data['amount'],
          odds: (data['odds'] as num).toDouble(),
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

class _TeamAccumulator {
  int played = 0;
  int won = 0;
  int draw = 0;
  int lost = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;
  int points = 0;
}
