import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Floating toast notification banner matching ref/login.html.
/// Renders on rootOverlay to ensure it always floats in front of modal sheets, bottom sheets, and dialogs.
class AppToast {
  AppToast._();

  static OverlayEntry? _activeEntry;

  /// Convenience shortcut for success toast
  static void showSuccess(BuildContext context, String message, {Duration duration = const Duration(milliseconds: 3200)}) {
    show(context, message: message, isSuccess: true, duration: duration);
  }

  /// Convenience shortcut for error toast
  static void showError(BuildContext context, String message, {Duration duration = const Duration(milliseconds: 3200)}) {
    show(context, message: message, isSuccess: false, duration: duration);
  }

  /// Displays a floating pill toast notification on rootOverlay.
  static void show(
    BuildContext context, {
    required String message,
    bool isSuccess = true,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    if (_activeEntry?.mounted ?? false) {
      _activeEntry?.remove();
    }
    _activeEntry = null;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay != null) {
      late final OverlayEntry entry;
      entry = OverlayEntry(
        builder: (_) => _AppToastWidget(
          message: message,
          isSuccess: isSuccess,
        ),
      );

      _activeEntry = entry;
      overlay.insert(entry);

      Future.delayed(duration, () {
        if (_activeEntry == entry) {
          if (entry.mounted) {
            entry.remove();
          }
          _activeEntry = null;
        }
      });
      return;
    }

    // Fallback if no overlay present (e.g. headless unit tests)
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          padding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: PotColors.textDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PotColors.warmBorder.withValues(alpha: 0.20),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSuccess
                        ? const Color(0x3010B981)
                        : PotColors.accentRed.withValues(alpha: 0.25),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isSuccess ? '✓' : '!',
                    style: TextStyle(
                      color: isSuccess ? const Color(0xFF34D399) : PotColors.accentRed,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: PotColors.pureWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class _AppToastWidget extends StatefulWidget {
  final String message;
  final bool isSuccess;

  const _AppToastWidget({
    required this.message,
    required this.isSuccess,
  });

  @override
  State<_AppToastWidget> createState() => _AppToastWidgetState();
}

class _AppToastWidgetState extends State<_AppToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: PotColors.textDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: PotColors.warmBorder.withValues(alpha: 0.20),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isSuccess
                          ? const Color(0x3010B981)
                          : PotColors.accentRed.withValues(alpha: 0.25),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.isSuccess ? '✓' : '!',
                      style: TextStyle(
                        color: widget.isSuccess
                            ? const Color(0xFF34D399)
                            : PotColors.accentRed,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: PotColors.pureWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
