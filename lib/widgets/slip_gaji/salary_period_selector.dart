import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../screens/slip_gaji/viewmodels/slip_gaji_view_model.dart';
import '../common/app_toast.dart';

/// Shared period dropdown used by Slip Gaji and Riwayat Gaji.
class SalaryPeriodSelector extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SalaryPeriodSelector({
    super.key,
    required this.label,
    required this.onTap,
  });

  static Future<void> pick({
    required BuildContext context,
    required SlipGajiViewModel viewModel,
  }) async {
    final periods = viewModel.availablePeriods;
    if (periods.isEmpty) {
      AppToast.showError(context, 'Belum ada periode gaji yang tersedia.');
      return;
    }

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SalaryPeriodPickerSheet(
        periods: periods,
        selectedPeriode: viewModel.selectedPayroll?.periode,
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      viewModel.selectPeriode(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: PotColors.pureWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: PotColors.warmBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Iconsax.calendar_2,
              size: 17,
              color: PotColors.primaryRed,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: PotColors.textDark,
                ),
              ),
            ),
            const Icon(
              Iconsax.arrow_down_1,
              size: 16,
              color: PotColors.primaryRed,
            ),
          ],
        ),
      ),
    );
  }
}

class SalaryPeriodPickerSheet extends StatelessWidget {
  final List<String> periods;
  final String? selectedPeriode;

  const SalaryPeriodPickerSheet({
    super.key,
    required this.periods,
    required this.selectedPeriode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: PotColors.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: PotColors.warmBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pilih Periode Gaji',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: PotColors.textDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: PotColors.warmBorder),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                children: [
                  for (final periode in periods)
                    Builder(
                      builder: (context) {
                        final isSelected = periode == selectedPeriode;
                        final label = DateFormatter.formatPeriode(periode);
                        return GestureDetector(
                          onTap: () => Navigator.of(context).pop(periode),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? PotColors.accentRed.withValues(alpha: 0.10)
                                  : PotColors.pureWhite,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? PotColors.primaryRed.withValues(alpha: 0.4)
                                    : PotColors.warmBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? PotColors.primaryRed
                                          : PotColors.textDark,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Iconsax.tick_circle,
                                    size: 18,
                                    color: PotColors.primaryRed,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
