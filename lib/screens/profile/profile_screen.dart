import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../widgets/auth/login/skyline_footer.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../riwayat/riwayat_screen.dart';
import 'viewmodels/profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  final ProfileViewModel? viewModel;
  final bool embedded;
  final ValueChanged<UserModel>? onUserUpdated;

  const ProfileScreen({
    super.key,
    required this.user,
    this.viewModel,
    this.embedded = false,
    this.onUserUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel _viewModel;
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? ProfileViewModel(initialUser: widget.user);
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _populateControllers(_viewModel.user);
    _viewModel.loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    if (widget.viewModel == null) _viewModel.dispose();
    super.dispose();
  }

  void _populateControllers(UserModel user) {
    _nameController.text = user.nama;
    _usernameController.text = user.username;
    _emailController.text = user.email;
    _phoneController.text = user.noHp;
  }

  void _startEditing() {
    _populateControllers(_viewModel.user);
    setState(() => _isEditing = true);
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    final saved = await _viewModel.updateProfile(
      nama: _nameController.text,
      username: _usernameController.text,
      email: _emailController.text,
      noHp: _phoneController.text,
    );
    if (!mounted) return;
    if (saved) {
      widget.onUserUpdated?.call(_viewModel.user);
      setState(() => _isEditing = false);
      AppToast.show(
        context,
        message: 'Profil berhasil diperbarui.',
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
      Navigator.of(context).pushAndRemoveUntil(
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

  void _navigateTo(int index) {
    if (index == 2) return;
    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen(user: _viewModel.user)),
        (route) => false,
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => RiwayatScreen(user: _viewModel.user)),
    );
  }

  Widget _buildContent() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final user = _viewModel.user;
        if (!_isEditing && !_viewModel.isLoading) _populateControllers(user);
        return RefreshIndicator(
          color: PotColors.primaryRed,
          onRefresh: _viewModel.loadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileIdentityCard(user: user, onEdit: _startEditing),
                    const SizedBox(height: 16),
                    if (_isEditing)
                      _ProfileEditForm(
                        nameController: _nameController,
                        usernameController: _usernameController,
                        emailController: _emailController,
                        phoneController: _phoneController,
                        isSaving: _viewModel.isSaving,
                        onSave: _saveProfile,
                        onCancel: () => setState(() => _isEditing = false),
                      )
                    else
                      _ProfileDetailsCard(
                        user: user,
                        lapakDisplayName: _viewModel.lapakDisplayName,
                      ),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: 'Keluar Akun',
                      icon: Iconsax.logout,
                      isOutlined: true,
                      isLoading: _viewModel.isLoggingOut,
                      onPressed: _handleLogout,
                    ),
                    if (_viewModel.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      _ProfileError(message: _viewModel.errorMessage!),
                    ],
                    if (_viewModel.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: PotColors.primaryRed,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    const SkylineFooter(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();
    if (widget.embedded) return content;
    return Scaffold(
      backgroundColor: PotColors.bgCream,
      appBar: const AppHeader(),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 2, onTap: _navigateTo),
      body: content,
    );
  }
}

class _ProfileIdentityCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;

  const _ProfileIdentityCard({required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PotColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PotColors.warmBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: PotColors.menuPink,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              user.initials,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: PotColors.primaryRed,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: PotColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.role.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: PotColors.primaryRed,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit profil',
            onPressed: onEdit,
            icon: const Icon(
              Iconsax.edit_2,
              color: PotColors.primaryRed,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileEditForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _ProfileEditForm({
    required this.nameController,
    required this.usernameController,
    required this.emailController,
    required this.phoneController,
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PotColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PotColors.warmBorder),
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: nameController,
            label: 'Nama',
            prefixIcon: Iconsax.user,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: usernameController,
            label: 'Username',
            prefixIcon: Iconsax.user_tag,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: emailController,
            label: 'Email',
            prefixIcon: Iconsax.sms,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: phoneController,
            label: 'No. HP',
            prefixIcon: Iconsax.call,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: 'Simpan Perubahan',
            icon: Iconsax.tick_circle,
            isLoading: isSaving,
            onPressed: onSave,
          ),
          const SizedBox(height: 10),
          CustomButton(
            label: 'Batal',
            isOutlined: true,
            isDisabled: isSaving,
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailsCard extends StatelessWidget {
  final UserModel user;
  final String lapakDisplayName;

  const _ProfileDetailsCard({
    required this.user,
    required this.lapakDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    final details = [
      ('Email', user.email),
      ('Username', user.username),
      ('No. HP', user.noHp.isEmpty ? '-' : user.noHp),
      ('Status', user.isActive ? 'Aktif' : 'Tidak aktif'),
      ('Lapak', lapakDisplayName),
    ];
    return Container(
      decoration: BoxDecoration(
        color: PotColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PotColors.warmBorder),
      ),
      child: Column(
        children: details.asMap().entries.map((entry) {
          final isLast = entry.key == details.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(color: PotColors.warmBorder),
                    ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    entry.value.$1,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: PotColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    entry.value.$2,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: PotColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  final String message;
  const _ProfileError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PotColors.statusErrorBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PotColors.statusErrorBorder),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: PotColors.statusErrorText,
        ),
      ),
    );
  }
}
