import 'dart:io';
import 'package:flutter/material.dart';
import '../common/proof_photo_upload_card.dart';

/// Card for uploading payment proof (Bukti QRIS / Transfer)
/// Reuses the common [ProofPhotoUploadCard] with contextual labels.
class PenjualanBuktiUploadCard extends StatelessWidget {
  final File? photoFile;
  final String paymentMethod;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onRemoveTap;

  const PenjualanBuktiUploadCard({
    super.key,
    required this.photoFile,
    required this.paymentMethod,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    final isQris = paymentMethod.toLowerCase() == 'qris';
    final title = isQris ? 'Upload Bukti QRIS' : 'Upload Bukti Transfer';

    return ProofPhotoUploadCard(
      photoFile: photoFile,
      title: title,
      subtitle: 'Wajib upload foto/screenshot bukti transaksi $title',
      sheetTitle: 'Unggah Bukti Pembayaran',
      sheetSubtitle: 'Pilih sumber foto bukti pembayaran transaksi',
      statusText: 'Bukti Pembayaran Terlampir',
      onCameraTap: onCameraTap,
      onGalleryTap: onGalleryTap,
      onRemoveTap: onRemoveTap,
    );
  }
}
