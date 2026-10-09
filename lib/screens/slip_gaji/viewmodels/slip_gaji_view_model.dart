import '../../../core/constants/app_constants.dart';
import '../../../core/models/payroll_model.dart';
import '../../../core/models/slip_gaji_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/network/api_error_mapper.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/viewmodels/base_view_model.dart';
import '../repositories/slip_gaji_repository.dart';
import '../repositories/slip_gaji_repository_impl.dart';

/// State machine managing the Slip Gaji screen state.
///
/// Keeps state intentionally lean:
/// - Only payrolls for the current user with `status = published` are fetched.
/// - Slip Gaji PDF document record is loaded lazily on-demand when the user
///   requests the detail view, avoiding N+1 document fetches for history rows.
class SlipGajiViewModel extends BaseViewModel {
  final SlipGajiRepository _repository;

  SlipGajiViewModel({
    SlipGajiRepository? repository,
    UserModel? currentUser,
  })  : _repository = repository ?? SlipGajiRepositoryImpl(),
        _user = currentUser;

  UserModel? _user;
  List<PayrollModel> _payrolls = [];
  PayrollModel? _selectedPayroll;
  SlipGajiModel? _selectedSlipGaji;
  bool _isLoading = false;
  bool _isOpeningDetail = false;
  String? _errorMessage;

  UserModel? get user => _user;
  List<PayrollModel> get payrolls => List.unmodifiable(_payrolls);
  PayrollModel? get selectedPayroll => _selectedPayroll;
  SlipGajiModel? get selectedSlipGaji => _selectedSlipGaji;
  bool get isLoading => _isLoading;
  bool get isOpeningDetail => _isOpeningDetail;
  String? get errorMessage => _errorMessage;

  bool get hasPayrollData => _selectedPayroll != null;
  bool get hasError => _errorMessage != null && _errorMessage!.trim().isNotEmpty;

  String get formattedCurrentDate => DateFormatter.formatCurrentDate();

  String get formattedSelectedPeriode {
    return _selectedPayroll?.formattedPeriode ?? 'Pilih Periode';
  }

  int get gajiPokok => _selectedPayroll?.gajiPokok ?? 0;
  int get bonusPenjualan => _selectedPayroll?.bonusPenjualan ?? 0;
  int get lembur => _selectedPayroll?.lembur ?? 0;
  int get potongan => _selectedPayroll?.potongan ?? 0;
  int get kasbon => _selectedPayroll?.kasbon ?? 0;
  int get totalGaji => _selectedPayroll?.totalGaji ?? 0;
  int get hariKerja => _selectedPayroll?.hariKerja ?? 0;
  int get totalPenjualan => _selectedPayroll?.totalPenjualan ?? 0;

  List<PayrollModel> get filteredRiwayatGaji {
    final selected = _selectedPayroll?.periode;
    if (selected == null || selected.isEmpty) return List.unmodifiable(_payrolls);
    return _payrolls.where((item) => item.periode == selected).toList();
  }

  List<String> get availablePeriods {
    return _payrolls.map((p) => p.periode).toList();
  }

  void _setLoading(bool value) {
    if (isDisposed) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setOpening(bool value) {
    if (isDisposed) return;
    _isOpeningDetail = value;
    notifyListeners();
  }

  void _setError(String? message) {
    if (isDisposed) return;
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> initialize() async {
    _setLoading(true);
    _setError(null);
    try {
      _user ??= await TokenStorage.getUser();
      if (_user == null) {
        throw const ApiException(
          statusCode: 401,
          rawMessage: 'missing user',
          userMessage: 'Sesi login Anda telah berakhir. Silakan masuk kembali.',
        );
      }

      final payrolls = await _repository.getPayrolls(
        userId: _user!.id,
        status: AppConstants.payrollPublished,
      );

      payrolls.sort((a, b) => b.periodeDateTime.compareTo(a.periodeDateTime));
      _payrolls = payrolls;
      _selectedPayroll = payrolls.isNotEmpty ? payrolls.first : null;
      _selectedSlipGaji = null;
    } on ApiException catch (e) {
      _setError(e.userMessage);
    } catch (_) {
      _setError(ApiErrorMapper.defaultErrorMessage);
    } finally {
      _setLoading(false);
    }
  }

  void selectPeriode(String periode) {
    final match = _payrolls.where((p) => p.periode == periode.trim());
    if (match.isEmpty) return;
    _selectedPayroll = match.first;
    _selectedSlipGaji = null;
    notifyListeners();
  }

  void selectPayroll(PayrollModel payroll) {
    _selectedPayroll = payroll;
    _selectedSlipGaji = null;
    notifyListeners();
  }

  Future<SlipGajiModel?> loadSlipGajiForSelected() async {
    final payroll = _selectedPayroll;
    if (payroll == null) return null;
    _setOpening(true);
    try {
      final doc = await _repository.getSlipGajiByPayrollId(payroll.id);
      if (isDisposed) return doc;
      _selectedSlipGaji = doc;
      notifyListeners();
      return doc;
    } on ApiException catch (_) {
      if (isDisposed) return null;
      _selectedSlipGaji = null;
      notifyListeners();
      return null;
    } catch (_) {
      if (isDisposed) return null;
      _selectedSlipGaji = null;
      notifyListeners();
      return null;
    } finally {
      _setOpening(false);
    }
  }
}
