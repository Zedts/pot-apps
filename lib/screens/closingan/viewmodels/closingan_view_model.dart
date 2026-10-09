import '../../../core/constants/app_constants.dart';
import '../../../core/models/closing_model.dart';
import '../../../core/models/lapak_model.dart';
import '../../../core/models/penerimaan_model.dart';
import '../../../core/models/penjualan_model.dart';
import '../../../core/models/stok_lapak_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/viewmodels/base_view_model.dart';
import '../repositories/closingan_repository.dart';
import '../repositories/closingan_repository_impl.dart';

/// ViewModel managing state, real-time calculations, discrepancy checks,
/// and submission for the Daily Closing ("Closing Harian") screen.
class ClosinganViewModel extends BaseViewModel {
  final ClosinganRepository _repository;

  UserModel? _user;
  LapakModel? _stall;

  List<StokLapakModel> _stokList = [];
  List<PenjualanModel> _todaySales = [];
  List<PenerimaanModel> _todayReceipts = [];
  ClosingModel? _todayClosing;

  int? _stokFisik;
  int? _uangTunaiFisik;
  String _catatan = '';

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  ClosinganViewModel({
    UserModel? currentUser,
    ClosinganRepository? repository,
  })  : _user = currentUser,
        _repository = repository ?? ClosinganRepositoryImpl();

  // Getters
  UserModel? get user => _user;
  LapakModel? get stall => _stall;
  List<StokLapakModel> get stokList => _stokList;
  List<PenjualanModel> get todaySales => _todaySales;
  List<PenerimaanModel> get todayReceipts => _todayReceipts;
  ClosingModel? get todayClosing => _todayClosing;

  int? get rawStokFisik => _stokFisik;
  int? get rawUangTunaiFisik => _uangTunaiFisik;
  String get catatan => _catatan;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool get isAlreadyClosedToday => _todayClosing != null;

  /// Dynamic Indonesian date header subtitle (e.g. "Jumat, 11 September 2026")
  String get formattedCurrentDate => DateFormatter.formatCurrentDate();

  /// ISO Date string for today (YYYY-MM-DD)
  String get todayIsoDate => DateFormatter.formatDateIso(DateTime.now());

  // --- 1. Ringkasan Inventaris (Shift / Hari Ini) ---
  int get stokSistem => _stokList.fold(0, (sum, item) => sum + item.stokAkhir);
  int get totalBarangMasukHariIni => _todayReceipts.fold(0, (sum, item) => sum + item.qtyTerima);
  int get totalStokTerjualHariIni => _todaySales.fold(0, (sum, item) => sum + item.totalQty);
  int get totalStokAwalHariIni => (stokSistem - totalBarangMasukHariIni + totalStokTerjualHariIni).clamp(0, 999999);

  // Canonical getters mapped to today's shift metrics for UI & tests
  int get totalStokAwal => totalStokAwalHariIni;
  int get totalStokMasuk => totalBarangMasukHariIni;
  int get totalStokTerjual => totalStokTerjualHariIni;

  // --- 2. Penjualan Omzet Shift (Strictly for THAT DAY only) ---
  int get tunaiSistem {
    return _todaySales
        .where((s) => s.metodePembayaran.trim().toLowerCase() == 'tunai')
        .fold(0, (sum, s) => sum + s.totalHarga);
  }

  int get qrisSistem {
    return _todaySales
        .where((s) => s.metodePembayaran.trim().toLowerCase() == 'qris')
        .fold(0, (sum, s) => sum + s.totalHarga);
  }

  int get transferSistem {
    return _todaySales
        .where((s) => s.metodePembayaran.trim().toLowerCase() == 'transfer')
        .fold(0, (sum, s) => sum + s.totalHarga);
  }

  int get totalOmset => tunaiSistem + qrisSistem + transferSistem;

  // --- 3. Reconciliation Values & Discrepancies ---
  int get effectiveStokFisik => _stokFisik ?? stokSistem;
  int get effectiveUangTunaiFisik => _uangTunaiFisik ?? totalOmset;

  int get selisihStok => effectiveStokFisik - stokSistem;
  int get selisihUang => effectiveUangTunaiFisik - totalOmset;

  bool get hasStockDiscrepancy => selisihStok != 0;
  bool get hasCashDiscrepancy => selisihUang != 0;
  bool get hasAnyDiscrepancy => hasStockDiscrepancy || hasCashDiscrepancy;

  /// Dynamic hint text under the notes input
  String get dynamicHintText {
    if (hasAnyDiscrepancy) {
      return 'Terdapat selisih stok / uang fisik. Ketuk untuk isi catatan otomatis.';
    }
    return 'Semua stok dan kasir sesuai (catatan opsional).';
  }

  /// Suggested auto-fill note when discrepancy is detected
  String get suggestedDiscrepancyNote {
    final parts = <String>[];
    if (hasStockDiscrepancy) {
      final sign = selisihStok > 0 ? '+$selisihStok' : '$selisihStok';
      parts.add('selisih stok $sign pcs');
    }
    if (hasCashDiscrepancy) {
      final sign = selisihUang > 0 ? '+${CurrencyFormatter.formatRupiah(selisihUang)}' : CurrencyFormatter.formatRupiah(selisihUang);
      parts.add('selisih kasir $sign');
    }
    if (parts.isEmpty) return 'Semua fisik sesuai sistem.';
    return 'Terdapat ${parts.join(" dan ")}.';
  }

  /// Initialize and load all operational data concurrently
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_user == null) {
        try {
          _user = await TokenStorage.getUser();
        } catch (_) {}
      }

      final lapakId = _user?.lapakId ?? '';
      if (lapakId.isNotEmpty) {
        // Concurrently fetch stall metadata, stock list, sales, today's closing, and today's receipts
        final results = await Future.wait([
          _repository.getLapak(lapakId),
          _repository.getStokLapak(lapakId),
          _repository.getSalesHistory(lapakId: lapakId, tanggal: todayIsoDate),
          _repository.getTodayClosing(lapakId: lapakId, tanggal: todayIsoDate),
          _repository.getReceiptHistory(lapakId: lapakId, tanggal: todayIsoDate),
        ]);

        _stall = results[0] as LapakModel?;
        _stokList = results[1] as List<StokLapakModel>;

        final rawSales = results[2] as List<PenjualanModel>;
        final now = DateTime.now();
        // Guarantee strict single-day scoping in local time
        _todaySales = rawSales.where((s) {
          final d = s.tanggal;
          if (d == null) return false;
          return DateFormatter.isSameDay(d, now);
        }).toList();

        _todayClosing = results[3] as ClosingModel?;

        final rawReceipts = results[4] as List<PenerimaanModel>;
        _todayReceipts = rawReceipts.where((r) {
          final d = r.tanggal;
          if (d == null) return false;
          return DateFormatter.isSameDay(d, now);
        }).toList();

        // If today already has a submitted closing, initialize form with submitted values
        if (_todayClosing != null) {
          _stokFisik = _todayClosing!.stokFisik;
          _uangTunaiFisik = _todayClosing!.uangTunaiFisik;
          _catatan = _todayClosing!.catatan;
        } else {
          // Default initial physical inputs to system baseline
          _stokFisik = stokSistem;
          _uangTunaiFisik = totalOmset;
        }
      }
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
    } catch (e) {
      _errorMessage = 'Gagal memuat data closing: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStokFisik(int? value) {
    _stokFisik = value;
    notifyListeners();
  }

  void setUangTunaiFisik(int? value) {
    _uangTunaiFisik = value;
    notifyListeners();
  }

  void setCatatan(String value) {
    _catatan = value;
    notifyListeners();
  }

  /// Refresh screen data on pull-to-refresh
  Future<void> refresh() async {
    await initialize();
  }

  /// Submit closing report to the backend API
  Future<ClosingModel?> submitClosing() async {
    final lapakId = _user?.lapakId ?? _stall?.id ?? '';
    if (lapakId.isEmpty) {
      _errorMessage = 'Lapak belum ditentukan. Tidak dapat mengirim laporan closing.';
      notifyListeners();
      return null;
    }

    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final payload = <String, dynamic>{
        'lapak_id': lapakId.trim(),
        'spg_id': _user?.id ?? '',
        'tanggal': todayIsoDate,
        'stok_sistem': stokSistem,
        'stok_fisik': effectiveStokFisik,
        'total_omset': totalOmset,
        'tunai_sistem': tunaiSistem,
        'qris_sistem': qrisSistem,
        'transfer_sistem': transferSistem,
        'uang_tunai_fisik': effectiveUangTunaiFisik,
        'selisih_stok': selisihStok,
        'selisih_uang': selisihUang,
        'catatan': _catatan.trim(),
        'status': AppConstants.closingPending,
      };

      final result = await _repository.createClosing(payload);
      _todayClosing = result;
      _successMessage = 'Laporan closing berhasil dicatat (${result.statusLabel}).';
      return result;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      return null;
    } catch (e) {
      _errorMessage = 'Gagal mengirim laporan closing: ${e.toString()}';
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
