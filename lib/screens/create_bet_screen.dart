import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../config/colors.dart';
import '../models/models.dart';
import '../providers/bet_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';

class CreateBetScreen extends StatefulWidget {
  final Match? match;

  const CreateBetScreen({Key? key, this.match}) : super(key: key);

  @override
  State<CreateBetScreen> createState() => _CreateBetScreenState();
}

class _CreateBetScreenState extends State<CreateBetScreen> {
  final _homeTeamController = TextEditingController();
  final _awayTeamController = TextEditingController();
  final _leagueController = TextEditingController(text: 'Liga de Barrio');
  final _amountController = TextEditingController(text: '250');
  final _homeScoreController = TextEditingController(text: '0');
  final _awayScoreController = TextEditingController(text: '0');
  final _shotsController = TextEditingController(text: '0');

  DateTime _kickoff = DateTime.now().add(const Duration(hours: 2));
  Match? _selectedMatch;
  BetMarket _selectedMarket = BetMarket.matchWinner;
  String? _selectedOption;
  bool _isSubmitting = false;
  bool _isCreatingMatch = false;
  bool _isUpdatingStats = false;
  MatchStatus _creatorStatus = MatchStatus.live;
  String _creatorFirstScorer = '';
  String _selectedLanguage = 'es';

  static const Map<String, String> _languageLabels = {
    'es': 'Español',
    'ca': 'Català',
    'en': 'English',
  };

  String _t(String key) {
    const localized = {
      'es': {
        'appBarTitle': 'Crear Apuesta V2',
        'appBarSubtitle': 'Tema y idioma al alcance',
        'settingsTitle': 'Ajustes',
        'settingsSubtitle': 'Personaliza tema e idioma',
        'themeTitle': 'Modo claro',
        'themeDescription': 'Activa para usar el tema claro',
        'languageTitle': 'Idioma',
        'languageDescription': 'Selecciona tu idioma favorito',
        'close': 'Cerrar',
      },
      'ca': {
        'appBarTitle': 'Crear Aposta V2',
        'appBarSubtitle': 'Tema i idioma a l\'abast',
        'settingsTitle': 'Ajustos',
        'settingsSubtitle': 'Personalitza tema i idioma',
        'themeTitle': 'Mode clar',
        'themeDescription': 'Activa per usar el mode clar',
        'languageTitle': 'Idioma',
        'languageDescription': 'Selecciona el teu idioma preferit',
        'close': 'Tancar',
      },
      'en': {
        'appBarTitle': 'Create Bet V2',
        'appBarSubtitle': 'Theme and language ready',
        'settingsTitle': 'Settings',
        'settingsSubtitle': 'Personalize theme and language',
        'themeTitle': 'Light mode',
        'themeDescription': 'Enable to switch to the light theme',
        'languageTitle': 'Language',
        'languageDescription': 'Choose your preferred language',
        'close': 'Close',
      },
    };
    return localized[_selectedLanguage]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _selectedMatch = widget.match;

    Future.microtask(() {
      context.read<BetProvider>().seedRandomMatchesIfEmpty();
    });
  }

  @override
  void dispose() {
    _homeTeamController.dispose();
    _awayTeamController.dispose();
    _leagueController.dispose();
    _amountController.dispose();
    _homeScoreController.dispose();
    _awayScoreController.dispose();
    _shotsController.dispose();
    super.dispose();
  }

  String _marketLabel(BetMarket market) {
    switch (market) {
      case BetMarket.matchWinner:
        return 'Ganador del partido';
      case BetMarket.firstScoringTeam:
        return 'Equipo que marcará primero';
      case BetMarket.overTwoGoals:
        return 'Más de 2 goles';
      case BetMarket.totalGoals:
        return 'Total de goles (exacto)';
      case BetMarket.totalShotsOnTarget:
        return 'Total de chutes a puerta';
    }
  }

  List<String> _marketOptions(Match match, BetMarket market) {
    switch (market) {
      case BetMarket.matchWinner:
        return [match.homeTeam, 'Empate', match.awayTeam];
      case BetMarket.firstScoringTeam:
        return [match.homeTeam, match.awayTeam];
      case BetMarket.overTwoGoals:
        return ['Sí', 'No'];
      case BetMarket.totalGoals:
        return ['0', '1', '2', '3', '4', '5', '6', '7', '8+'];
      case BetMarket.totalShotsOnTarget:
        return ['0-5', '6-9', '10+'];
    }
  }

  double _computeOdds({
    required Match match,
    required BetMarket market,
    required String option,
  }) {
    final randomFactor = ((match.id.hashCode.abs() % 20) / 100.0) + 0.9;

    switch (market) {
      case BetMarket.matchWinner:
        final homeWeight = (match.homeScore ?? 0) + 1.4;
        final awayWeight = (match.awayScore ?? 0) + 1.2;
        final drawWeight = 1.9;

        if (option == match.homeTeam) return (3.2 / homeWeight) * randomFactor;
        if (option == match.awayTeam) return (3.2 / awayWeight) * randomFactor;
        return (3.0 / drawWeight) * randomFactor;
      case BetMarket.firstScoringTeam:
        if (option == match.homeTeam) return 1.95 * randomFactor;
        return 2.10 * randomFactor;
      case BetMarket.overTwoGoals:
        return option == 'Sí' ? 1.75 * randomFactor : 2.25 * randomFactor;
      case BetMarket.totalGoals:
        if (option == '0') return 8.0 * randomFactor;
        if (option == '1') return 5.5 * randomFactor;
        if (option == '2') return 3.9 * randomFactor;
        if (option == '3') return 3.2 * randomFactor;
        if (option == '4') return 3.6 * randomFactor;
        if (option == '5') return 4.8 * randomFactor;
        if (option == '6') return 6.8 * randomFactor;
        if (option == '7') return 8.5 * randomFactor;
        return 10.0 * randomFactor;
      case BetMarket.totalShotsOnTarget:
        if (option == '0-5') return 2.3 * randomFactor;
        if (option == '6-9') return 1.95 * randomFactor;
        return 2.7 * randomFactor;
    }
  }

  BetType _betTypeFromSelection({
    required Match match,
    required BetMarket market,
    required String option,
  }) {
    if (market == BetMarket.matchWinner) {
      if (option == match.homeTeam) return BetType.homeWin;
      if (option == match.awayTeam) return BetType.awayWin;
      return BetType.draw;
    }

    if (market == BetMarket.overTwoGoals) {
      return option == 'Sí' ? BetType.over : BetType.under;
    }

    return BetType.over;
  }

  Future<void> _pickKickoffDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _kickoff,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (!mounted || pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_kickoff),
    );

    if (!mounted || pickedTime == null) return;

    setState(() {
      _kickoff = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _createCustomMatch() async {
    final user = context.read<UserProvider>().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para crear partidos.')),
      );
      return;
    }

    final home = _homeTeamController.text.trim();
    final away = _awayTeamController.text.trim();
    final league = _leagueController.text.trim();

    if (home.isEmpty || away.isEmpty || league.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos del partido.')),
      );
      return;
    }

    if (home.toLowerCase() == away.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Los equipos deben ser distintos.')),
      );
      return;
    }

    setState(() => _isCreatingMatch = true);

    final matchId = await context.read<BetProvider>().createCustomMatch(
          ownerUserId: user.id,
          ownerName: user.name,
          homeTeam: home,
          awayTeam: away,
          league: league,
          kickoff: _kickoff,
        );

    setState(() => _isCreatingMatch = false);

    if (!mounted) return;

    if (matchId != null) {
      _homeTeamController.clear();
      _awayTeamController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Partido creado. Ya puedes abrir apuestas para todos.'),
          backgroundColor: BetFlixColors.greenLime,
        ),
      );
    } else {
      final error = context.read<BetProvider>().errorMessage ?? 'No se pudo crear el partido';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: BetFlixColors.accentRed),
      );
    }
  }

  Future<void> _updateCreatorStats() async {
    final match = _selectedMatch;
    final user = context.read<UserProvider>().currentUser;

    if (match == null || user == null) return;

    final homeScore = int.tryParse(_homeScoreController.text) ?? 0;
    final awayScore = int.tryParse(_awayScoreController.text) ?? 0;
    final shots = int.tryParse(_shotsController.text) ?? 0;

    String firstScorer = _creatorFirstScorer;
    if (firstScorer.isEmpty && (homeScore > 0 || awayScore > 0)) {
      firstScorer = homeScore >= awayScore ? match.homeTeam : match.awayTeam;
    }

    setState(() => _isUpdatingStats = true);

    final success = await context.read<BetProvider>().updateCustomMatchStats(
          matchId: match.id,
          ownerUserId: user.id,
          homeScore: homeScore,
          awayScore: awayScore,
          shotsOnTargetTotal: shots,
          firstScoringTeam: firstScorer,
          status: _creatorStatus,
        );

    setState(() => _isUpdatingStats = false);

    if (!mounted) return;

    if (success) {
      await context.read<UserProvider>().loadCurrentUser();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_creatorStatus == MatchStatus.finished
              ? 'Partido cerrado y apuestas liquidadas automáticamente.'
              : 'Marcador actualizado por el creador del partido.'),
          backgroundColor: BetFlixColors.greenLime,
        ),
      );
    } else {
      final error = context.read<BetProvider>().errorMessage ?? 'No se pudieron actualizar las estadísticas';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: BetFlixColors.accentRed),
      );
    }
  }

  Future<void> _placeBet() async {
    final user = context.read<UserProvider>().currentUser;
    final match = _selectedMatch;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para apostar.')),
      );
      return;
    }

    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un partido primero.')),
      );
      return;
    }

    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una opción de mercado.')),
      );
      return;
    }

    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un monto válido.')),
      );
      return;
    }

    if (amount > user.coins) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saldo insuficiente. Tienes ${user.coins} 🪙 y necesitas $amount 🪙.'),
          backgroundColor: BetFlixColors.accentRed,
        ),
      );
      return;
    }

    final odds = _computeOdds(
      match: match,
      market: _selectedMarket,
      option: _selectedOption!,
    );
    final potentialWinnings = (amount * odds).toInt();

    final confirmed = await _confirmBetDialog(
      matchTitle: '${match.homeTeam} vs ${match.awayTeam}',
      marketLabel: _marketLabel(_selectedMarket),
      selectionLabel: _selectedOption!,
      amount: amount,
      odds: odds,
      potentialWinnings: potentialWinnings,
      currentCoins: user.coins,
    );

    if (!confirmed) return;

    final coinsBefore = user.coins;

    setState(() => _isSubmitting = true);

    final success = await context.read<BetProvider>().createBet(
          userId: user.id,
          matchId: match.id,
          betType: _betTypeFromSelection(
            match: match,
            market: _selectedMarket,
            option: _selectedOption!,
          ),
          market: _selectedMarket,
          selection: _selectedOption!,
          matchTitle: '${match.homeTeam} vs ${match.awayTeam}',
          createdByUserId: match.createdByUserId,
          amount: amount,
          odds: odds,
        );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      await context.read<UserProvider>().loadCurrentUser();
      final updatedCoins = context.read<UserProvider>().currentUser?.coins ?? (coinsBefore - amount);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Apuesta creada. Saldo: $coinsBefore → $updatedCoins 🪙 · Ganancia potencial: $potentialWinnings 🪙',
          ),
          backgroundColor: BetFlixColors.greenLime,
        ),
      );
      Navigator.pop(context);
    } else {
      final error = context.read<BetProvider>().errorMessage ?? 'No se pudo crear la apuesta';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: BetFlixColors.accentRed),
      );
    }
  }

  Future<bool> _confirmBetDialog({
    required String matchTitle,
    required String marketLabel,
    required String selectionLabel,
    required int amount,
    required double odds,
    required int potentialWinnings,
    required int currentCoins,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar apuesta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Partido: $matchTitle'),
              Text('Mercado: $marketLabel'),
              Text('Selección: $selectionLabel'),
              const SizedBox(height: 8),
              Text('Monto: $amount 🪙'),
              Text('Cuota: ${odds.toStringAsFixed(2)}x'),
              Text('Ganancia potencial: $potentialWinnings 🪙'),
              const SizedBox(height: 8),
              Text('Saldo actual: $currentCoins 🪙'),
              Text('Saldo tras apostar: ${currentCoins - amount} 🪙'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageGradient = isDark
        ? BetFlixColors.pageGradient
        : const [Color(0xFFF3F4F6), Color(0xFFE5E7EB), Color(0xFFF9FAFB)];
    final primaryText = isDark ? Colors.white : const Color(0xFF111827);
    final secondaryText = isDark ? Colors.white70 : const Color(0xFF4B5563);
    final inputBg = isDark ? const Color(0xFF2A2A3E) : Colors.white;
    final panelGradient = isDark
        ? BetFlixColors.cardGradient
        : const [Color(0xFFFFFFFF), Color(0xFFF3F4F6)];
    final listItemGradient = isDark
        ? const [Color(0xFF2A2A3E), Color(0xFF1A1A2E)]
        : const [Color(0xFFFFFFFF), Color(0xFFF3F4F6)];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('appBarTitle'),
              style: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_languageLabels[_selectedLanguage]} · ${_t('appBarSubtitle')}',
              style: TextStyle(
                color: primaryText.withOpacity(0.72),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: primaryText),
            onPressed: _showSettingsMenu,
            tooltip: _t('settingsTitle'),
          ),
        ],
      ),
      body: StreamBuilder<List<Match>>(
        stream: context.watch<BetProvider>().getOpenMatchesStream(),
        builder: (context, snapshot) {
          final hasStreamError = snapshot.hasError;
          final matches = snapshot.data ?? const <Match>[];

          if (_selectedMatch == null) {
            _selectedMatch = widget.match ?? (matches.isNotEmpty ? matches.first : null);
          }

          final selectedMatch = _selectedMatch;
          final options = selectedMatch == null
              ? const <String>[]
              : _marketOptions(selectedMatch, _selectedMarket);

          if (_selectedOption == null && options.isNotEmpty) {
            _selectedOption = options.first;
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: pageGradient,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1024),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                if (hasStreamError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: BetFlixColors.accentRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: BetFlixColors.accentRed.withOpacity(0.45)),
                      ),
                      child: Text(
                        'No se pudieron cargar los partidos abiertos. Puedes apostar en el partido seleccionado manualmente.',
                        style: TextStyle(color: secondaryText),
                      ),
                    ),
                  ),
                _reveal(
                  _sectionTitle('1) Crea tu partido del barrio'),
                ),
                _reveal(
                  _panel(
                  child: Column(
                    children: [
                      _textInput(_homeTeamController, 'Equipo local'),
                      const SizedBox(height: 10),
                      _textInput(_awayTeamController, 'Equipo visitante'),
                      const SizedBox(height: 10),
                      _textInput(_leagueController, 'Liga / Torneo'),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _pickKickoffDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: BetFlixColors.purpleVibrant.withOpacity(0.25)),
                          ),
                          child: Text(
                            'Inicio: ${_kickoff.day.toString().padLeft(2, '0')}/${_kickoff.month.toString().padLeft(2, '0')} ${_kickoff.hour.toString().padLeft(2, '0')}:${_kickoff.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(color: primaryText),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isCreatingMatch ? null : _createCustomMatch,
                          style: ElevatedButton.styleFrom(backgroundColor: BetFlixColors.orangeVibrant),
                          child: _isCreatingMatch
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : const Text('Publicar partido personalizado'),
                        ),
                      ),
                    ],
                  ),
                ),
                ),
                const SizedBox(height: 18),
                _reveal(_sectionTitle('2) Elige partido abierto para apostar')),
                _reveal(_panel(
                  child: snapshot.hasError
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: BetFlixColors.accentRed.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: BetFlixColors.accentRed.withOpacity(0.6)),
                          ),
                          child: Text(
                            'Error al cargar partidos de Firestore. '
                            'Suele ser por reglas o índices.\n\nDetalle: ${snapshot.error}',
                            style: TextStyle(color: primaryText),
                          ),
                        )
                      : snapshot.connectionState == ConnectionState.waiting
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(color: BetFlixColors.cyanBright),
                          ),
                        )
                      : matches.isEmpty
                          ? Text(
                              'No hay partidos abiertos todavía. Crea uno arriba y entra en acción.',
                              style: TextStyle(color: secondaryText),
                            )
                          : Column(
                              children: matches.map((match) {
                                final isSelected = selectedMatch?.id == match.id;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedMatch = match;
                                      _selectedOption = null;
                                      _homeScoreController.text = (match.homeScore ?? 0).toString();
                                      _awayScoreController.text = (match.awayScore ?? 0).toString();
                                      _shotsController.text = (match.shotsOnTargetTotal ?? 0).toString();
                                      _creatorStatus = match.status;
                                      _creatorFirstScorer = match.firstScoringTeam ?? '';
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? BetFlixColors.vibrantGradientLinear
                                          : LinearGradient(
                                              colors: listItemGradient,
                                            ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected ? BetFlixColors.cyanBright : Colors.transparent,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${match.homeTeam} vs ${match.awayTeam}',
                                                style: TextStyle(
                                                  color: isSelected ? Colors.white : primaryText,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${match.league} • ${match.source == MatchSource.userCreated ? 'Creado por ${match.createdByName ?? 'usuario'}' : 'Generado por BetFlix'}',
                                                style: TextStyle(
                                                  color: isSelected ? Colors.white70 : secondaryText,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${match.homeScore ?? 0}-${match.awayScore ?? 0}',
                                          style: const TextStyle(
                                            color: BetFlixColors.goldYellow,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                )),
                const SizedBox(height: 18),
                if (selectedMatch != null && user != null && selectedMatch.createdByUserId == user.id)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _reveal(_sectionTitle('3) Panel del creador (control del partido)')),
                      _reveal(_panel(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: _textInput(_homeScoreController, 'Goles local', number: true)),
                                const SizedBox(width: 10),
                                Expanded(child: _textInput(_awayScoreController, 'Goles visitante', number: true)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _textInput(_shotsController, 'Total chutes a puerta', number: true),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: _creatorFirstScorer.isEmpty ? null : _creatorFirstScorer,
                              dropdownColor: inputBg,
                              style: TextStyle(color: primaryText),
                              decoration: InputDecoration(
                                hintText: 'Equipo que marcó primero',
                                hintStyle: TextStyle(color: secondaryText),
                                filled: true,
                                fillColor: inputBg,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: selectedMatch.homeTeam,
                                  child: Text(selectedMatch.homeTeam, style: TextStyle(color: primaryText)),
                                ),
                                DropdownMenuItem(
                                  value: selectedMatch.awayTeam,
                                  child: Text(selectedMatch.awayTeam, style: TextStyle(color: primaryText)),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _creatorFirstScorer = value ?? '';
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<MatchStatus>(
                              value: _creatorStatus,
                              dropdownColor: inputBg,
                              style: TextStyle(color: primaryText),
                              decoration: InputDecoration(
                                hintText: 'Estado del partido',
                                hintStyle: TextStyle(color: secondaryText),
                                filled: true,
                                fillColor: inputBg,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: MatchStatus.scheduled,
                                  child: Text('Programado', style: TextStyle(color: primaryText)),
                                ),
                                DropdownMenuItem(
                                  value: MatchStatus.live,
                                  child: Text('En vivo', style: TextStyle(color: primaryText)),
                                ),
                                DropdownMenuItem(
                                  value: MatchStatus.finished,
                                  child: Text('Finalizado (liquidar)', style: TextStyle(color: primaryText)),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _creatorStatus = value ?? MatchStatus.live;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isUpdatingStats ? null : _updateCreatorStats,
                                style: ElevatedButton.styleFrom(backgroundColor: BetFlixColors.cyanBright),
                                child: _isUpdatingStats
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                      )
                                    : const Text('Actualizar goles y estadísticas'),
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 18),
                    ],
                  ),
                _reveal(_sectionTitle('4) Mercados avanzados para apostar')),
                _reveal(_panel(
                  child: selectedMatch == null
                      ? Text('Selecciona un partido para habilitar mercados.', style: TextStyle(color: secondaryText))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: BetMarket.values.map((market) {
                                final selected = market == _selectedMarket;
                                return ChoiceChip(
                                  label: Text(_marketLabel(market)),
                                  selected: selected,
                                  labelStyle: TextStyle(
                                    color: selected ? Colors.black : (isDark ? BetFlixColors.cyanBright : const Color(0xFF111827)),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  selectedColor: BetFlixColors.cyanBright,
                                  backgroundColor: isDark ? const Color(0xFF292941) : const Color(0xFFE5E7EB),
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedMarket = market;
                                      _selectedOption = _marketOptions(selectedMatch, market).first;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: options.map((option) {
                                final selected = option == _selectedOption;
                                final odds = _computeOdds(
                                  match: selectedMatch,
                                  market: _selectedMarket,
                                  option: option,
                                );
                                return InkWell(
                                  onTap: () => setState(() => _selectedOption = option),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: selected ? BetFlixColors.pinkBright : inputBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: selected ? BetFlixColors.pinkBright : BetFlixColors.purpleVibrant.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      '$option  •  ${odds.toStringAsFixed(2)}x',
                                      style: TextStyle(
                                        color: selected ? Colors.white : (isDark ? BetFlixColors.cyanBright : const Color(0xFF111827)),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 14),
                            _textInput(_amountController, 'Monto de apuesta (coins)', number: true),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _placeBet,
                                style: ElevatedButton.styleFrom(backgroundColor: BetFlixColors.pinkBright),
                                child: _isSubmitting
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        'Crear apuesta V2',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                )),
              ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final themeProvider = context.watch<ThemeProvider>();
            final isLightTheme = themeProvider.themeMode == ThemeMode.light;
            final primaryText = Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF111827);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF0EA5E9)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.settings, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('settingsTitle'),
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _t('settingsSubtitle'),
                              style: TextStyle(
                                color: primaryText.withOpacity(0.72),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    _t('themeTitle'),
                    style: TextStyle(
                      color: primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _t('themeDescription'),
                            style: TextStyle(color: primaryText.withOpacity(0.85)),
                          ),
                        ),
                        Switch(
                          value: isLightTheme,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _t('languageTitle'),
                    style: TextStyle(
                      color: primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _t('languageDescription'),
                    style: TextStyle(color: primaryText.withOpacity(0.75), fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ..._languageLabels.entries.map(
                    (entry) {
                      return RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        value: entry.key,
                        groupValue: _selectedLanguage,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedLanguage = value;
                          });
                        },
                        title: Text(
                          entry.value,
                          style: TextStyle(color: primaryText, fontWeight: FontWeight.w500),
                        ),
                        activeColor: BetFlixColors.cyanBright,
                      );
                    },
                  ).toList(),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(_t('close').toUpperCase()),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? BetFlixColors.cyanBright : const Color(0xFF111827),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _panel({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelGradient = isDark
        ? BetFlixColors.cardGradient
        : const [Color(0xFFFFFFFF), Color(0xFFF3F4F6)];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: panelGradient,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BetFlixColors.cyanBright.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: BetFlixColors.black.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _reveal(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppConstants.animationDurationMedium,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }

  Widget _textInput(TextEditingController controller, String hint, {bool number = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF6B7280)),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A3E) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
