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
}
