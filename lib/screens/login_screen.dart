import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../providers/user_provider.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;

  final List<Map<String, String>> demoUsers = [
    {'email': 'agarcia@gmail.com', 'password': '123', 'name': 'Aaron Garcia'},
    {'email': 'jterreros@gmail.com', 'password': '123', 'name': 'Jan Terreros'},
    {'email': 'gblanco@gmail.com', 'password': '123', 'name': 'Gerard Blanco'},
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final matchedDemoUsers = demoUsers.where(
      (user) => user['email'] == email && user['password'] == password,
    );

    bool success = await context.read<UserProvider>().signIn(
          email: email,
          password: password,
        );

    // Para usuarios demo predefinidos, hacemos fallback a demo login
    // solo si el login email/password real falla.
    if (!success && matchedDemoUsers.isNotEmpty) {
      success = await context.read<UserProvider>().signInDemo(
            email: email,
            name: matchedDemoUsers.first['name'] ?? 'Usuario Demo',
          );
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      final error = context.read<UserProvider>().errorMessage ?? 'Error en login';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: BetFlixColors.accentRed),
      );
    }
  }

  void _fillDemoUser(Map<String, String> user) {
    _emailController.text = user['email'] ?? '';
    _passwordController.text = user['password'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              BetFlixColors.background,
              const Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: BetFlixColors.vibrantGradientLinear,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    'B',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'BetFlix',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: BetFlixColors.purpleVibrant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Apuesta en tu barrio',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: BetFlixColors.cyanBright,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Input
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: const Color(0xFF2A2A3E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: BetFlixColors.purpleVibrant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: BetFlixColors.purpleVibrant.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: BetFlixColors.cyanBright, width: 2),
                    ),
                    prefixIcon: Icon(Icons.email, color: BetFlixColors.cyanBright),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Input
                TextField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: const Color(0xFF2A2A3E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: BetFlixColors.purpleVibrant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: BetFlixColors.purpleVibrant.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: BetFlixColors.cyanBright, width: 2),
                    ),
                    prefixIcon: Icon(Icons.lock, color: BetFlixColors.cyanBright),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        color: BetFlixColors.cyanBright,
                      ),
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BetFlixColors.pinkBright,
                      disabledBackgroundColor: BetFlixColors.pinkBright.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Iniciar Sesión',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Demo Users Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: BetFlixColors.cyanBright.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF2A2A3E).withOpacity(0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usuarios de Demo',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: BetFlixColors.cyanBright,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...demoUsers.map((user) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => _fillDemoUser(user),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A2E),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: BetFlixColors.purpleVibrant.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: BetFlixColors.purpleVibrant,
                                  child: Text(
                                    user['name']?[0] ?? '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user['name'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        user['email'] ?? '',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: BetFlixColors.cyanBright,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta? ',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text(
                        'Regístrate',
                        style: TextStyle(
                          color: BetFlixColors.cyanBright,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
