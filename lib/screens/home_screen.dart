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
  final TextEditingController _newSeasonController = TextEditingController();
  final TextEditingController _calendarTeamsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRandomMatches();
    Future.microtask(() async {
      await context.read<BetProvider>().ensureActiveSeason();
      await context.read<BetProvider>().seedRandomMatchesIfEmpty();
      await context.read<BetProvider>().autoCloseExpiredMatches();
    });

    _simulationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _simulateMatchResults();
      context.read<BetProvider>().autoCloseExpiredMatches();
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
    _newSeasonController.dispose();
    _calendarTeamsController.dispose();
    super.dispose();
  }

  // No se usan listas estáticas aquí; se generan dinámicamente en initState

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().currentUser;

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
                userName: currentUser?.name ?? 'Usuario',
                coins: currentUser?.coins ?? 0,
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
    return StreamBuilder<NeighborhoodSeason?>(
      stream: context.watch<BetProvider>().getActiveSeasonStream(),
      builder: (context, seasonSnapshot) {
        final season = seasonSnapshot.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Modo Torneo de Barrio',
                  style: TextStyle(
                    color: BetFlixColors.orangeVibrant,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _createSeasonDialog,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: BetFlixColors.orangeVibrant),
                  ),
                  icon: const Icon(Icons.add, color: BetFlixColors.orangeVibrant, size: 16),
                  label: const Text(
                    'Nueva temporada',
                    style: TextStyle(color: BetFlixColors.orangeVibrant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/tournament-center'),
                icon: const Icon(Icons.dashboard_customize, color: BetFlixColors.cyanBright),
                label: const Text(
                  'Abrir Centro de Torneos',
                  style: TextStyle(color: BetFlixColors.cyanBright, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: season == null ? null : () => _generateCalendarDialog(season),
                    style: ElevatedButton.styleFrom(backgroundColor: BetFlixColors.cyanBright),
                    icon: const Icon(Icons.calendar_month, color: Colors.black),
                    label: const Text('Generar jornadas + playoff', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: season == null ? null : () => _awardSeasonPrizes(season),
                    style: ElevatedButton.styleFrom(backgroundColor: BetFlixColors.goldYellow),
                    icon: const Icon(Icons.emoji_events, color: Colors.black),
                    label: const Text('Premiar temporada', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              season == null ? 'Cargando temporada...' : 'Activa: ${season.name}',
              style: const TextStyle(color: Colors.white70),
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
              child: season == null
                  ? const Center(
                      child: CircularProgressIndicator(color: BetFlixColors.orangeVibrant),
                    )
                  : StreamBuilder<List<NeighborhoodTeamStanding>>(
                      stream: context
                          .watch<BetProvider>()
                          .getNeighborhoodTournamentTableStream(seasonId: season.id),
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
            if (season != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF202035),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BetFlixColors.cyanBright.withOpacity(0.2)),
                ),
                child: StreamBuilder<List<Match>>(
                  stream: context.watch<BetProvider>().getSeasonFixturesStream(seasonId: season.id),
                  builder: (context, snapshot) {
                    final fixtures = snapshot.data ?? const <Match>[];
                    if (fixtures.isEmpty) {
                      return const Text(
                        'No hay calendario generado todavía para esta temporada.',
                        style: TextStyle(color: Colors.white70),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Calendario (Jornadas y Playoff)',
                          style: TextStyle(
                            color: BetFlixColors.cyanBright,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...fixtures.take(8).map((fixture) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'J${fixture.roundNumber ?? 0} • ${fixture.phase ?? 'regular'} • ${fixture.homeTeam} vs ${fixture.awayTeam}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _createSeasonDialog() async {
    _newSeasonController.text = 'Temporada ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C30),
          title: const Text('Crear nueva temporada', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _newSeasonController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Nombre de temporada',
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );

    if (result != true || !mounted) return;
    final name = _newSeasonController.text.trim();
    if (name.isEmpty) return;

    final success = await context.read<BetProvider>().startNewSeason(seasonName: name);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Nueva temporada creada: $name' : 'No se pudo crear la temporada.'),
      ),
    );
  }

  Future<void> _generateCalendarDialog(NeighborhoodSeason season) async {
    _calendarTeamsController.text = [
      'Barrio Norte FC',
      'Almagro Juniors',
      'Atlético Ciudad',
      'Racing Pueblo',
      'Libertad FC',
      'Fénix Rojos',
    ].join('\n');

    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C30),
          title: const Text('Generar calendario', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: 420,
            child: TextField(
              controller: _calendarTeamsController,
              maxLines: 10,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Un equipo por línea',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Generar'),
            ),
          ],
        );
      },
    );

    if (result != true || !mounted) return;
    final teams = _calendarTeamsController.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final success = await context.read<BetProvider>().generateSeasonSchedule(
          seasonId: season.id,
          seasonName: season.name,
          teams: teams,
        );

    if (!mounted) return;
    final error = context.read<BetProvider>().errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Calendario generado con jornadas + playoff.'
            : (error ?? 'No se pudo generar el calendario.')),
      ),
    );
  }

  Future<void> _awardSeasonPrizes(NeighborhoodSeason season) async {
    final message = await context.read<BetProvider>().awardSeasonPrizes(seasonId: season.id);
    if (!mounted) return;
    final error = context.read<BetProvider>().errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? error ?? 'No se pudieron aplicar premios de temporada.'),
      ),
    );
  }
}
