import '../../../core/constants/api_endpoints.dart';
import '../../../core/models/payroll_model.dart';
import '../../../core/models/slip_gaji_model.dart';
import '../../../core/network/api_client.dart';
import 'slip_gaji_repository.dart';

/// Concrete implementation of [SlipGajiRepository] communicating with POT backend API.
class SlipGajiRepositoryImpl implements SlipGajiRepository {
  final ApiClient _apiClient;

  SlipGajiRepositoryImpl({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<PayrollModel>> getPayrolls({
    String? userId,
    String? periode,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (userId != null && userId.trim().isNotEmpty) {
      queryParams['user_id'] = userId.trim();
    }
    if (periode != null && periode.trim().isNotEmpty) {
      queryParams['periode'] = periode.trim();
    }
    if (status != null && status.trim().isNotEmpty) {
      queryParams['status'] = status.trim().toLowerCase();
    }

    final response = await _apiClient.get(
      ApiEndpoints.payroll,
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final rawList = response['data'] as List<dynamic>? ?? [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map((item) => PayrollModel.fromJson(item))
        .toList();
  }

  @override
  Future<SlipGajiModel?> getSlipGajiByPayrollId(String payrollId) async {
    if (payrollId.trim().isEmpty) return null;

    final queryParams = <String, dynamic>{
      'payroll_id': payrollId.trim(),
    };

    final response = await _apiClient.get(
      ApiEndpoints.slipGaji,
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final rawList = response['data'] as List<dynamic>? ?? [];
    final candidates = rawList.whereType<Map<String, dynamic>>();
    if (candidates.isEmpty) return null;
    return SlipGajiModel.fromJson(candidates.first);
  }
}
