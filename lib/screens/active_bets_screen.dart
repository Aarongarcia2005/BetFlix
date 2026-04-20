import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../models/models.dart';
import '../providers/bet_provider.dart';
import '../providers/user_provider.dart';
import 'create_bet_screen.dart';
import '../widgets/betflix_widgets.dart';

class ActiveBetsScreen extends StatefulWidget {
  const ActiveBetsScreen({Key? key}) : super(key: key);

  @override
  State<ActiveBetsScreen> createState() => _ActiveBetsScreenState();
}

class _ActiveBetsScreenState extends State<ActiveBetsScreen> {
  final GlobalKey _communityMarketsKey = GlobalKey();
  bool _highlightCommunityMarkets = false;

  Future<void> _scrollToCommunityMarkets() async {
    final targetContext = _communityMarketsKey.currentContext;
    if (targetContext == null) return;

    if (mounted) {
      setState(() => _highlightCommunityMarkets = true);
    }

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _highlightCommunityMarkets = false);
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = context.read<UserProvider>().currentUser?.id;
      if (userId != null) {
        context.read<BetProvider>().loadUserBets(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageGradient = isDark
        ? BetFlixColors.pageGradient
        : const [Color(0xFFF6F8FF), Color(0xFFEAF0FF), Color(0xFFDDE8FF)];
    final titleColor = isDark ? Colors.white : const Color(0xFF172033);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mis Apuestas Activas',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: pageGradient,
          ),
        ),
        child: Consumer2<UserProvider, BetProvider>(
        builder: (context, userProvider, betProvider, _) {
          if (betProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: BetFlixColors.cyanBright),
            );
          }
          return RefreshIndicator(
            color: BetFlixColors.cyanBright,
            onRefresh: () async {
              final userId = userProvider.currentUser?.id;
              if (userId != null) {
                await betProvider.loadUserBets(userId);
              }
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _neighborhoodCoreSection(),
                const SizedBox(height: 14),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  padding: _highlightCommunityMarkets
                      ? const EdgeInsets.all(10)
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: _highlightCommunityMarkets
                        ? BetFlixColors.cyanBright.withOpacity(0.09)
                        : Colors.transparent,
                    border: Border.all(
                      color: _highlightCommunityMarkets
                          ? BetFlixColors.cyanBright.withOpacity(0.7)
                          : Colors.transparent,
                      width: 1.4,
                    ),
                    boxShadow: _highlightCommunityMarkets
                        ? [
                            BoxShadow(
                              color: BetFlixColors.cyanBright.withOpacity(0.22),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ]
                        : const [],
                  ),
                  child: KeyedSubtree(
                    key: _communityMarketsKey,
                    child: StreamBuilder<List<Match>>(
                    stream: betProvider.getOpenMatchesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _infoCard(
                          icon: Icons.warning_amber_rounded,
                          title: 'No se pudieron cargar partidos de barrio',
                          subtitle: 'Revisa Firebase (reglas/índices) y vuelve a intentar.',
                        );
                      }

                      final currentUserId = userProvider.currentUser?.id;
                      final openCommunityMatches = (snapshot.data ?? const <Match>[])
                          .where((m) => m.source == MatchSource.userCreated)
                          .where((m) => m.createdByUserId == null || m.createdByUserId != currentUserId)
                          .take(4)
                          .toList();

                      if (openCommunityMatches.isEmpty) {
                        return _infoCard(
                          icon: Icons.groups_2_outlined,
                          title: 'Aún no hay partidos de barrio abiertos',
                          subtitle: 'Sé el primero en crear uno y deja que tu gente entre a apostar.',
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 18,
                                color: _highlightCommunityMarkets
                                    ? BetFlixColors.goldYellow
                                    : BetFlixColors.cyanBright,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Partidos de barrio para apostar ahora',
                                style: TextStyle(
                                  color: BetFlixColors.cyanBright,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                            ),
                          const SizedBox(height: 8),
                          ...openCommunityMatches.map((match) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1D1D32) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: BetFlixColors.purpleVibrant.withOpacity(0.28)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${match.homeTeam} vs ${match.awayTeam}',
                                          style: TextStyle(
                                            color: titleColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Creador: ${match.createdByName ?? 'Comunidad'} • ${match.betsCount} apuestas',
                                          style: TextStyle(
                                            color: isDark ? Colors.white70 : const Color(0xFF5A6683),
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
                                    ),
                                    child: const Text('Entrar'),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                  ),
                ),
                const SizedBox(height: 14),
                if (betProvider.userBets.isEmpty)
                  _infoCard(
                    icon: Icons.sports_score,
                    title: 'No tienes apuestas activas todavía',
                    subtitle: 'Crea un partido personalizado o entra en uno de la comunidad.',
                  )
                else
                  ...betProvider.userBets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final bet = entry.value;
                    return _AnimatedBetCard(
                      delayMs: 65 * index,
                      child: _BetCard(bet: bet),
                    );
                  }),
              ],
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _neighborhoodCoreSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF2A213D), Color(0xFF1A1629)]
              : const [Color(0xFFF1F5FF), Color(0xFFE5ECFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BetFlixColors.cyanBright.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mercado de Barrios',
            style: TextStyle(
              color: BetFlixColors.cyanBright,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Crea tu propio partido con nombres reales del barrio y deja que toda la comunidad entre a apostar.',
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF4C5874),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/create-bet'),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                style: ElevatedButton.styleFrom(backgroundColor: BetFlixColors.pinkBright),
                label: const Text('Crear partido personalizado'),
              ),
              OutlinedButton.icon(
                onPressed: _scrollToCommunityMarkets,
                icon: const Icon(Icons.campaign_outlined, size: 18),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: BetFlixColors.cyanBright),
                  foregroundColor: BetFlixColors.cyanBright,
                ),
                label: const Text('Abrir mercados y apostar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BetFlixColors.purpleVibrant.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: BetFlixColors.pinkBright.withOpacity(0.95)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF172033),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF5A6683),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBetCard extends StatelessWidget {
  final Widget child;
  final int delayMs;

  const _AnimatedBetCard({required this.child, required this.delayMs});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }
}

class _BetCard extends StatelessWidget {
  final Bet bet;

  const _BetCard({required this.bet});

  Color _getStatusColor(BetStatus status) {
    switch (status) {
      case BetStatus.won:
        return BetFlixColors.greenLime;
      case BetStatus.lost:
        return BetFlixColors.accentRed;
      case BetStatus.pending:
        return BetFlixColors.cyanBright;
      case BetStatus.voided:
      case BetStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusText(BetStatus status) {
    switch (status) {
      case BetStatus.won:
        return '✓ Ganada';
      case BetStatus.lost:
        return '✗ Perdida';
      case BetStatus.pending:
        return '⏳ Pendiente';
      case BetStatus.voided:
      case BetStatus.cancelled:
        return 'Cancelada';
    }
  }

  String _marketLabel(BetMarket market) {
    switch (market) {
      case BetMarket.matchWinner:
        return 'Ganador';
      case BetMarket.firstScoringTeam:
        return 'Primer gol';
      case BetMarket.overTwoGoals:
        return 'Más de 2 goles';
      case BetMarket.totalGoals:
        return 'Total goles';
      case BetMarket.totalShotsOnTarget:
        return 'Chutes a puerta';
    }
  }

  Future<void> _cancelBet(BuildContext context) async {
    final userId = context.read<UserProvider>().currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay sesión activa.')),
      );
      return;
    }

    final success = await context.read<BetProvider>().cancelBet(
          betId: bet.id,
          userId: userId,
        );

    if (!context.mounted) return;

    if (success) {
      await context.read<UserProvider>().loadCurrentUser();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apuesta cancelada correctamente.')),
      );
      return;
    }

    final error = context.read<BetProvider>().errorMessage ?? 'No se pudo cancelar la apuesta.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }

  Future<void> _showBetDetails(BuildContext context) async {
    Match? match;
    String? lookupError;

    try {
      match = await context.read<BetProvider>().getMatchById(bet.matchId);
    } catch (e) {
      lookupError = e.toString();
    }

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detalle de apuesta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text('Partido: ${bet.matchTitle ?? 'Sin título'}'),
                Text('Mercado: ${_marketLabel(bet.market)}'),
                Text('Selección: ${bet.selection.isEmpty ? bet.betType.name : bet.selection}'),
                Text('Monto: ${bet.amount} 🪙'),
                Text('Cuota: ${bet.odds.toStringAsFixed(2)}x'),
                Text('Ganancia potencial: ${bet.potentialWinnings ?? (bet.amount * bet.odds).toInt()} 🪙'),
                Text('Estado: ${_getStatusText(bet.status)}'),
                if (lookupError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    lookupError!,
                    style: const TextStyle(color: BetFlixColors.accentRed),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: match == null
                        ? null
                        : () {
                            Navigator.pop(sheetContext);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateBetScreen(match: match),
                              ),
                            );
                          },
                    icon: const Icon(Icons.sports_soccer),
                    label: const Text('Ir al partido'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : const Color(0xFF172033);
    final secondaryText = isDark ? Colors.white70 : const Color(0xFF5A6683);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? BetFlixColors.cardGradient
              : const [Color(0xFFFFFFFF), Color(0xFFF1F5FF)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BetFlixColors.cyanBright.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: BetFlixColors.black.withOpacity(0.2),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bet.matchTitle?.isNotEmpty == true
                          ? bet.matchTitle!
                          : 'Apuesta #${bet.id.substring(0, 8)}',
                      style: TextStyle(
                        color: primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bet.createdAt.day.toString().padLeft(2, '0') +
                          '/${bet.createdAt.month.toString().padLeft(2, '0')}/${bet.createdAt.year}',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(bet.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getStatusColor(bet.status)),
                ),
                child: Text(
                  _getStatusText(bet.status),
                  style: TextStyle(
                    color: _getStatusColor(bet.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bet Details Grid
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monto Apostado',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bet.amount} 🪙',
                      style: const TextStyle(
                        color: BetFlixColors.goldYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cuota',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bet.odds.toStringAsFixed(2)}x',
                      style: const TextStyle(
                        color: BetFlixColors.cyanBright,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ganancia Potencial',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bet.potentialWinnings} 🪙',
                      style: const TextStyle(
                        color: BetFlixColors.greenLime,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bet Type
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mercado: ${_marketLabel(bet.market)}',
                  style: const TextStyle(
                    color: BetFlixColors.pinkBright,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Selección: ${bet.selection.isEmpty ? bet.betType.name : bet.selection}',
                  style: const TextStyle(
                    color: BetFlixColors.cyanBright,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (bet.createdByUserId != null && bet.createdByUserId!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Partido creado por: ${bet.createdByUserId == 'system' ? 'BetFlix Engine' : bet.createdByUserId}',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 11,
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Action Buttons
          if (bet.status == BetStatus.pending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _cancelBet(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: BetFlixColors.accentRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: BetFlixColors.accentRed),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showBetDetails(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BetFlixColors.cyanBright,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Ver Detalles',
                      style: TextStyle(color: BetFlixColors.background),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
