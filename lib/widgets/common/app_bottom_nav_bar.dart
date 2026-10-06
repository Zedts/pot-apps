import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';

/// Reusable bottom navigation bar matching the design in ref/home.html.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PotColors.pureWhite.withValues(alpha: 0.96),
        border: const Border(
          top: BorderSide(color: PotColors.warmBorder, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  label: 'Beranda',
                  icon: Iconsax.home_2,
                  activeIcon: Iconsax.home_2,
                ),
                _buildNavItem(
                  index: 1,
                  label: 'Riwayat',
                  icon: Iconsax.receipt_item,
                  activeIcon: Iconsax.receipt_item,
                ),
                _buildNavItem(
                  index: 2,
                  label: 'Profil',
                  icon: Iconsax.user,
                  activeIcon: Iconsax.user,
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Bottom home indicator bar
            Container(
              width: 110,
              height: 3.5,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive ? PotColors.primaryRed : PotColors.textMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? PotColors.primaryRed : PotColors.textMuted,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
