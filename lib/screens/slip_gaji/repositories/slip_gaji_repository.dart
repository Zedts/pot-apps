import '../../../core/models/payroll_model.dart';
import '../../../core/models/slip_gaji_model.dart';

/// Abstract repository contract for Salary Slip (Slip Gaji) screen data operations.
///
/// Only declares the operations actually exercised by the Slip Gaji user flow
/// to avoid unused interface bloat.
abstract class SlipGajiRepository {
  /// Fetch payroll records filtered by user, period, and/or status.
  ///
  /// Employee self-serve view should always pass [userId] so the backend
  /// returns only records belonging to the authenticated user.
  Future<List<PayrollModel>> getPayrolls({
    String? userId,
    String? periode,
    String? status,
  });

  /// Fetch the Slip Gaji PDF document record associated with a specific payroll.
  ///
  /// Returns `null` when no document has been uploaded for the given payroll.
  Future<SlipGajiModel?> getSlipGajiByPayrollId(String payrollId);
}
