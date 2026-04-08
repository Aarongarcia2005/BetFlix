import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../models/models.dart';
import '../providers/bet_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/betflix_widgets.dart';

class ActiveBetsScreen extends StatefulWidget {
  const ActiveBetsScreen({Key? key}) : super(key: key);

  @override
  State<ActiveBetsScreen> createState() => _ActiveBetsScreenState();
}

class _ActiveBetsScreenState extends State<ActiveBetsScreen> {
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
    return Scaffold(
      backgroundColor: BetFlixColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mis Apuestas Activas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer2<UserProvider, BetProvider>(
        builder: (context, userProvider, betProvider, _) {
          if (betProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: BetFlixColors.cyanBright),
            );
          }

          if (betProvider.userBets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_score,
                    size: 64,
                    color: BetFlixColors.purpleVibrant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay apuestas activas',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/create-bet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BetFlixColors.pinkBright,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Crear Apuesta'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: betProvider.userBets.length,
            itemBuilder: (context, index) {
              final bet = betProvider.userBets[index];
              return _BetCard(bet: bet);
            },
          );
        },
      ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: BetFlixColors.vibrantGradientLinear,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BetFlixColors.pinkBright.withOpacity(0.3),
        ),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bet.createdAt.day.toString().padLeft(2, '0') +
                          '/${bet.createdAt.month.toString().padLeft(2, '0')}/${bet.createdAt.year}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
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
                        color: Colors.white.withOpacity(0.7),
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
                        color: Colors.white.withOpacity(0.7),
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
                        color: Colors.white.withOpacity(0.7),
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
              color: Colors.white.withOpacity(0.1),
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
                  color: Colors.white.withOpacity(0.65),
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
                    onPressed: () {
                      // Cancelar apuesta
                    },
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
                    onPressed: () {
                      // Ver detalles
                    },
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
