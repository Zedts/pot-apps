import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/stok_lapak_model.dart';
import '../../core/models/user_model.dart';
import '../../widgets/auth/login/skyline_footer.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/penjualan_stok/penjualan_bukti_upload_card.dart';
import '../../widgets/penjualan_stok/penjualan_payment_method_selector.dart';
import '../../widgets/penjualan_stok/penjualan_product_picker_item.dart';
import '../../widgets/penjualan_stok/penjualan_selected_product_item.dart';
import '../../widgets/penjualan_stok/penjualan_stok_tab_bar.dart';
import '../../widgets/penjualan_stok/riwayat_penjualan_sheet.dart';
import '../../widgets/penjualan_stok/stok_saat_ini_list_view.dart';
import 'viewmodels/penjualan_stok_view_model.dart';

/// Screen coordinating "Stok & Penjualan", supporting:
/// Tab 1: Input Penjualan with stock-based picker (Phase A) and selected review (Phase B).
/// Tab 2: Stok Saat Ini real-time 4-metric inventory balances.
class PenjualanStokScreen extends StatefulWidget {
  final UserModel? currentUser;
  final PenjualanStokViewModel? viewModel;

  const PenjualanStokScreen({super.key, this.currentUser, this.viewModel});

  @override
  State<PenjualanStokScreen> createState() => _PenjualanStokScreenState();
}

class _PenjualanStokScreenState extends State<PenjualanStokScreen> {
  late final PenjualanStokViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? PenjualanStokViewModel(currentUser: widget.currentUser);
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_viewModel.selectedTabIndex == 0) {
      await _viewModel.initialize();
    } else {
      await _viewModel.refreshStok();
    }
  }

  Future<void> _handleSubmitPenjualan() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Simpan Penjualan?',
      content:
          'Total transaksi ${CurrencyFormatter.formatRupiah(_viewModel.totalHarga)} (${_viewModel.totalQuantity} item) dengan metode ${_viewModel.selectedPaymentMethod.toUpperCase()}. Lanjutkan?',
      confirmLabel: 'Ya, Simpan',
      cancelLabel: 'Periksa Kembali',
    );

    if (confirmed != true) return;

    final success = await _viewModel.submitPenjualan();
    if (!mounted) return;

    if (success) {
      AppToast.showSuccess(
        context,
        _viewModel.successMessage ?? 'Transaksi penjualan berhasil dicatat!',
      );
      _searchController.clear();
      _catatanController.clear();
      setState(() {
        _searchQuery = '';
      });
    } else if (_viewModel.errorMessage != null) {
      AppToast.showError(
        context,
        _viewModel.errorMessage!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return PopScope(
          canPop: !_viewModel.isViewingSelectedProducts,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (_viewModel.isViewingSelectedProducts) {
              _viewModel.setViewingSelectedProducts(false);
            }
          },
          child: Scaffold(
            backgroundColor: PotColors.bgCream,
            appBar: AppHeader(
              title: 'Stok & Penjualan',
              subtitle: _viewModel.formattedCurrentDate,
              showBackButton: true,
              onBackTap: () {
                if (_viewModel.isViewingSelectedProducts) {
                  _viewModel.setViewingSelectedProducts(false);
                } else {
                  Navigator.maybePop(context);
                }
              },
            trailing: GestureDetector(
              onTap: () => RiwayatPenjualanSheet.show(context, _viewModel),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: PotColors.cardCream,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: PotColors.warmBorder),
                  boxShadow: [
                    BoxShadow(
                      color: PotColors.primaryRed.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Iconsax.document_text,
                  size: 17,
                  color: PotColors.primaryRed,
                ),
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: PotColors.primaryRed,
            backgroundColor: PotColors.pureWhite,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Segmented Tabs: Input Penjualan & Stok Saat Ini
                  PenjualanStokTabBar(
                    selectedIndex: _viewModel.selectedTabIndex,
                    onTabChanged: _viewModel.setTabIndex,
                  ),

                  const SizedBox(height: 14),

                  // Tab Content Switching
                  if (_viewModel.selectedTabIndex == 0)
                    _buildInputPenjualanTab()
                  else
                    StokSaatIniListView(viewModel: _viewModel),

                  const SizedBox(height: 24),
                  const SkylineFooter(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
  }

  Widget _buildInputPenjualanTab() {
    if (_viewModel.isViewingSelectedProducts) {
      return _buildSelectedReviewPhase();
    }
    return _buildProductSelectionPhase();
  }

  /// Phase A: Product Selection with Top 5 Stock Items and Disabled "Lihat Pilihan" when empty
  Widget _buildProductSelectionPhase() {
    final availableProducts = _viewModel.availableStockItems;
    final List<StokLapakModel> displayProducts;
    if (_searchQuery.isEmpty) {
      displayProducts = _viewModel.quickPickStockItems;
    } else {
      displayProducts = availableProducts
          .where((p) => p.productName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Product Selection Card
        Container(
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
              // Search Input Field
              Container(
                decoration: BoxDecoration(
                  color: PotColors.cardCream.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PotColors.warmBorder),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: PotColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: PotColors.textLight,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.search_normal,
                      size: 16,
                      color: PotColors.textLight,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: PotColors.textMuted,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Produk Tersedia',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: PotColors.textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: PotColors.cardCream,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: PotColors.warmBorder),
                    ),
                    child: Text(
                      _searchQuery.isEmpty ? 'Top 5 Stok Terbanyak' : '${displayProducts.length} produk',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: PotColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1, color: PotColors.warmBorder),
              const SizedBox(height: 6),

              // Product Rows List
              if (_viewModel.isLoading && availableProducts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: PotColors.primaryRed),
                  ),
                )
              else if (availableProducts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.box_remove,
                          size: 40,
                          color: PotColors.textLight.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Stok Lapak Kosong',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: PotColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Belum ada stok produk yang tersedia di lapak ini. Silakan lakukan penerimaan barang terlebih dahulu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: PotColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (displayProducts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Produk tidak ditemukan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: PotColors.textMuted,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayProducts.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    color: PotColors.warmBorder,
                  ),
                  itemBuilder: (context, index) {
                    final item = displayProducts[index];
                    final isSelected = _viewModel.isProductSelected(item.produkId);
                    return PenjualanProductPickerItem(
                      stockItem: item,
                      isSelected: isSelected,
                      onToggle: () => _viewModel.toggleProductSelection(item.produkId),
                    );
                  },
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Action Button: "Lihat Pilihan" (strictly disabled if no products selected)
        CustomButton(
          label: _viewModel.hasSelectedProducts
              ? 'Lihat Pilihan (${_viewModel.selectedProductsCount} Produk)'
              : 'Lihat Pilihan',
          icon: Iconsax.arrow_right_3,
          isDisabled: !_viewModel.hasSelectedProducts,
          onPressed: _viewModel.hasSelectedProducts
              ? () => _viewModel.setViewingSelectedProducts(true)
              : null,
        ),
      ],
    );
  }

  /// Phase B: Selected Products Review with Stepper bounded by stock, Trash cancel button, and Payment Submission
  Widget _buildSelectedReviewPhase() {
    final selectedItems = _viewModel.selectedStockItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Navigation: Back to Product Selection
        GestureDetector(
          onTap: () => _viewModel.setViewingSelectedProducts(false),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: PotColors.pureWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PotColors.warmBorder),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.arrow_left,
                  size: 16,
                  color: PotColors.primaryRed,
                ),
                SizedBox(width: 8),
                Text(
                  'Kembali ke Pilihan Produk',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: PotColors.primaryRed,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Selected Products Cart & Transaction Card
        Container(
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Produk Dipilih',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: PotColors.textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: PotColors.cardCream,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: PotColors.warmBorder),
                    ),
                    child: Text(
                      '${selectedItems.length} produk',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: PotColors.primaryRed,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: PotColors.warmBorder),

              // Full Selected Products List (no 5-item limiter, steppers strictly capped, trash cancel button)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedItems.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: PotColors.warmBorder,
                ),
                itemBuilder: (context, index) {
                  final item = selectedItems[index];
                  final qty = _viewModel.getQuantity(item.produkId);
                  return PenjualanSelectedProductItem(
                    stockItem: item,
                    quantity: qty,
                    onIncrement: () => _viewModel.incrementQuantity(item.produkId),
                    onDecrement: () => _viewModel.decrementQuantity(item.produkId),
                    onRemove: () => _viewModel.removeProductSelection(item.produkId),
                  );
                },
              ),

              const SizedBox(height: 14),

              // Payment Method Selector
              const Divider(height: 1, color: PotColors.warmBorder),
              const SizedBox(height: 14),

              PenjualanPaymentMethodSelector(
                selectedMethod: _viewModel.selectedPaymentMethod,
                onMethodSelected: _viewModel.setPaymentMethod,
              ),

              const SizedBox(height: 14),

              // Optional Catatan Field
              Container(
                decoration: BoxDecoration(
                  color: PotColors.cardCream.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: PotColors.warmBorder),
                ),
                child: TextField(
                  controller: _catatanController,
                  onChanged: _viewModel.setCatatan,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: PotColors.textDark,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Catatan transaksi (opsional)...',
                    hintStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: PotColors.textLight,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Total Price Summary Row
              const Divider(height: 1, color: PotColors.warmBorder),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: PotColors.textDark,
                        ),
                      ),
                      if (_viewModel.totalQuantity > 0)
                        Text(
                          '${_viewModel.totalQuantity} pcs dipilih',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: PotColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    CurrencyFormatter.formatRupiah(_viewModel.totalHarga),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: PotColors.locationGreen,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Non-Cash Payment Proof Upload Card
        if (_viewModel.isNonCash) ...[
          const SizedBox(height: 14),
          PenjualanBuktiUploadCard(
            photoFile: _viewModel.buktiBayarFile,
            paymentMethod: _viewModel.selectedPaymentMethod,
            onCameraTap: _viewModel.pickBuktiBayarCamera,
            onGalleryTap: _viewModel.pickBuktiBayarGallery,
            onRemoveTap: _viewModel.removeBuktiBayar,
          ),
        ],

        const SizedBox(height: 16),

        // Simpan Penjualan Button
        CustomButton(
          label: 'Simpan Penjualan',
          icon: Iconsax.save_2,
          isLoading: _viewModel.isSubmitting,
          isDisabled: !_viewModel.canSubmit,
          onPressed: _handleSubmitPenjualan,
        ),
      ],
    );
  }
}
