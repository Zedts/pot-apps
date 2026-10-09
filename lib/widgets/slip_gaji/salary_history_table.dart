import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/payroll_model.dart';
import '../../core/utils/currency_formatter.dart';

/// Preview or full payroll history table bound to GET /payroll list fields.
class SalaryHistoryTable extends StatelessWidget {
  final List<PayrollModel> items;
  final String? selectedPayrollId;
  final ValueChanged<PayrollModel> onRowTap;
  final VoidCallback? onSeeAllTap;
  final String title;

  const SalaryHistoryTable({
    super.key,
    required this.items,
    required this.onRowTap,
    this.selectedPayrollId,
    this.onSeeAllTap,
    this.title = 'Riwayat Gaji',
  });

  static const int previewRowLimit = 3;

  @override
  Widget build(BuildContext context) {
    final visibleItems = onSeeAllTap == null
        ? items
        : items.take(previewRowLimit).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: PotColors.pureWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PotColors.warmBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: PotColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              if (onSeeAllTap != null)
                InkWell(
                  onTap: onSeeAllTap,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: PotColors.primaryRed,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: PotColors.primaryRed,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (visibleItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Belum ada riwayat gaji.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: PotColors.textMuted,
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PotColors.warmBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    color: PotColors.cardCream,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            'PERIODE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: PotColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'HARI KERJA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: PotColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            'TOTAL GAJI',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: PotColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...visibleItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isLast = index == items.length - 1;
                    final isSelected = item.id == selectedPayrollId;

                    return InkWell(
                      onTap: () => onRowTap(item),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? PotColors.accentRed.withValues(alpha: 0.06)
                              : PotColors.pureWhite,
                          border: isLast
                              ? null
                              : const Border(
                                  bottom: BorderSide(color: PotColors.warmBorder),
                                ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.formattedPeriode,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? PotColors.primaryRed
                                          : PotColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    'Penjualan ${CurrencyFormatter.formatRupiah(item.totalPenjualan)}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: PotColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                '${item.hariKerja} hari',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: PotColors.textDark,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                CurrencyFormatter.formatRupiah(item.totalGaji),
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: PotColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
