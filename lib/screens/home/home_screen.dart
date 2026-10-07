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
import '../penerimaan/penerimaan_screen.dart';
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

  const HomeScreen({
    super.key,
    required this.user,
    this.viewModel,
    this.homeRepository,
    this.authService,
    this.googleAuthService,
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final isUnassigned = _viewModel.isUnassigned;

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
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: RefreshIndicator(
                  color: PotColors.primaryRed,
                  onRefresh: _handleRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // User Information Banner Card (matching ref/home.html)
                        HomeUserBanner(
                          user: _viewModel.user,
                          formattedDate: _viewModel.formattedDate,
                          roleBadgeLabel: _viewModel.roleBadgeLabel,
                          lapakDisplayInfo: _viewModel.lapakDisplayInfo,
                        ),

                        const SizedBox(height: 18),

                        // Role Conditional Rendering
                        if (isUnassigned) ...[
                          // When role == 'unassigned': Hide 6 cards & show waiting notice
                          HomeUnassignedView(
                            user: _viewModel.user,
                            isLoading: _viewModel.isLoading,
                            onRefresh: _handleRefresh,
                            onLogout: _handleLogout,
                          ),
                        ] else ...[
                          // When role is assigned: Show 6 operational menu cards
                          HomeMenuGrid(
                            onCardTap: (menuId, menuTitle) {
                              if (menuId == 'absen') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => AttendanceScreen(
                                      currentUser: _viewModel.user,
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (menuId == 'terima_barang') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => PenerimaanScreen(
                                      currentUser: _viewModel.user,
                                    ),
                                  ),
                                );
                                return;
                              }
                              AppToast.show(
                                context,
                                message: 'Menu $menuTitle sedang dalam tahap pengembangan.',
                                isSuccess: true,
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Skyline Vector Footer + Slogan
                          const SkylineFooter(),
                        ],

                        // Extra bottom padding to avoid overlapping the bottom nav bar
                        if (!isUnassigned) const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
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
                      _viewModel.setTabIndex(1);
                      AppToast.show(
                        context,
                        message: 'Halaman Riwayat sedang dalam pengembangan.',
                        isSuccess: true,
                      );
                    } else if (index == 2) {
                      // _viewModel.setTabIndex(2);
                      // AppToast.show(
                      //   context,
                      //   message: 'Halaman Profil sedang dalam pengembangan.',
                      //   isSuccess: true,
                      // );
                      // Temporary: Profile navigation button functions as logout
                      _handleLogout();
                    }
                  },
                ),
        );
      },
    );
  }
}
