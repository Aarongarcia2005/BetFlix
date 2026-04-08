import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class BetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _mapFirestoreError(Object e) {
    if (e is FirebaseException) {
      if (e.code == 'permission-denied') {
        return 'Firestore deniega permisos. Revisa reglas y que el usuario esté autenticado.';
      }
      if (e.code == 'failed-precondition') {
        return 'Firestore requiere un índice para esta consulta. Crea los índices de firestore.indexes.json.';
      }
      if (e.code == 'unavailable') {
        return 'Firestore no disponible. Revisa conexión e inicialización de Firebase.';
      }
      return e.message ?? 'Error de Firebase (${e.code}).';
    }
    return e.toString();
  }

  Future<NeighborhoodSeason> _getOrCreateActiveSeason() async {
    final activeSnapshot = await _firestore
        .collection('seasons')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (activeSnapshot.docs.isNotEmpty) {
      final doc = activeSnapshot.docs.first;
      final data = doc.data();
      return NeighborhoodSeason(
        id: doc.id,
        name: data['name'] ?? 'Temporada Actual',
        isActive: data['isActive'] ?? true,
        createdAt: _parseDateTime(data['createdAt']),
      );
    }

    final now = DateTime.now();
    final name = 'Temporada ${now.year}-${now.month.toString().padLeft(2, '0')}';
    final docRef = await _firestore.collection('seasons').add({
      'name': name,
      'isActive': true,
      'createdAt': now.toIso8601String(),
    });

    return NeighborhoodSeason(
      id: docRef.id,
      name: name,
      isActive: true,
      createdAt: now,
    );
  }

  Future<void> ensureActiveSeason() async {
    await _getOrCreateActiveSeason();
  }

  Stream<NeighborhoodSeason?> getActiveSeasonStream() {
    return _firestore
        .collection('seasons')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final data = doc.data();
      return NeighborhoodSeason(
        id: doc.id,
        name: data['name'] ?? 'Temporada Actual',
        isActive: data['isActive'] ?? true,
        createdAt: _parseDateTime(data['createdAt']),
      );
    });
  }

  Future<void> startNewSeason({required String seasonName}) async {
    final batch = _firestore.batch();
    final activeSnapshot = await _firestore
        .collection('seasons')
        .where('isActive', isEqualTo: true)
        .get();

    for (final doc in activeSnapshot.docs) {
      batch.update(doc.reference, {'isActive': false});
    }

    final newSeasonRef = _firestore.collection('seasons').doc();
    batch.set(newSeasonRef, {
      'name': seasonName,
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
    });

    await batch.commit();
  }

  Future<void> resolvePlayoffBracketForSeason({required String seasonId}) async {
    final finishedRegularSnapshot = await _firestore
        .collection('matches')
        .where('seasonId', isEqualTo: seasonId)
        .where('phase', isEqualTo: 'regular')
        .where('status', isEqualTo: MatchStatus.finished.name)
        .get();

    final Map<String, _TeamAccumulator> table = {};
    for (final doc in finishedRegularSnapshot.docs) {
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

    final ranking = table.entries.toList()
      ..sort((a, b) {
        if (b.value.points != a.value.points) {
          return b.value.points.compareTo(a.value.points);
        }
        final gdA = a.value.goalsFor - a.value.goalsAgainst;
        final gdB = b.value.goalsFor - b.value.goalsAgainst;
        if (gdB != gdA) return gdB.compareTo(gdA);
        return b.value.goalsFor.compareTo(a.value.goalsFor);
      });

    if (ranking.length >= 4) {
      final top = ranking.take(4).map((e) => e.key).toList();
      final semisSnapshot = await _firestore
          .collection('matches')
          .where('seasonId', isEqualTo: seasonId)
          .where('phase', isEqualTo: 'playoff_semifinal')
          .orderBy('roundNumber')
          .get();

      if (semisSnapshot.docs.length >= 2) {
        await semisSnapshot.docs[0].reference.update({
          'homeTeam': top[0],
          'awayTeam': top[3],
        });
        await semisSnapshot.docs[1].reference.update({
          'homeTeam': top[1],
          'awayTeam': top[2],
        });
      }
    }

    final finishedSemisSnapshot = await _firestore
        .collection('matches')
        .where('seasonId', isEqualTo: seasonId)
        .where('phase', isEqualTo: 'playoff_semifinal')
        .where('status', isEqualTo: MatchStatus.finished.name)
        .orderBy('roundNumber')
        .get();

    if (finishedSemisSnapshot.docs.length < 2) return;

    final semi1 = _matchFromDoc(finishedSemisSnapshot.docs[0]);
    final semi2 = _matchFromDoc(finishedSemisSnapshot.docs[1]);
    final semi1Winner = (semi1.homeScore ?? 0) >= (semi1.awayScore ?? 0) ? semi1.homeTeam : semi1.awayTeam;
    final semi1Loser = semi1Winner == semi1.homeTeam ? semi1.awayTeam : semi1.homeTeam;
    final semi2Winner = (semi2.homeScore ?? 0) >= (semi2.awayScore ?? 0) ? semi2.homeTeam : semi2.awayTeam;
    final semi2Loser = semi2Winner == semi2.homeTeam ? semi2.awayTeam : semi2.homeTeam;

    final finalSnapshot = await _firestore
        .collection('matches')
        .where('seasonId', isEqualTo: seasonId)
        .where('phase', isEqualTo: 'playoff_final')
        .limit(1)
        .get();
    final thirdSnapshot = await _firestore
        .collection('matches')
        .where('seasonId', isEqualTo: seasonId)
        .where('phase', isEqualTo: 'playoff_third_place')
        .limit(1)
        .get();

    if (finalSnapshot.docs.isNotEmpty) {
      await finalSnapshot.docs.first.reference.update({
        'homeTeam': semi1Winner,
        'awayTeam': semi2Winner,
      });
    }
    if (thirdSnapshot.docs.isNotEmpty) {
      await thirdSnapshot.docs.first.reference.update({
        'homeTeam': semi1Loser,
        'awayTeam': semi2Loser,
      });
    }
  }

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
    if (value == MatchSource.tournamentGenerated.name) {
      return MatchSource.tournamentGenerated;
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
      seasonId: data['seasonId'] as String?,
      seasonName: data['seasonName'] as String?,
      roundNumber: data['roundNumber'] as int?,
      phase: data['phase'] as String?,
    );
  }

  List<List<String>> _buildRoundRobinRounds(List<String> originalTeams) {
    final teams = List<String>.from(originalTeams);
    if (teams.length.isOdd) {
      teams.add('BYE');
    }

    final rounds = <List<String>>[];
    final n = teams.length;
    final half = n ~/ 2;

    for (int round = 0; round < n - 1; round++) {
      final pairings = <String>[];
      for (int i = 0; i < half; i++) {
        final home = teams[i];
        final away = teams[n - 1 - i];
        if (home != 'BYE' && away != 'BYE') {
          pairings.add('$home|$away');
        }
      }
      rounds.add(pairings);

      final fixed = teams.first;
      final rotating = teams.sublist(1);
      rotating.insert(0, rotating.removeLast());
      teams
        ..clear()
        ..add(fixed)
        ..addAll(rotating);
    }

    return rounds;
  }

  Future<bool> generateSeasonSchedule({
    required String seasonId,
    required String seasonName,
    required List<String> teams,
    DateTime? firstKickoff,
  }) async {
    if (teams.length < 4) {
      throw 'Se requieren al menos 4 equipos para generar calendario.';
    }

    final normalized = teams
        .map((team) => team.trim())
        .where((team) => team.isNotEmpty)
        .toSet()
        .toList();

    if (normalized.length < 4) {
      throw 'Debes introducir al menos 4 equipos únicos.';
    }

    final existing = await _firestore
        .collection('matches')
        .where('seasonId', isEqualTo: seasonId)
        .where('source', isEqualTo: MatchSource.tournamentGenerated.name)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw 'Esta temporada ya tiene calendario generado.';
    }

    final kickoffBase = firstKickoff ?? DateTime.now().add(const Duration(days: 1));
    final rounds = _buildRoundRobinRounds(normalized);
    final batch = _firestore.batch();

    for (int r = 0; r < rounds.length; r++) {
      final roundPairings = rounds[r];
      for (int m = 0; m < roundPairings.length; m++) {
        final parts = roundPairings[m].split('|');
        final home = parts[0];
        final away = parts[1];
        final kickoff = kickoffBase.add(Duration(days: r * 7, hours: m * 2));
        final ref = _firestore.collection('matches').doc();
        batch.set(ref, {
          'homeTeam': home,
          'awayTeam': away,
          'homeTeamLogo': '🏟️',
          'awayTeamLogo': '🏟️',
          'homeScore': 0,
          'awayScore': 0,
          'shotsOnTargetTotal': 0,
          'firstScoringTeam': '',
          'dateTime': kickoff.toIso8601String(),
          'status': MatchStatus.scheduled.name,
          'league': 'Torneo de Barrio',
          'isLocal': true,
          'createdByUserId': 'system',
          'createdByName': 'Calendario BetFlix',
          'source': MatchSource.tournamentGenerated.name,
          'betsCount': 0,
          'seasonId': seasonId,
          'seasonName': seasonName,
          'roundNumber': r + 1,
          'phase': 'regular',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    }

    // Playoff placeholders (semis + final + tercer puesto)
    final playoffBase = kickoffBase.add(Duration(days: rounds.length * 7 + 1));
    final playoffMatches = [
      {'home': '1º Liga', 'away': '4º Liga', 'round': rounds.length + 1, 'phase': 'playoff_semifinal'},
      {'home': '2º Liga', 'away': '3º Liga', 'round': rounds.length + 1, 'phase': 'playoff_semifinal'},
      {'home': 'Perdedor SF1', 'away': 'Perdedor SF2', 'round': rounds.length + 2, 'phase': 'playoff_third_place'},
      {'home': 'Ganador SF1', 'away': 'Ganador SF2', 'round': rounds.length + 2, 'phase': 'playoff_final'},
    ];

    for (int i = 0; i < playoffMatches.length; i++) {
      final p = playoffMatches[i];
      final ref = _firestore.collection('matches').doc();
      batch.set(ref, {
        'homeTeam': p['home'],
        'awayTeam': p['away'],
        'homeTeamLogo': '🏆',
        'awayTeamLogo': '🏆',
        'homeScore': 0,
        'awayScore': 0,
        'shotsOnTargetTotal': 0,
        'firstScoringTeam': '',
        'dateTime': playoffBase.add(Duration(days: i < 2 ? 0 : 7, hours: i * 2)).toIso8601String(),
        'status': MatchStatus.scheduled.name,
        'league': 'Playoff Torneo de Barrio',
        'isLocal': true,
        'createdByUserId': 'system',
        'createdByName': 'Calendario BetFlix',
        'source': MatchSource.tournamentGenerated.name,
        'betsCount': 0,
        'seasonId': seasonId,
        'seasonName': seasonName,
        'roundNumber': p['round'],
        'phase': p['phase'],
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    await batch.commit();
    return true;
  }

  Stream<List<Match>> getSeasonFixturesStream({required String seasonId}) {
    return _firestore
        .collection('matches')
        .where('seasonId', isEqualTo: seasonId)
        .orderBy('roundNumber')
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_matchFromDoc).toList());
  }

  Future<String> awardSeasonPrizes({required String seasonId}) async {
    final rewardDocRef = _firestore.collection('season_rewards').doc(seasonId);
    final existingRewardDoc = await rewardDocRef.get();
    if (existingRewardDoc.exists) {
      return 'La temporada ya fue premiada anteriormente.';
    }

    final matchesSnapshot = await _firestore
        .collection('matches')
        .where('seasonId', isEqualTo: seasonId)
        .where('status', isEqualTo: MatchStatus.finished.name)
        .get();

    final matchIds = matchesSnapshot.docs.map((doc) => doc.id).toList();
    if (matchIds.isEmpty) {
      throw 'No hay partidos finalizados en esta temporada.';
    }

    final Map<String, _SeasonUserStat> stats = {};

    for (int i = 0; i < matchIds.length; i += 10) {
      final chunk = matchIds.sublist(i, i + 10 > matchIds.length ? matchIds.length : i + 10);
      final betsSnapshot = await _firestore
          .collection('bets')
          .where('matchId', whereIn: chunk)
          .get();

      for (final doc in betsSnapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String?;
        if (userId == null || userId.isEmpty) continue;

        final entry = stats.putIfAbsent(userId, () => _SeasonUserStat());
        entry.totalBets += 1;

        final status = data['status'] as String?;
        final amount = (data['amount'] as num?)?.toInt() ?? 0;
        final payout = (data['potentialWinnings'] as num?)?.toInt() ?? 0;

        if (status == BetStatus.won.name) {
          entry.wonBets += 1;
          entry.net += payout;
        } else if (status == BetStatus.lost.name) {
          entry.net -= amount;
        }
      }
    }

    if (stats.isEmpty) {
      throw 'No hay apuestas para premiar en esta temporada.';
    }

    final sorted = stats.entries.toList()
      ..sort((a, b) {
        if (b.value.net != a.value.net) return b.value.net.compareTo(a.value.net);
        return b.value.wonBets.compareTo(a.value.wonBets);
      });

    final top3 = sorted.take(3).toList();
    final bonuses = [5000, 3000, 1500];
    final batch = _firestore.batch();
    final winnersPayload = <Map<String, dynamic>>[];

    for (int i = 0; i < top3.length; i++) {
      final userId = top3[i].key;
      final bonus = bonuses[i];
      final userRef = _firestore.collection('users').doc(userId);
      batch.set(userRef, {'coins': FieldValue.increment(bonus)}, SetOptions(merge: true));
      winnersPayload.add({
        'position': i + 1,
        'userId': userId,
        'bonus': bonus,
        'net': top3[i].value.net,
      });
    }

    String? mvpUserId;
    double bestRate = -1;
    for (final entry in sorted) {
      if (entry.value.totalBets < 3) continue;
      final rate = entry.value.wonBets / entry.value.totalBets;
      if (rate > bestRate) {
        bestRate = rate;
        mvpUserId = entry.key;
      }
    }
    mvpUserId ??= sorted.first.key;

    final mvpRef = _firestore.collection('users').doc(mvpUserId);
    batch.set(mvpRef, {'coins': FieldValue.increment(2500)}, SetOptions(merge: true));

    final seasonDoc = await _firestore.collection('seasons').doc(seasonId).get();
    final seasonName = (seasonDoc.data() ?? {})['name'] ?? seasonId;

    batch.set(rewardDocRef, {
      'seasonId': seasonId,
      'seasonName': seasonName,
      'awardedAt': DateTime.now().toIso8601String(),
      'top3': winnersPayload,
      'championUserId': top3.isNotEmpty ? top3.first.key : '',
      'championBonus': bonuses.first,
      'mvpUserId': mvpUserId,
      'mvpBonus': 2500,
    });

    batch.set(
      _firestore.collection('seasons').doc(seasonId),
      {
        'isActive': false,
        'awardedAt': DateTime.now().toIso8601String(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
    return 'Premios aplicados: Top 3 + MVP con bonos de temporada.';
  }

  Stream<List<SeasonChampionEntry>> getSeasonChampionsHistoryStream() {
    return _firestore
        .collection('season_rewards')
        .orderBy('awardedAt', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SeasonChampionEntry(
          seasonId: data['seasonId'] ?? doc.id,
          seasonName: data['seasonName'] ?? data['seasonId'] ?? doc.id,
          championUserId: data['championUserId'] ?? '',
          awardedAt: _parseDateTime(data['awardedAt']),
          championBonus: (data['championBonus'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    });
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
      final activeSeason = await _getOrCreateActiveSeason();
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
        'seasonId': activeSeason.id,
        'seasonName': activeSeason.name,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return docRef.id;
    } catch (e) {
      throw 'Error al crear partido personalizado: ${_mapFirestoreError(e)}';
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
    final activeSeason = await _getOrCreateActiveSeason();
    final existing = await _firestore
        .collection('matches')
        .where('source', isEqualTo: MatchSource.randomGenerated.name)
      .where('seasonId', isEqualTo: activeSeason.id)
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
        'seasonId': activeSeason.id,
        'seasonName': activeSeason.name,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> autoCloseExpiredMatches({
    Duration gracePeriod = const Duration(minutes: 110),
  }) async {
    final threshold = DateTime.now().subtract(gracePeriod).toIso8601String();
    final snapshot = await _firestore
        .collection('matches')
        .where('status', whereIn: [
          MatchStatus.scheduled.name,
          MatchStatus.live.name,
        ])
        .where('dateTime', isLessThanOrEqualTo: threshold)
        .get();

    if (snapshot.docs.isEmpty) return;

    final random = Random();
    final touchedSeasons = <String>{};
    for (final doc in snapshot.docs) {
      final match = _matchFromDoc(doc);
      if (match.seasonId != null && match.seasonId!.isNotEmpty) {
        touchedSeasons.add(match.seasonId!);
      }
      final homeScore = match.homeScore ?? random.nextInt(5);
      final awayScore = match.awayScore ?? random.nextInt(5);
      final shots = match.shotsOnTargetTotal ?? (5 + random.nextInt(10));
      final firstScorer = (match.firstScoringTeam == null || match.firstScoringTeam!.isEmpty)
          ? (random.nextBool() ? match.homeTeam : match.awayTeam)
          : match.firstScoringTeam!;

      await doc.reference.update({
        'homeScore': homeScore,
        'awayScore': awayScore,
        'shotsOnTargetTotal': shots,
        'firstScoringTeam': firstScorer,
        'status': MatchStatus.finished.name,
        'autoClosedAt': DateTime.now().toIso8601String(),
      });

      await resolveBetsForMatch(
        match: Match(
          id: match.id,
          homeTeam: match.homeTeam,
          awayTeam: match.awayTeam,
          homeTeamLogo: match.homeTeamLogo,
          awayTeamLogo: match.awayTeamLogo,
          dateTime: match.dateTime,
          status: MatchStatus.finished,
          league: match.league,
          isLocal: match.isLocal,
          homeScore: homeScore,
          awayScore: awayScore,
          createdByUserId: match.createdByUserId,
          createdByName: match.createdByName,
          source: match.source,
          shotsOnTargetTotal: shots,
          firstScoringTeam: firstScorer,
          betsCount: match.betsCount,
          seasonId: match.seasonId,
          seasonName: match.seasonName,
        ),
      );
    }

    for (final seasonId in touchedSeasons) {
      await resolvePlayoffBracketForSeason(seasonId: seasonId);
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
        seasonId: data['seasonId'] as String?,
        seasonName: data['seasonName'] as String?,
      );
      await resolveBetsForMatch(match: updatedMatch);

      final sid = updatedMatch.seasonId;
      if (sid != null && sid.isNotEmpty) {
        await resolvePlayoffBracketForSeason(seasonId: sid);
      }
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

      final userRef = _firestore.collection('users').doc(userId);
      batch.set(userRef, {
        'totalBets': FieldValue.increment(1),
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      throw 'Error al crear apuesta: ${_mapFirestoreError(e)}';
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

  Stream<List<NeighborhoodTeamStanding>> getNeighborhoodTournamentTableStream({
    required String seasonId,
  }) {
    return _firestore
        .collection('matches')
        .where('source', isEqualTo: MatchSource.userCreated.name)
        .where('status', isEqualTo: MatchStatus.finished.name)
        .where('seasonId', isEqualTo: seasonId)
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
      throw 'Error al obtener apuestas: ${_mapFirestoreError(e)}';
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
        await userDocRef.set({
          'coins': FieldValue.increment(potentialWinnings),
          'correctBets': FieldValue.increment(1),
        }, SetOptions(merge: true));
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
    const sampleDemoEmails = {
      'agarcia@gmail.com',
      'jterreros@gmail.com',
      'gblanco@gmail.com',
    };

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

        final isDemo = data['isDemo'] == true;
        final email = (data['email'] ?? '').toString().trim().toLowerCase();
        final name = (data['name'] ?? '').toString().trim().toLowerCase();
        final looksLikeSampleName = name == 'aaron garcia' ||
            name == 'jan terreros' ||
            name == 'gerard blanco';
        if (isDemo || sampleDemoEmails.contains(email) || looksLikeSampleName) {
          continue;
        }

        entries.add(RankingEntry(
          position: entries.length + 1,
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

class _SeasonUserStat {
  int totalBets = 0;
  int wonBets = 0;
  int net = 0;
}
