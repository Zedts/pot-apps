import '../constants/api_endpoints.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';

/// Authentication service managing email login, Google sign-in, session profile, and logout.
class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Logs in with email and password strictly.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
      requiresAuth: false,
    );

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final authResponse = AuthResponse.fromJson(data);

    // Persist JWT token and user profile locally
    if (authResponse.token.isNotEmpty) {
      await TokenStorage.saveToken(authResponse.token);
      await TokenStorage.saveUser(authResponse.user);
    }

    return authResponse;
  }

  /// Registers a new user with nama, username, email, password, and optional noHp.
  /// Confirm password is only checked locally and never included in the request payload.
  Future<AuthResponse> register({
    required String nama,
    required String username,
    required String email,
    required String password,
    String? noHp,
  }) async {
    final body = <String, dynamic>{
      'nama': nama.trim(),
      'username': username.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
    };
    if (noHp != null && noHp.trim().isNotEmpty) {
      body['no_hp'] = noHp.trim();
    }

    final response = await _apiClient.post(
      ApiEndpoints.register,
      body: body,
      requiresAuth: false,
    );

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final authResponse = AuthResponse.fromJson(data);

    // Persist JWT token and user profile locally
    if (authResponse.token.isNotEmpty) {
      await TokenStorage.saveToken(authResponse.token);
      await TokenStorage.saveUser(authResponse.user);
    }

    return authResponse;
  }

  /// Logs in or registers with Google ID Token.
  Future<AuthResponse> loginWithGoogle({required String idToken}) async {
    final response = await _apiClient.post(
      ApiEndpoints.googleLogin,
      body: {
        'idToken': idToken,
      },
      requiresAuth: false,
    );

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final authResponse = AuthResponse.fromJson(data);

    if (authResponse.token.isNotEmpty) {
      await TokenStorage.saveToken(authResponse.token);
      await TokenStorage.saveUser(authResponse.user);
    }

    return authResponse;
  }

  /// Retrieves the current authenticated user profile using stored JWT Bearer token.
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(
      ApiEndpoints.me,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final user = UserModel.fromJson(data);
    await TokenStorage.saveUser(user);
    return user;
  }

  /// Clears stored credentials and session upon logout.
  Future<void> logout() async {
    await TokenStorage.clear();
  }
}
