import '../../../core/models/closing_model.dart';
import '../../../core/models/lapak_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/viewmodels/base_view_model.dart';
import '../repositories/closingan_repository.dart';
import '../repositories/closingan_repository_impl.dart';

/// ViewModel managing state, filter chips, and data retrieval for the
/// Closing History Archive screen ("Riwayat Closing").
class ClosingHistoryViewModel extends BaseViewModel {
  final ClosinganRepository _repository;
  UserModel? _user;
  LapakModel? _stall;

  List<ClosingModel> _history = [];
  String _selectedFilter = 'semua'; // 'semua' | 'pending' | 'terverifikasi' | 'perlu_revisi'
  bool _isLoading = true;
  String? _errorMessage;

  ClosingHistoryViewModel({
    UserModel? currentUser,
    LapakModel? currentStall,
    ClosinganRepository? repository,
  })  : _user = currentUser,
        _stall = currentStall,
        _repository = repository ?? ClosinganRepositoryImpl();

  // Getters
  UserModel? get user => _user;
  LapakModel? get stall => _stall;
  List<ClosingModel> get history => _history;
  String get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<ClosingModel> get filteredHistory {
    if (_selectedFilter == 'semua') return _history;
    return _history
        .where((c) => c.status.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  int get totalCount => _history.length;
  int get pendingCount => _history.where((c) => c.isPending).length;
  int get terverifikasiCount => _history.where((c) => c.isTerverifikasi).length;
  int get perluRevisiCount => _history.where((c) => c.isPerluRevisi).length;
  int get balancedCount => _history.where((c) => !c.hasAnyDiscrepancy).length;
  int get discrepantCount => _history.where((c) => c.hasAnyDiscrepancy).length;

  Future<void> initialize() async {
    await fetchHistory();
  }

  Future<void> fetchHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_user == null) {
        try {
          _user = await TokenStorage.getUser();
        } catch (_) {}
      }

      final lapakId = _user?.lapakId ?? _stall?.id ?? '';
      if (lapakId.isNotEmpty) {
        _stall ??= await _repository.getLapak(lapakId);

        _history = await _repository.getClosingHistory(
          lapakId: lapakId,
          spgId: _user?.id,
        );
      }
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
    } catch (e) {
      _errorMessage = 'Gagal memuat riwayat closing: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }
}
