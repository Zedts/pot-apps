import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_colors.dart';
import '../common/custom_button.dart';

/// Digital signature field for pengiriman transfer DO.
/// Tapping the field opens an isolated full-canvas modal sheet where the user
/// can draw their signature freely with zero scroll-view interference.
class TtdPengirimCanvas extends StatefulWidget {
  final File? initialFile;
  final ValueChanged<File?> onSignatureChanged;
  final bool disabled;

  const TtdPengirimCanvas({
    super.key,
    this.initialFile,
    required this.onSignatureChanged,
    this.disabled = false,
  });

  @override
  State<TtdPengirimCanvas> createState() => _TtdPengirimCanvasState();
}

class _TtdPengirimCanvasState extends State<TtdPengirimCanvas> {
  File? _signatureFile;

  @override
  void initState() {
    super.initState();
    _signatureFile = widget.initialFile;
  }

  @override
  void didUpdateWidget(covariant TtdPengirimCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFile != oldWidget.initialFile) {
      _signatureFile = widget.initialFile;
    }
  }

  Future<void> _openSignatureModal() async {
    if (widget.disabled) return;

    final result = await showModalBottomSheet<File>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SignatureCanvasModal(),
    );

    if (result != null) {
      setState(() {
        _signatureFile = result;
      });
      widget.onSignatureChanged(result);
    }
  }

  void _clearSignature() {
    if (widget.disabled) return;
    setState(() {
      _signatureFile = null;
    });
    widget.onSignatureChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final hasSignature = _signatureFile != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PotColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PotColors.warmBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanda Tangan Pengirim (Opsional)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: PotColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Ketuk untuk membuka kanvas tanda tangan',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: PotColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (hasSignature && !widget.disabled) ...[
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: _openSignatureModal,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: PotColors.cardCream,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: PotColors.warmBorder),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.edit_2, size: 12, color: PotColors.textDark),
                            SizedBox(width: 3),
                            Text(
                              'Ubah',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: PotColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: _clearSignature,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: PotColors.menuPink,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: PotColors.primaryRed.withValues(alpha: 0.2)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.trash, size: 12, color: PotColors.primaryRed),
                            SizedBox(width: 3),
                            Text(
                              'Hapus',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: PotColors.primaryRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // Main Interactive Card / Preview
          if (hasSignature)
            InkWell(
              onTap: widget.disabled ? null : _openSignatureModal,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                height: 100,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: PotColors.warmBorder),
                ),
                child: Image.file(
                  _signatureFile!,
                  fit: BoxFit.contain,
                ),
              ),
            )
          else
            InkWell(
              onTap: widget.disabled ? null : _openSignatureModal,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: PotColors.cardCream.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: PotColors.warmBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: PotColors.accentRed.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Iconsax.edit,
                        size: 20,
                        color: PotColors.primaryRed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Goreskan Tanda Tangan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: PotColors.textDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Buka kanvas layar penuh untuk menandatangani',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: PotColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: PotColors.primaryRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.edit_2, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Buka Kanvas',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Status Indicator
          Row(
            children: [
              Icon(
                hasSignature ? Icons.check_circle_outline : Icons.info_outline,
                size: 13,
                color: hasSignature ? PotColors.locationGreen : PotColors.textLight,
              ),
              const SizedBox(width: 4),
              Text(
                hasSignature ? 'Tanda tangan tersimpan' : 'Belum ditandatangani',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: hasSignature ? PotColors.locationGreen : PotColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dedicated modal sheet presenting an isolated drawing canvas with no scroll conflicts.
class SignatureCanvasModal extends StatefulWidget {
  const SignatureCanvasModal({super.key});

  @override
  State<SignatureCanvasModal> createState() => _SignatureCanvasModalState();
}

class _SignatureCanvasModalState extends State<SignatureCanvasModal> {
  final List<Offset?> _points = [];
  bool _hasDrawn = false;
  bool _isSaving = false;

  void _addPoint(Offset? point) {
    setState(() {
      _points.add(point);
      if (!_hasDrawn && point != null) {
        _hasDrawn = true;
      }
    });
  }

  void _clear() {
    setState(() {
      _points.clear();
      _hasDrawn = false;
    });
  }

  Future<void> _handleSave() async {
    if (_points.isEmpty || !_hasDrawn) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isSaving = true);

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 240);

      // Pure white background
      final bgPaint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

      // Black ink strokes
      final strokePaint = Paint()
        ..color = Colors.black
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 3.0;

      for (int i = 0; i < _points.length - 1; i++) {
        final p1 = _points[i];
        final p2 = _points[i + 1];
        if (p1 != null && p2 != null) {
          canvas.drawLine(p1, p2, strokePaint);
        } else if (p1 != null && p2 == null) {
          canvas.drawCircle(p1, 1.5, strokePaint);
        }
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final buffer = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/ttd_pengirim_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(buffer);

        if (mounted) {
          Navigator.of(context).pop(file);
        }
      } else if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('[SignatureCanvasModal] Error exporting signature: $e');
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: PotColors.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
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
          const SizedBox(height: 12),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tanda Tangan Petugas Pengirim',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: PotColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: PotColors.warmBorder.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: PotColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Goreskan tanda tangan Anda pada kanvas di bawah ini:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: PotColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),

          // Full-Canvas Drawing Box (Completely isolated, zero gesture conflicts)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PotColors.warmBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (details) => _addPoint(details.localPosition),
                    onPanUpdate: (details) => _addPoint(details.localPosition),
                    onPanEnd: (details) => _addPoint(null),
                    child: CustomPaint(
                      painter: _SignaturePainter(points: _points),
                      size: Size.infinite,
                    ),
                  ),
                  if (!_hasDrawn)
                    IgnorePointer(
                      child: Center(
                        child: Text(
                          'Tanda tangani di sini',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: PotColors.textLight.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Modal Actions
          Row(
            children: [
              // Ulangi / Hapus
              InkWell(
                onTap: _hasDrawn ? _clear : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _hasDrawn ? PotColors.pureWhite : PotColors.cardCream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PotColors.warmBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.refresh,
                        size: 16,
                        color: _hasDrawn ? PotColors.primaryRed : PotColors.textLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ulangi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _hasDrawn ? PotColors.primaryRed : PotColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Simpan Tanda Tangan
              Expanded(
                child: CustomButton(
                  label: 'Simpan Tanda Tangan',
                  icon: Iconsax.tick_circle,
                  isLoading: _isSaving,
                  isDisabled: !_hasDrawn || _isSaving,
                  onPressed: _handleSave,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  _SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, paint);
      } else if (p1 != null && p2 == null) {
        canvas.drawCircle(p1, 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
