import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../widgets/auth/login/skyline_footer.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/proof_photo_upload_card.dart';
import '../../widgets/penerimaan/penerimaan_catatan_card.dart';
import '../../widgets/penerimaan/penerimaan_location_card.dart';
import '../../widgets/penerimaan/penerimaan_received_items_card.dart';
import '../../widgets/penerimaan/penerimaan_shipment_picker_card.dart';
import '../../widgets/penerimaan/pengiriman_inspection_sheet.dart';
import 'penerimaan_history_screen.dart';
import 'pengiriman_list_screen.dart';
import 'viewmodels/penerimaan_view_model.dart';

/// Main screen for Terima Barang (Penerimaan) feature
class PenerimaanScreen extends StatefulWidget {
  final UserModel? currentUser;

  const PenerimaanScreen({
    super.key,
    this.currentUser,
  });

  @override
  State<PenerimaanScreen> createState() => _PenerimaanScreenState();
}

class _PenerimaanScreenState extends State<PenerimaanScreen> {
  late final PenerimaanViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PenerimaanViewModel();
    _viewModel.init(currentUser: widget.currentUser);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _openShipmentInspection(BuildContext context, dynamic shipment) {
    PengirimanInspectionSheet.show(
      context,
      initialShipment: shipment,
      loadDetail: _viewModel.getShipmentDetail,
      onSelectShipment: (detailed) {
        _viewModel.selectShipment(detailed);
      },
      onToggleStatus: (updated) async {
        await _viewModel.updateShipment(updated);
      },
    );
  }


  Future<void> _handleSimpanPenerimaan() async {
    if (_viewModel.hasDiscrepancy) {
      // Prompt confirmation if there are quantity discrepancies
      final confirmed = await ConfirmationDialog.show(
        context,
        title: 'Konfirmasi Selisih Barang',
        content:
            'Terdapat selisih sebanyak ${_viewModel.totalSelisih} pcs pada '
            '${_viewModel.discrepantItemNames.join(", ")}.\n\n'
            'Apakah Anda yakin ingin menyimpan penerimaan dengan status SELISIH?',
        confirmLabel: 'Ya, Simpan Selisih',
        cancelLabel: 'Periksa Kembali',
        confirmColor: PotColors.primaryRed,
      );
      if (confirmed == true && mounted) {
        await _executeSubmit();
      }
    } else {
      await _executeSubmit();
    }
  }

  Future<void> _executeSubmit() async {
    final result = await _viewModel.submitPenerimaan();
    if (!mounted) return;

    if (result != null) {
      AppToast.show(
        context,
        message: 'Penerimaan barang berhasil disimpan (${result.status.toUpperCase()}).',
        isSuccess: true,
      );
    } else if (_viewModel.errorMessage != null) {
      AppToast.show(
        context,
        message: _viewModel.errorMessage!,
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: PotColors.bgCream,
          appBar: AppHeader(
            showBackButton: true,
            title: 'Terima Barang',
            subtitle: _viewModel.formattedCurrentDate,
            trailing: _buildHeaderActions(context),
          ),
          body: RefreshIndicator(
            color: PotColors.primaryRed,
            backgroundColor: Colors.white,
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            onRefresh: () async {
              await _viewModel.refreshShipments();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
              child: Column(
                children: [
                  // 1. Stall Location Info Card
                  PenerimaanLocationCard(stall: _viewModel.stall),
                  const SizedBox(height: 14),

                  // 2. Upload Foto Nota Card (Reusable Component)
                  ProofPhotoUploadCard(
                    photoFile: _viewModel.capturedFotoNota,
                    title: 'Unggah Foto Nota',
                    subtitle: 'Ambil foto nota fisik pengiriman barang',
                    sheetTitle: 'Unggah Foto Nota',
                    sheetSubtitle: 'Pilih sumber pengambilan foto nota fisik pengiriman',
                    statusText: 'Foto Nota Terlampir',
                    onCameraTap: () => _viewModel.captureFotoNota(source: ImageSource.camera),
                    onGalleryTap: () => _viewModel.captureFotoNota(source: ImageSource.gallery),
                    onRemoveTap: _viewModel.clearFotoNota,
                  ),
                  const SizedBox(height: 14),

                  // 3. Dynamic Card: Picker (Top 3) vs Received Items Checklist
                  if (_viewModel.selectedShipment == null)
                    PenerimaanShipmentPickerCard(
                      shipments: _viewModel.quickPickShipments,
                      onShipmentTap: (s) => _openShipmentInspection(context, s),
                      onSeeAllTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PengirimanListScreen(viewModel: _viewModel),
                          ),
                        );
                      },
                    )
                  else
                    PenerimaanReceivedItemsCard(
                      shipment: _viewModel.selectedShipment!,
                      items: _viewModel.verifiedItems,
                      onQtyChanged: _viewModel.updateItemQtyTerima,
                      onBackTap: _viewModel.cancelShipmentSelection,
                    ),
                  const SizedBox(height: 14),

                  // 4. Catatan Section & Dynamic Discrepancy Hint
                  PenerimaanCatatanCard(
                    catatan: _viewModel.catatan,
                    onCatatanChanged: _viewModel.setCatatan,
                    hintText: _viewModel.discrepancyHintText,
                    hasDiscrepancy: _viewModel.hasDiscrepancy,
                    totalSelisih: _viewModel.totalSelisih,
                    discrepantItems: _viewModel.discrepantItemNames,
                  ),
                  const SizedBox(height: 18),

                  // 5. Primary Action: Simpan Penerimaan (Disabled when unselected)
                  CustomButton(
                    label: 'Simpan Penerimaan',
                    icon: Iconsax.box_add,
                    isDisabled: !_viewModel.canSubmit,
                    isLoading: _viewModel.isSubmitting,
                    onPressed: _handleSimpanPenerimaan,
                  ),
                  const SizedBox(height: 24),
                  const SkylineFooter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Action buttons at the top right of the header matching ref/penerimaan.html
  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Button: Riwayat Penerimaan (Document Icon)
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PenerimaanHistoryScreen(viewModel: _viewModel),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: PotColors.cardCream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PotColors.warmBorder),
            ),
            child: const Icon(
              Iconsax.document_text,
              size: 18,
              color: PotColors.primaryRed,
            ),
          ),
        ),
      ],
    );
  }
}
