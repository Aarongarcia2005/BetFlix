import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../config/app_constants.dart';
import '../config/app_theme.dart';
import '../models/models.dart';
import '../widgets/betflix_widgets.dart';

/// Pantalla de partido en vivo con estadísticas y opciones
class LiveMatchScreen extends StatefulWidget {
  const LiveMatchScreen({Key? key}) : super(key: key);

  @override
  State<LiveMatchScreen> createState() => _LiveMatchScreenState();
}

class _LiveMatchScreenState extends State<LiveMatchScreen> {
  final Match liveMatch = Match(
    id: '1',
    homeTeam: 'Barrio Norte FC',
    awayTeam: 'Almagro Juniors',
    homeTeamLogo: '🔵',
    awayTeamLogo: '⚫',
    homeScore: 2,
    awayScore: 1,
    dateTime: DateTime.now(),
    status: MatchStatus.live,
    league: 'Liga Local Regional',
    isLocal: true,
  );

  int _minute = 68;
  int homeGoals = 2;
  int awayGoals = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BetFlixColors.background,
      appBar: AppBar(
        title: const Text('Partido en Vivo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppConstants.paddingMedium),

            // Marcador en vivo
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: BetFlixColors.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              ),
              child: Column(
                children: [
                  // Minuto
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: BetFlixColors.accentRed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: BetFlixColors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_minute}\' EN VIVO',
                          style: const TextStyle(
                            color: BetFlixColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),

                  // Equipos y marcador
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Equipo local
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              liveMatch.homeTeamLogo,
                              style: const TextStyle(fontSize: 40),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              liveMatch.homeTeam,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: BetFlixColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Marcador
                      Column(
                        children: [
                          Text(
                            '$homeGoals',
                            style: const TextStyle(
                              color: BetFlixColors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            '-',
                            style: TextStyle(
                              color: BetFlixColors.goldYellow,
                              fontSize: 28,
                            ),
                          ),
                          Text(
                            '$awayGoals',
                            style: const TextStyle(
                              color: BetFlixColors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Equipo visitante
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              liveMatch.awayTeamLogo,
                              style: const TextStyle(fontSize: 40),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              liveMatch.awayTeam,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: BetFlixColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Eventos del partido
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Eventos del Partido',
                    style: BetFlixTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _eventItem('Gol', 'Barrio Norte FC', '⚽', '23\''),
                  _eventItem('Tarjeta Amarilla', 'Almagro Juniors', '🟨', '35\''),
                  _eventItem('Gol', 'Barrio Norte FC', '⚽', '52\''),
                  _eventItem('Gol', 'Almagro Juniors', '⚽', '61\''),
                  _eventItem('Cambio', 'Barrio Norte FC', '🔄', '67\''),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Opciones de apuesta en vivo
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Apuestas en Vivo',
                    style: BetFlixTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _liveOddCard('Próximo Gol', 'Barrio Norte', '1.80'),
                        const SizedBox(width: AppConstants.paddingMedium),
                        _liveOddCard('Total Goles', '3+', '2.15'),
                        const SizedBox(width: AppConstants.paddingMedium),
                        _liveOddCard('Minuto Gol', '70-75\'', '3.50'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Botón para crear apuesta en vivo
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/create-bet');
                  },
                  child: const Text(
                    '+ Crear Apuesta en Vivo',
                    style: BetFlixTextStyles.buttonText,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),
          ],
        ),
      ),
    );
  }

  Widget _eventItem(String eventType, String team, String icon, String minute) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventType,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  team,
                  style: BetFlixTextStyles.subtitle,
                ),
              ],
            ),
          ),
          Text(
            minute,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: BetFlixColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _liveOddCard(String market, String option, String odd) {
    return Card(
      elevation: AppConstants.elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingSmall),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              market,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              option,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              odd,
              style: BetFlixTextStyles.odds,
            ),
          ],
        ),
      ),
    );
  }
}
