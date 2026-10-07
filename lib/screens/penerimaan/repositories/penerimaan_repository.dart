import 'dart:io';
import '../../../core/models/lapak_model.dart';
import '../../../core/models/penerimaan_model.dart';
import '../../../core/models/pengiriman_model.dart';

/// Abstract contract for Goods Receipt (Penerimaan) and Read-Only Shipment Discovery
abstract class PenerimaanRepository {
  /// Fetches available shipments for a stall (strictly read-only for SPG).
  Future<List<PengirimanModel>> getAvailableShipments({
    required String lapakId,
    String? status,
  });

  /// Fetches full shipment details and line-item manifest by shipment ID (strictly read-only).
  Future<PengirimanModel> getShipmentDetail(String id);

  /// Updates shipment status on the backend (real persistent change across refreshes).
  Future<PengirimanModel> updateShipmentStatus({
    required String pengirimanId,
    required String status,
  });

  /// Records receipt of a shipment with optional 2-step foto nota attachment.
  Future<PenerimaanModel> createPenerimaan({
    required String pengirimanId,
    required int qtyTerima,
    String? catatan,
    File? photoFile,
  });

  /// Uploads physical foto nota to Cloudinary via backend endpoint.
  Future<PenerimaanModel> uploadNota({
    required String penerimaanId,
    required File photoFile,
  });

  /// Fetches historical receipts archive for the SPG / stall.
  Future<List<PenerimaanModel>> getReceiptHistory({
    String? spgId,
    String? lapakId,
    String? status,
  });

  /// Fetches stall profile.
  Future<LapakModel?> getLapak(String lapakId);
}
