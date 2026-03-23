import 'dart:math';
import '../models/models.dart';

class MatchService {
  final Random _random = Random();

  // Genera partidos aleatorios con estado puede ser scheduled/live
  List<Match> generateRandomMatches({int count = 6}) {
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

    final matches = <Match>[];

    for (int i = 0; i < count; i++) {
      final home = teams[_random.nextInt(teams.length)];
      String away;
      do {
        away = teams[_random.nextInt(teams.length)];
      } while (away == home);

      final status = MatchStatus.values[_random.nextInt(3)]; // scheduled/live/finished
      final date = DateTime.now().add(Duration(minutes: 30 * i));

      int? homeScore;
      int? awayScore;
      if (status == MatchStatus.live || status == MatchStatus.finished) {
        homeScore = _random.nextInt(5);
        awayScore = _random.nextInt(5);
      }

      matches.add(
        Match(
          id: 'match_${DateTime.now().millisecondsSinceEpoch}_${i}',
          homeTeam: home,
          awayTeam: away,
          homeTeamLogo: '⚽',
          awayTeamLogo: '⚽',
          dateTime: date,
          status: status,
          league: 'Liga de Barrios',
          isLocal: _random.nextBool(),
          homeScore: homeScore,
          awayScore: awayScore,
        ),
      );
    }

    return matches;
  }

  /// Determina el resultado de un partido finished y resuelve ganador
  BetType? computeMatchWinner(Match match) {
    if (match.homeScore == null || match.awayScore == null) return null;
    if (match.homeScore! > match.awayScore!) return BetType.homeWin;
    if (match.homeScore! < match.awayScore!) return BetType.awayWin;
    return BetType.draw;
  }

  /// Poner en estado finished random a partidos live o scheduled
  List<Match> resolveMatchResults(List<Match> currentMatches) {
    return currentMatches.map((match) {
      if (match.status == MatchStatus.scheduled || match.status == MatchStatus.live) {
        final updatedHome = _random.nextInt(5);
        final updatedAway = _random.nextInt(5);

        return Match(
          id: match.id,
          homeTeam: match.homeTeam,
          awayTeam: match.awayTeam,
          homeTeamLogo: match.homeTeamLogo,
          awayTeamLogo: match.awayTeamLogo,
          dateTime: match.dateTime,
          status: MatchStatus.finished,
          league: match.league,
          isLocal: match.isLocal,
          homeScore: updatedHome,
          awayScore: updatedAway,
        );
      }
      return match;
    }).toList();
  }
}
