import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Floating toast notification banner matching ref/login.html.
class AppToast {
  AppToast._();

  /// Displays a floating pill toast notification.
  static void show(
    BuildContext context, {
    required String message,
    bool isSuccess = true,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
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
              // Status Badge
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

              // Message
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
