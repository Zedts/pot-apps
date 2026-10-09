import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/slip_gaji/salary_detail_modal.dart';
import '../../widgets/slip_gaji/salary_history_table.dart';
import '../../widgets/slip_gaji/salary_period_selector.dart';
import 'viewmodels/slip_gaji_view_model.dart';

/// Full payroll archive opened from the Slip Gaji table "Lihat Semua" action.
class SlipGajiHistoryScreen extends StatelessWidget {
  final SlipGajiViewModel viewModel;

  const SlipGajiHistoryScreen({
    super.key,
    required this.viewModel,
  });

  Future<void> _handleRefresh(BuildContext context) async {
    await viewModel.initialize();
    if (!context.mounted) return;
    AppToast.show(
      context,
      message: 'Data riwayat gaji berhasil diperbarui.',
      isSuccess: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: PotColors.bgCream,
          appBar: AppHeader(
            showBackButton: true,
            title: 'Riwayat Gaji',
            subtitle: viewModel.formattedCurrentDate,
          ),
          body: RefreshIndicator(
            color: PotColors.primaryRed,
            backgroundColor: PotColors.pureWhite,
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            onRefresh: () => _handleRefresh(context),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SalaryPeriodSelector(
                    label: viewModel.formattedSelectedPeriode,
                    onTap: () => SalaryPeriodSelector.pick(
                      context: context,
                      viewModel: viewModel,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 88,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Periode',
                            value: viewModel.formattedSelectedPeriode,
                            color: PotColors.textDark,
                            bgColor: PotColors.pureWhite,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Hari Kerja',
                            value: '${viewModel.hariKerja}',
                            color: PotColors.statusInfoText,
                            bgColor: PotColors.statusInfoBg,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Total Gaji',
                            value: CurrencyFormatter.formatRupiah(
                              viewModel.totalGaji,
                            ),
                            color: PotColors.statusSuccessText,
                            bgColor: PotColors.statusSuccessBg,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (viewModel.isLoading && viewModel.payrolls.isEmpty)
                    const Padding(
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
                    )
                  else
                    SalaryHistoryTable(
                      title: 'Riwayat Gaji',
                      items: viewModel.filteredRiwayatGaji,
                      selectedPayrollId: viewModel.selectedPayroll?.id,
                      onRowTap: (item) => SalaryDetailModal.showFromViewModel(
                        context,
                        viewModel,
                        payroll: item,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color == PotColors.textDark ? PotColors.textMuted : color,
            ),
          ),
        ],
      ),
    );
  }
}
