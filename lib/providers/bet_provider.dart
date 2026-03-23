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
