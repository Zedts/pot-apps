import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/models/lapak_model.dart';
import '../../../core/models/stok_lapak_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/date_formatter.dart';
import '../repositories/penjualan_stok_repository.dart';
import '../repositories/penjualan_stok_repository_impl.dart';

/// ViewModel managing stall-to-stall stock transfer Delivery Order (DO) flow.
class StokTransferViewModel extends ChangeNotifier {
  final PenjualanStokRepository _repository;
  UserModel? _user;
  LapakModel? _originStall;

  // Flow & Step State
  int _currentStep = 0; // 0: Select Products, 1: Quantity Allocation, 2: DO Details & Review
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;
  String _searchQuery = '';

  // Origin Stall Stock (Source)
  List<StokLapakModel> _allOriginStock = [];
  final Map<String, int> _quantities = {};

  // Destination Stalls & Courier
  List<LapakModel> _destinationStalls = [];
  LapakModel? _selectedDestinationStall;
  UserModel? _selectedCourier;

  // Transfer Date & Digital Signature
  DateTime _transferDate = DateTime.now();
  File? _ttdPengirimFile;

  StokTransferViewModel({
    UserModel? currentUser,
    LapakModel? initialOriginStall,
    PenjualanStokRepository? repository,
  })  : _user = currentUser,
        _selectedCourier = currentUser,
        _originStall = initialOriginStall,
        _repository = repository ?? PenjualanStokRepositoryImpl();

  // Getters
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get searchQuery => _searchQuery;

  UserModel? get currentUser => _user;
  LapakModel? get originStall => _originStall;
  DateTime get transferDate => _transferDate;
  File? get ttdPengirimFile => _ttdPengirimFile;

  List<LapakModel> get destinationStalls => _destinationStalls;
  LapakModel? get selectedDestinationStall => _selectedDestinationStall;

  List<UserModel> get couriers => _user != null ? [_user!] : [];
  UserModel? get selectedCourier => _selectedCourier ?? _user;

  Map<String, int> get quantities => _quantities;

  /// Products currently held by origin stall that have available stock (stokAkhir > 0)
  List<StokLapakModel> get availableOriginStock =>
      _allOriginStock.where((item) => item.stokAkhir > 0).toList();

  /// Filtered origin stock matching search query
  List<StokLapakModel> get filteredOriginStock {
    final available = availableOriginStock;
    if (_searchQuery.trim().isEmpty) return available;
    final q = _searchQuery.trim().toLowerCase();
    return available.where((item) => item.productName.toLowerCase().contains(q)).toList();
  }

  /// Whether a specific product is currently selected for transfer
  bool isProductSelected(String productId) => _quantities.containsKey(productId);

  /// Toggle selection for a product: adds with default qty=1 or removes from transfer
  void toggleProductSelection(String productId) {
    if (_quantities.containsKey(productId)) {
      _quantities.remove(productId);
    } else {
      _quantities[productId] = 1;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Items selected for transfer with quantity > 0
  List<StokLapakModel> get selectedTransferItems =>
      _allOriginStock.where((item) => (_quantities[item.produkId] ?? 0) > 0).toList();

  /// Total count of unique products selected
  int get selectedProductsCount => _quantities.length;

  /// Total units to be transferred across all selected items
  int get totalTransferUnits => _quantities.values.fold(0, (sum, q) => sum + q);

  /// Formatted date in Indonesian
  String get formattedTransferDate => DateFormatter.formatFullDate(_transferDate);

  /// Validation: can proceed to Step 1 (Quantity Allocation)
  bool get canProceedToStep2 => selectedProductsCount > 0;

  /// Validation: can proceed to Step 2 (Destination, Courier, TTD)
  bool get canProceedToStep3 => totalTransferUnits > 0;

  /// Validation: can submit transfer DO
  bool get canSubmit {
    return totalTransferUnits > 0 &&
        _selectedDestinationStall != null &&
        _selectedCourier != null &&
        !_isSubmitting;
  }

  /// Initialize metadata, stock list, stalls list, and courier staff list
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user ??= await TokenStorage.getUser();
      final originId = _originStall?.id ?? _user?.lapakId ?? '';

      if (originId.isEmpty) {
        _errorMessage = 'Outlet asal belum ditetapkan untuk akun ini.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Parallel fetch: origin stall details, origin stock, all stalls
      final results = await Future.wait([
        _originStall == null ? _repository.getLapak(originId) : Future.value(_originStall),
        _repository.getStokLapak(originId),
        _repository.getAllLapak(),
      ]);

      _originStall = results[0] as LapakModel?;
      _allOriginStock = results[1] as List<StokLapakModel>;

      final allStalls = results[2] as List<LapakModel>;
      // Exclude origin stall from destination list to strictly prevent self-transfer
      _destinationStalls = allStalls.where((l) => l.id != originId).toList();

      // Automatically assign courier to the logged-in user creating the transfer DO
      _selectedCourier = _user;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
    } catch (e) {
      _errorMessage = 'Gagal memuat data transfer stok: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Step Navigation ---

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep == 0 && canProceedToStep2) {
      _currentStep = 1;
      notifyListeners();
    } else if (_currentStep == 1 && canProceedToStep3) {
      _currentStep = 2;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // --- Quantity Modifiers ---

  void updateQuantity(String productId, int newQty, int maxStock) {
    if (newQty <= 0) {
      _quantities.remove(productId);
    } else {
      _quantities[productId] = newQty > maxStock ? maxStock : newQty;
    }
    notifyListeners();
  }

  void incrementQuantity(String productId, int maxStock) {
    final current = _quantities[productId] ?? 0;
    if (current < maxStock) {
      _quantities[productId] = current + 1;
      notifyListeners();
    }
  }

  void decrementQuantity(String productId) {
    final current = _quantities[productId] ?? 0;
    if (current > 1) {
      _quantities[productId] = current - 1;
    } else {
      _quantities.remove(productId);
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    _quantities.remove(productId);
    notifyListeners();
  }

  // --- Field Setters ---

  void setSelectedDestinationStall(LapakModel? stall) {
    _selectedDestinationStall = stall;
    notifyListeners();
  }

  void setSelectedCourier(UserModel? courier) {
    _selectedCourier = courier;
    notifyListeners();
  }

  void setTransferDate(DateTime date) {
    _transferDate = date;
    notifyListeners();
  }

  void setTtdPengirimFile(File? file) {
    _ttdPengirimFile = file;
    notifyListeners();
  }

  // --- Submission ---

  /// Submits stock transfer Delivery Order (DO) in Draft status.
  /// Returns `true` if creation succeeded.
  Future<bool> submitTransfer() async {
    if (!canSubmit) return false;

    final originId = _originStall?.id ?? _user?.lapakId ?? '';
    final destId = _selectedDestinationStall!.id;
    final courierId = _selectedCourier!.id;

    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final itemsPayload = selectedTransferItems.map((item) {
        final qty = _quantities[item.produkId] ?? 0;
        return {
          'produk_id': item.produkId,
          'qty': qty,
        };
      }).toList();

      await _repository.createTransferPengiriman(
        asalLapakId: originId,
        tujuanLapakId: destId,
        pengirimId: courierId,
        tanggal: _transferDate,
        items: itemsPayload,
        ttdPengirimFile: _ttdPengirimFile,
      );

      _successMessage = 'Surat Jalan Transfer Stok berhasil dibuat dalam status Draft.';
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      return false;
    } catch (e) {
      _errorMessage = 'Gagal membuat transfer stok: $e';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
