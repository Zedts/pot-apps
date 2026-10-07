import '../../../core/models/auth_response.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../core/viewmodels/base_view_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/auth_repository_impl.dart';

/// ViewModel managing state and business operations for RegisterScreen.
/// Encapsulates field validations, registration requests, Google auth, and errors.
class RegisterViewModel extends BaseViewModel {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  bool _isGoogleLoading = false;

  String? _nameError;
  String? _usernameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _errorMessage;

  RegisterViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl();

  // Getters
  bool get isLoading => _isLoading;
  bool get isGoogleLoading => _isGoogleLoading;

  String? get nameError => _nameError;
  String? get usernameError => _usernameError;
  String? get emailError => _emailError;
  String? get phoneError => _phoneError;
  String? get passwordError => _passwordError;
  String? get confirmPasswordError => _confirmPasswordError;
  String? get errorMessage => _errorMessage;

  // Field error clearers for onChanged events
  void clearNameError() {
    if (_nameError != null) {
      _nameError = null;
      notifyListeners();
    }
  }

  void clearUsernameError() {
    if (_usernameError != null) {
      _usernameError = null;
      notifyListeners();
    }
  }

  void clearEmailError() {
    if (_emailError != null) {
      _emailError = null;
      notifyListeners();
    }
  }

  void clearPhoneError() {
    if (_phoneError != null) {
      _phoneError = null;
      notifyListeners();
    }
  }

  void clearPasswordError() {
    if (_passwordError != null) {
      _passwordError = null;
      notifyListeners();
    }
  }

  void clearConfirmPasswordError() {
    if (_confirmPasswordError != null) {
      _confirmPasswordError = null;
      notifyListeners();
    }
  }

  /// Validates all 6 registration fields.
  bool validate({
    required String nama,
    required String username,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) {
    _nameError = Validators.validateName(nama);
    _usernameError = Validators.validateUsername(username);
    _emailError = Validators.validateEmail(email);
    _phoneError = Validators.validatePhone(phone);
    _passwordError = Validators.validatePassword(password);
    _confirmPasswordError = Validators.validateConfirmPassword(
      confirmPassword,
      password,
    );
    _errorMessage = null;
    notifyListeners();

    return _nameError == null &&
        _usernameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  /// Executes registration request with client validation.
  Future<AuthResponse?> register({
    required String nama,
    required String username,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    final isValid = validate(
      nama: nama,
      username: username,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (!isValid) {
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _authRepository.registerWithEmail(
        nama: nama,
        username: username,
        email: email,
        password: password,
        noHp: phone.trim().isNotEmpty ? phone.trim() : null,
      );
      return authResponse;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      return null;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan sistem. Silakan coba lagi.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Executes Google OAuth sign-in flow for registration.
  Future<AuthResponse?> registerWithGoogle() async {
    _isGoogleLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _authRepository.loginWithGoogle();
      return authResponse;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      return null;
    } catch (_) {
      _errorMessage = 'Gagal menghubungkan autentikasi Akun Google.';
      return null;
    } finally {
      _isGoogleLoading = false;
      notifyListeners();
    }
  }
}
