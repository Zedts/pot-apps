import 'dart:io';
import 'package:http_parser/http_parser.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/models/lapak_model.dart';
import '../../../core/models/penerimaan_model.dart';
import '../../../core/models/pengiriman_model.dart';
import '../../../core/network/api_client.dart';
import 'penerimaan_repository.dart';

/// Concrete implementation of [PenerimaanRepository] interacting with POT backend API.
class PenerimaanRepositoryImpl implements PenerimaanRepository {
  final ApiClient _apiClient;

  PenerimaanRepositoryImpl({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<PengirimanModel>> getAvailableShipments({
    required String lapakId,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'lapak_id': lapakId.trim(),
    };
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status.trim();
    }

    final response = await _apiClient.get(
      ApiEndpoints.pengiriman,
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final rawList = response['data'] as List<dynamic>? ?? [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map((item) => PengirimanModel.fromJson(item))
        .toList();
  }

  @override
  Future<PengirimanModel> getShipmentDetail(String id) async {
    final response = await _apiClient.get(
      ApiEndpoints.pengirimanById(id),
      requiresAuth: true,
    );
    final data = response['data'] as Map<String, dynamic>;
    return PengirimanModel.fromJson(data);
  }

  @override
  Future<PengirimanModel> updateShipmentStatus({
    required String pengirimanId,
    required String status,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.pengirimanById(pengirimanId),
      body: {'status': status.trim()},
      requiresAuth: true,
    );
    final data = response['data'] as Map<String, dynamic>;
    return PengirimanModel.fromJson(data);
  }

  @override
  Future<PenerimaanModel> createPenerimaan({
    required String pengirimanId,
    required int qtyTerima,
    String? catatan,
    File? photoFile,
  }) async {
    final body = <String, dynamic>{
      'pengiriman_id': pengirimanId.trim(),
      'qty_terima': qtyTerima,
    };
    if (catatan != null && catatan.trim().isNotEmpty) {
      body['catatan'] = catatan.trim();
    }

    // Step 1: Create receipt record
    final response = await _apiClient.post(
      ApiEndpoints.penerimaan,
      body: body,
      requiresAuth: true,
    );

    var created = PenerimaanModel.fromJson(response['data'] as Map<String, dynamic>);

    // Step 2: Upload physical foto nota if attached
    if (photoFile != null) {
      created = await uploadNota(penerimaanId: created.id, photoFile: photoFile);
    }

    return created;
  }

  @override
  Future<PenerimaanModel> uploadNota({
    required String penerimaanId,
    required File photoFile,
  }) async {
    final response = await _apiClient.postMultipart(
      ApiEndpoints.penerimaanNota(penerimaanId),
      fileField: 'nota',
      file: photoFile,
      contentType: MediaType('image', 'jpeg'),
      requiresAuth: true,
    );
    final data = response['data'] as Map<String, dynamic>;
    return PenerimaanModel.fromJson(data);
  }

  @override
  Future<List<PenerimaanModel>> getReceiptHistory({
    String? spgId,
    String? lapakId,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (spgId != null && spgId.isNotEmpty) queryParams['spg_id'] = spgId.trim();
    if (status != null && status.isNotEmpty) queryParams['status'] = status.trim();

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
}
