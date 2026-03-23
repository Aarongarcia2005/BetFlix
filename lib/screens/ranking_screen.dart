import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../config/app_constants.dart';
import '../models/models.dart';
import '../providers/bet_provider.dart';

/// Pantalla de ranking de jugadores
class RankingScreen extends StatefulWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final List<RankingEntry> rankings = [
    RankingEntry(
      position: 1,
      userId: 'user1',
      userName: 'AnaPerez',
      profileImageUrl: 'A',
      coins: 12500,
      correctBets: 45,
      totalBets: 50,
      badges: 3,
    ),
    RankingEntry(
      position: 2,
      userId: 'user2',
      userName: 'LuisMarti',
      profileImageUrl: 'L',
      coins: 11200,
      correctBets: 42,
      totalBets: 50,
      badges: 2,
    ),
    RankingEntry(
      position: 3,
      userId: 'user3',
      userName: 'CarlosG.',
      profileImageUrl: 'C',
      coins: 8750,
      correctBets: 38,
      totalBets: 50,
      badges: 1,
    ),
    RankingEntry(
      position: 4,
      userId: 'user4',
      userName: 'MariaLopez',
      profileImageUrl: 'M',
      coins: 7200,
      correctBets: 32,
      totalBets: 50,
      badges: 1,
    ),
    RankingEntry(
      position: 5,
      userId: 'user5',
      userName: 'JuanRodriguez',
      profileImageUrl: 'J',
      coins: 6500,
      correctBets: 28,
      totalBets: 50,
      badges: 0,
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
          '🏆 Ranking Global',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Podio (Top 3)
          Container(
            decoration: BoxDecoration(
              gradient: BetFlixColors.vibrantGradientLinear,
              border: Border.all(color: BetFlixColors.pinkBright.withOpacity(0.3)),
            ),
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              children: [
                const SizedBox(height: AppConstants.paddingSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Segundo lugar
                    Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: BetFlixColors.cyanBright.withOpacity(0.2),
                            border: Border.all(
                              color: BetFlixColors.cyanBright,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              rankings[1].profileImageUrl,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('🥈', style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          rankings[1].userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${rankings[1].coins} 🪙',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: BetFlixColors.goldYellow,
                          ),
                        ),
                      ],
                    ),

                    // Primer lugar
                    Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                BetFlixColors.goldYellow,
                                BetFlixColors.goldYellow.withOpacity(0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: BetFlixColors.goldYellow.withOpacity(0.4),
                                spreadRadius: 3,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              rankings[0].profileImageUrl,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: BetFlixColors.background,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('🥇', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 4),
                        Text(
                          rankings[0].userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${rankings[0].coins} 🪙',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: BetFlixColors.goldYellow,
                          ),
                        ),
                      ],
                    ),

                    // Tercer lugar
                    Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: BetFlixColors.accentRed.withOpacity(0.2),
                            border: Border.all(
                              color: BetFlixColors.accentRed,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              rankings[2].profileImageUrl,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('🥉', style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          rankings[2].userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${rankings[2].coins} 🪙',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: BetFlixColors.goldYellow,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingLarge),
              ],
            ),
          ),

          // Ranking completo
          Expanded(
            child: ListView.builder(
              itemCount: rankings.length,
              itemBuilder: (context, index) {
                final entry = rankings[index];
                final isTopThree = index < 3;
                final successRate = entry.totalBets > 0
                    ? (entry.correctBets / entry.totalBets * 100)
                    : 0;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                    vertical: AppConstants.paddingSmall,
                  ),
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    gradient: isTopThree
                        ? BetFlixColors.purpleGradientLinear
                        : LinearGradient(
                            colors: [
                              const Color(0xFF2A2A3E),
                              const Color(0xFF1A1A2E),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                    border: Border.all(
                      color: isTopThree
                          ? BetFlixColors.goldYellow.withOpacity(0.3)
                          : BetFlixColors.purpleVibrant.withOpacity(0.2),
                      width: isTopThree ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Posición
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isTopThree
                              ? BetFlixColors.goldYellow
                              : BetFlixColors.purpleVibrant,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.position}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingMedium),

                      // Perfil
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: BetFlixColors.cyanBright.withOpacity(0.2),
                          border: Border.all(color: BetFlixColors.cyanBright),
                        ),
                        child: Center(
                          child: Text(
                            entry.profileImageUrl,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingMedium),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${successRate.toStringAsFixed(0)}% acierto • ${entry.correctBets}/${entry.totalBets}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                                if (entry.badges > 0)
                                  Row(
                                    children: [
                                      const SizedBox(width: 8),
                                      Text(
                                        '🏅 ×${entry.badges}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Monedas
                      Text(
                        '${entry.coins} 🪙',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isTopThree
                              ? BetFlixColors.goldYellow
                              : BetFlixColors.greenLime,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
