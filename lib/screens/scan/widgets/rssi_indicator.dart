import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A visual RSSI signal strength indicator bar.
class RssiIndicator extends StatelessWidget {
  final int rssi;
  final double size;
  final int barCount;

  const RssiIndicator({
    super.key,
    required this.rssi,
    this.size = 16,
    this.barCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = ((rssi + 100) / 70).clamp(0.0, 1.0);
    final int filledBars = (ratio * barCount).round().clamp(0, barCount);

    Color barColor;
    if (ratio >= 0.7) {
      barColor = AppColors.rssiExcellent;
    } else if (ratio >= 0.45) {
      barColor = AppColors.rssiGood;
    } else if (ratio >= 0.2) {
      barColor = AppColors.rssiFair;
    } else {
      barColor = AppColors.rssiPoor;
    }

    return SizedBox(
      height: size,
      width: size,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(barCount, (int i) {
          final bool filled = i < filledBars;
          final double barHeight = size * (i + 1) / barCount;
          return Container(
            width: size / (barCount * 1.8),
            height: barHeight,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: filled ? barColor : barColor.withAlpha(40),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
