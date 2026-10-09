import '../../../core/constants/api_endpoints.dart';
import '../../../core/models/closing_model.dart';
import '../../../core/models/lapak_model.dart';
import '../../../core/models/penerimaan_model.dart';
import '../../../core/models/penjualan_model.dart';
import '../../../core/models/stok_lapak_model.dart';
import '../../../core/network/api_client.dart';
import 'closingan_repository.dart';

/// Concrete implementation of [ClosinganRepository] communicating with POT backend API.
class ClosinganRepositoryImpl implements ClosinganRepository {
  final ApiClient _apiClient;

  ClosinganRepositoryImpl({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<StokLapakModel>> getStokLapak(String lapakId) async {
    final queryParams = <String, dynamic>{
      'lapak_id': lapakId.trim(),
    };

    final response = await _apiClient.get(
      ApiEndpoints.stokLapak,
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final rawList = response['data'] as List<dynamic>? ?? [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map((item) => StokLapakModel.fromJson(item))
        .toList();
  }

  @override
  Future<List<PenjualanModel>> getSalesHistory({
    required String lapakId,
    String? tanggal,
    String? spgId,
  }) async {
    final queryParams = <String, dynamic>{
      'lapak_id': lapakId.trim(),
    };
    if (tanggal != null && tanggal.trim().isNotEmpty) {
      queryParams['tanggal'] = tanggal.trim();
    }
    if (spgId != null && spgId.trim().isNotEmpty) {
      queryParams['spg_id'] = spgId.trim();
    }

    final response = await _apiClient.get(
      ApiEndpoints.penjualan,
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final rawList = response['data'] as List<dynamic>? ?? [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map((item) => PenjualanModel.fromJson(item))
        .toList();
  }

  @override
  Future<List<PenerimaanModel>> getReceiptHistory({
    required String lapakId,
    String? tanggal,
  }) async {
    final queryParams = <String, dynamic>{
      'lapak_id': lapakId.trim(),
    };
    if (tanggal != null && tanggal.trim().isNotEmpty) {
      queryParams['tanggal'] = tanggal.trim();
    }

    final response = await _apiClient.get(
      ApiEndpoints.penerimaan,
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final rawList = response['data'] as List<dynamic>? ?? [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map((item) => PenerimaanModel.fromJson(item))
        .toList();
  }

  @override
  Future<LapakModel?> getLapak(String lapakId) async {
    if (lapakId.isEmpty) return null;
    try {
      final response = await _apiClient.get(
        ApiEndpoints.lapakById(lapakId),
        requiresAuth: true,
      );
      final data = response['data'] as Map<String, dynamic>;
      return LapakModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ClosingModel> createClosing(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.closing,
      body: payload,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return ClosingModel.fromJson(data);
  }

  @override
  Future<List<ClosingModel>> getClosingHistory({
    required String lapakId,
    String? spgId,
    String? tanggal,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'lapak_id': lapakId.trim(),
    };
    if (spgId != null && spgId.trim().isNotEmpty) {
      queryParams['spg_id'] = spgId.trim();
    }
    if (tanggal != null && tanggal.trim().isNotEmpty) {
      queryParams['tanggal'] = tanggal.trim();
    }
    if (status != null && status.trim().isNotEmpty) {
      queryParams['status'] = status.trim().toLowerCase();
    }

    final response = await _apiClient.get(
      ApiEndpoints.closing,
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final rawList = response['data'] as List<dynamic>? ?? [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map((item) => ClosingModel.fromJson(item))
        .toList();
  }

  @override
  Future<ClosingModel?> getTodayClosing({
    required String lapakId,
    required String tanggal,
  }) async {
    final list = await getClosingHistory(
      lapakId: lapakId,
      tanggal: tanggal,
    );
    if (list.isNotEmpty) {
      return list.first;
    }
    return null;
  }
}
