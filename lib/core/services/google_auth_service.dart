import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../network/api_exception.dart';
import '../utils/env_config.dart';

/// Helper service for Google Sign-In interaction using google_sign_in 7.x API
/// and exchanging the Google OAuth ID Token for a Firebase Auth ID Token.
class GoogleAuthService {
  final GoogleSignIn _googleSignIn;
  final http.Client _httpClient;
  static bool _isInitialized = false;

  GoogleAuthService({
    GoogleSignIn? googleSignIn,
    http.Client? httpClient,
  })  : _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _httpClient = httpClient ?? http.Client();

  /// Ensures GoogleSignIn.instance is properly initialized with serverClientId.
  Future<void> _ensureInitialized() async {
    await initialize();
  }

  /// Explicit initialization method to be called at application startup.
  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final serverClientId = EnvConfig.googleServerClientId;
      await GoogleSignIn.instance.initialize(
        serverClientId: serverClientId,
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('[GoogleAuthService] Failed to initialize GoogleSignIn: $e');
    }
  }

  /// Exchanges a raw Google OAuth ID Token for a Firebase Auth ID Token
  /// via Firebase Identity Toolkit REST API.
  Future<String> _exchangeForFirebaseIdToken(String googleIdToken) async {
    final apiKey = EnvConfig.firebaseWebApiKey;
    final uri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=$apiKey',
    );

    final response = await _httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'postBody': 'id_token=$googleIdToken&providerId=google.com',
        'requestUri': 'http://localhost',
        'returnSecureToken': true,
      }),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw const ApiException(
        statusCode: 408,
        rawMessage: 'Firebase Identity Toolkit token exchange timeout',
        userMessage: 'Waktu koneksi verifikasi akun Google habis. Silakan coba lagi.',
      ),
    );

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>? ?? {};

    if (response.statusCode != 200) {
      final errorMsg = responseBody['error']?['message'] ?? 'Unknown error';
      debugPrint('[GoogleAuthService] Identity Toolkit error (${response.statusCode}): $errorMsg');
      throw const ApiException(
        statusCode: 401,
        rawMessage: 'Failed to exchange Google credential for Firebase token',
        userMessage: 'Gagal memverifikasi akun Google dengan Firebase. Silakan coba lagi.',
      );
    }

    final firebaseIdToken = responseBody['idToken'] as String?;
    if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
      throw const ApiException(
        statusCode: 401,
        rawMessage: 'No Firebase ID token in response',
        userMessage: 'Gagal memperoleh token verifikasi akun Google.',
      );
    }

    return firebaseIdToken;
  }

  /// Triggers the Google Sign-In flow and returns the verified Firebase ID Token.
  /// Returns `null` if the user dismissed or cancelled the sign-in prompt.
  Future<String?> signIn() async {
    try {
      await _ensureInitialized();

      final GoogleSignInAccount account = await _googleSignIn.authenticate();
      final auth = account.authentication;
      final googleIdToken = auth.idToken;

      if (googleIdToken == null || googleIdToken.isEmpty) {
        throw const ApiException(
          statusCode: 401,
          rawMessage: 'No ID token received from Google Sign-In',
          userMessage: 'Gagal memperoleh data akun Google. Silakan coba lagi.',
        );
      }

      // Exchange raw Google OAuth token for Firebase Auth ID token
      final firebaseIdToken = await _exchangeForFirebaseIdToken(googleIdToken);

      return firebaseIdToken;
    } on GoogleSignInException catch (e) {
      debugPrint('[GoogleAuthService] GoogleSignInException: ${e.code} - ${e.description}');
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      throw ApiException(
        statusCode: 500,
        rawMessage: e.description ?? 'GoogleSignInException',
        userMessage: 'Gagal masuk dengan Google. Pastikan layanan Google Play aktif di perangkat Anda.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      debugPrint('[GoogleAuthService] Exception: $e');
      throw const ApiException(
        statusCode: 500,
        rawMessage: 'Google Sign-In generic failure',
        userMessage: 'Gagal menghubungkan akun Google. Silakan coba lagi.',
      );
    }
  }

  /// Signs out from Google.
  Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
