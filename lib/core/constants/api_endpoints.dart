class ApiEndpoints {
  ApiEndpoints._();

  // Health
  static const String health = '/health';

  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleLogin = '/auth/google';
  static const String me = '/auth/me';

  // Users
  static const String users = '/users';
}
