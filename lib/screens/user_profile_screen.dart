import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../config/app_constants.dart';
import '../config/app_theme.dart';
import '../models/models.dart';
import '../widgets/betflix_widgets.dart';

/// Pantalla de perfil de usuario
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final BetFlixUser userExample = BetFlixUser(
    id: '1',
    name: 'Carlos G.',
    email: 'carlos@example.com',
    profileImageUrl: 'C',
    coins: 3200,
    winStreak: 5,
    totalBets: 50,
    correctBets: 38,
    level: 4,
    joinDate: DateTime(2023, 6, 15),
  );

  final List<BetFlixBadge> badges = [
    BetFlixBadge(
      id: '1',
      title: 'Campeón',
      description: 'Primer lugar en ranking',
      icon: Icons.emoji_events,
      unlocked: true,
    ),
    BetFlixBadge(
      id: '2',
      title: 'Tripleta',
      description: '3 victorias consecutivas',
      icon: Icons.trending_up,
      unlocked: true,
    ),
    BetFlixBadge(
      id: '3',
      title: 'Recha Mágica',
      description: '10 victorias consecutivas',
      icon: Icons.local_fire_department,
      unlocked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BetFlixColors.background,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuración'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header de perfil
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: BetFlixColors.primaryGradient,
                ),
              ),
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: BetFlixColors.white,
                      border: Border.all(
                        color: BetFlixColors.goldYellow,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        userExample.profileImageUrl,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: BetFlixColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    userExample.name,
                    style: const TextStyle(
                      color: BetFlixColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userExample.email,
                    style: const TextStyle(
                      color: BetFlixColors.goldYellow,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  CoinWidget(
                    amount: userExample.coins,
                    isHighlighted: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Estadísticas
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estadísticas',
                    style: BetFlixTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: AppConstants.paddingMedium,
                    mainAxisSpacing: AppConstants.paddingMedium,
                    childAspectRatio: 1.2,
                    children: [
                      _buildStatCard(
                        'Nivel',
                        userExample.level.toString(),
                        '⭐',
                        BetFlixColors.goldYellow,
                      ),
                      _buildStatCard(
                        'Racha Actual',
                        '${userExample.winStreak}',
                        '🔥',
                        BetFlixColors.accentRed,
                      ),
                      _buildStatCard(
                        'Total Apuestas',
                        userExample.totalBets.toString(),
                        '🎯',
                        BetFlixColors.primaryBlue,
                      ),
                      _buildStatCard(
                        'Tasa de Acierto',
                        '${userExample.successRate.toStringAsFixed(0)}%',
                        '✅',
                        BetFlixColors.success,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Logros
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Logros',
                    style: BetFlixTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: AppConstants.paddingMedium,
                      mainAxisSpacing: AppConstants.paddingMedium,
                    ),
                    itemCount: badges.length,
                    itemBuilder: (context, index) {
                      final badge = badges[index];
                      return BadgeWidget(
                        icon: badge.unlocked ? '🏅' : '🔒',
                        title: badge.title,
                        unlocked: badge.unlocked,
                        tooltip: badge.description,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Botones de acción
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Historial de apuestas'),
                          ),
                        );
                      },
                      child: const Text('Ver Historial de Apuestas'),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cerrar sesión'),
                          ),
                        );
                      },
                      child: const Text('Cerrar Sesión'),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: BetFlixColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: BetFlixTextStyles.subtitle,
            ),
          ],
        ),
      ),
    );
  }
}
