import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

/// Istanbul Ottoman Mosque Skyline Silhouette Vector & Turkish Brand Slogan.
/// Recreates the skyline footer faithfully from ref/login.html using a clean CustomPainter.
class SkylineFooter extends StatelessWidget {
  const SkylineFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Vector Skyline Art
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            // 500:135 aspect ratio matching reference SVG
            final height = width * (135.0 / 500.0);

            return SizedBox(
              width: width,
              height: height,
              child: CustomPaint(
                size: Size(width, height),
                painter: _IstanbulSkylinePainter(),
              ),
            );
          },
        ),

        const SizedBox(height: 6),

        // Brand Signature Slogan
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Oleh',
                  style: const TextStyle(
                    color: PotColors.primaryRed,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  children: [
                    WidgetSpan(
                      child: Transform.translate(
                        offset: const Offset(0, -6),
                        child: const Text(
                          '2',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: PotColors.primaryRed,
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(
                      text: ' Turki',
                      style: TextStyle(
                        color: PotColors.primaryRed,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Lebih Dekat untuk Semua',
                style: GoogleFonts.playball(
                  color: PotColors.accentRed,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IstanbulSkylinePainter extends CustomPainter {
  _IstanbulSkylinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Reference coordinates are based on 500 x 135
    final scaleX = size.width / 500.0;
    final scaleY = size.height / 135.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // 1. Soft Background Hill Ridge
    final hillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x60EAA683),
          Color(0x8CDC8962),
        ],
      ).createShader(const Rect.fromLTWH(0, 85, 500, 25));

    final hillPath = Path()
      ..moveTo(0, 105)
      ..quadraticBezierTo(80, 88, 150, 91)
      ..quadraticBezierTo(230, 86, 310, 90)
      ..quadraticBezierTo(400, 85, 500, 92)
      ..lineTo(500, 105)
      ..lineTo(0, 105)
      ..close();
    canvas.drawPath(hillPath, hillPaint);

    // 2. Terracotta Foreground Buildings Paint
    final buildingPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xC0CF6E48),
          Color(0xE0B8552E),
        ],
      ).createShader(const Rect.fromLTWH(0, 10, 500, 110));

    final creamWindowPaint = Paint()
      ..color = PotColors.bgCream
      ..style = PaintingStyle.fill;

    // Left Minaret 1
    final minaret1 = Path()
      ..moveTo(87, 105)
      ..lineTo(87, 44)
      ..lineTo(85.5, 44)
      ..lineTo(85.5, 36)
      ..lineTo(88, 24)
      ..lineTo(90.5, 36)
      ..lineTo(90.5, 44)
      ..lineTo(89, 105)
      ..close();
    canvas.drawPath(minaret1, buildingPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(85, 44, 6, 2.5), const Radius.circular(0.4)), buildingPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(85.5, 62, 5, 2), const Radius.circular(0.4)), buildingPaint);

    // Building with Arched Windows
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(94, 68, 52, 37), const Radius.circular(0.5)), buildingPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(115, 45, 8, 23), const Radius.circular(0.5)), buildingPaint);
    final turretRoof = Path()
      ..moveTo(119, 37)
      ..lineTo(121.5, 45)
      ..lineTo(116.5, 45)
      ..close();
    canvas.drawPath(turretRoof, buildingPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(114, 55, 10, 2), const Radius.circular(0.3)), buildingPaint);

    // 3 Arched Windows
    for (final x in [101.0, 116.0, 131.0]) {
      final windowPath = Path()
        ..moveTo(x, 85)
        ..lineTo(x, 78)
        ..arcToPoint(Offset(x + 6, 78), radius: const Radius.circular(3))
        ..lineTo(x + 6, 85)
        ..close();
      canvas.drawPath(windowPath, creamWindowPaint);
    }

    // Left Single Dome Building
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(151, 74, 36, 31), const Radius.circular(0.5)), buildingPaint);
    final dome1 = Path()
      ..moveTo(151, 74)
      ..cubicTo(151, 56, 187, 56, 187, 74)
      ..close();
    canvas.drawPath(dome1, buildingPaint);
    final spirePaint = Paint()
      ..color = const Color(0xFFB8552E)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(169, 50), const Offset(169, 55), spirePaint);
    canvas.drawCircle(const Offset(169, 49), 1.2, Paint()..color = const Color(0xFFB8552E));

    // Tall Center-Left Minaret
    final minaret2 = Path()
      ..moveTo(248, 105)
      ..lineTo(248, 32)
      ..lineTo(246.5, 32)
      ..lineTo(246.5, 22)
      ..lineTo(249, 12)
      ..lineTo(251.5, 22)
      ..lineTo(251.5, 32)
      ..lineTo(250, 105)
      ..close();
    canvas.drawPath(minaret2, buildingPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(246, 32, 6, 2.5), const Radius.circular(0.4)), buildingPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(246.5, 52, 5, 2), const Radius.circular(0.4)), buildingPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(247, 70, 4.5, 1.8), const Radius.circular(0.4)), buildingPaint);

    // Grand Central Mosque Base & Wings
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(257, 70, 92, 35), const Radius.circular(0.5)), buildingPaint);
    final shoulder1 = Path()..moveTo(257, 75)..cubicTo(257, 66, 281, 66, 281, 75)..close();
    final shoulder2 = Path()..moveTo(325, 75)..cubicTo(325, 66, 349, 66, 349, 75)..close();
    canvas.drawPath(shoulder1, buildingPaint);
    canvas.drawPath(shoulder2, buildingPaint);

    // Central Grand Dome
    final mainDome = Path()..moveTo(281, 71)..cubicTo(281, 48, 325, 48, 325, 71)..close();
    canvas.drawPath(mainDome, buildingPaint);

    final domeCapPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xF09C3F1B), Color(0xD0BD5B33)],
      ).createShader(const Rect.fromLTWH(287, 50, 32, 15));
    final domeCap = Path()..moveTo(287, 60)..cubicTo(289, 50, 317, 50, 319, 60)..cubicTo(312, 65, 294, 65, 287, 60)..close();
    canvas.drawPath(domeCap, domeCapPaint);

    final finialPaint = Paint()
      ..color = const Color(0xFF9C3F1B)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(303, 41), const Offset(303, 48), finialPaint);
    canvas.drawCircle(const Offset(303, 40), 1.4, Paint()..color = const Color(0xFF9C3F1B));

    // Cascading Right Domes
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(360, 76, 90, 29), const Radius.circular(0.5)), buildingPaint);
    final medDome = Path()..moveTo(362, 77)..cubicTo(362, 64, 394, 64, 394, 77)..close();
    final smallDome = Path()..moveTo(403, 77)..cubicTo(403, 68, 427, 68, 427, 77)..close();
    canvas.drawPath(medDome, buildingPaint);
    canvas.drawPath(smallDome, buildingPaint);

    // Tall Center-Right Twin Minaret
    final minaret3 = Path()
      ..moveTo(347, 105)
      ..lineTo(347, 28)
      ..lineTo(345.5, 28)
      ..lineTo(345.5, 18)
      ..lineTo(348, 8)
      ..lineTo(350.5, 18)
      ..lineTo(350.5, 28)
      ..lineTo(349, 105)
      ..close();
    canvas.drawPath(minaret3, buildingPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(345, 28, 6, 2.5), const Radius.circular(0.4)), buildingPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(345.5, 48, 5, 2), const Radius.circular(0.4)), buildingPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(346, 68, 4.5, 1.8), const Radius.circular(0.4)), buildingPaint);

    // Right Minaret
    final minaret4 = Path()
      ..moveTo(432, 105)
      ..lineTo(432, 38)
      ..lineTo(430.5, 38)
      ..lineTo(430.5, 28)
      ..lineTo(433, 16)
      ..lineTo(435.5, 28)
      ..lineTo(435.5, 38)
      ..lineTo(434, 105)
      ..close();
    canvas.drawPath(minaret4, buildingPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(430, 38, 6, 2.5), const Radius.circular(0.4)), buildingPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(431, 58, 4.5, 1.8), const Radius.circular(0.4)), buildingPaint);

    // Far Right Pointed Spire
    final spireFar = Path()
      ..moveTo(483, 105)
      ..lineTo(483, 50)
      ..lineTo(485, 38)
      ..lineTo(487, 50)
      ..lineTo(487, 105)
      ..close();
    canvas.drawPath(spireFar, buildingPaint);

    // 3. Solid Ground Strip
    canvas.drawRect(const Rect.fromLTWH(0, 103, 500, 18), buildingPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
