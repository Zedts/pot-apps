import 'package:flutter/material.dart';
import '../../core/models/lapak_model.dart';
import '../common/lapak_info_card.dart';

/// Clean card displaying current verified stall metadata matching ref/penerimaan.html.
/// Delegates to the shared [LapakInfoCard] to eliminate duplicate implementation.
class PenerimaanLocationCard extends StatelessWidget {
  final LapakModel? stall;

  const PenerimaanLocationCard({
    super.key,
    required this.stall,
  });

  @override
  Widget build(BuildContext context) {
    return LapakInfoCard(stall: stall);
  }
}
