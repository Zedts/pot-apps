import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../common/confirmation_dialog.dart';
import '../common/custom_text_field.dart';
import '../common/dynamic_field_hint.dart';

/// Catatan input card with dynamic discrepancy hint text & ConfirmationDialog auto-fill
class PenerimaanCatatanCard extends StatefulWidget {
  final String catatan;
  final ValueChanged<String> onCatatanChanged;
  final String hintText;
  final bool hasDiscrepancy;
  final int totalSelisih;
  final List<String> discrepantItems;

  const PenerimaanCatatanCard({
    super.key,
    required this.catatan,
    required this.onCatatanChanged,
    required this.hintText,
    required this.hasDiscrepancy,
    required this.totalSelisih,
    required this.discrepantItems,
  });

  @override
  State<PenerimaanCatatanCard> createState() => _PenerimaanCatatanCardState();
}

class _PenerimaanCatatanCardState extends State<PenerimaanCatatanCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.catatan);
  }

  @override
  void didUpdateWidget(covariant PenerimaanCatatanCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.catatan != _controller.text) {
      _controller.text = widget.catatan;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleHintTap(BuildContext context) async {
    if (!widget.hasDiscrepancy) return;

    final itemsStr = widget.discrepantItems.join(', ');
    final suggestedNote = 'Terdapat selisih ${widget.totalSelisih} pcs pada $itemsStr';

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Gunakan Catatan Selisih?',
      content: 'Apakah Anda ingin mengisi catatan penerimaan dengan:\n\n"$suggestedNote"?',
      confirmLabel: 'Gunakan Catatan',
      cancelLabel: 'Batal',
      confirmColor: PotColors.primaryRed,
    );

    if (confirmed == true && mounted) {
      _controller.text = suggestedNote;
      widget.onCatatanChanged(suggestedNote);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: PotColors.pureWhite,
        borderRadius: BorderRadius.circular(28),
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
          // Section Label matching ref/penerimaan.html
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Catatan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: PotColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Opsional / Keterangan selisih',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: PotColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // CustomTextField for input
          CustomTextField(
            label: '',
            controller: _controller,
            hintText: 'Tuliskan catatan penerimaan...',
            maxLines: 2,
            onChanged: widget.onCatatanChanged,
          ),
          const SizedBox(height: 8),

          // Dynamic hint text using reusable component
          DynamicFieldHint(
            hintText: widget.hintText,
            isWarning: widget.hasDiscrepancy,
            onTap: widget.hasDiscrepancy ? () => _handleHintTap(context) : null,
          ),
        ],
      ),
    );
  }
}
