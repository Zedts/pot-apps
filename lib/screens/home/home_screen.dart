import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/google_auth_service.dart';
import '../../core/services/location_service.dart';
import '../../widgets/auth/login/skyline_footer.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/info_modal.dart';
import '../../widgets/home/home_menu_grid.dart';
import '../../widgets/home/home_unassigned_view.dart';
import '../../widgets/home/home_user_banner.dart';
import '../attendance/attendance_screen.dart';
import '../closingan/closingan_screen.dart';
import '../penerimaan/penerimaan_screen.dart';
import '../penjualan_stok/penjualan_stok_screen.dart';
import '../profile/profile_screen.dart';
import '../riwayat/riwayat_screen.dart';
import '../slip_gaji/slip_gaji_screen.dart';
import '../auth/login_screen.dart';
import 'repositories/home_repository.dart';
import 'repositories/home_repository_impl.dart';
import 'viewmodels/home_view_model.dart';

/// Main Home Screen implementing the layout and visual structure of ref/home.html.
/// Refactored to Clean Architecture & MVVM with reactive ListenableBuilder.
class HomeScreen extends StatefulWidget {
  final UserModel user;
  final HomeViewModel? viewModel;
  final HomeRepository? homeRepository;
  final AuthService? authService;
  final GoogleAuthService? googleAuthService;
  final bool embedded;

  const HomeScreen({
    super.key,
    required this.user,
    this.viewModel,
    this.homeRepository,
    this.authService,
    this.googleAuthService,
    this.embedded = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ??
        HomeViewModel(
          user: widget.user,
          homeRepository: widget.homeRepository ??
              HomeRepositoryImpl(
                authService: widget.authService,
                googleAuthService: widget.googleAuthService,
              ),
        );
    // Proactively request location permissions on home screen load
    LocationService().checkAndRequestPermission();
  }

  @override
  void dispose() {
    if (widget.viewModel == null) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  /// Prompts confirmation dialog and executes the logout flow via ViewModel.
  Future<void> _handleLogout() async {
    final shouldLogout = await ConfirmationDialog.show(
      context,
      icon: const Icon(Iconsax.logout, color: PotColors.primaryRed, size: 22),
      title: 'Konfirmasi Logout',
      content: 'Apakah Anda yakin ingin keluar dari akun POT?',
      confirmLabel: 'Keluar',
      cancelLabel: 'Batal',
    );

    if (shouldLogout != true) return;

    final success = await _viewModel.logout();
    if (!mounted) return;

    if (success) {
      AppToast.show(
        context,
        message: 'Berhasil keluar dari akun.',
        isSuccess: true,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else if (_viewModel.errorMessage != null) {
      AppToast.show(
        context,
        message: _viewModel.errorMessage!,
        isSuccess: false,
      );
    }
  }

  /// Triggers profile refresh to check if an Admin or Owner assigned a role.
  Future<void> _handleRefresh() async {
    await _viewModel.refreshProfile();
    if (!mounted) return;

    if (_viewModel.errorMessage != null) {
      AppToast.show(
        context,
        message: _viewModel.errorMessage!,
        isSuccess: false,
      );
    } else {
      AppToast.show(
        context,
        message: 'Data akun berhasil diperbarui.',
        isSuccess: true,
      );
    }
  }

  void _handleMenuTap(String menuId, String menuTitle) {
    final user = _viewModel.user;
    if (menuId == 'absen') {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => AttendanceScreen(currentUser: user)));
      return;
    }
    if (menuId == 'terima_barang') {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => PenerimaanScreen(currentUser: user)));
      return;
    }
    if (menuId == 'stok_penjualan') {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => PenjualanStokScreen(currentUser: user)));
      return;
    }
    if (menuId == 'closing_harian') {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ClosinganScreen(currentUser: user)));
      return;
    }
    if (menuId == 'slip_gaji') {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => SlipGajiScreen(currentUser: user)));
      return;
    }
    AppToast.show(context, message: 'Menu $menuTitle sedang dalam tahap pengembangan.', isSuccess: true);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final isUnassigned = _viewModel.isUnassigned;

        final body = SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: RefreshIndicator(
                color: PotColors.primaryRed,
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HomeUserBanner(
                        user: _viewModel.user,
                        formattedDate: _viewModel.formattedDate,
                        roleBadgeLabel: _viewModel.roleBadgeLabel,
                        lapakDisplayInfo: _viewModel.lapakDisplayInfo,
                      ),
                      const SizedBox(height: 18),
                      if (isUnassigned) ...[
                        HomeUnassignedView(user: _viewModel.user, isLoading: _viewModel.isLoading, onRefresh: _handleRefresh, onLogout: _handleLogout),
                      ] else ...[
                        HomeMenuGrid(onCardTap: _handleMenuTap),
                        const SizedBox(height: 24),
                        const SkylineFooter(),
                      ],
                      if (!isUnassigned) const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        if (widget.embedded) return body;

        return Scaffold(
          backgroundColor: PotColors.bgCream,
          appBar: AppHeader(
            onNotificationTap: () => InfoModal.show(context),
            onSupportTap: () {
              AppToast.show(
                context,
                message: 'Menghubungkan ke Admin & Owner...',
                isSuccess: true,
              );
            },
            trailing: isUnassigned
                ? IconButton(
                    tooltip: 'Keluar Akun',
                    icon: _viewModel.isLoggingOut
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                PotColors.primaryRed,
                              ),
                            ),
                          )
                        : const Icon(
                            Iconsax.logout,
                            color: PotColors.primaryRed,
                            size: 20,
                          ),
                    onPressed: _viewModel.isLoggingOut ? null : _handleLogout,
                  )
                : null,
          ),
          body: body,
          // Role Conditional Bottom Navigation Bar:
          // Hidden when unassigned, visible when assigned.
          bottomNavigationBar: isUnassigned
              ? null
              : AppBottomNavBar(
                  currentIndex: _viewModel.currentTabIndex,
                  onTap: (index) {
                    if (index == 0) {
                      _viewModel.setTabIndex(0);
                    } else if (index == 1) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RiwayatScreen(user: _viewModel.user),
                        ),
                      );
                    } else if (index == 2) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(user: _viewModel.user),
                        ),
                      );
                    }
                  },
                ),
        );
      },
    );
  }
}
