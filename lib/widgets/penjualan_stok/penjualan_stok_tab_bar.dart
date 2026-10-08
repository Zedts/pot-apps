import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Segmented tab bar switching between "Input Penjualan" and "Stok Saat Ini"
/// Styled to match the exact design tokens and aesthetics of the reference UI.
class PenjualanStokTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const PenjualanStokTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PotColors.cardCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PotColors.warmBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'Input Penjualan',
              isSelected: selectedIndex == 0,
              onTap: () => onTabChanged(0),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTabButton(
              title: 'Stok Saat Ini',
              isSelected: selectedIndex == 1,
              onTap: () => onTabChanged(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? PotColors.primaryRed : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: PotColors.primaryRed.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
            color: isSelected ? PotColors.pureWhite : PotColors.textMuted,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}
