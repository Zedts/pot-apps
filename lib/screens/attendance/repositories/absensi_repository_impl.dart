import 'dart:io';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/absensi_model.dart';
import '../../../core/models/lapak_model.dart';
import '../../../core/network/api_client.dart';
import 'absensi_repository.dart';

/// Concrete implementation of [AbsensiRepository] communicating with POT backend API.
class AbsensiRepositoryImpl implements AbsensiRepository {
  final ApiClient _apiClient;

  AbsensiRepositoryImpl({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  @override
  Future<AbsensiModel> clockIn({
    required String lapakId,
    required double latitude,
    required double longitude,
    File? photoFile,
    String? keterangan,
    String status = AppConstants.absenHadir,
  }) async {
    final body = <String, dynamic>{
      'lapak_id': lapakId,
      'status': status,
      'lokasi_masuk': {
        'latitude': latitude,
        'longitude': longitude,
      },
    };
    if (status != AppConstants.absenIzin) {
      body['jam_masuk'] = DateTime.now().toUtc().toIso8601String();
    }
    if (keterangan != null && keterangan.trim().isNotEmpty) {
      body['keterangan'] = keterangan.trim();
    }

    final response = await _apiClient.post(
      ApiEndpoints.absensi,
      body: body,
      requiresAuth: true,
    );

    var created = AbsensiModel.fromJson(response['data'] as Map<String, dynamic>);

    // If photo is provided, upload via absensiFoto endpoint
    if (photoFile != null) {
      created = await uploadPhoto(absensiId: created.id, photoFile: photoFile);
    }

    return created;
  }

  @override
  Future<AbsensiModel> uploadPhoto({
    required String absensiId,
    required File photoFile,
  }) async {
    final response = await _apiClient.postMultipart(
      ApiEndpoints.absensiFoto(absensiId),
      fileField: 'foto',
      file: photoFile,
      requiresAuth: true,
    );
    final data = response['data'] as Map<String, dynamic>;
    return AbsensiModel.fromJson(data);
  }

  @override
  Future<AbsensiModel> clockOut(String absensiId) async {
    final response = await _apiClient.patch(
      ApiEndpoints.absensiPulang(absensiId),
      body: {'jam_pulang': DateTime.now().toUtc().toIso8601String()},
      requiresAuth: true,
    );
    final data = response['data'] as Map<String, dynamic>;
    return AbsensiModel.fromJson(data);
  }

  @override
  Future<List<AbsensiModel>> getHistory({
    String? userId,
    String? lapakId,
    String? tanggal,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (userId != null && userId.isNotEmpty) queryParams['user_id'] = userId;
    if (lapakId != null && lapakId.isNotEmpty) queryParams['lapak_id'] = lapakId;
    if (tanggal != null && tanggal.isNotEmpty) queryParams['tanggal'] = tanggal;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final response = await _apiClient.get(
      ApiEndpoints.absensi,
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final rawList = response['data'] as List<dynamic>? ?? [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map((item) => AbsensiModel.fromJson(item))
        .toList();
  }

  @override
  Future<AbsensiModel> getDetail(String id) async {
    final response = await _apiClient.get(
      ApiEndpoints.absensiById(id),
      requiresAuth: true,
    );
    final data = response['data'] as Map<String, dynamic>;
    return AbsensiModel.fromJson(data);
  }

  @override
  Future<AbsensiModel?> getTodayAttendance({
    required String userId,
    required String tanggal,
  }) async {
    final list = await getHistory(userId: userId, tanggal: tanggal);
    if (list.isEmpty) return null;
    return list.first;
  }

  @override
  Future<LapakModel?> getLapak(String lapakId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.lapakById(lapakId),
        requiresAuth: true,
      );
      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        return LapakModel.fromJson(data);
      }
    } catch (_) {
      // Return null on failure
    }
    return null;
  }
}
