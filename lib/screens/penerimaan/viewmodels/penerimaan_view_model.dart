import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/activity_history_model.dart';
import '../../../core/models/lapak_model.dart';
import '../../../core/models/penerimaan_model.dart';
import '../../../core/models/pengiriman_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/activity_history_service.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/viewmodels/base_view_model.dart';
import '../repositories/penerimaan_repository.dart';
import '../repositories/penerimaan_repository_impl.dart';

/// ViewModel managing state and operations for Terima Barang (Penerimaan)
class PenerimaanViewModel extends BaseViewModel {
  final PenerimaanRepository _repository;
  final CameraService _cameraService;
  final ActivityHistoryService _activityHistoryService;

  UserModel? _user;
  LapakModel? _stall;

  List<PengirimanModel> _allShipments = [];
  PengirimanModel? _selectedShipment;
  List<ReceivedItemVerification> _verifiedItems = [];

  File? _capturedFotoNota;
  String _catatan = '';

  // Track shipments whose 'diterima_spg' status was explicitly locked via bookmark icon
  final Set<String> _lockedDiterimaStatusIds = {};

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  PenerimaanViewModel({
    PenerimaanRepository? repository,
    CameraService? cameraService,
    ActivityHistoryService? activityHistoryService,
  })  : _repository = repository ?? PenerimaanRepositoryImpl(),
        _cameraService = cameraService ?? CameraService(),
        _activityHistoryService = activityHistoryService ?? ActivityHistoryService();

  // Getters
  UserModel? get user => _user;
  LapakModel? get stall => _stall;

  /// All shipments sorted by status priority:
  /// 1. "Di Jalan", 2. "Diterima SPG", 3. "Draft", 4. "Selesai"
  List<PengirimanModel> get allShipments {
    final list = List<PengirimanModel>.from(_allShipments);
    list.sort(PengirimanModel.compareByPriority);
    return list;
  }

  /// Top 3 prioritized shipments for the "Pilih Barang Pengiriman" table:
  /// 1. "Di Jalan", 2. "Diterima SPG", 3. "Draft", 4. "Selesai"
  List<PengirimanModel> get quickPickShipments {
    final list = List<PengirimanModel>.from(_allShipments);
    list.sort(PengirimanModel.compareByPriority);
    return list.take(3).toList();
  }

  PengirimanModel? get selectedShipment => _selectedShipment;
  List<ReceivedItemVerification> get verifiedItems => _verifiedItems;
  File? get capturedFotoNota => _capturedFotoNota;
  String get catatan => _catatan;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Discrepancy Calculations
  int get totalKirim => _verifiedItems.fold<int>(0, (sum, i) => sum + i.qtyKirim);
  int get totalTerima => _verifiedItems.fold<int>(0, (sum, i) => sum + i.qtyTerima);
  int get totalSelisih =>
      _verifiedItems.where((i) => i.isSelisih).fold<int>(0, (sum, i) => sum + i.selisihDiff.abs());

  List<String> get discrepantItemNames =>
      _verifiedItems.where((i) => i.isSelisih).map((i) => i.namaProduk).toList();

  bool get hasDiscrepancy => totalSelisih > 0;

  /// Dynamic hint text formatted per requirement: hint: selisih $total_selisih pada $barang
  String get discrepancyHintText {
    if (totalSelisih > 0) {
      return 'hint: selisih $totalSelisih pada ${discrepantItemNames.join(", ")}';
    }
    return 'hint: Semua barang sesuai (0 selisih)';
  }

  /// Submit button is strictly disabled until shipment is selected
  bool get canSubmit => _selectedShipment != null && !_isSubmitting;

  /// Formatted date in Indonesian
  String get formattedCurrentDate => DateFormatter.formatCurrentDate();

  /// Initializes user session, stall metadata, and shipment list
  Future<void> init({UserModel? currentUser}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = currentUser ?? await TokenStorage.getUser();
      if (_user == null) {
        _errorMessage = 'Sesi pengguna tidak valid.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (_user!.lapakId != null && _user!.lapakId!.trim().isNotEmpty) {
        _stall = await _repository.getLapak(_user!.lapakId!.trim());
      }

      await refreshShipments();
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
    } catch (e) {
      _errorMessage = 'Gagal memuat data awal: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes available shipments for the stall
  Future<void> refreshShipments() async {
    _user ??= await TokenStorage.getUser();
    if (_user == null || _user!.lapakId == null || _user!.lapakId!.isEmpty) return;

    try {
      final fetched = await _repository.getAvailableShipments(
        lapakId: _user!.lapakId!,
      );
      fetched.sort(PengirimanModel.compareByPriority);
      _allShipments = fetched;
      notifyListeners();
    } catch (e) {
      debugPrint('[PenerimaanViewModel] Failed to refresh shipments: $e');
    }
  }

  /// Fetches single shipment with line items for bottom inspection sheet
  Future<PengirimanModel> getShipmentDetail(String shipmentId) async {
    return await _repository.getShipmentDetail(shipmentId);
  }

  /// Selects a shipment from the inspection sheet and transforms view into verified items
  void selectShipment(PengirimanModel detailedShipment) {
    _selectedShipment = detailedShipment;

    // Initialize item reception verifications (defaults to matching qtyKirim)
    _verifiedItems = detailedShipment.items
        .map((i) => ReceivedItemVerification(item: i, qtyTerima: i.qty))
        .toList();

    _errorMessage = null;
    notifyListeners();
  }

  /// Cancels shipment selection via back arrow button
  void cancelShipmentSelection() {
    _selectedShipment = null;
    _verifiedItems = [];
    _capturedFotoNota = null;
    notifyListeners();
  }

  /// Updates shipment status on backend and updates local lists
  Future<PengirimanModel> updateShipmentStatus({
    required String pengirimanId,
    required String status,
  }) async {
    final index = _allShipments.indexWhere((s) => s.id == pengirimanId);
    final previous = index != -1 ? _allShipments[index] : null;

    // Optimistic UI update
    if (previous != null) {
      final updatedLocally = previous.copyWith(status: status);
      _allShipments[index] = updatedLocally;
      if (_selectedShipment?.id == pengirimanId) {
        _selectedShipment = updatedLocally;
      }
      if (status.toLowerCase() == AppConstants.deliveryDiterimaSPG) {
        _lockedDiterimaStatusIds.add(pengirimanId);
      } else {
        _lockedDiterimaStatusIds.remove(pengirimanId);
      }
      notifyListeners();
    }

    try {
      final persisted = await _repository.updateShipmentStatus(
        pengirimanId: pengirimanId,
        status: status,
      );

      final pIndex = _allShipments.indexWhere((s) => s.id == pengirimanId);
      if (pIndex != -1) {
        _allShipments[pIndex] = persisted;
      }
      if (_selectedShipment?.id == pengirimanId) {
        _selectedShipment = persisted;
      }
      notifyListeners();
      return persisted;
    } catch (e) {
      // Rollback on failure
      if (previous != null && index != -1) {
        _allShipments[index] = previous;
        if (_selectedShipment?.id == pengirimanId) {
          _selectedShipment = previous;
        }
        if (previous.status.toLowerCase() == AppConstants.deliveryDiterimaSPG) {
          _lockedDiterimaStatusIds.add(pengirimanId);
        } else {
          _lockedDiterimaStatusIds.remove(pengirimanId);
        }
        notifyListeners();
      }
      rethrow;
    }
  }

  /// Toggles shipment status between 'dikirim_viar' and 'diterima_spg' and persists via backend
  Future<PengirimanModel?> toggleShipmentStatus(String shipmentId) async {
    final index = _allShipments.indexWhere((s) => s.id == shipmentId);
    if (index == -1) return null;

    final current = _allShipments[index];
    final nextStatus = (current.status.toLowerCase() == AppConstants.deliveryDiterimaSPG)
        ? AppConstants.deliveryDikirimViar
        : AppConstants.deliveryDiterimaSPG;

    return await updateShipmentStatus(
      pengirimanId: shipmentId,
      status: nextStatus,
    );
  }

  /// Updates a shipment with real backend persistence
  Future<PengirimanModel> updateShipment(PengirimanModel updated) async {
    return await updateShipmentStatus(
      pengirimanId: updated.id,
      status: updated.status,
    );
  }

  /// Persists/locks status as 'diterima_spg' via the bookmark/save icon button
  void lockDiterimaStatus(String shipmentId) {
    _lockedDiterimaStatusIds.add(shipmentId);
    notifyListeners();
  }

  bool isStatusLocked(String shipmentId) => _lockedDiterimaStatusIds.contains(shipmentId);

  /// Updates received count for an item in verified list
  void updateItemQtyTerima(int index, int newQty) {
    if (index >= 0 && index < _verifiedItems.length) {
      _verifiedItems[index].qtyTerima = newQty < 0 ? 0 : newQty;
      notifyListeners();
    }
  }

  /// Updates remarks text
  void setCatatan(String val) {
    _catatan = val;
    notifyListeners();
  }

  /// Captures photo proof of nota using camera (rear) or gallery
  Future<void> captureFotoNota({ImageSource source = ImageSource.camera}) async {
    final photo = await _cameraService.takeDocumentPhoto(source: source);
    if (photo != null) {
      _capturedFotoNota = photo;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Sets picked foto nota file directly (e.g. for testing)
  void setFotoNota(File file) {
    _capturedFotoNota = file;
    notifyListeners();
  }

  /// Clears the captured foto nota
  void clearFotoNota() {
    _capturedFotoNota = null;
    notifyListeners();
  }

  /// Submits the 2-step penerimaan creation & foto nota upload
  Future<PenerimaanModel?> submitPenerimaan() async {
    if (_selectedShipment == null) {
      _errorMessage = 'Pilih pengiriman terlebih dahulu.';
      notifyListeners();
      return null;
    }

    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _repository.createPenerimaan(
        pengirimanId: _selectedShipment!.id,
        qtyTerima: totalTerima,
        catatan: _catatan,
        photoFile: _capturedFotoNota,
      );

      await _activityHistoryService.record(
        ActivityHistoryModel(
          userId: _user?.id ?? result.spgId ?? '',
          lapakId: _user?.lapakId,
          activityType: AppConstants.activityReceiveGoods,
          title: 'Penerimaan Barang',
          description: '${result.qtyTerima} barang diterima (${result.status.toUpperCase()})',
          occurredAt: result.tanggal ?? result.createdAt ?? DateTime.now(),
          referenceId: result.id,
        ),
      );

      _successMessage = 'Penerimaan barang berhasil disimpan.';

      // Reset selection state & refresh shipments
      _selectedShipment = null;
      _verifiedItems = [];
      _capturedFotoNota = null;
      _catatan = '';

      await refreshShipments();
      return result;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      return null;
    } catch (e) {
      _errorMessage = 'Gagal menyimpan penerimaan: $e';
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
