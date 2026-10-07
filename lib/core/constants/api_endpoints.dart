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
}
