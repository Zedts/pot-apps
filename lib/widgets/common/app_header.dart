import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import 'info_modal.dart';

/// Reusable application header bar supporting both the main brand header
/// and sub-page navigation headers with title, back button, and custom actions.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSupportTap;
  final Widget? trailing;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final String? title;
  final String? subtitle;

  const AppHeader({
    super.key,
    this.onNotificationTap,
    this.onSupportTap,
    this.trailing,
    this.showBackButton = false,
    this.onBackTap,
    this.title,
    this.subtitle,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 72 : 60);

  @override
  Widget build(BuildContext context) {
    // If customized for a sub-screen with title or back button
    if (showBackButton || title != null) {
      return Container(
        color: PotColors.bgCream,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Back button or placeholder
              if (showBackButton)
                GestureDetector(
                  onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
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
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: PotColors.primaryRed,
                    ),
                  ),
                )
              else
                const SizedBox(width: 34),

              // Center: Screen title & subtitle
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: PotColors.textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: PotColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Right: Trailing action or placeholder
              trailing ?? const SizedBox(width: 34),
            ],
          ),
        ),
      );
    }

    // Default Brand Home Header
    return Container(
      color: PotColors.bgCream,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Real Brand Logo & System Titles
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PotColors.cardCream,
                    border: Border.all(
                      color: PotColors.goldAccent.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: PotColors.primaryRed.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    AppImages.imageLogo,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'OLEH',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: PotColors.primaryRed,
                          letterSpacing: -0.2,
                        ),
                        children: [
                          WidgetSpan(
                            child: Transform.translate(
                              offset: const Offset(0, -4),
                              child: const Text(
                                '2',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: PotColors.primaryRed,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(
                            text: ' TURKI',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: PotColors.primaryRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Presensi Karyawan',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: PotColors.textMuted,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Right: Actions (Notification, Support, or Trailing)
            Row(
              children: [
                if (trailing != null)
                  trailing!
                else ...[
                  // Notification Button with active badge
                  GestureDetector(
                    onTap: onNotificationTap ?? () => InfoModal.show(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: PotColors.cardCream,
                        borderRadius: BorderRadius.circular(12),
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
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(
                            Iconsax.notification,
                            size: 18,
                            color: PotColors.textDark,
                          ),
                          Positioned(
                            top: -1,
                            right: -1,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: PotColors.accentRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Support / Hubungi Admin Button
                  GestureDetector(
                    onTap: onSupportTap ?? () => InfoModal.show(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: PotColors.cardCream,
                        borderRadius: BorderRadius.circular(12),
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
                        Iconsax.messages_2,
                        size: 18,
                        color: PotColors.textDark,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
