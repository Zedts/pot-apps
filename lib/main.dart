import 'package:flutter/material.dart';
import 'core/models/user_model.dart';
import 'core/services/google_auth_service.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/env_config.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.init();
  await GoogleAuthService.initialize();

  final hasToken = await TokenStorage.hasToken();
  final initialUser = hasToken ? await TokenStorage.getUser() : null;

  runApp(PotApp(initialUser: initialUser));
}

class PotApp extends StatelessWidget {
  final UserModel? initialUser;

  const PotApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POT - Presensi Oleh² Turki',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: initialUser != null
          ? HomeScreen(user: initialUser!)
          : const LoginScreen(),
    );
  }
}
