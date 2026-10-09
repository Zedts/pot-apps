import 'package:flutter/material.dart';

import '../../core/models/user_model.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/common/info_modal.dart';
import '../profile/profile_screen.dart';
import '../riwayat/riwayat_screen.dart';
import 'home_screen.dart';

/// Persistent tab shell for the three primary destinations.
/// The shared header and navigation bar stay mounted while only tab content changes.
class AppNavigationShell extends StatefulWidget {
  final UserModel user;

  const AppNavigationShell({super.key, required this.user});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  late UserModel _user;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  void _updateUser(UserModel user) {
    if (!mounted) return;
    setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(user: _user, embedded: true),
      RiwayatScreen(user: _user, embedded: true),
      ProfileScreen(user: _user, embedded: true, onUserUpdated: _updateUser),
    ];
    return Scaffold(
      appBar: AppHeader(
        onNotificationTap: () => InfoModal.show(context),
        onSupportTap: () => AppToast.show(
          context,
          message: 'Menghubungkan ke Admin & Owner...',
          isSuccess: true,
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
