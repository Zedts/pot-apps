import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../widgets/auth/login/google_login_button.dart';
import '../../widgets/auth/login/skyline_footer.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/info_modal.dart';
import '../home/home_screen.dart';
import '../home/app_navigation_shell.dart';
import 'register_screen.dart';
import 'repositories/auth_repository.dart';
import 'viewmodels/login_view_model.dart';

/// Main Login Screen implementing the layout and visual structure of ref/login.html.
/// Refactored to MVVM architecture: UI delegates state and operations to [LoginViewModel].
class LoginScreen extends StatefulWidget {
  final LoginViewModel? viewModel;
  final AuthRepository? authRepository;

  const LoginScreen({
    super.key,
    this.viewModel,
    this.authRepository,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginViewModel _viewModel;

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ??
        LoginViewModel(authRepository: widget.authRepository);

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    if (widget.viewModel == null) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  /// Handles standard email and password authentication via ViewModel.
  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    final authResponse = await _viewModel.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (authResponse != null) {
      AppToast.show(
        context,
        message: 'Selamat datang kembali, ${authResponse.user.displayName}! Presensi aktif.',
        isSuccess: true,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => authResponse.user.role.toLowerCase() == 'unassigned' ? HomeScreen(user: authResponse.user) : AppNavigationShell(user: authResponse.user)),
        (route) => false,
      );
    } else if (_viewModel.errorMessage != null) {
      AppToast.show(
        context,
        message: _viewModel.errorMessage!,
        isSuccess: false,
      );
    }
  }

  /// Handles Google OAuth sign-in flow via ViewModel.
  Future<void> _handleGoogleLogin() async {
    FocusScope.of(context).unfocus();

    final authResponse = await _viewModel.loginWithGoogle();

    if (!mounted) return;

    if (authResponse != null) {
      AppToast.show(
        context,
        message: 'Selamat datang, ${authResponse.user.displayName}! Login Google berhasil.',
        isSuccess: true,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => authResponse.user.role.toLowerCase() == 'unassigned' ? HomeScreen(user: authResponse.user) : AppNavigationShell(user: authResponse.user)),
        (route) => false,
      );
    } else if (_viewModel.errorMessage != null) {
      AppToast.show(
        context,
        message: _viewModel.errorMessage!,
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PotColors.bgCream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top Bar: System Info Action
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => InfoModal.show(context),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: PotColors.cardCream,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: PotColors.warmBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: PotColors.primaryRed.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Iconsax.info_circle,
                              size: 18,
                              color: PotColors.primaryRed,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Brand Logo & System Titles
                      Image.asset(
                        AppImages.imageLogo,
                        width: 84,
                        height: 84,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 6),

                      const Text(
                        'POT',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: PotColors.primaryRed,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),

                      RichText(
                        text: TextSpan(
                          text: 'Presensi Oleh',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: PotColors.textDark,
                            letterSpacing: -0.2,
                          ),
                          children: [
                            WidgetSpan(
                              child: Transform.translate(
                            offset: const Offset(0, -5),
                            child: const Text(
                              '2',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: PotColors.textDark,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(
                          text: ' Turki',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: PotColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Welcome Heading
                  const Text(
                    'Selamat Datang!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: PotColors.textDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Masuk ke akun Anda',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: PotColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Input Form
                  CustomTextField(
                    controller: _emailController,
                    placeholder: 'Email',
                    prefixIcon: Iconsax.sms,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    errorText: _viewModel.emailError,
                    onChanged: (_) => _viewModel.clearEmailError(),
                  ),

                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _passwordController,
                    placeholder: 'Password',
                    prefixIcon: Iconsax.lock,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    errorText: _viewModel.passwordError,
                    onChanged: (_) => _viewModel.clearPasswordError(),
                    onSubmitted: _handleLogin,
                  ),

                  const SizedBox(height: 16),

                  // Login Button
                  CustomButton(
                    label: 'Login',
                    isLoading: _viewModel.isLoading,
                    onPressed: _handleLogin,
                  ),

                  const SizedBox(height: 14),

                  // Divider
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: PotColors.warmBorder,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'atau',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: PotColors.textMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: PotColors.warmBorder,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Google Sign-In Button
                  GoogleLoginButton(
                    isLoading: _viewModel.isGoogleLoading,
                    onPressed: _handleGoogleLogin,
                  ),

                  const SizedBox(height: 14),

                  // "Belum punya akun? Daftar" Link
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Belum punya akun? ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PotColors.textMuted,
                          ),
                          children: [
                            TextSpan(
                              text: 'Daftar',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: PotColors.primaryRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Skyline Vector Footer + Slogan
                  const SkylineFooter(),
                ],
              );
            },
          ),
        ),
      ),
    ),
  ),
);
  }
}
