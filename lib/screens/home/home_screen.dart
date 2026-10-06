import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/models/user_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/google_auth_service.dart';
import '../../widgets/auth/login/skyline_footer.dart';
import '../../widgets/common/app_toast.dart';
import '../auth/login_screen.dart';

/// Default Home Screen displayed after successful authentication.
class HomeScreen extends StatefulWidget {
  final UserModel user;
  final AuthService? authService;
  final GoogleAuthService? googleAuthService;

  const HomeScreen({
    super.key,
    required this.user,
    this.authService,
    this.googleAuthService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthService _authService;
  late final GoogleAuthService _googleAuthService;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _googleAuthService = widget.googleAuthService ?? GoogleAuthService();
  }

  /// Prompts confirmation and executes the logout flow.
  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PotColors.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Iconsax.logout, color: PotColors.primaryRed, size: 22),
            SizedBox(width: 8),
            Text(
              'Konfirmasi Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: PotColors.textDark,
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun POT?',
          style: TextStyle(
            fontSize: 13,
            color: PotColors.textMuted,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: PotColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PotColors.primaryRed,
              foregroundColor: PotColors.pureWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Keluar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    setState(() => _isLoggingOut = true);

    try {
      await _authService.logout();
      await _googleAuthService.signOut();

      if (!mounted) return;

      AppToast.show(
        context,
        message: 'Berhasil keluar dari akun.',
        isSuccess: true,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      AppToast.show(
        context,
        message: 'Terjadi kesalahan saat logout.',
        isSuccess: false,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final displayName = user.nama.trim().isNotEmpty ? user.nama.trim() : 'Pengguna';

    return Scaffold(
      backgroundColor: PotColors.bgCream,
      appBar: AppBar(
        backgroundColor: PotColors.bgCream,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              AppImages.imageLogo,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text(
              'POT Presensi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: PotColors.primaryRed,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Keluar Akun',
              icon: _isLoggingOut
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(PotColors.primaryRed),
                      ),
                    )
                  : const Icon(Iconsax.logout, color: PotColors.primaryRed, size: 22),
              onPressed: _isLoggingOut ? null : _handleLogout,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Greeting Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: PotColors.cardCream,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: PotColors.warmBorder),
                      boxShadow: [
                        BoxShadow(
                          color: PotColors.primaryRed.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // halo $nama requirement
                        Text(
                          'halo $displayName',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: PotColors.textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Selamat datang di Sistem Presensi Oleh² Turki.',
                          style: TextStyle(
                            fontSize: 13,
                            color: PotColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Account Details Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: PotColors.pureWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: PotColors.warmBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Akun',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: PotColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 14),

                        _buildInfoRow(
                          icon: Iconsax.personalcard,
                          label: 'Username',
                          value: user.username.isNotEmpty ? '@${user.username}' : '-',
                        ),
                        const Divider(height: 20, color: PotColors.warmBorder),

                        _buildInfoRow(
                          icon: Iconsax.sms,
                          label: 'Email',
                          value: user.email.isNotEmpty ? user.email : '-',
                        ),
                        const Divider(height: 20, color: PotColors.warmBorder),

                        _buildInfoRow(
                          icon: Iconsax.call,
                          label: 'Nomor Handphone',
                          value: user.noHp.isNotEmpty ? user.noHp : 'Belum diisi',
                        ),
                        const Divider(height: 20, color: PotColors.warmBorder),

                        _buildInfoRow(
                          icon: Iconsax.shield_security,
                          label: 'Role / Status',
                          value: '${user.role.toUpperCase()} (${user.status})',
                          valueColor: PotColors.primaryRed,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Prominent Logout Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PotColors.primaryRed,
                      side: const BorderSide(color: PotColors.primaryRed, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Iconsax.logout, size: 18),
                    label: const Text(
                      'Logout dari Akun',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: _isLoggingOut ? null : _handleLogout,
                  ),

                  const SizedBox(height: 36),

                  // Skyline Vector Footer + Slogan
                  const SkylineFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: PotColors.primaryRed),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: PotColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? PotColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
