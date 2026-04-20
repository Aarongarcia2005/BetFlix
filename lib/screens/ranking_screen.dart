import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../config/colors.dart';
import '../models/models.dart';
import '../providers/bet_provider.dart';
import '../providers/user_provider.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({Key? key}) : super(key: key);

  String _avatarText(String raw) {
    if (raw.trim().isEmpty) return '?';
    return raw.trim();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<UserProvider>().currentUser?.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF172033);
    final secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF45506A);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Ranking Global',
          style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<RankingEntry>>(
        stream: context.watch<BetProvider>().getRankingStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No se pudo cargar el ranking.\nDetalle: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: titleColor),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: BetFlixColors.cyanBright),
            );
          }

          final rawEntries = snapshot.data ?? const <RankingEntry>[];
          // Filtra entradas inválidas y evita usuarios internos.
          final entries = rawEntries
              .where((e) => e.userName.trim().isNotEmpty)
              .where((e) => !e.userName.toLowerCase().contains('betflix engine'))
              .toList();

          if (entries.isEmpty) {
            return Center(
              child: Text(
                'Todavía no hay usuarios reales en el ranking.',
                style: TextStyle(color: secondaryTextColor),
              ),
            );
          }

          final top3 = entries.take(3).toList();

          return Column(
            children: [
              if (top3.isNotEmpty) _TopPodium(top3: top3, avatarText: _avatarText),
              Expanded(
                child: ListView.builder(
                  itemCount: entries.length,
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final successRate = entry.totalBets > 0
                        ? (entry.correctBets / entry.totalBets * 100)
                        : 0.0;
                    final isTopThree = index < 3;
                    final isMe = currentUserId != null && currentUserId == entry.userId;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        gradient: isTopThree
                            ? BetFlixColors.purpleGradientLinear
                            : LinearGradient(
                                colors: [
                                  isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF6F8FF),
                                  isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE8EEFF),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                        border: Border.all(
                          color: isMe
                              ? BetFlixColors.cyanBright
                              : isTopThree
                                  ? BetFlixColors.goldYellow.withOpacity(0.35)
                                  : BetFlixColors.purpleVibrant.withOpacity(0.2),
                          width: isMe ? 2 : (isTopThree ? 2 : 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isTopThree ? BetFlixColors.goldYellow : BetFlixColors.purpleVibrant,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.position}',
                                style: TextStyle(
                                  color: isTopThree
                                      ? (isDark ? BetFlixColors.background : Colors.white)
                                      : titleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: BetFlixColors.cyanBright.withOpacity(0.2),
                              border: Border.all(color: BetFlixColors.cyanBright),
                            ),
                            child: Center(
                              child: Text(
                                _avatarText(entry.profileImageUrl),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMe ? '${entry.userName} (Tú)' : entry.userName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: titleColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${successRate.toStringAsFixed(0)}% acierto • ${entry.correctBets}/${entry.totalBets}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${entry.coins} 🪙',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isTopThree ? BetFlixColors.goldYellow : BetFlixColors.greenLime,
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
      ),
    );
  }
}

class _TopPodium extends StatelessWidget {
  final List<RankingEntry> top3;
  final String Function(String) avatarText;

  const _TopPodium({
    required this.top3,
    required this.avatarText,
  });

  @override
  Widget build(BuildContext context) {
    RankingEntry? first;
    RankingEntry? second;
    RankingEntry? third;

    for (final e in top3) {
      if (e.position == 1) first = e;
      if (e.position == 2) second = e;
      if (e.position == 3) third = e;
    }

    first ??= top3.isNotEmpty ? top3.first : null;

    return Container(
      decoration: BoxDecoration(
        gradient: BetFlixColors.vibrantGradientLinear,
        border: Border.all(color: BetFlixColors.pinkBright.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _podiumSlot(entry: second, medal: '🥈', size: 58, main: false, avatarText: avatarText),
          _podiumSlot(entry: first, medal: '🥇', size: 70, main: true, avatarText: avatarText),
          _podiumSlot(entry: third, medal: '🥉', size: 58, main: false, avatarText: avatarText),
        ],
      ),
    );
  }

  Widget _podiumSlot({
    required RankingEntry? entry,
    required String medal,
    required double size,
    required bool main,
    required String Function(String) avatarText,
  }) {
    if (entry == null) {
      return SizedBox(width: size + 24);
    }

    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: main ? BetFlixColors.goldYellow : BetFlixColors.cyanBright.withOpacity(0.2),
            border: Border.all(
              color: main ? BetFlixColors.goldYellow : BetFlixColors.cyanBright,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              avatarText(entry.profileImageUrl),
              style: TextStyle(
                fontSize: main ? 30 : 24,
                fontWeight: FontWeight.bold,
                color: main ? BetFlixColors.background : Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(medal, style: TextStyle(fontSize: main ? 30 : 22)),
        const SizedBox(height: 4),
        SizedBox(
          width: 92,
          child: Text(
            entry.userName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          '${entry.coins} 🪙',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: BetFlixColors.goldYellow,
          ),
        ),
      ],
    );
  }
}
