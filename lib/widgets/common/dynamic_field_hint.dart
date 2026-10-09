import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Reusable dynamic feedback hint placed underneath input fields.
/// Shows contextual warning or success status with optional tap action.
/// Shared across Penerimaan notes and Closingan reconciliation.
class DynamicFieldHint extends StatelessWidget {
  final String hintText;
  final bool isWarning;
  final VoidCallback? onTap;

  const DynamicFieldHint({
    super.key,
    required this.hintText,
    required this.isWarning,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = isWarning ? Icons.lightbulb_outline : Icons.check_circle_outline;
    final color = isWarning ? PotColors.statusWarningText : PotColors.statusSuccessText;
    final iconColor = isWarning ? PotColors.iconOrange : PotColors.statusSuccessText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Row(
          children: [
            Icon(
              iconData,
              size: 13,
              color: iconColor,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                hintText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                  decoration: (isWarning && onTap != null) ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
