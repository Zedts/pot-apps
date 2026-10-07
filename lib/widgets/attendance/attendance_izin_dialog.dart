import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../screens/attendance/viewmodels/attendance_view_model.dart';
import '../common/custom_button.dart';

/// Bottom sheet dialog for submitting absence / permission request (Izin / Sakit).
class AttendanceIzinDialog extends StatefulWidget {
  final AttendanceViewModel viewModel;

  const AttendanceIzinDialog({
    super.key,
    required this.viewModel,
  });

  static Future<bool?> show(BuildContext context, {required AttendanceViewModel viewModel}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AttendanceIzinDialog(viewModel: viewModel),
    );
  }

  @override
  State<AttendanceIzinDialog> createState() => _AttendanceIzinDialogState();
}

class _AttendanceIzinDialogState extends State<AttendanceIzinDialog> {
  final TextEditingController _keteranganController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final text = _keteranganController.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Harap isi alasan izin / sakit.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final success = await widget.viewModel.submitIzin(keterangan: text);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSubmitting = false;
        _error = widget.viewModel.errorMessage ?? 'Gagal mengajukan izin.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: PotColors.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PotColors.warmBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Pengajuan Izin / Sakit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: PotColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sampaikan alasan tidak dapat hadir di lapak hari ini.',
              style: TextStyle(
                fontSize: 12,
                color: PotColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _keteranganController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tuliskan alasan izin / sakit...',
                hintStyle: const TextStyle(fontSize: 12, color: PotColors.textMuted),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: PotColors.warmBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: PotColors.warmBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: PotColors.primaryRed, width: 1.5),
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: PotColors.primaryRed,
                ),
              ),
            ],

            const SizedBox(height: 18),

            CustomButton(
              label: 'Kirim Pengajuan Izin',
              onPressed: _handleSubmit,
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}
