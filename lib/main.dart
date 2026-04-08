import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/colors.dart';
import 'config/app_theme.dart';
import 'config/app_constants.dart';
import 'providers/user_provider.dart';
import 'providers/bet_provider.dart';
import 'screens/home_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/create_bet_screen.dart';
import 'screens/login_screen.dart';
import 'screens/active_bets_screen.dart';
import 'screens/tournament_center_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BetProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const AuthWrapper(),
        routes: {
          '/home': (context) => const MainNavigationScreen(),
          '/create-bet': (context) => const CreateBetScreen(),
          '/active-bets': (context) => const ActiveBetsScreen(),
          '/challenges': (context) => const ChallengesScreen(),
          '/ranking': (context) => const RankingScreen(),
          '/profile': (context) => const UserProfileScreen(),
          '/tournament-center': (context) => const TournamentCenterScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// AuthWrapper para mostrar LoginScreen o MainApp segÃºn autenticaciÃ³n
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        // Ejecuta el bootstrap de autenticación solo una vez.
        if (!userProvider.hasInitializedAuth) {
          if (!userProvider.isLoading) {
            Future.microtask(() {
              userProvider.loadCurrentUser();
            });
          }

          return const Scaffold(
            backgroundColor: BetFlixColors.background,
            body: Center(
              child: CircularProgressIndicator(color: BetFlixColors.cyanBright),
            ),
          );
        }

        if (userProvider.isAuthenticated && userProvider.currentUser != null) {
          return const MainNavigationScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

/// Pantalla principal con navegaciÃ³n por pestaÃ±as
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const ActiveBetsScreen(),
      const ChallengesScreen(),
      const RankingScreen(),
      const UserProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BetFlixColors.background,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              BetFlixColors.surfaceCardElevated,
              BetFlixColors.surfaceCard,
            ],
          ),
          border: Border.all(color: BetFlixColors.cyanBright.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: BetFlixColors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: BetFlixColors.cyanBright,
          unselectedItemColor: Colors.white.withOpacity(0.55),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_score_outlined),
              activeIcon: Icon(Icons.sports_score),
              label: 'Apuestas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events),
              label: 'Retos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined),
              activeIcon: Icon(Icons.leaderboard),
              label: 'Ranking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
      ),
    );
  }
}
