import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../common/confirmation_dialog.dart';
import '../common/custom_text_field.dart';
import '../common/dynamic_field_hint.dart';

/// Card containing physical count and drawer cash reconciliation inputs,
/// dynamic discrepancy calculations, and note field with dynamic hint matching ref/closingan.html.
class ClosingReconciliationCard extends StatefulWidget {
  final int stokSistem;
  final int tunaiSistem;
  final int effectiveStokFisik;
  final int effectiveUangTunaiFisik;
  final int selisihStok;
  final int selisihUang;
  final String catatan;
  final String dynamicHintText;
  final String suggestedNote;
  final bool hasDiscrepancy;
  final bool isReadOnly;
  final ValueChanged<int?> onStokFisikChanged;
  final ValueChanged<int?> onUangTunaiChanged;
  final ValueChanged<String> onCatatanChanged;

  const ClosingReconciliationCard({
    super.key,
    required this.stokSistem,
    required this.tunaiSistem,
    required this.effectiveStokFisik,
    required this.effectiveUangTunaiFisik,
    required this.selisihStok,
    required this.selisihUang,
    required this.catatan,
    required this.dynamicHintText,
    required this.suggestedNote,
    required this.hasDiscrepancy,
    this.isReadOnly = false,
    required this.onStokFisikChanged,
    required this.onUangTunaiChanged,
    required this.onCatatanChanged,
  });

  @override
  State<ClosingReconciliationCard> createState() => _ClosingReconciliationCardState();
}

class _ClosingReconciliationCardState extends State<ClosingReconciliationCard> {
  late final TextEditingController _stokController;
  late final TextEditingController _uangController;
  late final TextEditingController _catatanController;

  @override
  void initState() {
    super.initState();
    _stokController = TextEditingController(text: widget.effectiveStokFisik.toString());
    _uangController = TextEditingController(
      text: CurrencyFormatter.formatRupiah(widget.effectiveUangTunaiFisik, withPrefix: false),
    );
    _catatanController = TextEditingController(text: widget.catatan);
  }

  @override
  void didUpdateWidget(covariant ClosingReconciliationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.catatan != _catatanController.text) {
      _catatanController.text = widget.catatan;
    }
    if (oldWidget.effectiveStokFisik != widget.effectiveStokFisik || oldWidget.stokSistem != widget.stokSistem) {
      final currentParsed = int.tryParse(_stokController.text.trim()) ?? 0;
      if (currentParsed == oldWidget.effectiveStokFisik || currentParsed == oldWidget.stokSistem || _stokController.text.isEmpty || _stokController.text == '0') {
        _stokController.text = widget.effectiveStokFisik.toString();
      }
    }
    if (oldWidget.effectiveUangTunaiFisik != widget.effectiveUangTunaiFisik || oldWidget.tunaiSistem != widget.tunaiSistem) {
      final currentDigits = _uangController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final currentParsed = int.tryParse(currentDigits) ?? 0;
      if (currentParsed == oldWidget.effectiveUangTunaiFisik || currentParsed == oldWidget.tunaiSistem || _uangController.text.isEmpty || _uangController.text == '0') {
        _uangController.text = CurrencyFormatter.formatRupiah(widget.effectiveUangTunaiFisik, withPrefix: false);
      }
    }
  }

  @override
  void dispose() {
    _stokController.dispose();
    _uangController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _handleHintTap(BuildContext context) async {
    if (!widget.hasDiscrepancy || widget.isReadOnly) return;

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Gunakan Catatan Selisih?',
      content: 'Apakah Anda ingin mengisi catatan closing dengan:\n\n"${widget.suggestedNote}"?',
      confirmLabel: 'Gunakan Catatan',
      cancelLabel: 'Batal',
      confirmColor: PotColors.primaryRed,
    );

    if (confirmed == true && mounted) {
      _catatanController.text = widget.suggestedNote;
      widget.onCatatanChanged(widget.suggestedNote);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Stok Fisik Input & Live Selisih Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Stok Fisik (Hitung manual)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: PotColors.textDark,
                ),
              ),
              Text(
                'Unit / pcs',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: PotColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          CustomTextField(
            label: '',
            controller: _stokController,
            hintText: '0',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            readOnly: widget.isReadOnly,
            onChanged: (val) {
              final clean = val.trim();
              final parsed = clean.isEmpty ? 0 : int.tryParse(clean);
              widget.onStokFisikChanged(parsed);
            },
          ),
          const SizedBox(height: 6),

          // Stok Selisih Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Selisih Fisik vs Sistem:',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: PotColors.textMuted,
                ),
              ),
              _buildStokBadge(widget.selisihStok),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: PotColors.warmBorder),
          const SizedBox(height: 14),

          // 2. Uang Tunai Fisik Input & Live Selisih Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Uang Fisik (Hitung manual)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: PotColors.textDark,
                ),
              ),
              Text(
                'Total Penerimaan',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: PotColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          CustomTextField(
            label: '',
            controller: _uangController,
            hintText: '0',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            prefixText: 'Rp ',
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyFormatter.inputFormatter,
            ],
            readOnly: widget.isReadOnly,
            onChanged: (val) {
              final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
              final parsed = digits.isEmpty ? 0 : int.tryParse(digits);
              widget.onUangTunaiChanged(parsed);
            },
          ),
          const SizedBox(height: 6),

          // Uang Tunai Selisih Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Selisih Fisik vs Total Penjualan:',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: PotColors.textMuted,
                ),
              ),
              _buildUangBadge(widget.selisihUang),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: PotColors.warmBorder),
          const SizedBox(height: 14),

          // 3. Catatan Field & Dynamic Field Hint
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Catatan (opsional)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: PotColors.textDark,
                ),
              ),
              Text(
                'Keterangan selisih / kendala',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: PotColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          CustomTextField(
            label: '',
            controller: _catatanController,
            hintText: 'Tulis catatan...',
            maxLines: 2,
            textInputAction: TextInputAction.done,
            onSubmitted: () => FocusScope.of(context).unfocus(),
            readOnly: widget.isReadOnly,
            onChanged: widget.onCatatanChanged,
          ),
          const SizedBox(height: 6),

          // Reusable Dynamic Field Hint
          DynamicFieldHint(
            hintText: widget.dynamicHintText,
            isWarning: widget.hasDiscrepancy,
            onTap: widget.hasDiscrepancy ? () => _handleHintTap(context) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStokBadge(int selisih) {
    if (selisih == 0) {
      return const Text(
        '0 pcs (Sesuai)',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: PotColors.statusSuccessText,
        ),
      );
    } else if (selisih < 0) {
      return Text(
        '- ${selisih.abs()} pcs (Kurang)',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: PotColors.statusWarningText,
        ),
      );
    } else {
      return Text(
        '+ $selisih pcs (Lebih)',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: PotColors.statusInfoText,
        ),
      );
    }
  }

  Widget _buildUangBadge(int selisih) {
    if (selisih == 0) {
      return const Text(
        'Rp 0 (Sesuai)',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: PotColors.statusSuccessText,
        ),
      );
    } else if (selisih < 0) {
      return Text(
        '- ${CurrencyFormatter.formatRupiah(selisih.abs())} (Kurang)',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: PotColors.statusWarningText,
        ),
      );
    } else {
      return Text(
        '+ ${CurrencyFormatter.formatRupiah(selisih)} (Lebih)',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: PotColors.statusInfoText,
        ),
      );
    }
  }
}
