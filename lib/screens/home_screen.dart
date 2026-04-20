import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../config/app_constants.dart';
import '../config/app_theme.dart';
import '../models/models.dart';
import '../providers/bet_provider.dart';
import '../providers/theme_provider.dart';
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late final PageController _liveTickerPageController;
  late final AnimationController _livePulseController;
  int selectedMatchIndex = -1;
  final MatchService _matchService = MatchService();
  final Random _random = Random();
  Timer? _simulationTimer;
  List<Match> localMatches = [];
  List<Match> allMatches = [];
  late final Stream<List<Match>> _trendingMatchesStream;
  late final Stream<NeighborhoodSeason?> _activeSeasonStream;
  final TextEditingController _newSeasonController = TextEditingController();
  final TextEditingController _calendarTeamsController = TextEditingController();
  String _trendingFilter = 'live';
  Timer? _liveTickerTimer;
  int _liveTickerIndex = 0;
  int _liveTickerConfiguredCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _liveTickerPageController = PageController(viewportFraction: 0.9);
    _livePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.8,
      upperBound: 1.15,
    )..repeat(reverse: true);
    final betProvider = context.read<BetProvider>();
    _trendingMatchesStream = betProvider.getTrendingMatchesStream();
    _activeSeasonStream = betProvider.getActiveSeasonStream();
    _loadRandomMatches();
    Future.microtask(() async {
      await betProvider.ensureActiveSeason();
      await betProvider.seedRandomMatchesIfEmpty();
      await betProvider.autoCloseExpiredMatches();
    });

    if (!kIsWeb) {
      _simulationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        if (!mounted) return;
        // Evita setState reentrante durante eventos de puntero.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          try {
            _simulateMatchResults();
            context.read<BetProvider>().autoCloseExpiredMatches();
          } catch (_) {
            // Evita que errores de backend dejen la pantalla sin renderizado.
          }
        });
      });
    }
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
    _simulationTimer?.cancel();
    _liveTickerTimer?.cancel();
    _livePulseController.dispose();
    _liveTickerPageController.dispose();
    _tabController.dispose();
    _newSeasonController.dispose();
    _calendarTeamsController.dispose();
    super.dispose();
  }

  void _startLiveTickerAutoScroll(int itemCount) {
    if (_liveTickerConfiguredCount == itemCount && _liveTickerTimer != null) {
      return;
    }

    _liveTickerConfiguredCount = itemCount;

    if (itemCount <= 1) {
      _liveTickerTimer?.cancel();
      _liveTickerTimer = null;
      _liveTickerIndex = 0;
      return;
    }

    _liveTickerTimer?.cancel();
    _liveTickerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (!_liveTickerPageController.hasClients) return;

      _liveTickerIndex = (_liveTickerIndex + 1) % itemCount;
      _liveTickerPageController.animateToPage(
        _liveTickerIndex,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    });
  }

  // No se usan listas estáticas aquí; se generan dinámicamente en initState

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().currentUser;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageGradient = isDark
        ? BetFlixColors.pageGradient
        : const [Color(0xFFF6F8FF), Color(0xFFEAF0FF), Color(0xFFDDE8FF)];
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF172033);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: pageGradient,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingMedium,
                  AppConstants.paddingMedium,
                  AppConstants.paddingMedium,
                  0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ProfessionalHeader(
                    userName: currentUser?.name ?? 'Usuario',
                    coins: currentUser?.coins ?? 0,
                    profileImageUrl: currentUser?.profileImageUrl,
                    rankPosition: 1,
                    onProfileTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingMedium),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Inicio',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: primaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      tooltip: themeProvider.isDarkMode
                          ? 'Cambiar a modo claro'
                          : 'Cambiar a modo oscuro',
                      onPressed: () {
                        themeProvider.toggleTheme();
                      },
                      icon: Icon(
                        themeProvider.isDarkMode
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        color: isDark ? BetFlixColors.cyanBright : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.paddingSmall),

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
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _quickActionButton(
                      color: BetFlixColors.pinkBright,
                      onPressed: _loadRandomMatches,
                      icon: const Icon(Icons.refresh, size: 20),
                      label: 'Refrescar Partidos',
                    ),
                    _quickActionButton(
                      color: BetFlixColors.cyanBright,
                      onPressed: _simulateMatchResults,
                      icon: const Icon(Icons.sports_soccer, size: 20),
                      label: 'Simular Resultados',
                    ),
                    _quickActionButton(
                      color: BetFlixColors.orangeVibrant,
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
                      label: 'Apuesta Random',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                ),
                child: _liveNowTickerSection(),
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
      ),
    );
  }

  Widget _trendingFeedSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? BetFlixColors.cyanBright : const Color(0xFF0F172A);
    final cardBg = isDark ? const Color(0xFF222238) : Colors.white;
    final cardGradient = isDark
        ? const [Color(0xFF2B2B42), Color(0xFF18182A)]
        : const [Color(0xFFFFFFFF), Color(0xFFF3F4F6)];
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF111827);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Partidos en Tendencia',
              style: TextStyle(
                color: titleColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              tooltip: 'Actualizar partidos',
              onPressed: () {
                context.read<BetProvider>().autoCloseExpiredMatches();
              },
              icon: const Icon(Icons.refresh, color: BetFlixColors.cyanBright),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _trendingFilterChip('live', 'En directo', isDark),
            _trendingFilterChip('scheduled', 'Programados', isDark),
            _trendingFilterChip('finished', 'Finalizados', isDark),
            _trendingFilterChip('all', 'Todos', isDark),
          ],
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        StreamBuilder<List<Match>>(
          stream: _trendingMatchesStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _infoPanel('No se pudieron cargar los partidos en tendencia. Revisa Firebase/índices.');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: BetFlixColors.cyanBright),
              );
            }

            final matches = snapshot.data ?? const <Match>[];
            final filtered = matches.where((match) {
              switch (_trendingFilter) {
                case 'live':
                  return match.status == MatchStatus.live;
                case 'scheduled':
                  return match.status == MatchStatus.scheduled;
                case 'finished':
                  return match.status == MatchStatus.finished;
                case 'all':
                default:
                  return true;
              }
            }).toList();

            if (filtered.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No hay partidos para este filtro ahora mismo.',
                  style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF4B5563)),
                ),
              );
            }

            return Column(
              children: filtered.take(8).map((match) {
                final statusText = match.status == MatchStatus.live
                    ? 'EN DIRECTO'
                    : match.status == MatchStatus.scheduled
                        ? 'PROGRAMADO'
                        : match.status == MatchStatus.finished
                            ? 'FINALIZADO'
                            : 'CANCELADO';
                final statusColor = match.status == MatchStatus.live
                    ? BetFlixColors.accentRed
                    : match.status == MatchStatus.scheduled
                        ? BetFlixColors.cyanBright
                        : match.status == MatchStatus.finished
                            ? BetFlixColors.greenLime
                            : BetFlixColors.grey;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: cardGradient),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BetFlixColors.purpleVibrant.withOpacity(0.25)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${match.homeTeam} vs ${match.awayTeam}',
                                  style: TextStyle(
                                    color: primaryTextColor,
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              (match.homeScore != null && match.awayScore != null)
                                  ? 'Marcador: ${match.homeScore} - ${match.awayScore}'
                                  : 'Marcador pendiente',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                                fontSize: 12,
                              ),
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

  Widget _liveNowTickerSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? BetFlixColors.accentRed : const Color(0xFF111827);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF4B5563);
    final cardGradient = isDark
        ? const [Color(0xFF2A1E2D), Color(0xFF1A1525)]
        : const [Color(0xFFFFFFFF), Color(0xFFF3F4F6)];

    return StreamBuilder<List<Match>>(
      stream: _trendingMatchesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError || snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final liveMatches = (snapshot.data ?? const <Match>[])
            .where((match) => match.status == MatchStatus.live)
            .take(3)
            .toList();

        if (liveMatches.isEmpty) return const SizedBox.shrink();

        _startLiveTickerAutoScroll(liveMatches.length);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: BetFlixColors.accentRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'En Directo Ahora',
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Los partidos más calientes en este momento',
              style: TextStyle(color: subtitleColor, fontSize: 12),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 140,
              child: PageView.builder(
                controller: _liveTickerPageController,
                itemCount: liveMatches.length,
                onPageChanged: (index) {
                  _liveTickerIndex = index;
                },
                itemBuilder: (context, index) {
                  final match = liveMatches[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: cardGradient),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: BetFlixColors.accentRed.withOpacity(0.45)),
                      boxShadow: [
                        BoxShadow(
                          color: BetFlixColors.accentRed.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ScaleTransition(
                              scale: _livePulseController,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: BetFlixColors.accentRed,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF111827),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${match.homeTeam} vs ${match.awayTeam}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF111827),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${match.betsCount} apuestas abiertas',
                          style: const TextStyle(
                            color: BetFlixColors.cyanBright,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CreateBetScreen(match: match),
                                ),
                              );
                            },
                            icon: const Icon(Icons.flash_on, size: 16),
                            label: const Text('Apuesta rápida'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _trendingFilterChip(String value, String label, bool isDark) {
    final selected = _trendingFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: BetFlixColors.cyanBright,
      labelStyle: TextStyle(
        color: selected ? Colors.black : (isDark ? Colors.white : const Color(0xFF111827)),
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFE5E7EB),
      onSelected: (_) {
        setState(() {
          _trendingFilter = value;
        });
      },
    );
  }

  Widget _tournamentModeSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionTitleColor = isDark ? BetFlixColors.orangeVibrant : const Color(0xFF111827);
    final infoText = isDark ? Colors.white70 : const Color(0xFF4B5563);

    return StreamBuilder<NeighborhoodSeason?>(
      stream: _activeSeasonStream,
      builder: (context, seasonSnapshot) {
        if (seasonSnapshot.hasError) {
          return _infoPanel('No se pudo cargar el torneo de barrio.');
        }

        final season = seasonSnapshot.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Modo Torneo de Barrio',
                  style: TextStyle(
                    color: sectionTitleColor,
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
              style: TextStyle(color: infoText),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? const [Color(0xFF2C233A), Color(0xFF191726)]
                      : const [Color(0xFFFFFFFF), Color(0xFFF3F4F6)],
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
                        .read<BetProvider>()
                        .getNeighborhoodTournamentTableStream(seasonId: season.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: BetFlixColors.orangeVibrant),
                          );
                        }

                        final table = snapshot.data ?? const <NeighborhoodTeamStanding>[];
                        if (table.isEmpty) {
                          return Text(
                            'Finaliza partidos personalizados para generar la clasificación del torneo.',
                            style: TextStyle(color: infoText),
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
                                        style: TextStyle(
                                          color: isDark ? Colors.white : const Color(0xFF111827),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${entry.played}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: infoText),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${entry.goalDifference}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: infoText),
                                      ),
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
                  color: isDark ? const Color(0xFF202035) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BetFlixColors.cyanBright.withOpacity(0.2)),
                ),
                child: StreamBuilder<List<Match>>(
                  stream: context.read<BetProvider>().getSeasonFixturesStream(seasonId: season.id),
                  builder: (context, snapshot) {
                    final fixtures = snapshot.data ?? const <Match>[];
                    if (fixtures.isEmpty) {
                      return Text(
                        'No hay calendario generado todavía para esta temporada.',
                        style: TextStyle(color: infoText),
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
                              style: TextStyle(color: infoText, fontSize: 12),
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

  Widget _quickActionButton({
    required Color color,
    required VoidCallback onPressed,
    required Icon icon,
    required String label,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      icon: icon,
      label: Text(label),
    );
  }

  Widget _infoPanel(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? BetFlixColors.surfaceCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BetFlixColors.cyanBright.withOpacity(0.2)),
      ),
      child: Text(
        message,
        style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF4B5563)),
      ),
    );
  }
}
