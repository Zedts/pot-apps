import 'package:flutter/material.dart';
import 'core/models/user_model.dart';
import 'core/network/api_client.dart';
import 'core/services/google_auth_service.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/env_config.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/app_navigation_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.init();
  await GoogleAuthService.initialize();

  // Centralized 401 Unauthorized Interceptor:
  // Automatically purges expired credentials and redirects back to LoginScreen
  ApiClient.onUnauthorized = () async {
    await TokenStorage.clear();
    PotApp.navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  };

  final hasToken = await TokenStorage.hasToken();
  final initialUser = hasToken ? await TokenStorage.getUser() : null;

  runApp(PotApp(initialUser: initialUser));
}

class PotApp extends StatelessWidget {
  final UserModel? initialUser;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const PotApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'POT - Presensi Oleh² Turki',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: initialUser == null
          ? const LoginScreen()
          : initialUser!.role.toLowerCase() == 'unassigned'
              ? HomeScreen(user: initialUser!)
              : AppNavigationShell(user: initialUser!),
    );
  }
}
