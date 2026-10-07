import '../../../core/models/auth_response.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../core/viewmodels/base_view_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/auth_repository_impl.dart';

/// ViewModel managing state and business operations for LoginScreen.
/// Implements MVVM pattern to decouple UI rendering from authentication logic.
class LoginViewModel extends BaseViewModel {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _errorMessage;

  LoginViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl();

  // Getters
  bool get isLoading => _isLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get errorMessage => _errorMessage;

  /// Clears email field validation error when user types.
  void clearEmailError() {
    if (_emailError != null) {
      _emailError = null;
      notifyListeners();
    }
  }

  /// Clears password field validation error when user types.
  void clearPasswordError() {
    if (_passwordError != null) {
      _passwordError = null;
      notifyListeners();
    }
  }

  /// Validates email and password inputs.
  bool validate({required String email, required String password}) {
    _emailError = Validators.validateEmail(email);
    _passwordError = Validators.validatePassword(password);
    _errorMessage = null;
    notifyListeners();
    return _emailError == null && _passwordError == null;
  }

  /// Executes standard email and password authentication.
  Future<AuthResponse?> login({
    required String email,
    required String password,
  }) async {
    if (!validate(email: email, password: password)) {
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _authRepository.loginWithEmail(
        email: email,
        password: password,
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

  /// Executes Google OAuth sign-in flow and backend verification.
  Future<AuthResponse?> loginWithGoogle() async {
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
