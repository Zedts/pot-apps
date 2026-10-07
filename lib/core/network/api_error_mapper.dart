/// Translates technical API errors and status codes into friendly Indonesian messages.
/// Ensures zero raw backend errors or stack traces are ever exposed to the user.
class ApiErrorMapper {
  ApiErrorMapper._();

  /// Maps an HTTP status code and raw response message to a user-friendly message.
  static String mapStatusToUserMessage({
    required int statusCode,
    String? rawMessage,
    List<dynamic>? details,
  }) {
    final lowerRaw = (rawMessage ?? '').toLowerCase();

    switch (statusCode) {
      case 400:
        if (details != null && details.isNotEmpty) {
          final first = details.first.toString().toLowerCase();
          if (first.contains('nama')) {
            return 'Nama lengkap harus diisi minimal 2 karakter.';
          } else if (first.contains('username')) {
            return 'Username harus 3-30 karakter (hanya huruf, angka, dan _).';
          } else if (first.contains('email')) {
            return 'Format email tidak valid.';
          } else if (first.contains('password')) {
            return 'Password harus diisi minimal 6 karakter.';
          } else if (first.contains('no_hp') || first.contains('phone')) {
            return 'Nomor handphone harus berupa 8-15 digit angka.';
          } else if (first.contains('foto') || first.contains('image')) {
            return 'Format file foto tidak valid. Gunakan JPEG, PNG, atau WebP.';
          } else if (first.contains('lapak') || first.contains('koordinat')) {
            return 'Lokasi lapak belum ditentukan oleh Admin.';
          }
        }
        if (lowerRaw.contains('foto') || lowerRaw.contains('image')) {
          return 'Format file foto tidak valid. Gunakan JPEG, PNG, atau WebP.';
        }
        if (lowerRaw.contains('lapak') || lowerRaw.contains('koordinat')) {
          return 'Lokasi lapak belum ditentukan oleh Admin.';
        }
        if (lowerRaw.contains('malformed json')) {
          return 'Permintaan data tidak valid.';
        }
        if (rawMessage != null &&
            rawMessage.isNotEmpty &&
            !rawMessage.contains('{') &&
            !rawMessage.contains('Error:')) {
          return rawMessage;
        }
        return 'Format data yang dimasukkan belum benar.';

      case 401:
        if (lowerRaw.contains('inactive')) {
          return 'Akun Anda sedang dinonaktifkan. Silakan hubungi admin HRD.';
        }
        if (lowerRaw.contains('google id token')) {
          return 'Autentikasi akun Google tidak valid atau telah kedaluwarsa.';
        }
        if (lowerRaw.contains('token') || lowerRaw.contains('expired') || lowerRaw.contains('bearer')) {
          return 'Sesi login Anda telah berakhir. Silakan masuk kembali.';
        }
        return 'Email atau password yang Anda masukkan salah.';

      case 403:
        return 'Anda tidak memiliki hak akses untuk akun ini.';

      case 404:
        return 'Akun pengguna tidak ditemukan di sistem.';

      case 409:
        if (lowerRaw.contains('username')) {
          return 'Username sudah digunakan. Silakan pilih username lain.';
        }
        if (lowerRaw.contains('email')) {
          return 'Akun dengan email ini sudah terdaftar.';
        }
        if (lowerRaw.contains('phone') || lowerRaw.contains('nomor')) {
          return 'Nomor handphone sudah digunakan oleh akun lain.';
        }
        return 'Data akun sudah terdaftar di sistem.';

      case 500:
      case 502:
      case 503:
      case 504:
        return 'Terjadi gangguan pada server. Silakan coba beberapa saat lagi.';

      default:
        return 'Terjadi kendala saat memproses permintaan. Silakan coba lagi.';
    }
  }

  /// Friendly message for connection and timeout errors.
  static const String networkErrorMessage =
      'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';

  /// Friendly message for unexpected client runtime exceptions.
  static const String defaultErrorMessage =
      'Terjadi kesalahan. Silakan coba beberapa saat lagi.';
}
