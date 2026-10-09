import '../../../core/models/activity_history_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/activity_history_service.dart';
import '../../../core/viewmodels/base_view_model.dart';

class RiwayatViewModel extends BaseViewModel {
  final ActivityHistoryService _activityHistoryService;
  final UserModel user;
  List<ActivityHistoryModel> _entries = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  RiwayatViewModel({
    required this.user,
    ActivityHistoryService? activityHistoryService,
  }) : _activityHistoryService = activityHistoryService ?? ActivityHistoryService();

  List<ActivityHistoryModel> get entries {
    if (_searchQuery.isEmpty) return _entries;
    return _entries
        .where((entry) => entry.title.toLowerCase().contains(_searchQuery))
        .toList();
  }
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _entries = await _activityHistoryService.getForUser(user.id);
    } catch (_) {
      _errorMessage = 'Gagal memuat riwayat aktivitas lokal.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    final query = value.trim().toLowerCase();
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }
}
