import '../../../core/models/lapak_model.dart';
import '../../../core/models/user_model.dart';

/// Abstract repository contract for Home operations.
/// Follows Clean Architecture to isolate data fetching from UI and ViewModels.
abstract class HomeRepository {
  /// Fetches the latest authenticated user profile from GET /api/v1/auth/me
  /// and updates the local TokenStorage cache.
  Future<UserModel> refreshProfile();

  /// Retrieves the cached profile from local storage.
  Future<UserModel?> getCachedUser();

  /// Retrieves the lapak entity name by its ID.
  Future<String?> getLapakName(String lapakId);

  /// Retrieves the full lapak domain model by its ID.
  Future<LapakModel?> getLapak(String lapakId);

  /// Executes logout, clearing local credentials and third-party sessions.
  Future<void> logout();
}
