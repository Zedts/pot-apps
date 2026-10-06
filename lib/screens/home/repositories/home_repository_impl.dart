import '../../../core/constants/api_endpoints.dart';
import '../../../core/models/user_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/google_auth_service.dart';
import '../../../core/storage/token_storage.dart';
import 'home_repository.dart';

/// Concrete implementation of [HomeRepository] coordinating services and session cache.
class HomeRepositoryImpl implements HomeRepository {
  final AuthService _authService;
  final GoogleAuthService _googleAuthService;
  final ApiClient _apiClient;

  HomeRepositoryImpl({
    AuthService? authService,
    GoogleAuthService? googleAuthService,
    ApiClient? apiClient,
  })  : _authService = authService ?? AuthService(),
        _googleAuthService = googleAuthService ?? GoogleAuthService(),
        _apiClient = apiClient ?? ApiClient();

  @override
  Future<UserModel> refreshProfile() async {
    final user = await _authService.getProfile();
    return user;
  }

  @override
  Future<UserModel?> getCachedUser() async {
    return await TokenStorage.getUser();
  }

  @override
  Future<String?> getLapakName(String lapakId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.lapakById(lapakId),
        requiresAuth: true,
      );
      final data = response['data'] as Map<String, dynamic>?;
      if (data != null && data['nama'] != null) {
        return data['nama'] as String;
      }
    } catch (_) {
      // Gracefully handle 403 or network exceptions without crashing
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
    await _googleAuthService.signOut();
    await TokenStorage.clear();
  }
}
