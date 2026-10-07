import '../../../core/models/user_model.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/viewmodels/base_view_model.dart';
import '../repositories/home_repository.dart';
import '../repositories/home_repository_impl.dart';

/// ViewModel managing state and operations for HomeScreen.
/// Implements MVVM pattern to decouple UI presentation from business logic and network calls.
class HomeViewModel extends BaseViewModel {
  final HomeRepository _homeRepository;

  UserModel user;
  bool _isLoading = false;
  bool _isLoggingOut = false;
  String? _errorMessage;
  int _currentTabIndex = 0;
  String? _lapakNama;

  HomeViewModel({
    required this.user,
    HomeRepository? homeRepository,
  })  : _homeRepository = homeRepository ?? HomeRepositoryImpl() {
    loadLapakInfo();
  }

  bool get isLoading => _isLoading;
  bool get isLoggingOut => _isLoggingOut;
  String? get errorMessage => _errorMessage;
  int get currentTabIndex => _currentTabIndex;
  String? get lapakNama => _lapakNama;

  /// Checks whether the user role is unassigned.
  bool get isUnassigned => user.role.toLowerCase() == 'unassigned';

  /// Resolves the user greeting name.
  String get greetingName => user.displayName;

  /// Resolves the assigned lapak name, or informs that lapak is not assigned yet.
  String get lapakDisplayInfo {
    if (user.lapakId == null ||
        user.lapakId!.trim().isEmpty ||
        user.lapakId!.trim().toLowerCase() == 'null') {
      return 'Belum Ditugaskan';
    }
    if (_lapakNama != null &&
        _lapakNama!.trim().isNotEmpty &&
        _lapakNama!.trim().toLowerCase() != 'null') {
      return _lapakNama!.trim();
    }
    final raw = user.lapakId!.trim();
    if (raw.toLowerCase().startsWith('lapak')) {
      return raw.replaceAll('-', ' ').toUpperCase();
    }
    return 'Lapak $raw';
  }

  /// Resolves the badge text on the user banner.
  String get roleBadgeLabel {
    if (isUnassigned) {
      return 'Belum Ditugaskan';
    }
    return user.role.toUpperCase();
  }

  /// Formats the current date into localized Indonesian representation.
  /// Example: "Rabu, 7 Oktober 2026"
  String get formattedDate {
    final now = DateTime.now();
    const dayNames = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final dayName = dayNames[(now.weekday - 1) % 7];
    final monthName = monthNames[(now.month - 1) % 12];
    return '$dayName, ${now.day} $monthName ${now.year}';
  }

  /// Changes the bottom navigation tab index.
  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  /// Refreshes the user profile from the backend to pick up assigned role or lapak changes.
  Future<void> refreshProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _homeRepository.refreshProfile();
      user = updatedUser;
      await loadLapakInfo();
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
    } catch (_) {
      _errorMessage = 'Gagal memperbarui status akun. Silakan coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches lapak details if the user has an assigned lapak ID.
  Future<void> loadLapakInfo() async {
    final lapakId = user.lapakId;
    if (lapakId == null || lapakId.trim().isEmpty || lapakId.trim().toLowerCase() == 'null') {
      _lapakNama = null;
      notifyListeners();
      return;
    }

    try {
      final name = await _homeRepository.getLapakName(lapakId.trim());
      if (name != null && name.trim().isNotEmpty && name.trim().toLowerCase() != 'null') {
        _lapakNama = name.trim();
        notifyListeners();
      }
    } catch (_) {
      // Gracefully silent; lapakDisplayInfo will fallback safely without showing 'null'
    }
  }

  /// Executes logout flow. Returns `true` if successful.
  Future<bool> logout() async {
    _isLoggingOut = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _homeRepository.logout();
      return true;
    } catch (_) {
      _errorMessage = 'Terjadi kendala saat keluar akun.';
      return false;
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }
  }
}
