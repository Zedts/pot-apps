import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';

/// User Information Banner matching the reference in ref/home.html.
/// Displays user greeting, monogram avatar with gold ring, role badge, assigned lapak info, and dynamic Indonesian date.
class HomeUserBanner extends StatelessWidget {
  final UserModel user;
  final String formattedDate;
  final String roleBadgeLabel;
  final String lapakDisplayInfo;

  const HomeUserBanner({
    super.key,
    required this.user,
    required this.formattedDate,
    required this.roleBadgeLabel,
    required this.lapakDisplayInfo,
  });

  @override
  Widget build(BuildContext context) {
    final initial = user.displayName.isNotEmpty
        ? user.displayName.substring(0, 1).toUpperCase()
        : 'U';

    return Container(
      decoration: BoxDecoration(
        color: PotColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: PotColors.primaryRed.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          foregroundPainter: const _BannerBorderPainter(
            borderColor: PotColors.warmBorder,
            accentColor: PotColors.primaryRed,
            accentWidth: 4.5,
          ),
          child: Stack(
            children: [
              // Subtle warm gold corner decoration in top-right (matching ref/home.html)
              Positioned(
                top: -22,
                right: -22,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        PotColors.goldAccent.withValues(alpha: 0.16),
                        PotColors.goldAccent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Banner Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Monogram Avatar with Gold Ring & Active Status
                    Stack(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                PotColors.primaryRed,
                                PotColors.darkRed,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: PotColors.goldAccent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: PotColors.primaryRed.withValues(alpha: 0.18),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: PotColors.pureWhite,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        // Emerald active indicator
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF10B981),
                              border: Border.all(
                                color: PotColors.pureWhite,
                                width: 2.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 14),

                    // User Details, Lapak Info & Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Row 1: Greeting + Role Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Halo, ${user.displayName} 👋',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: PotColors.textDark,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: PotColors.primaryRed.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: PotColors.primaryRed.withValues(alpha: 0.20),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  roleBadgeLabel,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: PotColors.primaryRed,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),

                          // Row 2: Lapak Information Display
                          Row(
                            children: [
                              const Icon(
                                Iconsax.shop,
                                size: 13,
                                color: PotColors.primaryRed,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  lapakDisplayInfo,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: PotColors.textDark,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 3),

                          // Row 3: Dynamic Indonesian Date Display
                          Row(
                            children: [
                              const Icon(
                                Iconsax.calendar_1,
                                size: 13,
                                color: PotColors.goldAccent,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  formattedDate,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: PotColors.textMuted,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for seamless perimeter border and left edge accent strip.
class _BannerBorderPainter extends CustomPainter {
  final Color borderColor;
  final Color accentColor;
  final double accentWidth;

  const _BannerBorderPainter({
    required this.borderColor,
    required this.accentColor,
    this.accentWidth = 4.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 16.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1.0, size.height - 1.0),
      const Radius.circular(radius),
    );

    // 1. Draw perimeter border around the entire card
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, borderPaint);

    // 2. Overdraw the left accent strip cleanly with rounded left edge
    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(radius),
    ));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, accentWidth, size.height),
      accentPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BannerBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.accentWidth != accentWidth;
  }
}
