class AppConstants {
  AppConstants._();
  // Roles
  static const String roleSpg = "spg";
  static const String roleProduksi = "produksi";
  static const String roleViar = "viar";
  static const String roleAdmin = "admin";
  static const String roleOwner = "owner";

  // Transaction Payment Methods
  static const String paymentTunai = "Tunai";
  static const String paymentQris = "QRIS";
  static const String paymentTransfer = "Transfer";

  // Absensi Status
  static const String absenHadir = "hadir";
  static const String absenTerlambat = "terlambat";
  static const String absenIzin = "izin";

  // Closing Status
  static const String closingPending = "pending";
  static const String closingTerverifikasi = "terverifikasi";
  static const String closingRevisi = "perlu_revisi";

  // Payroll Status
  static const String payrollDraft = "draft";
  static const String payrollPublished = "published";

  // Receive Status
  static const String receiveSesuai = "sesuai";
  static const String receiveSelisih = "selisih";

  // Delivery Status
  static const String deliveryDraft = "draft";
  static const String deliveryDikirimViar = "dikirim_viar";
  static const String deliveryDiterimaSPG = "diterima_spg";
  static const String deliverySelesai = "selesai";

  // User/Produk Status
  static const String statusActive = "active";
  static const String statusInActive = "inactive";

  // Local activity history types
  static const String activityClockIn = 'clock_in';
  static const String activityClockOut = 'clock_out';
  static const String activityReceiveGoods = 'receive_goods';
  static const String activityProcessSale = 'process_sale';
  static const String activityDailyClosing = 'daily_closing';
  static const String activityProfileUpdated = 'profile_updated';
}
