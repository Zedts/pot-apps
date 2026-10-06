import '../../../core/models/auth_response.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/google_auth_service.dart';
import '../../../core/storage/token_storage.dart';
import 'auth_repository.dart';

/// Concrete implementation of [AuthRepository] coordinating network services
/// and persistent session storage.
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final GoogleAuthService _googleAuthService;

  AuthRepositoryImpl({
    AuthService? authService,
    GoogleAuthService? googleAuthService,
  })  : _authService = authService ?? AuthService(),
        _googleAuthService = googleAuthService ?? GoogleAuthService();

  @override
  Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _authService.login(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> registerWithEmail({
    required String nama,
    required String username,
    required String email,
    required String password,
    String? noHp,
  }) async {
    return await _authService.register(
      nama: nama,
      username: username,
      email: email,
      password: password,
      noHp: noHp,
    );
  }

  @override
  Future<AuthResponse?> loginWithGoogle() async {
    final idToken = await _googleAuthService.signIn();
    if (idToken == null) {
      // User cancelled or dismissed Google Sign-In prompt
      return null;
    }
    return await _authService.loginWithGoogle(idToken: idToken);
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
    await _googleAuthService.signOut();
    await TokenStorage.clear();
  }

  @override
  Future<UserModel?> getCachedUser() async {
    return await TokenStorage.getUser();
  }

  @override
  Future<bool> isAuthenticated() async {
    return await TokenStorage.hasToken();
  }
}
