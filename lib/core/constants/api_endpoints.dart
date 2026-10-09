class ApiEndpoints {
  ApiEndpoints._();
  // Health Check
  static const String health = '/health';

  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleLogin = '/auth/google';
  static const String me = '/auth/me';

  // Users
  static const String users = '/users';

  // Lapak
  static const String lapak = '/lapak';
  static String lapakById(String id) => '/lapak/$id';

  // Absensi
  static const String absensi = '/absensi';
  static String absensiById(String id) => '/absensi/$id';
  static String absensiPulang(String id) => '/absensi/$id/pulang';
  static String absensiFoto(String id) => '/absensi/$id/foto';

  // Pengiriman
  static const String pengiriman = '/pengiriman';
  static String pengirimanById(String id) => '/pengiriman/$id';
  static String pengirimanStatus(String id) => '/pengiriman/$id/status';

  // Penerimaan
  static const String penerimaan = '/penerimaan';
  static String penerimaanById(String id) => '/penerimaan/$id';
  static String penerimaanNota(String id) => '/penerimaan/$id/nota';

  // Produk
  static const String produk = '/produk';
  static String produkById(String id) => '/produk/$id';

  // Stok Lapak
  static const String stokLapak = '/stok-lapak';
  static String stokLapakById(String id) => '/stok-lapak/$id';

  // Penjualan
  static const String penjualan = '/penjualan';
  static String penjualanById(String id) => '/penjualan/$id';
  static String penjualanBuktiBayar(String id) => '/penjualan/$id/bukti-bayar';

  // Closing
  static const String closing = '/closing';
  static String closingById(String id) => '/closing/$id';

  // Payroll
  static const String payroll = '/payroll';

  // Slip Gaji
  static const String slipGaji = '/slip-gaji';
}
