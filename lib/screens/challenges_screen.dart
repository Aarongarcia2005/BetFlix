import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../config/app_constants.dart';
import '../config/app_theme.dart';
import '../models/models.dart';
import '../widgets/betflix_widgets.dart';

/// Pantalla de retos y desafíos
class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({Key? key}) : super(key: key);

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  int selectedTabIndex = 0;

  // Datos de ejemplo
  final List<Challenge> activeChallenges = [
    Challenge(
      id: '1',
      title: 'Reto 1 vs 1',
      description: 'Acertá el resultado de 3 partidos',
      icon: '🎯',
      rewardCoins: 500,
      deadline: DateTime.now().add(const Duration(days: 7)),
      status: ChallengeStatus.active,
      type: ChallengeType.correctPredictions,
      targetValue: 3,
      currentProgress: 2,
    ),
    Challenge(
      id: '2',
      title: 'Racha Ganadora',
      description: 'Gana 5 apuestas consecutivas',
      icon: '🔥',
      rewardCoins: 1000,
      deadline: DateTime.now().add(const Duration(days: 14)),
      status: ChallengeStatus.active,
      type: ChallengeType.winStreak,
      targetValue: 5,
      currentProgress: 3,
    ),
    Challenge(
      id: '3',
      title: 'Apostador Activo',
      description: 'Realiza 10 apuestas en una semana',
      icon: '⚡',
      rewardCoins: 750,
      deadline: DateTime.now().add(const Duration(days: 3)),
      status: ChallengeStatus.active,
      type: ChallengeType.betCount,
      targetValue: 10,
      currentProgress: 7,
    ),
  ];

  final List<Challenge> completedChallenges = [
    Challenge(
      id: '4',
      title: 'Primer Paso',
      description: 'Realiza tu primera apuesta',
      icon: '👟',
      rewardCoins: 200,
      deadline: DateTime.now().subtract(const Duration(days: 30)),
      status: ChallengeStatus.completed,
      type: ChallengeType.betCount,
      targetValue: 1,
      currentProgress: 1,
    ),
    Challenge(
      id: '5',
      title: 'Experto Local',
      description: 'Apuesta en 5 partidos locales',
      icon: '🏆',
      rewardCoins: 600,
      deadline: DateTime.now().subtract(const Duration(days: 10)),
      status: ChallengeStatus.completed,
      type: ChallengeType.betCount,
      targetValue: 5,
      currentProgress: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BetFlixColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Retos y Desafíos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: const Color(0xFF1A1A2E),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTabIndex = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selectedTabIndex == 0
                                ? BetFlixColors.cyanBright
                                : BetFlixColors.purpleVibrant.withOpacity(0.3),
                            width: selectedTabIndex == 0 ? 3 : 1,
                          ),
                        ),
                      ),
                      child: Text(
                        'Activos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selectedTabIndex == 0
                              ? BetFlixColors.cyanBright
                              : Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTabIndex = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selectedTabIndex == 1
                                ? BetFlixColors.primaryBlue
                                : BetFlixColors.borderLight,
                            width: selectedTabIndex == 1 ? 3 : 1,
                          ),
                        ),
                      ),
                      child: Text(
                        'Completados',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selectedTabIndex == 1
                              ? BetFlixColors.cyanBright
                              : Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  children: selectedTabIndex == 0
                      ? [
                          ...activeChallenges.map((challenge) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppConstants.paddingMedium,
                              ),
                              child: ChallengeCard(
                                title: challenge.title,
                                description: challenge.description,
                                icon: challenge.icon,
                                rewardCoins: challenge.rewardCoins,
                                progressPercentage:
                                    challenge.progressPercentage,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${challenge.title} seleccionado',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ]
                      : [
                          ...completedChallenges.map((challenge) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppConstants.paddingMedium,
                              ),
                              child: ChallengeCard(
                                title: challenge.title,
                                description: challenge.description,
                                icon: challenge.icon,
                                rewardCoins: challenge.rewardCoins,
                                progressPercentage: 100,
                                isCompleted: true,
                              ),
                            );
                          }).toList(),
                        ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
