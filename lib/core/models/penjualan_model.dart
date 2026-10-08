import '../utils/parser_utils.dart';
import 'lapak_model.dart';
import 'user_model.dart';

/// Single product line item in a sales transaction
class PenjualanItemModel {
  final String id;
  final String produkId;
  final String namaProduk;
  final int qty;
  final int hargaSatuan;
  final int subtotal;

  const PenjualanItemModel({
    required this.id,
    required this.produkId,
    required this.namaProduk,
    required this.qty,
    required this.hargaSatuan,
    required this.subtotal,
  });

  factory PenjualanItemModel.fromJson(Map<String, dynamic> json) {
    final qtyVal = ParserUtils.parseInt(json['qty']);
    final hargaVal = ParserUtils.parseInt(json['harga_satuan']);
    final subtotalVal = json['subtotal'] != null ? ParserUtils.parseInt(json['subtotal']) : (qtyVal * hargaVal);

    return PenjualanItemModel(
      id: json['id']?.toString() ?? '',
      produkId: json['produk_id']?.toString() ?? '',
      namaProduk: json['nama_produk']?.toString() ?? 'Produk',
      qty: qtyVal,
      hargaSatuan: hargaVal,
      subtotal: subtotalVal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'produk_id': produkId,
      'nama_produk': namaProduk,
      'qty': qty,
      'harga_satuan': hargaSatuan,
      'subtotal': subtotal,
    };
  }
}

/// Domain model representing a sales transaction (Penjualan)
class PenjualanModel {
  final String id;
  final DateTime? tanggal;
  final int totalHarga;
  final String metodePembayaran;
  final String? buktiBayarUrl;
  final String? buktiQrisUrl;
  final String catatan;
  final UserModel? spg;
  final LapakModel? lapak;
  final List<PenjualanItemModel> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PenjualanModel({
    required this.id,
    this.tanggal,
    required this.totalHarga,
    required this.metodePembayaran,
    this.buktiBayarUrl,
    this.buktiQrisUrl,
    this.catatan = '',
    this.spg,
    this.lapak,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Resolved proof URL supporting both bukti_bayar_url and legacy bukti_qris_url
  String? get resolvedBuktiUrl => buktiBayarUrl ?? buktiQrisUrl;

  bool get isTunai => metodePembayaran.toLowerCase() == 'tunai';
  bool get isQris => metodePembayaran.toLowerCase() == 'qris';
  bool get isTransfer => metodePembayaran.toLowerCase() == 'transfer';

  /// Total units sold across all items in this transaction
  int get totalQty => items.fold(0, (sum, item) => sum + item.qty);

  /// User-friendly formatted date: e.g. "08 Okt 2026, 14:30"
  String get formattedDateTime {
    final d = tanggal ?? createdAt;
    if (d == null) return '-';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final dateStr = '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
    final timeStr = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$dateStr, $timeStr';
  }

  factory PenjualanModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final List<PenjualanItemModel> parsedItems = [];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          parsedItems.add(PenjualanItemModel.fromJson(item));
        } else if (item is Map) {
          parsedItems.add(PenjualanItemModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final proof = json['bukti_bayar_url']?.toString() ?? json['bukti_qris_url']?.toString();

    return PenjualanModel(
      id: json['id']?.toString() ?? '',
      tanggal: ParserUtils.parseDate(json['tanggal']),
      totalHarga: ParserUtils.parseInt(json['total_harga']),
      metodePembayaran: json['metode_pembayaran']?.toString() ?? 'tunai',
      buktiBayarUrl: proof,
      buktiQrisUrl: proof,
      catatan: json['catatan']?.toString() ?? '',
      spg: json['spg'] is Map ? UserModel.fromJson(Map<String, dynamic>.from(json['spg'])) : null,
      lapak: json['lapak'] is Map ? LapakModel.fromJson(Map<String, dynamic>.from(json['lapak'])) : null,
      items: parsedItems,
      createdAt: ParserUtils.parseDate(json['createdAt']),
      updatedAt: ParserUtils.parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal': tanggal?.toIso8601String(),
      'total_harga': totalHarga,
      'metode_pembayaran': metodePembayaran,
      'bukti_bayar_url': buktiBayarUrl,
      'bukti_qris_url': buktiQrisUrl,
      'catatan': catatan,
      if (spg != null) 'spg': spg!.toJson(),
      if (lapak != null) 'lapak': lapak!.toJson(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
