import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../config/app_constants.dart';
import '../config/app_theme.dart';
import '../models/models.dart';
import '../providers/bet_provider.dart';
import '../providers/user_provider.dart';
import '../screens/create_bet_screen.dart';
import '../services/match_service.dart';
import '../widgets/betflix_widgets.dart';

/// Pantalla principal con partidos locales
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedMatchIndex = -1;
  final MatchService _matchService = MatchService();
  final Random _random = Random();
  late Timer _simulationTimer;
  List<Match> localMatches = [];
  List<Match> allMatches = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRandomMatches();

    _simulationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _simulateMatchResults();
    });
  }

  void _loadRandomMatches() {
    setState(() {
      localMatches = _matchService.generateRandomMatches(count: 4);
      allMatches = _matchService.generateRandomMatches(count: 8);
    });
  }

  void _simulateMatchResults() {
    setState(() {
      localMatches = _matchService.resolveMatchResults(localMatches);
      allMatches = _matchService.resolveMatchResults(allMatches);
    });

    // Si hay bets activas, actualizar estado desde BetProvider
    final betProvider = context.read<BetProvider>();
    for (final match in [...localMatches, ...allMatches]) {
      if (match.status == MatchStatus.finished) {
        betProvider.resolveMatchBets(match);
      }
    }
  }

  @override
  void dispose() {
    _simulationTimer.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // No se usan listas estáticas aquí; se generan dinámicamente en initState

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BetFlixColors.background,
      body: CustomScrollView(
        slivers: [
          // Header profesional
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: ProfessionalHeader(
                userName: 'Carlos G.',
                coins: 3200,
                rankPosition: 1,
                onProfileTap: () {
                  // Ir a perfil
                },
              ),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppConstants.paddingMedium),

                // Sección de partidos locales
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Partidos Locales',
                            style: TextStyle(
                              color: BetFlixColors.cyanBright,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            child: const Text(
                              'Ver más →',
                              style: TextStyle(
                                color: BetFlixColors.pinkBright,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                    ],
                  ),
                ),

                // Tarjetas de partidos locales
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                    ),
                    itemCount: localMatches.length,
                    itemBuilder: (context, index) {
                      final match = localMatches[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          right: AppConstants.paddingMedium,
                        ),
                        child: SizedBox(
                          width: 250,
                          child: MatchCard(
                            homeTeam: match.homeTeam,
                            awayTeam: match.awayTeam,
                            league: match.league,
                            dateTime:
                                'Hoy · ${match.dateTime.hour}:${match.dateTime.minute.toString().padLeft(2, '0')}',
                            isLocal: match.isLocal,
                            isLive: match.status == MatchStatus.live,
                            homeScore: match.homeScore,
                            awayScore: match.awayScore,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CreateBetScreen(match: match),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppConstants.paddingMedium),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BetFlixColors.pinkBright,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: _loadRandomMatches,
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text('Refrescar Partidos'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BetFlixColors.cyanBright,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: _simulateMatchResults,
                        icon: const Icon(Icons.sports_soccer, size: 20),
                        label: const Text('Simular Resultados'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BetFlixColors.orangeVibrant,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () async {
                          final user = context.read<UserProvider>().currentUser;
                          if (user == null || localMatches.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Inicia sesión y carga partidos primero.')),
                            );
                            return;
                          }
                          final match = localMatches[_random.nextInt(localMatches.length)];
                          final success = await context.read<BetProvider>().createRandomBet(
                                userId: user.id,
                                match: match,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? 'Apuesta aleatoria creada con éxito para ${match.homeTeam} vs ${match.awayTeam}.'
                                  : 'Error al crear apuesta aleatoria.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.auto_awesome, size: 20),
                        label: const Text('Apuesta Random'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                  ),
                  child: _trendingFeedSection(),
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                  ),
                  child: _tournamentModeSection(),
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Retos populares
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Retos Populares',
                            style: TextStyle(
                              color: BetFlixColors.cyanBright,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            child: const Text(
                              'Ver todos →',
                              style: TextStyle(
                                color: BetFlixColors.pinkBright,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      ChallengeCard(
                        title: 'Reto 1 vs 1',
                        description: 'Acertá el resultado de 3 partidos',
                        icon: '🎯',
                        rewardCoins: 500,
                        progressPercentage: 66,
                        onTap: () {
                          Navigator.pushNamed(context, '/challenges');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.paddingLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _trendingFeedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feed Trending',
          style: TextStyle(
            color: BetFlixColors.cyanBright,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        StreamBuilder<List<Match>>(
          stream: context.watch<BetProvider>().getTrendingMatchesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: BetFlixColors.cyanBright),
              );
            }

            final matches = snapshot.data ?? const <Match>[];
            if (matches.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF222238),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Aún no hay partidos en tendencia. Crea y apuesta para activarlo.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return Column(
              children: matches.take(5).map((match) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2B2B42),
                        const Color(0xFF18182A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BetFlixColors.purpleVibrant.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${match.homeTeam} vs ${match.awayTeam}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${match.betsCount} apuestas • ${match.source == MatchSource.userCreated ? 'Barrio' : 'Open BetFlix'}',
                              style: const TextStyle(
                                color: BetFlixColors.cyanBright,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateBetScreen(match: match),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BetFlixColors.pinkBright,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Apostar'),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _tournamentModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modo Torneo de Barrio',
          style: TextStyle(
            color: BetFlixColors.orangeVibrant,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2C233A),
                const Color(0xFF191726),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: BetFlixColors.orangeVibrant.withOpacity(0.3)),
          ),
          child: StreamBuilder<List<NeighborhoodTeamStanding>>(
            stream: context.watch<BetProvider>().getNeighborhoodTournamentTableStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: BetFlixColors.orangeVibrant),
                );
              }

              final table = snapshot.data ?? const <NeighborhoodTeamStanding>[];
              if (table.isEmpty) {
                return const Text(
                  'Finaliza partidos personalizados para generar la clasificación del torneo.',
                  style: TextStyle(color: Colors.white70),
                );
              }

              return Column(
                children: [
                  const Row(
                    children: [
                      Expanded(flex: 4, child: Text('Equipo', style: TextStyle(color: BetFlixColors.cyanBright, fontWeight: FontWeight.bold))),
                      Expanded(child: Text('PJ', textAlign: TextAlign.center, style: TextStyle(color: BetFlixColors.cyanBright, fontWeight: FontWeight.bold))),
                      Expanded(child: Text('DG', textAlign: TextAlign.center, style: TextStyle(color: BetFlixColors.cyanBright, fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Pts', textAlign: TextAlign.center, style: TextStyle(color: BetFlixColors.goldYellow, fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const Divider(color: Colors.white24),
                  ...table.take(6).map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              entry.teamName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(
                            child: Text('${entry.played}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                          ),
                          Expanded(
                            child: Text('${entry.goalDifference}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                          ),
                          Expanded(
                            child: Text('${entry.points}', textAlign: TextAlign.center, style: const TextStyle(color: BetFlixColors.goldYellow, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
