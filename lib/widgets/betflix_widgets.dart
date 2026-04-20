import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../config/app_constants.dart';
import '../config/app_theme.dart';

/// Tarjeta de partido profesional
class MatchCard extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final String league;
  final String dateTime;
  final bool isLive;
  final bool isLocal;
  final int? homeScore;
  final int? awayScore;
  final VoidCallback? onTap;

  const MatchCard({
    Key? key,
    required this.homeTeam,
    required this.awayTeam,
    required this.league,
    required this.dateTime,
    this.isLive = false,
    this.isLocal = false,
    this.homeScore,
    this.awayScore,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : BetFlixTextStyles.cardTitle.color;
    final secondaryTextColor = isDark ? Colors.white70 : BetFlixTextStyles.subtitle.color;
    final cardGradient = isDark
        ? [BetFlixColors.surfaceDark, BetFlixColors.surfaceLight]
        : const [Color(0xFFFFFFFF), Color(0xFFF3F4F6)];

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: AppConstants.elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          side: BorderSide(
            color: isLocal ? BetFlixColors.goldYellow : BetFlixColors.borderLight,
            width: isLocal ? 2 : 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: cardGradient,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              children: [
                // Header con liga y estado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        league,
                        style: BetFlixTextStyles.subtitle.copyWith(color: secondaryTextColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: BetFlixColors.accentRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: BetFlixColors.white,
                              ),
                              child: const SizedBox.shrink(),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'EN VIVO',
                              style: TextStyle(
                                color: BetFlixColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isLocal)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.star,
                          color: BetFlixColors.goldYellow,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),

                // Equipos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Equipo local
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: BetFlixColors.primaryBlue.withOpacity(0.1),
                            ),
                            child: const Icon(
                              Icons.sports_soccer,
                              color: BetFlixColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            homeTeam,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: BetFlixTextStyles.cardTitle.copyWith(color: primaryTextColor),
                          ),
                        ],
                      ),
                    ),

                    // VS
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: BetFlixColors.primaryBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'VS',
                            style: TextStyle(
                              color: BetFlixColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Equipo visitante
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: BetFlixColors.accentRed.withOpacity(0.1),
                            ),
                            child: const Icon(
                              Icons.sports_soccer,
                              color: BetFlixColors.accentRed,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            awayTeam,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: BetFlixTextStyles.cardTitle.copyWith(color: primaryTextColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),

                if (homeScore != null && awayScore != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                    child: Text(
                      '$homeScore - $awayScore',
                      style: TextStyle(
                        color: isDark ? BetFlixColors.white : const Color(0xFF111827),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Fecha y hora
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: BetFlixColors.borderLight,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: BetFlixColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateTime,
                        style: BetFlixTextStyles.subtitle.copyWith(color: secondaryTextColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón de apuesta estilo casa de apuestas
class BetButton extends StatelessWidget {
  final String label;
  final String odds;
  final VoidCallback onPressed;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? textColor;

  const BetButton({
    Key? key,
    required this.label,
    required this.odds,
    required this.onPressed,
    this.isSelected = false,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? (backgroundColor ?? BetFlixColors.primaryBlue)
              : BetFlixColors.white,
          border: Border.all(
            color: isSelected
                ? (backgroundColor ?? BetFlixColors.primaryBlue)
                : BetFlixColors.borderLight,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? (textColor ?? BetFlixColors.white)
                      : BetFlixColors.darkGrey,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                odds,
                style: TextStyle(
                  color: isSelected
                      ? (textColor ?? BetFlixColors.white)
                      : BetFlixColors.accentRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar monedas
class CoinWidget extends StatelessWidget {
  final int amount;
  final bool isHighlighted;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  const CoinWidget({
    Key? key,
    required this.amount,
    this.isHighlighted = false,
    this.textStyle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isHighlighted
                ? [BetFlixColors.goldYellow, BetFlixColors.goldYellow.withOpacity(0.7)]
                : [BetFlixColors.lightGrey, BetFlixColors.borderLight],
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: BetFlixColors.goldYellow.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '💰',
              style: TextStyle(
                fontSize: isHighlighted ? 16 : 14,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              amount.toString(),
              style: textStyle ??
                  TextStyle(
                    color: isHighlighted
                        ? BetFlixColors.darkGrey
                        : BetFlixColors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: isHighlighted ? 14 : 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge de badge/logros
class BadgeWidget extends StatelessWidget {
  final String icon;
  final String title;
  final bool unlocked;
  final String? tooltip;

  const BadgeWidget({
    Key? key,
    required this.icon,
    required this.title,
    this.unlocked = false,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip ?? title,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked
                  ? BetFlixColors.goldYellow
                  : BetFlixColors.lightGrey,
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: BetFlixColors.goldYellow.withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 8,
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Opacity(
                opacity: unlocked ? 1 : 0.4,
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: unlocked ? BetFlixColors.darkGrey : BetFlixColors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Header profesional con perfil y monedas
class ProfessionalHeader extends StatelessWidget {
  final String userName;
  final int coins;
  final String? profileImageUrl;
  final int rankPosition;
  final VoidCallback? onProfileTap;
  final VoidCallback? onCoinsTap;

  const ProfessionalHeader({
    Key? key,
    required this.userName,
    required this.coins,
    this.profileImageUrl,
    this.rankPosition = 0,
    this.onProfileTap,
    this.onCoinsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerGradient = isDark
        ? BetFlixColors.primaryGradient
        : const [Color(0xFFFFFFFF), Color(0xFFF3F4F6)];
    final headerTextColor = isDark ? BetFlixColors.white : const Color(0xFF111827);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: headerGradient,
        ),
        border: Border.all(
          color: isDark ? BetFlixColors.primaryBlueLight.withOpacity(0.3) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Row(
              children: [
                // Perfil
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? BetFlixColors.white : const Color(0xFFE5E7EB),
                      border: Border.all(
                        color: BetFlixColors.goldYellow,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: _buildProfileAvatar(),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),

                // Nombre y ranking
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          color: headerTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (rankPosition > 0)
                        Text(
                          '🏆 Ranking #$rankPosition',
                          style: const TextStyle(
                            color: BetFlixColors.goldYellow,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),

                // Monedas
                GestureDetector(
                  onTap: onCoinsTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? BetFlixColors.white.withOpacity(0.2) : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: BetFlixColors.goldYellow.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💰', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          coins.toString(),
                          style: const TextStyle(
                            color: BetFlixColors.goldYellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final avatar = (profileImageUrl ?? '').trim();
    if (avatar.isNotEmpty && (avatar.startsWith('http://') || avatar.startsWith('https://'))) {
      return ClipOval(
        child: Image.network(
          avatar,
          width: 46,
          height: 46,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _avatarTextFallback(),
        ),
      );
    }

    if (avatar.isNotEmpty) {
      return Text(
        avatar,
        style: const TextStyle(
          color: BetFlixColors.primaryBlue,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      );
    }

    return _avatarTextFallback();
  }

  Widget _avatarTextFallback() {
    return Text(
      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
      style: const TextStyle(
        color: BetFlixColors.primaryBlue,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }
}

/// Tarjeta de reto/desafío
class ChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final int rewardCoins;
  final double progressPercentage;
  final bool isCompleted;
  final VoidCallback? onTap;

  const ChallengeCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.rewardCoins,
    this.progressPercentage = 0,
    this.isCompleted = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: AppConstants.elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isCompleted
                  ? [
                      BetFlixColors.success.withOpacity(0.1),
                      BetFlixColors.success.withOpacity(0.05),
                    ]
                  : [BetFlixColors.white, BetFlixColors.lightGrey],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: BetFlixColors.success,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: BetFlixColors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  title,
                  style: BetFlixTextStyles.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: BetFlixTextStyles.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progressPercentage / 100,
                    backgroundColor: BetFlixColors.borderLight,
                    valueColor: AlwaysStoppedAnimation(
                      progressPercentage == 100
                          ? BetFlixColors.success
                          : BetFlixColors.primaryBlue,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${progressPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: BetFlixColors.grey,
                      ),
                    ),
                    Row(
                      children: [
                        const Text('💰', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '$rewardCoins',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: BetFlixColors.goldYellow,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
