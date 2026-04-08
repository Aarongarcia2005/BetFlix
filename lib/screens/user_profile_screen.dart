import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../config/colors.dart';
import '../models/models.dart';
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
  bool _isEditing = false;
  String _avatarFilter = 'todos';

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
    if (!_isEditing) {
      _nameController.text = user.name;
      _selectedAvatar = user.profileImageUrl.isNotEmpty ? user.profileImageUrl : '🙂';
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío.')),
      );
      return;
    }

    final success = await context.read<UserProvider>().updateProfile(
          name: name,
          profileImageUrl: _selectedAvatar,
        );

    if (!mounted) return;

    if (success) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado.'),
          backgroundColor: BetFlixColors.success,
        ),
      );
    } else {
      final err = context.read<UserProvider>().errorMessage ?? 'No se pudo guardar el perfil.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: BetFlixColors.accentRed),
      );
    }
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

    if (user == null) {
      return const Scaffold(
        backgroundColor: BetFlixColors.background,
        body: Center(
          child: Text('No hay usuario activo', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    _syncFromUser(user);

    return Scaffold(
      backgroundColor: BetFlixColors.background,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _syncFromUser(user);
                }
              });
            },
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
                      color: const Color(0xFF1A1A2E),
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
                  if (_isEditing)
                    TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: 'Tu nombre',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    )
                  else
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
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
            const SizedBox(height: 16),
            if (_isEditing) ...[
              const Text(
                'Elige tu avatar',
                style: TextStyle(
                  color: BetFlixColors.cyanBright,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  _filterChip('todos', 'Todos'),
                  _filterChip('chico', 'Chico'),
                  _filterChip('chica', 'Chica'),
                  _filterChip('estilo', 'Estilo'),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BetFlixColors.purpleVibrant.withOpacity(0.3)),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredAvatars.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (_, index) {
                    final avatar = _filteredAvatars[index];
                    final selected = avatar == _selectedAvatar;
                    return InkWell(
                      onTap: () => setState(() => _selectedAvatar = avatar),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selected
                              ? BetFlixColors.pinkBright.withOpacity(0.25)
                              : const Color(0xFF2A2A3E),
                          borderRadius: BorderRadius.circular(10),
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: BetFlixColors.pinkBright),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('Guardar perfil', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
            const SizedBox(height: 20),
            _statsPanel(user),
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
    final selected = _avatarFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: BetFlixColors.cyanBright,
      labelStyle: TextStyle(
        color: selected ? Colors.black : Colors.white,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: const Color(0xFF2A2A3E),
      onSelected: (_) => setState(() => _avatarFilter = value),
    );
  }

  Widget _statsPanel(BetFlixUser user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF23233A),
            const Color(0xFF17172A),
          ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
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
}
