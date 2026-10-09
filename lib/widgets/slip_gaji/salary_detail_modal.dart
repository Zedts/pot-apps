import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/payroll_model.dart';
import '../../core/models/slip_gaji_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../screens/slip_gaji/viewmodels/slip_gaji_view_model.dart';
import '../common/app_toast.dart';

/// Bottom sheet presenting the full payroll detail including working days,
/// sales reference, breakdown, and the optional PDF salary slip link.
///
/// Pattern matches [ClosingDetailSheet] drag handle, header, and layout style.
class SalaryDetailModal extends StatelessWidget {
  final PayrollModel payroll;
  final SlipGajiModel? slipGaji;

  const SalaryDetailModal({
    super.key,
    required this.payroll,
    this.slipGaji,
  });

  static Future<void> show(
    BuildContext context,
    PayrollModel payroll,
    SlipGajiModel? slipGaji,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SalaryDetailModal(payroll: payroll, slipGaji: slipGaji),
    );
  }

  static Future<void> showFromViewModel(
    BuildContext context,
    SlipGajiViewModel viewModel, {
    PayrollModel? payroll,
  }) async {
    final target = payroll ?? viewModel.selectedPayroll;
    if (target == null) return;
    viewModel.selectPayroll(target);
    await viewModel.loadSlipGajiForSelected();
    if (!context.mounted) return;
    await show(context, target, viewModel.selectedSlipGaji);
  }

  @override
  Widget build(BuildContext context) {
    final hasPdf = slipGaji?.hasPdf ?? false;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Slip Gaji',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: PotColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      payroll.formattedPeriode,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: PotColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: payroll.isPublished
                        ? PotColors.statusSuccessBg
                        : PotColors.cardCream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: payroll.isPublished
                          ? PotColors.statusSuccessBorder
                          : PotColors.warmBorder,
                    ),
                  ),
                  child: Text(
                    payroll.statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: payroll.isPublished
                          ? PotColors.statusSuccessText
                          : PotColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: PotColors.warmBorder),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: PotColors.pureWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: PotColors.warmBorder),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Iconsax.calendar_1,
                          label: 'Periode',
                          value: payroll.formattedPeriode,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          icon: Iconsax.briefcase,
                          label: 'Hari Kerja',
                          value: '${payroll.hariKerja} hari',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          icon: Iconsax.chart_1,
                          label: 'Total Penjualan',
                          value: CurrencyFormatter.formatRupiah(payroll.totalPenjualan),
                        ),
                        if (payroll.user?.nama.isNotEmpty ?? false) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Iconsax.user,
                            label: 'Penerima',
                            value: payroll.user!.nama,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: PotColors.pureWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: PotColors.warmBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rincian Gaji',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: PotColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildDataRow('Gaji Pokok', CurrencyFormatter.formatRupiah(payroll.gajiPokok)),
                        const SizedBox(height: 6),
                        _buildDataRow('Bonus Penjualan', CurrencyFormatter.formatRupiah(payroll.bonusPenjualan)),
                        const SizedBox(height: 6),
                        _buildDataRow('Lembur', CurrencyFormatter.formatRupiah(payroll.lembur)),
                        const SizedBox(height: 8),
                        const Divider(height: 1, color: PotColors.warmBorder),
                        const SizedBox(height: 8),
                        _buildDataRow(
                          'Potongan',
                          CurrencyFormatter.formatRupiah(payroll.potongan),
                          isPotongan: true,
                        ),
                        const SizedBox(height: 6),
                        _buildDataRow('Kasbon', CurrencyFormatter.formatRupiah(payroll.kasbon)),
                        const SizedBox(height: 8),
                        Divider(height: 1, color: PotColors.warmBorder.withValues(alpha: 0.7)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Gaji',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: PotColors.textDark,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatRupiah(payroll.totalGaji),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: PotColors.statusSuccessText,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (hasPdf) ...[
                    const SizedBox(height: 14),
                    _buildPdfCard(context),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfCard(BuildContext context) {
    final url = slipGaji!.fileUrl!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PotColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PotColors.warmBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: PotColors.accentRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Iconsax.document,
                  size: 16,
                  color: PotColors.primaryRed,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dokumen Slip Gaji PDF',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: PotColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Salin tautan untuk membuka di browser',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: PotColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: PotColors.warmBorder),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              AppToast.showSuccess(context, 'Tautan slip gaji siap disalin.');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: PotColors.cardCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PotColors.warmBorder),
              ),
              child: SelectableText(
                url,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: PotColors.textDark,
                  height: 1.4,
                ),
                maxLines: 4,
                onTap: () {
                  AppToast.showSuccess(context, 'Salin tautan untuk membuka slip PDF.');
                },
              ),
            ),
          ),
          if ((slipGaji?.tanggal.isNotEmpty ?? false)) ...[
            const SizedBox(height: 10),
            Text(
              'Tanggal upload: ${slipGaji!.formattedTanggal}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: PotColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: PotColors.primaryRed),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: PotColors.textMuted,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: PotColors.textDark,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(String label, String value, {bool isPotongan = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: PotColors.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isPotongan ? PotColors.primaryRed : PotColors.textDark,
          ),
        ),
      ],
    );
  }
}
