import 'package:flutter/material.dart';

/// Modelo para un partido de fútbol
class Match {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final int? homeScore;
  final int? awayScore;
  final DateTime dateTime;
  final MatchStatus status;
  final String league;
  final bool isLocal; // Si es un equipo local
  final String? createdByUserId;
  final String? createdByName;
  final MatchSource source;
  final int? shotsOnTargetTotal;
  final String? firstScoringTeam;
  final int betsCount;

  Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeTeamLogo,
    required this.awayTeamLogo,
    this.homeScore,
    this.awayScore,
    required this.dateTime,
    required this.status,
    required this.league,
    this.isLocal = false,
    this.createdByUserId,
    this.createdByName,
    this.source = MatchSource.randomGenerated,
    this.shotsOnTargetTotal,
    this.firstScoringTeam,
    this.betsCount = 0,
  });
}

enum MatchStatus {
  scheduled,
  live,
  finished,
  cancelled,
}

enum MatchSource {
  userCreated,
  randomGenerated,
}

/// Modelo para un usuario
class BetFlixUser {
  final String id;
  final String name;
  final String email;
  final String profileImageUrl;
  final int coins;
  final int winStreak;
  final int totalBets;
  final int correctBets;
  final int level;
  final DateTime joinDate;

  BetFlixUser({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.coins,
    this.winStreak = 0,
    this.totalBets = 0,
    this.correctBets = 0,
    this.level = 1,
    required this.joinDate,
  });

  double get successRate {
    if (totalBets == 0) return 0;
    return (correctBets / totalBets) * 100;
  }

  int get rankingPosition {
    // Este valor viene del servidor
    return 0;
  }

  BetFlixUser copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    int? coins,
    int? winStreak,
    int? totalBets,
    int? correctBets,
    int? level,
    DateTime? joinDate,
  }) {
    return BetFlixUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      coins: coins ?? this.coins,
      winStreak: winStreak ?? this.winStreak,
      totalBets: totalBets ?? this.totalBets,
      correctBets: correctBets ?? this.correctBets,
      level: level ?? this.level,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}

/// Modelo para una apuesta
class Bet {
  final String id;
  final String userId;
  final String matchId;
  final BetType betType;
  final BetMarket market;
  final String selection;
  final String? matchTitle;
  final String? createdByUserId;
  final int amount;
  final double odds;
  final DateTime createdAt;
  final BetStatus status;
  final int? potentialWinnings;

  Bet({
    required this.id,
    required this.userId,
    required this.matchId,
    required this.betType,
    this.market = BetMarket.matchWinner,
    this.selection = '',
    this.matchTitle,
    this.createdByUserId,
    required this.amount,
    required this.odds,
    required this.createdAt,
    required this.status,
    this.potentialWinnings,
  });
}

enum BetType {
  homeWin,
  awayWin,
  draw,
  over,
  under,
}

enum BetMarket {
  matchWinner,
  firstScoringTeam,
  overTwoGoals,
  totalGoals,
  totalShotsOnTarget,
}

enum BetStatus {
  pending,
  won,
  lost,
  voided,
  cancelled,
}

/// Modelo para un reto/desafío
class Challenge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int rewardCoins;
  final DateTime deadline;
  final ChallengeStatus status;
  final ChallengeType type;
  final int? targetValue;
  final int? currentProgress;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.rewardCoins,
    required this.deadline,
    required this.status,
    required this.type,
    this.targetValue,
    this.currentProgress,
  });

  double get progressPercentage {
    if (targetValue == null || currentProgress == null) return 0;
    return (currentProgress! / targetValue!) * 100;
  }
}

enum ChallengeStatus {
  active,
  completed,
  expired,
  locked,
}

enum ChallengeType {
  betCount,
  winStreak,
  correctPredictions,
  coinEarned,
  teamWins,
}

/// Modelo para el ranking
class RankingEntry {
  final int position;
  final String userId;
  final String userName;
  final String profileImageUrl;
  final int coins;
  final int correctBets;
  final int totalBets;
  final int badges;

  RankingEntry({
    required this.position,
    required this.userId,
    required this.userName,
    required this.profileImageUrl,
    required this.coins,
    required this.correctBets,
    required this.totalBets,
    required this.badges,
  });

  double get successRate {
    if (totalBets == 0) return 0;
    return (correctBets / totalBets) * 100;
  }
}

/// Modelo para logros/badges
class BetFlixBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;

  BetFlixBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });
}

class NeighborhoodTeamStanding {
  final String teamName;
  final int played;
  final int won;
  final int draw;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int points;

  NeighborhoodTeamStanding({
    required this.teamName,
    required this.played,
    required this.won,
    required this.draw,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.points,
  });

  int get goalDifference => goalsFor - goalsAgainst;
}
