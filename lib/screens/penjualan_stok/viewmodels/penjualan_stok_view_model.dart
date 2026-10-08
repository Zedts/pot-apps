import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/lapak_model.dart';
import '../../../core/models/penjualan_model.dart';
import '../../../core/models/stok_lapak_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/viewmodels/base_view_model.dart';
import '../repositories/penjualan_stok_repository.dart';
import '../repositories/penjualan_stok_repository_impl.dart';

/// ViewModel managing state, stock-based product selection, quantity bounds,
/// and sales transactions for the "Stok & Penjualan" module.
class PenjualanStokViewModel extends BaseViewModel {
  final PenjualanStokRepository _repository;
  final CameraService _cameraService;

  UserModel? _user;
  LapakModel? _stall;

  int _selectedTabIndex = 0; // 0: Input Penjualan, 1: Stok Saat Ini

  // Stock-Based Product Selection & Cart State (Tab 1)
  final Map<String, int> _quantities = {};
  bool _isViewingSelectedProducts = false;
  String _selectedPaymentMethod = 'tunai'; // 'tunai' | 'qris' | 'transfer'
  File? _buktiBayarFile;
  String _catatan = '';

  // Current Stock Balances (Tab 1 source & Tab 2 display)
  List<StokLapakModel> _stokList = [];

  // Sales History Modal / Sheet
  List<PenjualanModel> _salesHistory = [];

  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isLoadingHistory = false;
  String? _errorMessage;
  String? _successMessage;

  PenjualanStokViewModel({
    UserModel? currentUser,
    PenjualanStokRepository? repository,
    CameraService? cameraService,
  })  : _user = currentUser,
        _repository = repository ?? PenjualanStokRepositoryImpl(),
        _cameraService = cameraService ?? CameraService();

  // Getters
  UserModel? get user => _user;
  LapakModel? get stall => _stall;
  int get selectedTabIndex => _selectedTabIndex;

  Map<String, int> get quantities => _quantities;
  bool get isViewingSelectedProducts => _isViewingSelectedProducts;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  File? get buktiBayarFile => _buktiBayarFile;
  String get catatan => _catatan;

  List<StokLapakModel> get stokList => _stokList;
  List<PenjualanModel> get salesHistory => _salesHistory;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool get isNonCash => _selectedPaymentMethod != 'tunai';

  // --- Stock-Based Product Selection Filtering & Sorting ---

  /// All products belonging to the user's lapak that have available stock (stok_akhir > 0)
  List<StokLapakModel> get availableStockItems {
    final lapakId = _user?.lapakId ?? '';
    return _stokList.where((item) {
      final belongsToLapak = lapakId.isEmpty || item.lapakId == lapakId;
      return belongsToLapak && item.stokAkhir > 0;
    }).toList();
  }

  /// Available stock items sorted descending by stock quantity (highest stock first)
  List<StokLapakModel> get prioritizedAvailableStockItems {
    final list = List<StokLapakModel>.from(availableStockItems);
    list.sort((a, b) => b.stokAkhir.compareTo(a.stokAkhir));
    return list;
  }

  /// Initial display limited to top 5 products prioritized by available stock
  List<StokLapakModel> get quickPickStockItems {
    return prioritizedAvailableStockItems.take(5).toList();
  }

  /// List of stock items currently selected by the user
  List<StokLapakModel> get selectedStockItems {
    return availableStockItems
        .where((item) => (_quantities[item.produkId] ?? 0) > 0)
        .toList();
  }

  int get selectedProductsCount => selectedStockItems.length;

  bool get hasSelectedProducts => selectedProductsCount > 0;

  /// Total units selected across all products
  int get totalQuantity => _quantities.values.fold(0, (sum, q) => sum + q);

  /// Total calculated price in IDR based on selected stock items and quantities
  int get totalHarga {
    int total = 0;
    for (final item in selectedStockItems) {
      final q = _quantities[item.produkId] ?? 0;
      if (q > 0) {
        total += q * item.productPrice;
      }
    }
    return total;
  }

  /// Whether current transaction is ready for submission
  bool get canSubmit {
    if (totalQuantity <= 0 || _isSubmitting) return false;
    if (isNonCash && _buktiBayarFile == null) return false;
    return true;
  }

  // Stock summary totals for Tab 2
  int get totalStokAwal => _stokList.fold(0, (s, item) => s + item.stokAwal);
  int get totalStokMasuk => _stokList.fold(0, (s, item) => s + item.stokMasuk);
  int get totalStokTerjual => _stokList.fold(0, (s, item) => s + item.stokTerjual);
  int get totalStokAkhir => _stokList.fold(0, (s, item) => s + item.stokAkhir);

  /// Localized dynamic date subtitle (e.g. "Kamis, 8 Oktober 2026")
  String get formattedCurrentDate => DateFormatter.formatCurrentDate();

  /// Initial load: fetch user profile and stock balances
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
        _stall = await _repository.getLapak(lapakId);
        await _loadStokBalances(lapakId);
      }
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
    } catch (e) {
      _errorMessage = 'Gagal memuat data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
      if (index == 1) {
        refreshStok();
      }
    }
  }

  Future<void> _loadStokBalances(String lapakId) async {
    try {
      _stokList = await _repository.getStokLapak(lapakId);
    } catch (e) {
      debugPrint('Error loading stok lapak: $e');
    }
  }

  /// Refresh stock balances from server
  Future<void> refreshStok() async {
    final lapakId = _user?.lapakId ?? '';
    if (lapakId.isEmpty) return;

    try {
      _stokList = await _repository.getStokLapak(lapakId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing stok: $e');
    }
  }

  // --- Two-Phase Product Selection & Stepper Modifiers ---

  void setViewingSelectedProducts(bool value) {
    _isViewingSelectedProducts = value;
    notifyListeners();
  }

  bool isProductSelected(String productId) => (_quantities[productId] ?? 0) > 0;

  int getQuantity(String productId) => _quantities[productId] ?? 0;

  /// Toggles product selection in Phase A. When added, starts with quantity 1.
  void toggleProductSelection(String productId) {
    if (isProductSelected(productId)) {
      _quantities.remove(productId);
    } else {
      final stockItem = availableStockItems.where((s) => s.produkId == productId).firstOrNull;
      if (stockItem != null && stockItem.stokAkhir > 0) {
        _quantities[productId] = 1;
      }
    }
    notifyListeners();
  }

  /// Quick one-tap cancel / removal of an item from the staged cart
  void removeProductSelection(String productId) {
    _quantities.remove(productId);
    if (selectedProductsCount == 0) {
      _isViewingSelectedProducts = false;
    }
    notifyListeners();
  }

  /// Increments selected quantity, strictly bounded by available stock (stok_akhir)
  void incrementQuantity(String productId) {
    final stockItem = availableStockItems.where((s) => s.produkId == productId).firstOrNull;
    if (stockItem == null) return;

    final current = _quantities[productId] ?? 0;
    if (current < stockItem.stokAkhir) {
      _quantities[productId] = current + 1;
      _errorMessage = null;
    } else {
      _errorMessage = 'Jumlah tidak boleh melebihi sisa stok (${stockItem.stokAkhir} pcs)';
    }
    notifyListeners();
  }

  /// Decrements selected quantity. Decrementing below 1 removes product from cart.
  void decrementQuantity(String productId) {
    final current = _quantities[productId] ?? 0;
    if (current > 1) {
      _quantities[productId] = current - 1;
    } else {
      _quantities.remove(productId);
      if (selectedProductsCount == 0) {
        _isViewingSelectedProducts = false;
      }
    }
    notifyListeners();
  }

  void setQuantity(String productId, int qty) {
    final stockItem = availableStockItems.where((s) => s.produkId == productId).firstOrNull;
    if (stockItem == null) return;

    if (qty <= 0) {
      _quantities.remove(productId);
      if (selectedProductsCount == 0) {
        _isViewingSelectedProducts = false;
      }
    } else {
      _quantities[productId] = qty > stockItem.stokAkhir ? stockItem.stokAkhir : qty;
    }
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    if (!isNonCash) {
      _buktiBayarFile = null;
    }
    notifyListeners();
  }

  void setCatatan(String value) {
    _catatan = value;
    notifyListeners();
  }

  void clearCart() {
    _quantities.clear();
    _isViewingSelectedProducts = false;
    _buktiBayarFile = null;
    _catatan = '';
    notifyListeners();
  }

  // --- Payment Proof Capture / Picker ---

  Future<void> pickBuktiBayarCamera() async {
    try {
      final picked = await _cameraService.pickImage(ImageSource.camera);
      if (picked != null) {
        _buktiBayarFile = picked;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Gagal mengambil foto: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> pickBuktiBayarGallery() async {
    try {
      final picked = await _cameraService.pickImage(ImageSource.gallery);
      if (picked != null) {
        _buktiBayarFile = picked;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Gagal memilih foto dari galeri: ${e.toString()}';
      notifyListeners();
    }
  }

  void removeBuktiBayar() {
    _buktiBayarFile = null;
    notifyListeners();
  }

  // --- Sales Transaction Submission ---

  Future<bool> submitPenjualan() async {
    if (!canSubmit) return false;

    final lapakId = _user?.lapakId ?? '';
    if (lapakId.isEmpty) {
      _errorMessage = 'Lapak tidak terdeteksi untuk akun SPG ini.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Build items payload from staged stock items
      final items = <Map<String, dynamic>>[];
      for (final entry in _quantities.entries) {
        if (entry.value > 0) {
          items.add({
            'produk_id': entry.key,
            'qty': entry.value,
          });
        }
      }

      await _repository.createPenjualan(
        lapakId: lapakId,
        metodePembayaran: _selectedPaymentMethod,
        items: items,
        catatan: _catatan,
        buktiFile: _buktiBayarFile,
      );

      _successMessage = 'Transaksi penjualan berhasil dicatat!';
      clearCart();
      await refreshStok();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      return false;
    } catch (e) {
      _errorMessage = 'Gagal mencatat penjualan: ${e.toString()}';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // --- Sales History ---

  Future<void> loadSalesHistory() async {
    final lapakId = _user?.lapakId ?? '';
    if (lapakId.isEmpty) return;

    _isLoadingHistory = true;
    notifyListeners();

    try {
      _salesHistory = await _repository.getSalesHistory(
        lapakId: lapakId,
        spgId: _user?.id,
      );
    } catch (e) {
      debugPrint('Error loading sales history: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
