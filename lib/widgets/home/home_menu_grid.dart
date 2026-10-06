import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../common/app_toast.dart';
import 'home_menu_card.dart';

/// 2-Column × 3-Row Grid organizing the 6 operational menu cards from ref/home.html.
class HomeMenuGrid extends StatelessWidget {
  final void Function(String menuId, String menuTitle)? onCardTap;

  const HomeMenuGrid({
    super.key,
    this.onCardTap,
  });

  void _handleTap(BuildContext context, String menuId, String menuTitle) {
    if (onCardTap != null) {
      onCardTap!(menuId, menuTitle);
    } else {
      AppToast.show(
        context,
        message: 'Menu $menuTitle sedang dalam pengembangan.',
        isSuccess: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.12,
      children: [
        // 1. Absen Masuk Card (Mint Green)
        HomeMenuCard(
          label: 'Absen\nMasuk',
          icon: Iconsax.calendar_tick,
          backgroundColor: PotColors.menuGreen,
          borderColor: PotColors.borderGreen,
          iconColor: PotColors.iconGreen,
          onTap: () => _handleTap(context, 'absen', 'Absen Masuk'),
        ),

        // 2. Terima Barang Card (Soft Sky Blue)
        HomeMenuCard(
          label: 'Terima\nBarang',
          icon: Iconsax.box_add,
          backgroundColor: PotColors.menuBlue,
          borderColor: PotColors.borderBlue,
          iconColor: PotColors.iconBlue,
          onTap: () => _handleTap(context, 'terima_barang', 'Terima Barang'),
        ),

        // 3. Stok & Penjualan Card (Soft Warm Peach)
        HomeMenuCard(
          label: 'Stok &\nPenjualan',
          icon: Iconsax.shop,
          backgroundColor: PotColors.menuOrange,
          borderColor: PotColors.borderOrange,
          iconColor: PotColors.iconOrange,
          onTap: () => _handleTap(context, 'stok_penjualan', 'Stok & Penjualan'),
        ),

        // 4. Nota Pengeluaran Card (Soft Lavender)
        HomeMenuCard(
          label: 'Nota\nPengeluaran',
          icon: Iconsax.receipt_2,
          backgroundColor: PotColors.menuPurple,
          borderColor: PotColors.borderPurple,
          iconColor: PotColors.iconPurple,
          onTap: () => _handleTap(context, 'nota_pengeluaran', 'Nota Pengeluaran'),
        ),

        // 5. Closing Harian Card (Soft Rose / Red-Pink)
        HomeMenuCard(
          label: 'Closing\nHarian',
          icon: Iconsax.clipboard_tick,
          backgroundColor: PotColors.menuPink,
          borderColor: PotColors.borderPink,
          iconColor: PotColors.iconPink,
          onTap: () => _handleTap(context, 'closing_harian', 'Closing Harian'),
        ),

        // 6. Slip Gaji Card (Soft Slate Blue)
        HomeMenuCard(
          label: 'Slip\nGaji',
          icon: Iconsax.wallet_money,
          backgroundColor: PotColors.menuGray,
          borderColor: PotColors.borderGray,
          iconColor: PotColors.iconGray,
          onTap: () => _handleTap(context, 'slip_gaji', 'Slip Gaji'),
        ),
      ],
    );
  }
}
