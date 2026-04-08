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

  Stream<List<NeighborhoodTeamStanding>> getNeighborhoodTournamentTableStream() {
    return _betService.getNeighborhoodTournamentTableStream();
  }

  Future<void> seedRandomMatchesIfEmpty() async {
    await _betService.seedRandomMatchesIfEmpty();
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

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
