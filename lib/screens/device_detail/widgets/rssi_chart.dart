import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ble_utils.dart';
import '../../../core/constants/ui_constants.dart';

/// Real-time RSSI line chart using fl_chart.
class RssiChart extends StatefulWidget {
  final int rssi;

  const RssiChart({super.key, required this.rssi});

  @override
  State<RssiChart> createState() => _RssiChartState();
}

class _RssiChartState extends State<RssiChart> {
  final ListQueue<FlSpot> _spots = ListQueue<FlSpot>();
  int _timeIndex = 0;

  @override
  void didUpdateWidget(RssiChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rssi != oldWidget.rssi) {
      _addRssiValue(widget.rssi.toDouble());
    }
  }

  void _addRssiValue(double rssi) {
    _spots.add(FlSpot(_timeIndex.toDouble(), rssi));
    if (_spots.length > UiConstants.rssiChartMaxPoints) {
      _spots.removeFirst();
    }
    _timeIndex++;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (_spots.isEmpty) {
      _addRssiValue(widget.rssi.toDouble());
    }

    return Padding(
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      child: Column(
        children: [
          // Current RSSI display
          Card(
            child: Padding(
              padding: const EdgeInsets.all(UiConstants.spacingMd),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRssiStat(
                    context,
                    'RSSI',
                    '${widget.rssi} dBm',
                    AppColors.rssiExcellent,
                  ),
                  _buildRssiStat(
                    context,
                    'Quality',
                    BleUtils.rssiToLabel(widget.rssi),
                    widget.rssi >= -65
                        ? AppColors.rssiExcellent
                        : AppColors.rssiFair,
                  ),
                  _buildRssiStat(
                    context,
                    'Signal',
                    '${(BleUtils.rssiToPercent(widget.rssi) * 100).toInt()}%',
                    AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: UiConstants.spacingMd),

          // Chart
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(UiConstants.spacingMd),
                child: _spots.length < 2
                    ? const Center(
                        child: Text('Waiting for data...'),
                      )
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 15,
                            getDrawingHorizontalLine: (double value) {
                              return FlLine(
                                color: theme.colorScheme.outlineVariant
                                    .withAlpha(60),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: 15,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  return Text(
                                    '${value.toInt()}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minY: -100,
                          maxY: -20,
                          lineBarsData: [
                            LineChartBarData(
                              spots: _spots.toList(),
                              isCurved: true,
                              color: AppColors.rssiExcellent,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.rssiExcellent.withAlpha(30),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRssiStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
