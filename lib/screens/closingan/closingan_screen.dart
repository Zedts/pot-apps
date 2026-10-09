import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/closing_model.dart';
import '../../core/models/user_model.dart';
import '../../widgets/auth/login/skyline_footer.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/attendance/attendance_status_badge.dart';
import '../../widgets/closingan/closing_detail_sheet.dart';
import '../../widgets/closingan/closing_inventory_summary_card.dart';
import '../../widgets/closingan/closing_reconciliation_card.dart';
import '../../widgets/closingan/closing_sales_summary_card.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/lapak_info_card.dart';
import 'closing_history_screen.dart';
import 'viewmodels/closingan_view_model.dart';

/// Main Daily Closing Screen ("Closing Harian") for SPG shift reconciliation matching ref/closingan.html
class ClosinganScreen extends StatefulWidget {
  final UserModel? currentUser;

  const ClosinganScreen({
    super.key,
    this.currentUser,
  });

  @override
  State<ClosinganScreen> createState() => _ClosinganScreenState();
}

class _ClosinganScreenState extends State<ClosinganScreen> {
  late final ClosinganViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ClosinganViewModel(currentUser: widget.currentUser);
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Immediately dismiss keyboard and remove active focus
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(context).unfocus();

    final hasDiscrepancy = _viewModel.hasAnyDiscrepancy;

    final String confirmTitle;
    final String confirmContent;

    if (hasDiscrepancy) {
      confirmTitle = 'Konfirmasi Selisih Closing';
      final stockPart = _viewModel.hasStockDiscrepancy
          ? 'selisih stok ${_viewModel.selisihStok > 0 ? "+${_viewModel.selisihStok}" : _viewModel.selisihStok} pcs'
          : 'stok sesuai';
      final cashPart = _viewModel.hasCashDiscrepancy
          ? 'selisih kasir ${_viewModel.selisihUang > 0 ? "+${CurrencyFormatter.formatRupiah(_viewModel.selisihUang)}" : CurrencyFormatter.formatRupiah(_viewModel.selisihUang)}'
          : 'kasir sesuai';

      confirmContent =
          'Terdapat $stockPart dan $cashPart.\n\n'
          'Apakah Anda yakin ingin mengirim laporan closing dengan status selisih?';
    } else {
      confirmTitle = 'Kirim Laporan Closing';
      confirmContent =
          'Semua stok dan uang kasir sesuai sistem.\n\n'
          'Apakah Anda yakin ingin mengirim laporan closing hari ini?';
    }

    final confirmed = await ConfirmationDialog.show(
      context,
      title: confirmTitle,
      content: confirmContent,
      confirmLabel: 'Ya, Kirim Closing',
      cancelLabel: 'Batal',
      confirmColor: PotColors.primaryRed,
    );

    // Keep keyboard dismissed after dialog closes
    FocusManager.instance.primaryFocus?.unfocus();
    if (mounted) {
      FocusScope.of(context).unfocus();
    }

    if (confirmed == true && mounted) {
      final result = await _viewModel.submitClosing();
      if (!mounted) return;

      FocusManager.instance.primaryFocus?.unfocus();
      FocusScope.of(context).unfocus();

      if (result != null) {
        AppToast.show(
          context,
          message: 'Laporan closing berhasil dikirim (${result.statusLabel}).',
          isSuccess: true,
        );
      } else if (_viewModel.errorMessage != null) {
        AppToast.show(
          context,
          message: _viewModel.errorMessage!,
          isSuccess: false,
        );
      }
    }
  }

  Widget _buildRiwayatButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => ClosingHistoryScreen(
              currentUser: _viewModel.user,
              currentStall: _viewModel.stall,
            ),
          ),
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: PotColors.cardCream,
          borderRadius: BorderRadius.circular(16),
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
          Iconsax.document_text,
          size: 18,
          color: PotColors.primaryRed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (_viewModel.isLoading && _viewModel.stall == null) {
          return Scaffold(
            backgroundColor: PotColors.bgCream,
            appBar: AppHeader(
              showBackButton: true,
              title: 'Closing Harian',
              subtitle: _viewModel.formattedCurrentDate,
              trailing: _buildRiwayatButton(context),
            ),
            body: const Center(
              child: CircularProgressIndicator(color: PotColors.primaryRed),
            ),
          );
        }

        return Scaffold(
          backgroundColor: PotColors.bgCream,
          appBar: AppHeader(
            showBackButton: true,
            title: 'Closing Harian',
            subtitle: _viewModel.formattedCurrentDate,
            trailing: _buildRiwayatButton(context),
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: RefreshIndicator(
              color: PotColors.primaryRed,
              backgroundColor: Colors.white,
              displacement: 40,
              onRefresh: () async {
                await _viewModel.refresh();
                if (context.mounted) {
                  AppToast.show(
                    context,
                    message: 'Data closing diperbarui.',
                    isSuccess: true,
                  );
                }
              },
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Lapak Information Card
                    LapakInfoCard(stall: _viewModel.stall),
                    const SizedBox(height: 14),

                    // Already closed notice banner
                    if (_viewModel.isAlreadyClosedToday) ...[
                      _buildAlreadyClosedBanner(_viewModel.todayClosing!),
                      const SizedBox(height: 14),
                    ],

                    // 2. Ringkasan Inventaris (Shift / Hari Ini)
                    ClosingInventorySummaryCard(
                      stokAwal: _viewModel.totalStokAwalHariIni,
                      barangMasuk: _viewModel.totalBarangMasukHariIni,
                      terjual: _viewModel.totalStokTerjualHariIni,
                      stokAkhir: _viewModel.stokSistem,
                    ),
                    const SizedBox(height: 14),

                    // 3. Penjualan Omzet Shift (Strictly for that day)
                    ClosingSalesSummaryCard(
                      tunai: _viewModel.tunaiSistem,
                      qris: _viewModel.qrisSistem,
                      transfer: _viewModel.transferSistem,
                      totalOmset: _viewModel.totalOmset,
                    ),
                    const SizedBox(height: 14),

                    // 4. Rekonsiliasi & Input Fisik Card
                    ClosingReconciliationCard(
                      stokSistem: _viewModel.stokSistem,
                      tunaiSistem: _viewModel.totalOmset,
                      effectiveStokFisik: _viewModel.effectiveStokFisik,
                      effectiveUangTunaiFisik: _viewModel.effectiveUangTunaiFisik,
                      selisihStok: _viewModel.selisihStok,
                      selisihUang: _viewModel.selisihUang,
                      catatan: _viewModel.catatan,
                      dynamicHintText: _viewModel.dynamicHintText,
                      suggestedNote: _viewModel.suggestedDiscrepancyNote,
                      hasDiscrepancy: _viewModel.hasAnyDiscrepancy,
                      onStokFisikChanged: _viewModel.setStokFisik,
                      onUangTunaiChanged: _viewModel.setUangTunaiFisik,
                      onCatatanChanged: _viewModel.setCatatan,
                    ),
                    const SizedBox(height: 18),

                    // 5. Primary Action Button
                    CustomButton(
                      label: _viewModel.isAlreadyClosedToday ? 'Kirim Ulang Closing' : 'Kirim Closing',
                      icon: Iconsax.send_1,
                      isLoading: _viewModel.isSubmitting,
                      onPressed: _handleSubmit,
                    ),
                    const SizedBox(height: 24),
                    const SkylineFooter(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlreadyClosedBanner(ClosingModel closing) {
    return Container(
      decoration: BoxDecoration(
        color: PotColors.cardCream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PotColors.primaryRed.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => ClosingDetailSheet.show(context, closing),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: PotColors.menuPink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.clipboard_tick,
                    size: 18,
                    color: PotColors.primaryRed,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Closing Hari Ini Sudah Dikirim',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: PotColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Status: ${closing.statusLabel} • ${CurrencyFormatter.formatRupiah(closing.totalOmset)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: PotColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                AttendanceStatusBadge(status: closing.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
