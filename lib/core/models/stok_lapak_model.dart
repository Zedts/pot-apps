import '../utils/parser_utils.dart';
import 'lapak_model.dart';
import 'produk_model.dart';

/// Domain model representing current inventory stock at a Lapak (Stall)
/// Follows the invariant: stok_akhir = stok_awal + stok_masuk - stok_terjual
class StokLapakModel {
  final String id;
  final String lapakId;
  final String produkId;
  final int stokAwal;
  final int stokMasuk;
  final int stokTerjual;
  final int stokAkhir;
  final LapakModel? lapak;
  final ProdukModel? produk;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StokLapakModel({
    required this.id,
    required this.lapakId,
    required this.produkId,
    required this.stokAwal,
    required this.stokMasuk,
    required this.stokTerjual,
    required this.stokAkhir,
    this.lapak,
    this.produk,
    this.createdAt,
    this.updatedAt,
  });

  /// Name of the product (from relational object or fallback)
  String get productName => produk?.nama ?? 'Produk #$produkId';

  /// Unit price of the product
  int get productPrice => produk?.harga ?? 0;

  factory StokLapakModel.fromJson(Map<String, dynamic> json) {
    final sAwal = ParserUtils.parseInt(json['stok_awal']);
    final sMasuk = ParserUtils.parseInt(json['stok_masuk']);
    final sTerjual = ParserUtils.parseInt(json['stok_terjual']);
    final sAkhirRaw = json['stok_akhir'];
    final sAkhir = sAkhirRaw != null ? ParserUtils.parseInt(sAkhirRaw) : (sAwal + sMasuk - sTerjual);

    LapakModel? lapakModel;
    if (json['lapak'] is Map) {
      lapakModel = LapakModel.fromJson(Map<String, dynamic>.from(json['lapak']));
    }

    ProdukModel? produkModel;
    if (json['produk'] is Map) {
      produkModel = ProdukModel.fromJson(Map<String, dynamic>.from(json['produk']));
    }

    final lapakId = json['lapak_id']?.toString() ??
        (lapakModel?.id ?? (json['lapak'] is Map ? json['lapak']['id']?.toString() : '')) ?? '';
    final produkId = json['produk_id']?.toString() ??
        (produkModel?.id ?? (json['produk'] is Map ? json['produk']['id']?.toString() : '')) ?? '';

    return StokLapakModel(
      id: json['id']?.toString() ?? '',
      lapakId: lapakId,
      produkId: produkId,
      stokAwal: sAwal,
      stokMasuk: sMasuk,
      stokTerjual: sTerjual,
      stokAkhir: sAkhir,
      lapak: lapakModel,
      produk: produkModel,
      createdAt: ParserUtils.parseDate(json['createdAt']),
      updatedAt: ParserUtils.parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lapak_id': lapakId,
      'produk_id': produkId,
      'stok_awal': stokAwal,
      'stok_masuk': stokMasuk,
      'stok_terjual': stokTerjual,
      'stok_akhir': stokAkhir,
      if (lapak != null) 'lapak': lapak!.toJson(),
      if (produk != null) 'produk': produk!.toJson(),
    };
  }
}
