import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';

/// Information and status view rendered exclusively when user role is 'unassigned'.
/// Informs the user to wait for Admin/Owner assignment and provides account details and refresh/logout actions.
class HomeUnassignedView extends StatelessWidget {
  final UserModel user;
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;

  const HomeUnassignedView({
    super.key,
    required this.user,
    required this.isLoading,
    required this.onRefresh,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Pending Assignment Notice Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB), // Amber soft tint
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFDE68A)),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Iconsax.timer_1,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menunggu Penugasan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF92400E),
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Akun terdaftar belum memiliki peran kerja',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Akun Anda telah aktif di sistem Presensi Oleh² Turki, namun peran (Role) dan penempatan kerja belum ditentukan. Silakan menunggu Admin atau Owner memberikan penugasan peran kepada Anda.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF78350F),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Account Information Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: PotColors.pureWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: PotColors.warmBorder),
            boxShadow: [
              BoxShadow(
                color: PotColors.primaryRed.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Akun Anda',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
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
                label: 'Status Peran',
                value: 'Belum Ditugaskan (UNASSIGNED)',
                valueColor: const Color(0xFFD97706),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 3. Check Assignment Status Button
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            backgroundColor: PotColors.pureWhite,
            foregroundColor: PotColors.textDark,
            side: const BorderSide(color: PotColors.warmBorder, width: 1.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: isLoading ? null : onRefresh,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(PotColors.primaryRed),
                  ),
                )
              : const Icon(Iconsax.refresh, size: 18, color: PotColors.primaryRed),
          label: Text(
            isLoading ? 'Memeriksa status...' : 'Periksa Status Penugasan',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: PotColors.textDark,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 4. Logout Action
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: PotColors.primaryRed,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: onLogout,
          icon: const Icon(Iconsax.logout, size: 16),
          label: const Text(
            'Keluar dari Akun',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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
                  fontWeight: FontWeight.w700,
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
