import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../config/colors.dart';
import '../models/models.dart';
import '../providers/bet_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import 'login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedAvatar = '🙂';
  String _selectedLanguage = 'es';
  String _avatarFilter = 'todos';
  String _movementFilter = 'all';

  static const Map<String, String> _languageLabels = {
    'es': 'Español',
    'ca': 'Català',
    'en': 'English',
  };

  String _t(String key) {
    const localized = {
      'es': {
        'profileTitle': 'Mi Perfil',
        'editProfile': 'Editar perfil',
        'settings': 'Ajustes',
        'saveProfile': 'Guardar perfil',
        'nameHint': 'Tu nombre',
        'selectAvatar': 'Elige tu avatar',
        'darkMode': 'Modo claro',
        'themeDescription': 'Activa para tema claro',
        'languageTitle': 'Idioma',
        'languageDescription': 'Selecciona idioma',
        'close': 'Cerrar',
      },
      'ca': {
        'profileTitle': 'El meu Perfil',
        'editProfile': 'Editar perfil',
        'settings': 'Ajustos',
        'saveProfile': 'Desa el perfil',
        'nameHint': 'El teu nom',
        'selectAvatar': 'Tria el teu avatar',
        'darkMode': 'Mode clar',
        'themeDescription': 'Activa per tema clar',
        'languageTitle': 'Idioma',
        'languageDescription': 'Selecciona idioma',
        'close': 'Tancar',
      },
      'en': {
        'profileTitle': 'My Profile',
        'editProfile': 'Edit profile',
        'settings': 'Settings',
        'saveProfile': 'Save profile',
        'nameHint': 'Your name',
        'selectAvatar': 'Choose your avatar',
        'darkMode': 'Light mode',
        'themeDescription': 'Turn on for light theme',
        'languageTitle': 'Language',
        'languageDescription': 'Choose language',
        'close': 'Close',
      },
    };
    return localized[_selectedLanguage]?[key] ?? key;
  }

  static const List<String> _maleAvatars = [
    '🧑‍🦱', '🧑‍🦰', '🧑‍🦲', '🧔', '👨‍💼', '👨‍🎤', '👨‍🎨', '👨‍🚀',
  ];
  static const List<String> _femaleAvatars = [
    '👩‍🦱', '👩‍🦰', '👩‍🦳', '👱‍♀️', '👩‍💼', '👩‍🎤', '👩‍🎨', '👩‍🚀',
  ];
  static const List<String> _styleAvatars = [
    '🤖', '🐯', '🦊', '🐼', '🦁', '🐨', '🦄', '🐸', '😎', '🔥', '⚽', '🎮',
  ];

  List<String> get _filteredAvatars {
    switch (_avatarFilter) {
      case 'chico':
        return _maleAvatars;
      case 'chica':
        return _femaleAvatars;
      case 'estilo':
        return _styleAvatars;
      default:
        return [..._maleAvatars, ..._femaleAvatars, ..._styleAvatars];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _syncFromUser(BetFlixUser user) {
    _nameController.text = user.name;
    _selectedAvatar = user.profileImageUrl.isNotEmpty ? user.profileImageUrl : '🙂';
  }

  Widget _editFilterChip(String value, String label, String currentFilter, void Function(void Function()) setSheetState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = currentFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: BetFlixColors.cyanBright,
      labelStyle: TextStyle(
        color: selected ? Colors.black : (isDark ? Colors.white : const Color(0xFF172033)),
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFEAF0FF),
      onSelected: (_) => setSheetState(() {
        avatarFilter = value;
      }),
    );
  }

  void _showEditProfileMenu(BetFlixUser user) {
    String selectedAvatar = user.profileImageUrl.isNotEmpty ? user.profileImageUrl : '🙂';
    String name = user.name;
    String avatarFilter = 'todos';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final primaryText = isDark ? Colors.white : const Color(0xFF172033);
            final secondaryText = isDark ? Colors.white70 : const Color(0xFF6B7280);
            final filteredAvatars = () {
              switch (avatarFilter) {
                case 'chico':
                  return _maleAvatars;
                case 'chica':
                  return _femaleAvatars;
                case 'estilo':
                  return _styleAvatars;
                default:
                  return [..._maleAvatars, ..._femaleAvatars, ..._styleAvatars];
              }
            }();

            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _t('editProfile'),
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajusta tu nombre y avatar para que tu perfil destaque más.',
                    style: TextStyle(color: secondaryText, fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: TextEditingController(text: name),
                    onChanged: (value) => name = value,
                    decoration: InputDecoration(
                      labelText: _t('nameHint'),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1F1F32) : const Color(0xFFF7F9FF),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _t('selectAvatar'),
                    style: TextStyle(
                      color: primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _editFilterChip('todos', 'Todos', avatarFilter, setSheetState),
                      _editFilterChip('chico', 'Chico', avatarFilter, setSheetState),
                      _editFilterChip('chica', 'Chica', avatarFilter, setSheetState),
                      _editFilterChip('estilo', 'Estilo', avatarFilter, setSheetState),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C30) : const Color(0xFFF8FAFF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredAvatars.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (_, index) {
                        final avatar = filteredAvatars[index];
                        final selected = avatar == selectedAvatar;
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setSheetState(() => selectedAvatar = avatar),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            decoration: BoxDecoration(
                              color: selected ? BetFlixColors.pinkBright.withOpacity(0.25) : (isDark ? const Color(0xFF2A2A3E) : const Color(0xFFFFFFFF)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected ? BetFlixColors.pinkBright : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(child: Text(avatar, style: const TextStyle(fontSize: 24))),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (name.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('El nombre no puede estar vacío.')),
                          );
                          return;
                        }
                        final success = await context.read<UserProvider>().updateProfile(
                              name: name.trim(),
                              profileImageUrl: selectedAvatar,
                            );
                        if (!mounted) return;
                        if (success) {
                          Navigator.of(context).pop();
                          setState(() => _syncFromUser(context.read<UserProvider>().currentUser!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Perfil actualizado.'), backgroundColor: BetFlixColors.success),
                          );
                        } else {
                          final err = context.read<UserProvider>().errorMessage ?? 'No se pudo guardar el perfil.';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(err), backgroundColor: BetFlixColors.accentRed),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BetFlixColors.pinkBright,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: Text(_t('saveProfile'), style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Future<void> _logout() async {
    await context.read<UserProvider>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final user = provider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : const Color(0xFF172033);
    final secondaryText = isDark ? Colors.white70 : const Color(0xFF4C5874);

    if (user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: Text('No hay usuario activo', style: TextStyle(color: primaryText)),
        ),
      );
    }

    _syncFromUser(user);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(_t('profileTitle')),
        actions: [
          Tooltip(
            message: _t('editProfile'),
            child: IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => _showEditProfileMenu(user),
            ),
          ),
          Tooltip(
            message: _t('settings'),
            child: IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: _showSettingsMenu,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    BetFlixColors.purpleVibrant.withOpacity(0.9),
                    BetFlixColors.primaryBlueLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BetFlixColors.cyanBright.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                      border: Border.all(color: BetFlixColors.goldYellow, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        _selectedAvatar,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(color: BetFlixColors.cyanBright),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Coins: ${user.coins}  •  Nivel ${user.level}',
                      style: const TextStyle(
                        color: BetFlixColors.goldYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showEditProfileMenu(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BetFlixColors.cyanBright,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                label: Text(_t('editProfile'), style: const TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            _statsPanel(user),
            const SizedBox(height: 16),
            _coinMovementPanel(user.id),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: BetFlixColors.accentRed),
                ),
                icon: const Icon(Icons.logout, color: BetFlixColors.accentRed),
                label: const Text('Cerrar sesión', style: TextStyle(color: BetFlixColors.accentRed)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = _avatarFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: BetFlixColors.cyanBright,
      labelStyle: TextStyle(
        color: selected ? Colors.black : Colors.white,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFEAF0FF),
      onSelected: (_) => setState(() => _avatarFilter = value),
    );
  }

  Widget _statsPanel(BetFlixUser user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF23233A), Color(0xFF17172A)]
              : const [Color(0xFFFFFFFF), Color(0xFFF1F5FF)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BetFlixColors.cyanBright.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tus estadísticas',
            style: TextStyle(
              color: BetFlixColors.cyanBright,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          _statRow('Apuestas totales', '${user.totalBets}'),
          _statRow('Aciertos', '${user.correctBets}'),
          _statRow('Tasa de acierto', '${user.successRate.toStringAsFixed(1)}%'),
          _statRow('Racha', '${user.winStreak}'),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF5A6683),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: BetFlixColors.goldYellow,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _coinMovementPanel(String userId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelGradient = isDark
        ? const [Color(0xFF23233A), Color(0xFF17172A)]
        : const [Color(0xFFFFFFFF), Color(0xFFF1F5FF)];
    final rowBg = isDark ? const Color(0xFF1D1D31) : const Color(0xFFEAF0FF);
    final primaryText = isDark ? Colors.white : const Color(0xFF172033);
    final secondaryText = isDark ? Colors.white70 : const Color(0xFF5A6683);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: panelGradient),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BetFlixColors.cyanBright.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Últimos movimientos de monedas',
            style: TextStyle(
              color: BetFlixColors.cyanBright,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<CoinMovement>>(
            stream: context.read<BetProvider>().getUserCoinMovementsStream(userId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  'No se pudo cargar el historial de monedas.',
                  style: TextStyle(color: secondaryText),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: BetFlixColors.cyanBright),
                  ),
                );
              }

              final movements = snapshot.data ?? const <CoinMovement>[];
              final filteredMovements = movements.where((movement) {
                switch (_movementFilter) {
                  case 'bets':
                    return movement.type == 'bet_placed';
                  case 'wins':
                    return movement.type == 'bet_won';
                  case 'refunds':
                    return movement.type == 'bet_cancelled_refund';
                  case 'all':
                  default:
                    return true;
                }
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _movementFilterChip('all', 'Todo'),
                      _movementFilterChip('bets', 'Apuestas'),
                      _movementFilterChip('wins', 'Premios'),
                      _movementFilterChip('refunds', 'Reembolsos'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (filteredMovements.isEmpty)
                    Text(
                      'No hay movimientos para este filtro.',
                      style: TextStyle(color: secondaryText),
                    )
                  else
                    Column(
                      children: filteredMovements.take(8).map((movement) {
                        final positive = movement.amount >= 0;
                        final amountColor = positive ? BetFlixColors.greenLime : BetFlixColors.accentRed;
                        final sign = positive ? '+' : '';
                        final dt = movement.createdAt;
                        final dateLabel =
                            '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} '
                            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: rowBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: BetFlixColors.borderLight.withOpacity(0.25)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movement.description,
                                      style: TextStyle(
                                        color: primaryText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$dateLabel • Saldo ${movement.balanceBefore} → ${movement.balanceAfter}',
                                      style: TextStyle(color: secondaryText, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '$sign${movement.amount} 🪙',
                                style: TextStyle(
                                  color: amountColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _movementFilterChip(String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = _movementFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: BetFlixColors.cyanBright,
      labelStyle: TextStyle(
        color: selected ? Colors.black : (isDark ? Colors.white : const Color(0xFF172033)),
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFEAF0FF),
      onSelected: (_) {
        setState(() {
          _movementFilter = value;
        });
      },
    );
  }
}
