import '../../../core/models/auth_response.dart';
import '../../../core/models/user_model.dart';

/// Abstract repository contract for authentication operations.
/// Follows Clean Architecture principles to decouple presentation from data sources.
abstract class AuthRepository {
  /// Authenticates user with email and password.
  Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  });

  /// Registers a new user with required profile fields and email credentials.
  Future<AuthResponse> registerWithEmail({
    required String nama,
    required String username,
    required String email,
    required String password,
    String? noHp,
  });

  /// Orchestrates Google Sign-In, Firebase token exchange, and backend verification.
  /// Returns `null` if the user cancels or dismisses the Google prompt.
  Future<AuthResponse?> loginWithGoogle();

  /// Logs out the user, clearing local tokens and third-party sessions.
  Future<void> logout();

  /// Retrieves the currently cached user profile from local storage.
  Future<UserModel?> getCachedUser();

  /// Checks whether an authenticated JWT session currently exists.
  Future<bool> isAuthenticated();
}
