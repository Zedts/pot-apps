class ApiEndpoints {
  ApiEndpoints._();
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
}
