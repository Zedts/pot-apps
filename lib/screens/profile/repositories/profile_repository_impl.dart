import '../../../core/constants/api_endpoints.dart';
import '../../../core/models/user_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/storage/token_storage.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../auth/repositories/auth_repository_impl.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final AuthService _authService;
  final AuthRepository _authRepository;
  final ApiClient _apiClient;

  ProfileRepositoryImpl({
    AuthService? authService,
    AuthRepository? authRepository,
    ApiClient? apiClient,
  })  : _authService = authService ?? AuthService(),
        _authRepository = authRepository ?? AuthRepositoryImpl(),
        _apiClient = apiClient ?? ApiClient();

  @override
  Future<UserModel> getProfile() => _authService.getProfile();

  @override
  Future<UserModel> updateProfile({
    required String userId,
    required String nama,
    required String username,
    required String email,
    required String noHp,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.userById(userId),
      body: {
        'nama': nama.trim(),
        'username': username.trim(),
        'email': email.trim().toLowerCase(),
        'no_hp': noHp.trim(),
      },
      requiresAuth: true,
    );
    final user = UserModel.fromJson(response['data'] as Map<String, dynamic>? ?? {});
    await TokenStorage.saveUser(user);
    return user;
  }

  @override
  Future<void> logout() => _authRepository.logout();
}
