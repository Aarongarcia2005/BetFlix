import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/bet_service.dart';

class BetProvider extends ChangeNotifier {
  final BetService _betService = BetService();
  List<Bet> _userBets = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Bet> get userBets => _userBets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load user bets
  Future<void> loadUserBets(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userBets = await _betService.getUserBets(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create bet
  Future<bool> createBet({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _betService.createBet(
        userId: userId,
        matchId: matchId,
        betType: betType,
        market: market,
        selection: selection,
        matchTitle: matchTitle,
        createdByUserId: createdByUserId,
        amount: amount,
        odds: odds,
      );
      await loadUserBets(userId);
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

  /// Get active bets stream
  Stream<List<Bet>> getActiveBetsStream(String userId) {
    return _betService.getActiveBetsStream(userId);
  }

  /// Get ranking stream
  Stream<List<RankingEntry>> getRankingStream() {
    return _betService.getRankingStream();
  }

  Stream<List<Match>> getOpenMatchesStream() {
    return _betService.getOpenMatchesStream();
  }

  Stream<List<Match>> getTrendingMatchesStream() {
    return _betService.getTrendingMatchesStream();
  }

  Stream<NeighborhoodSeason?> getActiveSeasonStream() {
    return _betService.getActiveSeasonStream();
  }

  Stream<List<NeighborhoodTeamStanding>> getNeighborhoodTournamentTableStream({
    required String seasonId,
  }) {
    return _betService.getNeighborhoodTournamentTableStream(seasonId: seasonId);
  }

  Stream<List<Match>> getSeasonFixturesStream({required String seasonId}) {
    return _betService.getSeasonFixturesStream(seasonId: seasonId);
  }

  Stream<List<SeasonChampionEntry>> getSeasonChampionsHistoryStream() {
    return _betService.getSeasonChampionsHistoryStream();
  }

  Stream<List<CoinMovement>> getUserCoinMovementsStream(String userId) {
    return _betService.getUserCoinMovementsStream(userId);
  }

  Future<void> seedRandomMatchesIfEmpty() async {
    await _betService.seedRandomMatchesIfEmpty();
  }

  Future<void> ensureActiveSeason() async {
    await _betService.ensureActiveSeason();
  }

  Future<bool> startNewSeason({required String seasonName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _betService.startNewSeason(seasonName: seasonName);
      await _betService.seedRandomMatchesIfEmpty();
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

  Future<void> autoCloseExpiredMatches() async {
    try {
      await _betService.autoCloseExpiredMatches();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> generateSeasonSchedule({
    required String seasonId,
    required String seasonName,
    required List<String> teams,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _betService.generateSeasonSchedule(
        seasonId: seasonId,
        seasonName: seasonName,
        teams: teams,
      );
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

  Future<String?> awardSeasonPrizes({required String seasonId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final message = await _betService.awardSeasonPrizes(seasonId: seasonId);
      _isLoading = false;
      notifyListeners();
      return message;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> resolvePlayoffBracketForSeason({required String seasonId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _betService.resolvePlayoffBracketForSeason(seasonId: seasonId);
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

  Future<String?> createCustomMatch({
    required String ownerUserId,
    required String ownerName,
    required String homeTeam,
    required String awayTeam,
    required String league,
    required DateTime kickoff,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = await _betService.createCustomMatch(
        ownerUserId: ownerUserId,
        ownerName: ownerName,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        league: league,
        kickoff: kickoff,
      );
      _isLoading = false;
      notifyListeners();
      return id;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateCustomMatchStats({
    required String matchId,
    required String ownerUserId,
    required int homeScore,
    required int awayScore,
    required int shotsOnTargetTotal,
    required String firstScoringTeam,
    required MatchStatus status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _betService.updateCustomMatchStats(
        matchId: matchId,
        ownerUserId: ownerUserId,
        homeScore: homeScore,
        awayScore: awayScore,
        shotsOnTargetTotal: shotsOnTargetTotal,
        firstScoringTeam: firstScoringTeam,
        status: status,
      );
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

  /// Resolver apuestas de un partido
  Future<void> resolveMatchBets(Match match) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _betService.resolveBetsForMatch(match: match);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crear apuesta aleatoria
  Future<bool> createRandomBet({
    required String userId,
    required Match match,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _betService.createRandomBetForUser(userId: userId, match: match);
      await loadUserBets(userId);
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

  Future<bool> cancelBet({
    required String betId,
    required String userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _betService.cancelBet(betId: betId, userId: userId);
      await loadUserBets(userId);
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

  Future<Match?> getMatchById(String matchId) {
    return _betService.getMatchById(matchId);
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
