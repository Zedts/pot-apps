import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/models/lapak_model.dart';
import '../../../core/models/penjualan_model.dart';
import '../../../core/models/stok_lapak_model.dart';
import '../../../core/network/api_client.dart';
import 'penjualan_stok_repository.dart';

/// Concrete implementation of [PenjualanStokRepository] interacting with POT backend API.
class PenjualanStokRepositoryImpl implements PenjualanStokRepository {
  final ApiClient _apiClient;

  PenjualanStokRepositoryImpl({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

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
  Future<PenjualanModel> createPenjualan({
    required String lapakId,
    required String metodePembayaran,
    required List<Map<String, dynamic>> items,
    String? catatan,
    File? buktiFile,
  }) async {
    final normalizedMetode = metodePembayaran.trim().toLowerCase();

    // If non-cash with proof photo, send as atomic multipart request in one roundtrip
    if (buktiFile != null && normalizedMetode != 'tunai') {
      final fields = <String, String>{
        'lapak_id': lapakId.trim(),
        'metode_pembayaran': normalizedMetode,
        'tanggal': DateTime.now().toUtc().toIso8601String(),
        'items': jsonEncode(items),
      };
      if (catatan != null && catatan.trim().isNotEmpty) {
        fields['catatan'] = catatan.trim();
      }

      final response = await _apiClient.postMultipart(
        ApiEndpoints.penjualan,
        fields: fields,
        fileField: 'bukti_bayar',
        file: buktiFile,
        contentType: MediaType('image', 'jpeg'),
        requiresAuth: true,
      );

      return PenjualanModel.fromJson(response['data'] as Map<String, dynamic>);
    }

    // Default JSON payload for cash transactions or transactions without proof
    final body = <String, dynamic>{
      'lapak_id': lapakId.trim(),
      'metode_pembayaran': normalizedMetode,
      'tanggal': DateTime.now().toUtc().toIso8601String(),
      'items': items,
    };
    if (catatan != null && catatan.trim().isNotEmpty) {
      body['catatan'] = catatan.trim();
    }

    final response = await _apiClient.post(
      ApiEndpoints.penjualan,
      body: body,
      requiresAuth: true,
    );

    return PenjualanModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<PenjualanModel> uploadBuktiBayar({
    required String penjualanId,
    required File photoFile,
  }) async {
    final response = await _apiClient.postMultipart(
      ApiEndpoints.penjualanBuktiBayar(penjualanId),
      fileField: 'bukti_bayar',
      file: photoFile,
      contentType: MediaType('image', 'jpeg'),
      requiresAuth: true,
    );
    final data = response['data'] as Map<String, dynamic>;
    return PenjualanModel.fromJson(data);
  }

  @override
  Future<List<PenjualanModel>> getSalesHistory({
    required String lapakId,
    String? spgId,
  }) async {
    final queryParams = <String, dynamic>{
      'lapak_id': lapakId.trim(),
    };
    if (spgId != null && spgId.isNotEmpty) {
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
