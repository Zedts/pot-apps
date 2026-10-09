import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../widgets/auth/login/skyline_footer.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/riwayat/activity_history_table.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import 'viewmodels/riwayat_view_model.dart';

class RiwayatScreen extends StatefulWidget {
  final UserModel user;
  final RiwayatViewModel? viewModel;
  final bool embedded;

  const RiwayatScreen({super.key, required this.user, this.viewModel, this.embedded = false});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  late final RiwayatViewModel _viewModel;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? RiwayatViewModel(user: widget.user);
    _searchController = TextEditingController();
    _viewModel.loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (widget.viewModel == null) _viewModel.dispose();
    super.dispose();
  }

  void _navigateTo(int index) {
    if (index == 1) return;
    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)),
        (route) => false,
      );
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ProfileScreen(user: widget.user)));
  }

  Widget _buildContent() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => RefreshIndicator(
        color: PotColors.primaryRed,
        onRefresh: () async {
          await _viewModel.loadHistory();
          if (!context.mounted || _viewModel.errorMessage == null) return;
          AppToast.show(context, message: _viewModel.errorMessage!, isSuccess: false);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: PotColors.pureWhite,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: PotColors.warmBorder),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Riwayat Aktivitas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: PotColors.textDark, letterSpacing: -0.2)),
                        const SizedBox(height: 4),
                        const Text('Catatan aktivitas tersimpan di perangkat ini.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: PotColors.textMuted)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _searchController,
                          onChanged: _viewModel.setSearchQuery,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: PotColors.textDark),
                          decoration: InputDecoration(
                            hintText: 'Cari aktivitas...',
                            hintStyle: const TextStyle(color: PotColors.textLight),
                            prefixIcon: const Icon(Iconsax.search_normal, size: 18, color: PotColors.textLight),
                            suffixIcon: _viewModel.searchQuery.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.close, size: 18, color: PotColors.textMuted),
                                    onPressed: () {
                                      _searchController.clear();
                                      _viewModel.setSearchQuery('');
                                    },
                                  ),
                            filled: true,
                            fillColor: PotColors.cardCream,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PotColors.warmBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PotColors.warmBorder)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PotColors.primaryRed, width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_viewModel.isLoading && _viewModel.entries.isEmpty)
                          const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: CircularProgressIndicator(color: PotColors.primaryRed)))
                        else
                          ActivityHistoryTable(entries: _viewModel.entries, searchActive: _viewModel.searchQuery.isNotEmpty),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SkylineFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();
    if (widget.embedded) return content;
    return Scaffold(
      backgroundColor: PotColors.bgCream,
      appBar: const AppHeader(),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 1, onTap: _navigateTo),
      body: content,
    );
  }
}
