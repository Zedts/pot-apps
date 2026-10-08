import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Payment method selection chips (Tunai, QRIS, Transfer)
class PenjualanPaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onMethodSelected;

  const PenjualanPaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    const methods = [
      {'key': 'tunai', 'label': 'Tunai'},
      {'key': 'qris', 'label': 'QRIS'},
      {'key': 'transfer', 'label': 'Transfer'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metode Pembayaran',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: PotColors.textDark,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: methods.map((m) {
            final key = m['key']!;
            final label = m['label']!;
            final isSelected = selectedMethod.toLowerCase() == key;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: key != 'transfer' ? 8.0 : 0.0,
                ),
                child: InkWell(
                  onTap: () => onMethodSelected(key),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? PotColors.primaryRed : PotColors.cardCream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? PotColors.primaryRed : PotColors.warmBorder,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: PotColors.primaryRed.withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                        color: isSelected ? PotColors.pureWhite : PotColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
