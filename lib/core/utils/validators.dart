/// Input field validators for authentication.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  /// Validates email format and presence.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Silakan masukkan email Anda';
    }
    final trimmed = value.trim();
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,30}$');
  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');

  /// Validates full name (minimum 2 characters).
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Silakan masukkan nama lengkap Anda';
    }
    if (value.trim().length < 2) {
      return 'Nama lengkap minimal 2 karakter';
    }
    return null;
  }

  /// Validates username (3-30 alphanumeric and underscore characters).
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Silakan masukkan username Anda';
    }
    final trimmed = value.trim();
    if (!_usernameRegex.hasMatch(trimmed)) {
      return 'Username 3-30 karakter (hanya huruf, angka, dan _)';
    }
    return null;
  }

  /// Validates optional phone number (8-15 digits if provided).
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    final trimmed = value.trim();
    if (!_phoneRegex.hasMatch(trimmed)) {
      return 'Nomor handphone tidak valid (8-15 digit)';
    }
    return null;
  }

  /// Validates password presence and minimum length.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Silakan masukkan password Anda';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  /// Validates password confirmation matches original password.
  static String? validateConfirmPassword(String? confirmValue, String? password) {
    if (confirmValue == null || confirmValue.isEmpty) {
      return 'Silakan konfirmasi password Anda';
    }
    if (confirmValue != password) {
      return 'Konfirmasi password tidak cocok';
    }
    return null;
  }
}
