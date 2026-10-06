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
import 'repositories/auth_repository.dart';
import 'viewmodels/register_view_model.dart';

/// Register Screen matching the visual layout and design language of LoginScreen.
/// Refactored to MVVM architecture: UI delegates state and operations to [RegisterViewModel].
class RegisterScreen extends StatefulWidget {
  final RegisterViewModel? viewModel;
  final AuthRepository? authRepository;

  const RegisterScreen({
    super.key,
    this.viewModel,
    this.authRepository,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final RegisterViewModel _viewModel;

  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ??
        RegisterViewModel(authRepository: widget.authRepository);

    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    if (widget.viewModel == null) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  /// Handles user registration via ViewModel.
  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    final authResponse = await _viewModel.register(
      nama: _nameController.text,
      username: _usernameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (authResponse != null) {
      AppToast.show(
        context,
        message: 'Pendaftaran berhasil! Selamat datang, ${authResponse.user.displayName}.',
        isSuccess: true,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: authResponse.user)),
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

  /// Handles Google OAuth registration and login flow via ViewModel.
  Future<void> _handleGoogleRegister() async {
    FocusScope.of(context).unfocus();

    final authResponse = await _viewModel.registerWithGoogle();

    if (!mounted) return;

    if (authResponse != null) {
      AppToast.show(
        context,
        message: 'Selamat datang, ${authResponse.user.displayName}! Pendaftaran Google berhasil.',
        isSuccess: true,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: authResponse.user)),
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
                      // Top Bar: Back & Info Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
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
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: PotColors.primaryRed,
                              ),
                            ),
                          ),
                          GestureDetector(
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
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Brand Logo & System Titles
                      Image.asset(
                        AppImages.imageLogo,
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 6),

                      const Text(
                        'POT',
                        style: TextStyle(
                          fontSize: 28,
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
                            fontSize: 14,
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
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: PotColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Welcome Heading
                      const Text(
                        'Daftar Akun Baru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: PotColors.textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Buat akun Anda untuk memulai presensi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: PotColors.textMuted,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Input Form Fields matching POST /api/v1/auth/register payload
                      CustomTextField(
                        controller: _nameController,
                        placeholder: 'Nama Lengkap',
                        prefixIcon: Iconsax.user,
                        textInputAction: TextInputAction.next,
                        errorText: _viewModel.nameError,
                        onChanged: (_) => _viewModel.clearNameError(),
                      ),

                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: _usernameController,
                        placeholder: 'Username',
                        prefixIcon: Iconsax.personalcard,
                        textInputAction: TextInputAction.next,
                        errorText: _viewModel.usernameError,
                        onChanged: (_) => _viewModel.clearUsernameError(),
                      ),

                      const SizedBox(height: 12),

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
                        controller: _phoneController,
                        placeholder: 'Nomor Handphone (Opsional)',
                        prefixIcon: Iconsax.call,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        errorText: _viewModel.phoneError,
                        onChanged: (_) => _viewModel.clearPhoneError(),
                      ),

                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: _passwordController,
                        placeholder: 'Password',
                        prefixIcon: Iconsax.lock,
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        errorText: _viewModel.passwordError,
                        onChanged: (_) => _viewModel.clearPasswordError(),
                      ),

                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: _confirmPasswordController,
                        placeholder: 'Konfirmasi Password',
                        prefixIcon: Iconsax.lock_1,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        errorText: _viewModel.confirmPasswordError,
                        onChanged: (_) => _viewModel.clearConfirmPasswordError(),
                        onSubmitted: _handleRegister,
                      ),

                      const SizedBox(height: 18),

                      // Register Button
                      CustomButton(
                        label: 'Daftar',
                        isLoading: _viewModel.isLoading,
                        onPressed: _handleRegister,
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

                      // Google Registration Button
                      GoogleLoginButton(
                        label: 'Daftar dengan Google',
                        isLoading: _viewModel.isGoogleLoading,
                        onPressed: _handleGoogleRegister,
                      ),

                      const SizedBox(height: 14),

                      // "Sudah punya akun? Masuk" Link
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: RichText(
                            text: const TextSpan(
                              text: 'Sudah punya akun? ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: PotColors.textMuted,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Masuk',
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
