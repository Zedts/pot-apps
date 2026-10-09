import '../../../core/models/user_model.dart';

/// Contract for loading the signed-in user's current profile.
abstract class ProfileRepository {
  Future<UserModel> getProfile();

  Future<UserModel> updateProfile({
    required String userId,
    required String nama,
    required String username,
    required String email,
    required String noHp,
  });

  Future<void> logout();
}
