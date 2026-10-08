import '../utils/parser_utils.dart';

/// Domain model representing a product in the catalog
class ProdukModel {
  final String id;
  final String nama;
  final String? kategoriId;
  final String? satuanId;
  final int harga;
  final String status;
  final String? kategoriNama;
  final String? satuanNama;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProdukModel({
    required this.id,
    required this.nama,
    this.kategoriId,
    this.satuanId,
    required this.harga,
    this.status = 'aktif',
    this.kategoriNama,
    this.satuanNama,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAktif => status.toLowerCase() == 'aktif';

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    String? katNama;
    if (json['kategori'] is Map) {
      katNama = json['kategori']['nama']?.toString();
    }

    String? satNama;
    if (json['satuan'] is Map) {
      satNama = json['satuan']['nama']?.toString();
    }

    return ProdukModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      kategoriId: json['kategori_id']?.toString() ?? (json['kategori'] is Map ? json['kategori']['id']?.toString() : null),
      satuanId: json['satuan_id']?.toString() ?? (json['satuan'] is Map ? json['satuan']['id']?.toString() : null),
      harga: ParserUtils.parseInt(json['harga']),
      status: json['status']?.toString() ?? 'aktif',
      kategoriNama: katNama,
      satuanNama: satNama,
      createdAt: ParserUtils.parseDate(json['createdAt']),
      updatedAt: ParserUtils.parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'kategori_id': kategoriId,
      'satuan_id': satuanId,
      'harga': harga,
      'status': status,
      if (kategoriNama != null) 'kategori': {'id': kategoriId, 'nama': kategoriNama},
      if (satuanNama != null) 'satuan': {'id': satuanId, 'nama': satuanNama},
    };
  }
}
