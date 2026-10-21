import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/lapak_model.dart';
import '../../core/models/stok_lapak_model.dart';
import '../../core/models/user_model.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/searchable_picker_modal.dart';
import '../../widgets/penjualan_stok/penjualan_product_picker_item.dart';
import '../../widgets/penjualan_stok/ttd_pengirim_canvas.dart';
import 'viewmodels/stok_transfer_view_model.dart';

/// Screen allowing staff/SPG to create a stall-to-stall Delivery Order (DO)
/// to transfer stock from their assigned stall to another stall in a 3-step workflow:
/// Step 0: Product selection with search bar (no counter)
/// Step 1: Quantity allocation (+ / - steppers bounded by stock limit, trash removal)
/// Step 2: Destination stall, courier staff, date, digital signature & submission
class StokTransferScreen extends StatefulWidget {
  final UserModel? currentUser;
  final LapakModel? originStall;

  const StokTransferScreen({
    super.key,
    this.currentUser,
    this.originStall,
  });

  @override
  State<StokTransferScreen> createState() => _StokTransferScreenState();
}

class _StokTransferScreenState extends State<StokTransferScreen> {
  late final StokTransferViewModel _viewModel;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _viewModel = StokTransferViewModel(
      currentUser: widget.currentUser,
      initialOriginStall: widget.originStall,
    );
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return PopScope(
          canPop: _viewModel.currentStep == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (_viewModel.currentStep > 0) {
              _viewModel.previousStep();
            }
          },
          child: Scaffold(
            backgroundColor: PotColors.bgCream,
            appBar: AppHeader(
              title: 'Transfer Stok',
              subtitle: _viewModel.formattedTransferDate,
              showBackButton: true,
              onBackTap: () {
                if (_viewModel.currentStep > 0) {
                  _viewModel.previousStep();
                } else {
                  Navigator.of(context).maybePop(false);
                }
              },
            ),
            body: _viewModel.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: PotColors.primaryRed),
                  )
                : _viewModel.errorMessage != null && _viewModel.destinationStalls.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Iconsax.info_circle, size: 48, color: PotColors.primaryRed),
                              const SizedBox(height: 12),
                              Text(
                                _viewModel.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: PotColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 140,
                                child: CustomButton(
                                  label: 'Coba Lagi',
                                  icon: Iconsax.refresh,
                                  onPressed: _viewModel.initialize,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          // 3-Node Step Header Bar
                          _buildStepIndicator(),

                          // Step Content
                          Expanded(
                            child: _viewModel.currentStep == 0
                                ? _buildProductSelectionStep()
                                : _viewModel.currentStep == 1
                                    ? _buildQuantityAllocationStep()
                                    : _buildTransferDetailsStep(),
                          ),
                        ],
                      ),
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: PotColors.pureWhite,
        border: Border(bottom: BorderSide(color: PotColors.warmBorder)),
      ),
      child: Row(
        children: [
          _buildStepNode(1, 'Pilih Produk', _viewModel.currentStep >= 0, () {
            if (_viewModel.currentStep > 0) _viewModel.setStep(0);
          }),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              color: _viewModel.currentStep >= 1 ? PotColors.primaryRed : PotColors.warmBorder,
            ),
          ),
          _buildStepNode(2, 'Kuantitas', _viewModel.currentStep >= 1, () {
            if (_viewModel.canProceedToStep2) {
              FocusScope.of(context).unfocus();
              _viewModel.setStep(1);
            }
          }),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              color: _viewModel.currentStep >= 2 ? PotColors.primaryRed : PotColors.warmBorder,
            ),
          ),
          _buildStepNode(3, 'Tujuan & TTD', _viewModel.currentStep >= 2, () {
            if (_viewModel.canProceedToStep3) {
              FocusScope.of(context).unfocus();
              _viewModel.setStep(2);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildStepNode(int step, String label, bool isActive, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? PotColors.primaryRed : PotColors.cardCream,
              border: Border.all(
                color: isActive ? PotColors.primaryRed : PotColors.warmBorder,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$step',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.white : PotColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              color: isActive ? PotColors.textDark : PotColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Step 0: Product Selection (Search + Toggle)
  // ==========================================

  Widget _buildProductSelectionStep() {
    final filteredItems = _viewModel.filteredOriginStock;

    return Column(
      children: [
        // Origin Stall Header Info
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: PotColors.cardCream,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PotColors.warmBorder),
          ),
          child: Row(
            children: [
              const Icon(Iconsax.shop, size: 18, color: PotColors.primaryRed),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Asal Stok: ${_viewModel.originStall?.nama ?? "Lapak Bertugas"}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: PotColors.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Search Bar matching Penjualan / Stok screens
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: PotColors.pureWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PotColors.warmBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Iconsax.search_normal,
                  size: 16,
                  color: PotColors.textLight,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _viewModel.setSearchQuery,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PotColors.textDark,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Cari produk yang akan ditransfer...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: PotColors.textLight,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _viewModel.setSearchQuery('');
                    },
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: PotColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pilih Produk Tersedia',
                style: TextStyle(
                  fontSize: 12,
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
                  '${filteredItems.length} produk',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PotColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Product List with Selection Toggle
        Expanded(
          child: filteredItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      _viewModel.searchQuery.isNotEmpty
                          ? 'Tidak ada produk sesuai "${_viewModel.searchQuery}"'
                          : 'Tidak ada stok produk yang tersedia untuk ditransfer dari outlet ini.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: PotColors.textMuted,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: filteredItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final isSelected = _viewModel.isProductSelected(item.produkId);
                    return Container(
                      decoration: BoxDecoration(
                        color: PotColors.pureWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? PotColors.primaryRed.withValues(alpha: 0.5)
                              : PotColors.warmBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: PenjualanProductPickerItem(
                        stockItem: item,
                        isSelected: isSelected,
                        onToggle: () => _viewModel.toggleProductSelection(item.produkId),
                      ),
                    );
                  },
                ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PotColors.pureWhite,
            border: const Border(top: BorderSide(color: PotColors.warmBorder)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Produk Terpilih',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: PotColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_viewModel.selectedProductsCount} produk',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: PotColors.primaryRed,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 150,
                child: CustomButton(
                  label: _viewModel.canProceedToStep2
                      ? 'Lanjut (${_viewModel.selectedProductsCount})'
                      : 'Lanjut',
                  icon: Iconsax.arrow_right_3,
                  isDisabled: !_viewModel.canProceedToStep2,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _viewModel.nextStep();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // Step 1: Quantity Allocation (+ / - Steppers)
  // ==========================================

  Widget _buildQuantityAllocationStep() {
    final selectedItems = _viewModel.selectedTransferItems;

    return Column(
      children: [
        // Subheader navigation / title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Atur Kuantitas Transfer',
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
                  '${selectedItems.length} produk dipilih',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PotColors.primaryRed,
                  ),
                ),
              ),
            ],
          ),
        ),

        // List of Selected Products with Stepper & Trash
        Expanded(
          child: selectedItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Iconsax.box_remove, size: 40, color: PotColors.textLight),
                        const SizedBox(height: 10),
                        const Text(
                          'Belum ada produk yang dipilih',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: PotColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 160,
                          child: CustomButton(
                            label: 'Pilih Produk',
                            icon: Iconsax.arrow_left_2,
                            onPressed: _viewModel.previousStep,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: selectedItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = selectedItems[index];
                    final qty = _viewModel.quantities[item.produkId] ?? 0;
                    return _buildQuantityItemCard(item, qty);
                  },
                ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PotColors.pureWhite,
            border: const Border(top: BorderSide(color: PotColors.warmBorder)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Ditransfer',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: PotColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_viewModel.totalTransferUnits} unit (${_viewModel.selectedProductsCount} produk)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: PotColors.primaryRed,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 160,
                child: CustomButton(
                  label: 'Lanjut ke Tujuan',
                  icon: Iconsax.arrow_right_3,
                  isDisabled: !_viewModel.canProceedToStep3,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _viewModel.nextStep();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityItemCard(StokLapakModel item, int qty) {
    final maxStock = item.stokAkhir;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PotColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PotColors.warmBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Name and Available Stock
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: PotColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: PotColors.menuGreen,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: PotColors.borderGreen),
                      ),
                      child: Text(
                        'Tersedia: $maxStock unit',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: PotColors.statusSuccessText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Stepper Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: qty > 1 ? () => _viewModel.decrementQuantity(item.produkId) : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: qty > 1 ? PotColors.cardCream : PotColors.warmBorder.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PotColors.warmBorder),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: qty > 1 ? PotColors.textDark : PotColors.textLight,
                  ),
                ),
              ),
              _TransferQuantityInputField(
                key: ValueKey('transfer_qty_${item.produkId}'),
                quantity: qty,
                maxStock: maxStock,
                onChanged: (newQty) {
                  _viewModel.updateQuantity(item.produkId, newQty, maxStock);
                },
              ),
              InkWell(
                onTap: qty < maxStock ? () => _viewModel.incrementQuantity(item.produkId, maxStock) : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: qty < maxStock ? PotColors.primaryRed : PotColors.warmBorder.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: qty < maxStock ? PotColors.primaryRed : PotColors.warmBorder,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: qty < maxStock ? Colors.white : PotColors.textLight,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // Remove / Trash Button
          InkWell(
            onTap: () => _viewModel.removeProduct(item.produkId),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: PotColors.accentRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Iconsax.trash,
                size: 16,
                color: PotColors.primaryRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Step 2: Destination, Courier & Signature
  // ==========================================

  Widget _buildTransferDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transfer Summary Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PotColors.cardCream,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PotColors.warmBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Iconsax.box_tick, size: 16, color: PotColors.primaryRed),
                    SizedBox(width: 6),
                    Text(
                      'Ringkasan Produk Transfer',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: PotColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: PotColors.warmBorder),
                const SizedBox(height: 8),
                ..._viewModel.selectedTransferItems.map((item) {
                  final qty = _viewModel.quantities[item.produkId] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.productName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: PotColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$qty unit',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: PotColors.primaryRed,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                const Divider(height: 1, color: PotColors.warmBorder),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Transfer',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: PotColors.textDark,
                      ),
                    ),
                    Text(
                      '${_viewModel.totalTransferUnits} unit (${_viewModel.selectedProductsCount} produk)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: PotColors.primaryRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Destination Stall Picker with Searchable Modal
          SearchablePickerField<LapakModel>(
            label: 'Outlet Lapak Tujuan *',
            title: 'Pilih Outlet Lapak Tujuan',
            placeholder: 'Pilih outlet tujuan transfer...',
            prefixIcon: Iconsax.shop,
            items: _viewModel.destinationStalls,
            value: _viewModel.selectedDestinationStall,
            itemLabel: (s) => s.nama,
            itemSublabel: (s) => s.lokasi.isNotEmpty ? s.lokasi : null,
            equalityChecker: (a, b) => a.id == b.id,
            onChanged: _viewModel.setSelectedDestinationStall,
          ),

          const SizedBox(height: 14),

          // Petugas Pengirim (Kurir / Staf) - Automatically filled by logged-in user
          const Text(
            'Petugas Pengirim (Kurir / Staf)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: PotColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: PotColors.cardCream.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PotColors.warmBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Iconsax.user,
                  size: 18,
                  color: PotColors.primaryRed,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _viewModel.selectedCourier?.displayName ??
                            _viewModel.currentUser?.displayName ??
                            'Petugas Bertugas',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: PotColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${_viewModel.selectedCourier?.username ?? _viewModel.currentUser?.username ?? "-"} • ${_viewModel.selectedCourier?.role.toUpperCase() ?? _viewModel.currentUser?.role.toUpperCase() ?? "STAFF"} (Akun Anda)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: PotColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: PotColors.menuGreen,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PotColors.borderGreen),
                  ),
                  child: const Text(
                    'Otomatis',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: PotColors.statusSuccessText,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Transfer Date (Jakarta Time)
          const Text(
            'Tanggal Pengiriman *',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: PotColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _viewModel.transferDate,
                firstDate: DateTime.now().subtract(const Duration(days: 7)),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) {
                _viewModel.setTransferDate(picked);
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: PotColors.pureWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PotColors.warmBorder),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.calendar_1, size: 16, color: PotColors.primaryRed),
                  const SizedBox(width: 8),
                  Text(
                    _viewModel.formattedTransferDate,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: PotColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down, size: 18, color: PotColors.textMuted),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // TTD Pengirim Digital Canvas (tap to open full-canvas modal)
          TtdPengirimCanvas(
            initialFile: _viewModel.ttdPengirimFile,
            onSignatureChanged: _viewModel.setTtdPengirimFile,
            disabled: _viewModel.isSubmitting,
          ),

          if (_viewModel.errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: PotColors.menuPink,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PotColors.primaryRed.withValues(alpha: 0.3)),
              ),
              child: Text(
                _viewModel.errorMessage!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: PotColors.primaryRed,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Submit DO Button
          CustomButton(
            label: 'Buat Surat Jalan DO (Draft)',
            icon: Iconsax.truck_fast,
            isDisabled: !_viewModel.canSubmit,
            isLoading: _viewModel.isSubmitting,
            onPressed: () async {
              final success = await _viewModel.submitTransfer();
              if (!mounted) return;
              if (success) {
                AppToast.showSuccess(
                  context,
                  'Delivery Order transfer berhasil dibuat dalam status Draft!',
                );
                Navigator.of(context).pop(true);
              } else if (_viewModel.errorMessage != null) {
                AppToast.showError(
                  context,
                  _viewModel.errorMessage!,
                );
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// An inline numeric text field that allows direct keyboard typing of transfer quantity
/// with automatic bounds enforcement (1 <= value <= maxStock) and stepper synchronization.
class _TransferQuantityInputField extends StatefulWidget {
  final int quantity;
  final int maxStock;
  final ValueChanged<int> onChanged;

  const _TransferQuantityInputField({
    super.key,
    required this.quantity,
    required this.maxStock,
    required this.onChanged,
  });

  @override
  State<_TransferQuantityInputField> createState() => _TransferQuantityInputFieldState();
}

class _TransferQuantityInputFieldState extends State<_TransferQuantityInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.quantity}');
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _TransferQuantityInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantity != oldWidget.quantity) {
      final currentParsed = int.tryParse(_controller.text);
      if (currentParsed != widget.quantity) {
        _controller.text = '${widget.quantity}';
        _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
      }
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      final parsed = int.tryParse(_controller.text);
      if (parsed == null || parsed < 1) {
        _controller.text = '1';
        widget.onChanged(1);
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: PotColors.cardCream.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PotColors.warmBorder),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: PotColors.primaryRed,
          height: 1.2,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          border: InputBorder.none,
        ),
        onChanged: (val) {
          final parsed = int.tryParse(val);
          if (parsed != null && parsed > 0) {
            if (parsed > widget.maxStock) {
              _controller.text = '${widget.maxStock}';
              _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
              widget.onChanged(widget.maxStock);
            } else {
              widget.onChanged(parsed);
            }
          }
        },
      ),
    );
  }
}
