import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../widgets/auth/login/skyline_footer.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/slip_gaji/salary_breakdown_card.dart';
import '../../widgets/slip_gaji/salary_detail_modal.dart';
import '../../widgets/slip_gaji/salary_history_table.dart';
import '../../widgets/slip_gaji/salary_period_selector.dart';
import 'slip_gaji_history_screen.dart';
import 'viewmodels/slip_gaji_view_model.dart';

/// Main Slip Gaji (Salary Slip) screen matching ref/slipGaji.html reference design.
class SlipGajiScreen extends StatefulWidget {
  final UserModel? currentUser;

  const SlipGajiScreen({
    super.key,
    this.currentUser,
  });

  @override
  State<SlipGajiScreen> createState() => _SlipGajiScreenState();
}

class _SlipGajiScreenState extends State<SlipGajiScreen> {
  late final SlipGajiViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SlipGajiViewModel(currentUser: widget.currentUser);
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleLihatDetail() async {
    await SalaryDetailModal.showFromViewModel(context, _viewModel);
  }

  void _openRiwayatScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SlipGajiHistoryScreen(viewModel: _viewModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (ctx, _) {
        return Scaffold(
          backgroundColor: PotColors.bgCream,
          appBar: AppHeader(
            showBackButton: true,
            title: 'Slip Gaji',
            subtitle: _viewModel.formattedCurrentDate,
          ),
          body: RefreshIndicator(
            color: PotColors.primaryRed,
            onRefresh: _viewModel.initialize,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SalaryPeriodSelector(
                    label: _viewModel.formattedSelectedPeriode,
                    onTap: () => SalaryPeriodSelector.pick(
                      context: ctx,
                      viewModel: _viewModel,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_viewModel.hasError)
                    _buildErrorBanner(ctx, _viewModel.errorMessage!),
                  if (_viewModel.isLoading && !_viewModel.hasPayrollData)
                    _buildLoadingView(ctx)
                  else if (!_viewModel.hasPayrollData)
                    _buildEmptyState(ctx)
                  else ...[
                    SalaryBreakdownCard(
                      gajiPokok: _viewModel.gajiPokok,
                      bonusPenjualan: _viewModel.bonusPenjualan,
                      lembur: _viewModel.lembur,
                      potongan: _viewModel.potongan,
                      kasbon: _viewModel.kasbon,
                      totalGaji: _viewModel.totalGaji,
                      isOpening: _viewModel.isOpeningDetail,
                      onLihatDetail: _handleLihatDetail,
                    ),
                  ],
                  const SizedBox(height: 14),
                  SalaryHistoryTable(
                    items: _viewModel.payrolls,
                    selectedPayrollId: _viewModel.selectedPayroll?.id,
                    onRowTap: (item) => SalaryDetailModal.showFromViewModel(
                      ctx,
                      _viewModel,
                      payroll: item,
                    ),
                    onSeeAllTap: _openRiwayatScreen,
                  ),
                  const SizedBox(height: 20),
                  const SkylineFooter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            color: PotColors.primaryRed,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: PotColors.accentRed.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PotColors.accentRed.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Iconsax.info_circle, size: 16, color: PotColors.primaryRed),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: PotColors.primaryRed,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: PotColors.cardCream,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PotColors.warmBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: PotColors.accentRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(Iconsax.wallet_money, size: 24, color: PotColors.primaryRed),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum Ada Slip Gaji',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: PotColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Slip gaji untuk periode ini belum tersedia. Silakan hubungi admin HRD untuk informasi lebih lanjut.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: PotColors.textMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
