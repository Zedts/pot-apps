import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Utility class for application environment configuration.
/// Safely manages loading and resolution of base API URLs and Google OAuth client IDs across platforms.
class EnvConfig {
  EnvConfig._();

  static bool _initialized = false;

  /// Initializes environment variables from the `.env` asset file.
  static Future<void> init() async {
    if (_initialized) return;
    try {
      await dotenv.load(fileName: '.env');
      _initialized = true;
    } catch (e) {
      debugPrint('[EnvConfig] Warning: Failed to load .env file: $e.');
      _initialized = true;
    }
  }

  /// Returns the base server URL configured in `.env`.
  static String get baseServerUrl {
    String url = dotenv.maybeGet('BASE_API_URL')!;

    // Remove any trailing slash for consistency
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    return url;
  }

  /// Full base URL including `/api/v1` prefix.
  static String get apiBaseUrl => '$baseServerUrl/api/v1';

  /// Google Server Client ID (Web Client ID) used for server authentication on Android/Web.
  static String? get googleServerClientId =>
      dotenv.maybeGet('GOOGLE_SERVER_CLIENT_ID');

  /// Firebase Web API Key used for Identity Toolkit token exchange.
  static String get firebaseWebApiKey =>
      dotenv.maybeGet('FIREBASE_WEB_API_KEY') ??
      'AIzaSyC0HOpFl93eKvqat0mfRrauhCr7ahQ_s60';
}
