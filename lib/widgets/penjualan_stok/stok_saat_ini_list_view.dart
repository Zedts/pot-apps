import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../screens/penjualan_stok/viewmodels/penjualan_stok_view_model.dart';
import 'stok_balance_card.dart';

/// Tab 2 view displaying real-time inventory balances (summary + list per product)
class StokSaatIniListView extends StatefulWidget {
  final PenjualanStokViewModel viewModel;

  const StokSaatIniListView({
    super.key,
    required this.viewModel,
  });

  @override
  State<StokSaatIniListView> createState() => _StokSaatIniListViewState();
}

class _StokSaatIniListViewState extends State<StokSaatIniListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stokList = widget.viewModel.stokList;

    if (widget.viewModel.isLoading && stokList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: PotColors.primaryRed),
        ),
      );
    }

    if (stokList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: PotColors.menuPink,
                  shape: BoxShape.circle,
                  border: Border.all(color: PotColors.primaryRed.withValues(alpha: 0.15)),
                ),
                child: const Icon(
                  Iconsax.box_1,
                  color: PotColors.primaryRed,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Belum Ada Data Stok',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: PotColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Data inventaris stok lapak akan muncul setelah penerimaan barang atau pencatatan awal dilakukan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: PotColors.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filteredList = _searchQuery.isEmpty
        ? stokList
        : stokList
            .where((item) => item.productName.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Lapak Stock Summary Card
        StokBalanceCard(
          stockItem: null,
          isSummary: true,
          totalAwal: widget.viewModel.totalStokAwal,
          totalMasuk: widget.viewModel.totalStokMasuk,
          totalTerjual: widget.viewModel.totalStokTerjual,
          totalAkhir: widget.viewModel.totalStokAkhir,
        ),

        const SizedBox(height: 16),

        // Search Input Field matching Input Penjualan tab
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

        const SizedBox(height: 16),

        // Section Title & Counter Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Rincian Stok Produk',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: PotColors.textDark,
                  letterSpacing: -0.2,
                ),
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
                '${filteredList.length} produk',
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

        // List of Product Balance Cards or Empty Search Notice
        if (filteredList.isEmpty)
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
            itemCount: filteredList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = filteredList[index];
              return StokBalanceCard(stockItem: item);
            },
          ),
      ],
    );
  }
}
