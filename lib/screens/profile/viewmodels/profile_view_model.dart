import '../../../core/constants/app_constants.dart';
import '../../../core/models/activity_history_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/activity_history_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/viewmodels/base_view_model.dart';
import '../../home/repositories/home_repository.dart';
import '../../home/repositories/home_repository_impl.dart';
import '../repositories/profile_repository.dart';
import '../repositories/profile_repository_impl.dart';

class ProfileViewModel extends BaseViewModel {
  final ProfileRepository _repository;
  final HomeRepository _homeRepository;
  final ActivityHistoryService _activityHistoryService;
  UserModel _user;
  String? _lapakName;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isLoggingOut = false;
  String? _errorMessage;

  ProfileViewModel({
    required UserModel initialUser,
    ProfileRepository? repository,
    HomeRepository? homeRepository,
    ActivityHistoryService? activityHistoryService,
  }) : _user = initialUser,
       _repository = repository ?? ProfileRepositoryImpl(),
       _homeRepository = homeRepository ?? HomeRepositoryImpl(),
       _activityHistoryService =
           activityHistoryService ?? ActivityHistoryService();

  UserModel get user => _user;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isLoggingOut => _isLoggingOut;
  String? get errorMessage => _errorMessage;
  String get lapakDisplayName {
    if (_user.lapakId == null || _user.lapakId!.trim().isEmpty) {
      return 'Belum ditugaskan';
    }
    return _lapakName?.trim().isNotEmpty == true
        ? _lapakName!.trim()
        : 'Lapak tidak tersedia';
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repository.getProfile();
    } on ApiException catch (error) {
      _errorMessage = error.userMessage;
    } catch (_) {
      _errorMessage = 'Gagal memuat profil. Silakan coba lagi.';
    } finally {
      await _loadLapakName();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String nama,
    required String username,
    required String email,
    required String noHp,
  }) async {
    final validationError =
        Validators.validateName(nama) ??
        Validators.validateUsername(username) ??
        Validators.validateEmail(email) ??
        Validators.validatePhone(noHp);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _repository.updateProfile(
        userId: _user.id,
        nama: nama,
        username: username,
        email: email,
        noHp: noHp,
      );
      final occurredAt = DateTime.now();
      await _activityHistoryService.record(
        ActivityHistoryModel(
          userId: _user.id,
          lapakId: _user.lapakId,
          activityType: AppConstants.activityProfileUpdated,
          title: 'Profil Diperbarui',
          description: 'Data profil berhasil diperbarui',
          occurredAt: occurredAt,
          referenceId:
              '${_user.id}:${occurredAt.toUtc().microsecondsSinceEpoch}',
        ),
      );
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.userMessage;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal memperbarui profil. Silakan coba lagi.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    _isLoggingOut = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.logout();
      return true;
    } catch (_) {
      _errorMessage = 'Terjadi kendala saat keluar akun.';
      return false;
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }
  }

  Future<void> _loadLapakName() async {
    final lapakId = _user.lapakId;
    _lapakName = null;
    if (lapakId == null || lapakId.trim().isEmpty) return;
    try {
      _lapakName = await _homeRepository.getLapakName(lapakId.trim());
    } catch (_) {
      // A failed name lookup must not block profile data from being shown.
    }
  }
}
