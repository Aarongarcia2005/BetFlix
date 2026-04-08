import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/colors.dart';
import '../models/models.dart';
import '../providers/bet_provider.dart';

class TournamentCenterScreen extends StatefulWidget {
  const TournamentCenterScreen({Key? key}) : super(key: key);

  @override
  State<TournamentCenterScreen> createState() => _TournamentCenterScreenState();
}

class _TournamentCenterScreenState extends State<TournamentCenterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BetFlixColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Centro de Torneos'),
      ),
      body: StreamBuilder<NeighborhoodSeason?>(
        stream: context.watch<BetProvider>().getActiveSeasonStream(),
        builder: (context, seasonSnapshot) {
          final season = seasonSnapshot.data;
          if (season == null) {
            return const Center(
              child: CircularProgressIndicator(color: BetFlixColors.cyanBright),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Temporada activa: ${season.name}',
                        style: const TextStyle(
                          color: BetFlixColors.orangeVibrant,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final ok = await context
                                    .read<BetProvider>()
                                    .resolvePlayoffBracketForSeason(seasonId: season.id);
                                if (!mounted) return;
                                final error = context.read<BetProvider>().errorMessage;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(ok
                                        ? 'Llaves playoff actualizadas automáticamente.'
                                        : (error ?? 'No se pudieron actualizar llaves.')),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: BetFlixColors.cyanBright),
                              icon: const Icon(Icons.hub, color: Colors.black),
                              label: const Text('Actualizar llaves playoff', style: TextStyle(color: Colors.black)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final message = await context
                                    .read<BetProvider>()
                                    .awardSeasonPrizes(seasonId: season.id);
                                if (!mounted) return;
                                final error = context.read<BetProvider>().errorMessage;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      message ?? error ?? 'No se pudieron aplicar premios de temporada.',
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: BetFlixColors.goldYellow),
                              icon: const Icon(Icons.workspace_premium, color: Colors.black),
                              label: const Text('Premiar', style: TextStyle(color: Colors.black)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Jornadas y Playoff',
                  style: TextStyle(
                    color: BetFlixColors.cyanBright,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _panel(
                  child: StreamBuilder<List<Match>>(
                    stream: context.watch<BetProvider>().getSeasonFixturesStream(seasonId: season.id),
                    builder: (context, fixtureSnapshot) {
                      final fixtures = fixtureSnapshot.data ?? const <Match>[];
                      if (fixtures.isEmpty) {
                        return const Text(
                          'No hay calendario aún para esta temporada.',
                          style: TextStyle(color: Colors.white70),
                        );
                      }

                      final grouped = <int, List<Match>>{};
                      for (final m in fixtures) {
                        final key = m.roundNumber ?? 0;
                        grouped.putIfAbsent(key, () => []);
                        grouped[key]!.add(m);
                      }
                      final rounds = grouped.keys.toList()..sort();

                      return Column(
                        children: rounds.map((round) {
                          final roundMatches = grouped[round] ?? const <Match>[];
                          return ExpansionTile(
                            title: Text(
                              'Jornada $round',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            collapsedIconColor: BetFlixColors.cyanBright,
                            iconColor: BetFlixColors.cyanBright,
                            children: roundMatches.map((match) {
                              return ListTile(
                                dense: true,
                                title: Text(
                                  '${match.homeTeam} vs ${match.awayTeam}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  '${match.phase ?? 'regular'} • ${match.status.name}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: Text(
                                  '${match.homeScore ?? 0}-${match.awayScore ?? 0}',
                                  style: const TextStyle(
                                    color: BetFlixColors.goldYellow,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Historial de Campeones',
                  style: TextStyle(
                    color: BetFlixColors.orangeVibrant,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _panel(
                  child: StreamBuilder<List<SeasonChampionEntry>>(
                    stream: context.watch<BetProvider>().getSeasonChampionsHistoryStream(),
                    builder: (context, historySnapshot) {
                      final history = historySnapshot.data ?? const <SeasonChampionEntry>[];
                      if (history.isEmpty) {
                        return const Text(
                          'Todavía no hay temporadas premiadas.',
                          style: TextStyle(color: Colors.white70),
                        );
                      }

                      return Column(
                        children: history.map((entry) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.emoji_events, color: BetFlixColors.goldYellow),
                            title: Text(
                              entry.seasonName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              'Campeón usuario: ${entry.championUserId}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Text(
                              '+${entry.championBonus}',
                              style: const TextStyle(
                                color: BetFlixColors.greenLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2A2A3E),
            const Color(0xFF17172A),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BetFlixColors.purpleVibrant.withOpacity(0.28)),
      ),
      child: child,
    );
  }
}
