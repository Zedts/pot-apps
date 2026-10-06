import 'package:flutter_test/flutter_test.dart';
import 'package:pot_apps/core/network/api_client.dart';
import 'package:pot_apps/core/network/api_error_mapper.dart';
import 'package:pot_apps/core/network/api_exception.dart';
import 'package:pot_apps/core/services/auth_service.dart';
import 'package:pot_apps/core/storage/token_storage.dart';
import 'package:pot_apps/core/utils/env_config.dart';
import 'package:pot_apps/core/utils/validators.dart';
import 'package:pot_apps/core/models/user_model.dart';
import 'package:pot_apps/screens/auth/repositories/auth_repository_impl.dart';
import 'package:pot_apps/screens/auth/viewmodels/login_view_model.dart';
import 'package:pot_apps/screens/auth/viewmodels/register_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EnvConfig.init();
  });

  group('Validators Unit Tests', () {
    test('Email validator accepts valid emails and rejects invalid ones', () {
      expect(Validators.validateEmail('admin@pot.com'), isNull);
      expect(Validators.validateEmail('user.test+1@example.co.id'), isNull);

      expect(Validators.validateEmail(''), 'Silakan masukkan email Anda');
      expect(Validators.validateEmail(null), 'Silakan masukkan email Anda');
      expect(Validators.validateEmail('not-an-email'), 'Format email tidak valid');
      expect(Validators.validateEmail('user@'), 'Format email tidak valid');
    });

    test('Password validator validates presence and minimum length', () {
      expect(Validators.validatePassword('Admin#123'), isNull);
      expect(Validators.validatePassword('123456'), isNull);

      expect(Validators.validatePassword(''), 'Silakan masukkan password Anda');
      expect(Validators.validatePassword(null), 'Silakan masukkan password Anda');
      expect(Validators.validatePassword('12345'), 'Password minimal 6 karakter');
    });
    test('Name validator requires presence and minimum 2 characters', () {
      expect(Validators.validateName('Ahmad Fauzi'), isNull);
      expect(Validators.validateName('Jo'), isNull);
      expect(Validators.validateName(''), 'Silakan masukkan nama lengkap Anda');
      expect(Validators.validateName('A'), 'Nama lengkap minimal 2 karakter');
    });

    test('Username validator enforces 3-30 alphanumeric and underscore characters', () {
      expect(Validators.validateUsername('ahmad_123'), isNull);
      expect(Validators.validateUsername('user'), isNull);
      expect(Validators.validateUsername(''), 'Silakan masukkan username Anda');
      expect(Validators.validateUsername('ab'), 'Username 3-30 karakter (hanya huruf, angka, dan _)');
      expect(Validators.validateUsername('user-invalid'), 'Username 3-30 karakter (hanya huruf, angka, dan _)');
    });

    test('Phone validator allows optional empty and validates 8-15 digits when provided', () {
      expect(Validators.validatePhone(''), isNull);
      expect(Validators.validatePhone(null), isNull);
      expect(Validators.validatePhone('08123456789'), isNull);
      expect(Validators.validatePhone('+628123456789'), isNull);
      expect(Validators.validatePhone('12345'), 'Nomor handphone tidak valid (8-15 digit)');
    });

    test('Confirm password validator verifies equality with original password', () {
      expect(Validators.validateConfirmPassword('secret123', 'secret123'), isNull);
      expect(Validators.validateConfirmPassword('', 'secret123'), 'Silakan konfirmasi password Anda');
      expect(Validators.validateConfirmPassword('wrongpass', 'secret123'), 'Konfirmasi password tidak cocok');
    });
  });

  group('ApiErrorMapper Tests (Masking Backend Raw Errors)', () {
    test('Masks 401 Unauthorized to friendly Indonesian text', () {
      final msg = ApiErrorMapper.mapStatusToUserMessage(
        statusCode: 401,
        rawMessage: 'Invalid email or password.',
      );
      expect(msg, 'Email atau password yang Anda masukkan salah.');
    });

    test('Masks 401 Inactive Account to HRD contact advice', () {
      final msg = ApiErrorMapper.mapStatusToUserMessage(
        statusCode: 401,
        rawMessage: 'Account is inactive. Please contact support.',
      );
      expect(msg, 'Akun Anda sedang dinonaktifkan. Silakan hubungi admin HRD.');
    });

    test('Masks 409 Conflict messages (username, email, phone) to user-friendly messages', () {
      expect(
        ApiErrorMapper.mapStatusToUserMessage(
          statusCode: 409,
          rawMessage: "The username 'ahmad' is already taken.",
        ),
        'Username sudah digunakan. Silakan pilih username lain.',
      );

      expect(
        ApiErrorMapper.mapStatusToUserMessage(
          statusCode: 409,
          rawMessage: "An account with email 'ahmad@pot.com' is already registered.",
        ),
        'Akun dengan email ini sudah terdaftar.',
      );
    });

    test('Masks 401 Token Expiration to session expired message', () {
      final msg = ApiErrorMapper.mapStatusToUserMessage(
        statusCode: 401,
        rawMessage: 'Your authentication token has expired (30-day limit). Please log in again.',
      );
      expect(msg, 'Sesi login Anda telah berakhir. Silakan masuk kembali.');
    });

    test('Masks 500 Server Error to general system error message', () {
      final msg = ApiErrorMapper.mapStatusToUserMessage(
        statusCode: 500,
        rawMessage: 'JWT_SECRET environment variable is not configured.',
      );
      expect(msg, 'Terjadi gangguan pada server. Silakan coba beberapa saat lagi.');
    });
  });

  group('UserModel Domain Tests', () {
    test('displayName resolves in order of precedence: nama -> username -> email -> Pengguna', () {
      const userWithNama = UserModel(
        id: '1',
        nama: 'Ahmad Fauzi',
        username: 'afauzi',
        email: 'afauzi@pot.com',
        role: 'spg',
        noHp: '',
        status: 'active',
        authProvider: 'password',
      );
      expect(userWithNama.displayName, 'Ahmad Fauzi');

      const userWithUsername = UserModel(
        id: '2',
        nama: '',
        username: 'afauzi',
        email: 'afauzi@pot.com',
        role: 'spg',
        noHp: '',
        status: 'active',
        authProvider: 'password',
      );
      expect(userWithUsername.displayName, 'afauzi');

      const userWithEmailOnly = UserModel(
        id: '3',
        nama: '',
        username: '',
        email: 'afauzi@pot.com',
        role: 'spg',
        noHp: '',
        status: 'active',
        authProvider: 'password',
      );
      expect(userWithEmailOnly.displayName, 'afauzi@pot.com');
    });
  });

  group('Live Backend Integration Tests', () {
    final authService = AuthService(apiClient: ApiClient());

    test('Successful login with valid credentials against running backend', () async {
      try {
        final authResponse = await authService.login(
          email: 'admin@pot.com',
          password: 'Admin#123',
        );

        expect(authResponse.token, isNotEmpty);
        expect(authResponse.user.email, 'admin@pot.com');
        expect(authResponse.user.role, 'admin');

        // Verify token storage
        final savedToken = await TokenStorage.getToken();
        expect(savedToken, authResponse.token);

        final savedUser = await TokenStorage.getUser();
        expect(savedUser, isNotNull);
        expect(savedUser?.email, 'admin@pot.com');
      } on ApiException catch (e) {
        fail('Expected successful login, but got ApiException: ${e.userMessage}');
      }
    });

    test('Invalid credentials properly trigger ApiException with masked message', () async {
      try {
        await authService.login(
          email: 'admin@pot.com',
          password: 'WrongPassword#999',
        );
        fail('Should have thrown ApiException on invalid password');
      } on ApiException catch (e) {
        expect(e.statusCode, 401);
        expect(e.userMessage, 'Email atau password yang Anda masukkan salah.');
        // Verify raw backend error name is NOT exposed in userMessage
        expect(e.userMessage.contains('UnauthorizedError'), isFalse);
      }
    });

    test('AuthRepositoryImpl executes login, persists session, and handles logout', () async {
      final repository = AuthRepositoryImpl(authService: authService);

      final authResponse = await repository.loginWithEmail(
        email: 'admin@pot.com',
        password: 'Admin#123',
      );

      expect(authResponse.token, isNotEmpty);
      expect(await repository.isAuthenticated(), isTrue);

      final cachedUser = await repository.getCachedUser();
      expect(cachedUser?.email, 'admin@pot.com');

      await repository.logout();
      expect(await repository.isAuthenticated(), isFalse);
    });
  });

  group('MVVM ViewModels Unit Tests', () {
    test('LoginViewModel validates inputs and manages field errors reactively', () {
      final viewModel = LoginViewModel();

      expect(viewModel.validate(email: '', password: ''), isFalse);
      expect(viewModel.emailError, isNotNull);
      expect(viewModel.passwordError, isNotNull);

      viewModel.clearEmailError();
      expect(viewModel.emailError, isNull);

      viewModel.clearPasswordError();
      expect(viewModel.passwordError, isNull);

      expect(viewModel.validate(email: 'user@test.com', password: 'password123'), isTrue);
      expect(viewModel.emailError, isNull);
      expect(viewModel.passwordError, isNull);
    });

    test('RegisterViewModel validates all 6 fields and clears field errors', () {
      final viewModel = RegisterViewModel();

      expect(
        viewModel.validate(
          nama: '',
          username: '',
          email: '',
          phone: '',
          password: '',
          confirmPassword: '',
        ),
        isFalse,
      );

      expect(viewModel.nameError, isNotNull);
      expect(viewModel.usernameError, isNotNull);
      expect(viewModel.emailError, isNotNull);
      expect(viewModel.passwordError, isNotNull);

      viewModel.clearNameError();
      expect(viewModel.nameError, isNull);

      viewModel.clearUsernameError();
      expect(viewModel.usernameError, isNull);

      expect(
        viewModel.validate(
          nama: 'Budi Santoso',
          username: 'budisantoso',
          email: 'budi@pot.com',
          phone: '08123456789',
          password: 'Password#123',
          confirmPassword: 'Password#123',
        ),
        isTrue,
      );
    });
  });
}
