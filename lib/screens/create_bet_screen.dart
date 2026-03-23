import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../config/app_constants.dart';
import '../config/app_theme.dart';
import '../models/models.dart';
import '../widgets/betflix_widgets.dart';
import '../providers/bet_provider.dart';
import '../providers/user_provider.dart';

/// Pantalla para crear apuestas
class CreateBetScreen extends StatefulWidget {
  final Match? match;

  const CreateBetScreen({Key? key, this.match}) : super(key: key);

  @override
  State<CreateBetScreen> createState() => _CreateBetScreenState();
}

class _CreateBetScreenState extends State<CreateBetScreen> {
  int? selectedBetIndex;
  int betAmount = 100;
  double selectedOdds = 1.0;
  bool _isCreating = false;
  late Match selectedMatch;

  @override
  void initState() {
    super.initState();
    selectedMatch = widget.match ?? matchExample;
  }

  // Datos de ejemplo
  final Match matchExample = Match(
    id: '1',
    homeTeam: 'Barrio Norte FC',
    awayTeam: 'Almagro Juniors',
    homeTeamLogo: '🔵',
    awayTeamLogo: '⚫',
    dateTime: DateTime.now().add(const Duration(hours: 2)),
    status: MatchStatus.scheduled,
    league: 'Liga Local Regional',
    isLocal: true,
  );

  final List<Map<String, dynamic>> betOptions = [
    {
      'label': 'Victoria\nLocal',
      'odds': 2.10,
      'icon': Icons.trending_up,
      'betType': BetType.homeWin,
    },
    {
      'label': 'Empate',
      'odds': 3.50,
      'icon': Icons.remove,
      'betType': BetType.draw,
    },
    {
      'label': 'Victoria\nVisitante',
      'odds': 3.20,
      'icon': Icons.trending_down,
      'betType': BetType.awayWin,
    },
  ];

  int get potentialWinnings {
    return (betAmount * selectedOdds).toInt();
  }

  void _createBet() async {
    final selectedMatch = widget.match ?? matchExample;

    if (selectedBetIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una opción de apuesta')),
      );
      return;
    }

    if (betAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto válido')),
      );
      return;
    }

    final userId = context.read<UserProvider>().currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no autenticado')),
      );
      return;
    }

    setState(() => _isCreating = true);

    final success = await context.read<BetProvider>().createBet(
      userId: userId,
      matchId: selectedMatch.id,
      betType: betOptions[selectedBetIndex!]['betType'],
      amount: betAmount,
      odds: selectedOdds,
    );

    setState(() => _isCreating = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Apuesta creada exitosamente!'),
          backgroundColor: BetFlixColors.greenLime,
        ),
      );
      Navigator.pop(context);
    } else {
      final error = context.read<BetProvider>().errorMessage ?? 'Error al crear apuesta';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: BetFlixColors.accentRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BetFlixColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Crear Apuesta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppConstants.paddingMedium),

            // Tarjeta del partido
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: BetFlixColors.vibrantGradientLinear,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BetFlixColors.pinkBright.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            selectedMatch.homeTeam,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Text(
                          'VS',
                          style: TextStyle(
                            color: BetFlixColors.cyanBright,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            selectedMatch.awayTeam,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      selectedMatch.league,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Opciones de apuesta
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona tu apuesta',
                    style: TextStyle(
                      color: BetFlixColors.cyanBright,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: AppConstants.paddingSmall,
                      mainAxisSpacing: AppConstants.paddingSmall,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: betOptions.length,
                    itemBuilder: (context, index) {
                      final option = betOptions[index];
                      final isSelected = selectedBetIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedBetIndex = index;
                            selectedOdds = option['odds'];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? BetFlixColors.purpleGradientLinear
                                : LinearGradient(
                                    colors: [
                                      const Color(0xFF2A2A3E),
                                      const Color(0xFF1A1A2E),
                                    ],
                                  ),
                            border: Border.all(
                              color: isSelected
                                  ? BetFlixColors.pinkBright
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                option['icon'],
                                color: isSelected
                                    ? BetFlixColors.goldYellow
                                    : BetFlixColors.cyanBright,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                option['label'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${option['odds']}x',
                                style: TextStyle(
                                  color: BetFlixColors.greenLime,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Monto de apuesta
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monto de apuesta',
                    style: TextStyle(
                      color: BetFlixColors.cyanBright,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ingresa el monto',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      filled: true,
                      fillColor: const Color(0xFF2A2A3E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: BetFlixColors.purpleVibrant.withOpacity(0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: BetFlixColors.purpleVibrant.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: BetFlixColors.cyanBright, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.attach_money, color: BetFlixColors.goldYellow),
                    ),
                    onChanged: (value) {
                      setState(() {
                        betAmount = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Montos sugeridos
                  Wrap(
                    spacing: AppConstants.paddingSmall,
                    children: [100, 250, 500, 1000].map((amount) {
                      final isSelected = betAmount == amount;
                      return GestureDetector(
                        onTap: () => setState(() => betAmount = amount),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? BetFlixColors.pinkBright : const Color(0xFF2A2A3E),
                            border: Border.all(
                              color: isSelected ? BetFlixColors.pinkBright : BetFlixColors.purpleVibrant.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$amount 🪙',
                            style: TextStyle(
                              color: isSelected ? Colors.white : BetFlixColors.cyanBright,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Resumen
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2A2A3E),
                    const Color(0xFF1A1A2E),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                border: Border.all(
                  color: BetFlixColors.cyanBright.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Monto apostado:',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        '$betAmount 🪙',
                        style: const TextStyle(
                          color: BetFlixColors.goldYellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cuota:',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        '${selectedOdds.toStringAsFixed(2)} x',
                        style: const TextStyle(
                          color: BetFlixColors.cyanBright,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: BetFlixColors.purpleVibrant.withOpacity(0.3),
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ganancia potencial:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '$potentialWinnings 🪙',
                        style: const TextStyle(
                          color: BetFlixColors.greenLime,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Botón de crear apuesta
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isCreating ? null : _createBet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BetFlixColors.pinkBright,
                        disabledBackgroundColor: BetFlixColors.pinkBright.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isCreating
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Crear Apuesta',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: BetFlixColors.purpleVibrant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: BetFlixColors.cyanBright),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
