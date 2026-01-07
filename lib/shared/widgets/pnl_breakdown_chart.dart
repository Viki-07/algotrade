import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PnlBreakdownChart extends StatelessWidget {
  const PnlBreakdownChart({super.key, required this.realized, required this.unrealized});

  final double realized;
  final double unrealized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = NumberFormat.compactCurrency(symbol: '\u20b9');

    final maxAbs = [realized.abs(), unrealized.abs()].reduce((a, b) => a > b ? a : b);
    final maxY = (maxAbs <= 1e-6) ? 1.0 : maxAbs * 1.25;

    final realizedColor = realized >= 0 ? Colors.green.shade500 : Colors.red.shade500;
    final unrealizedColor = unrealized >= 0 ? Colors.green.shade800 : Colors.red.shade800;

    final gridColor = theme.colorScheme.outlineVariant;
    final labelColor = theme.colorScheme.onSurfaceVariant;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: -maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => theme.colorScheme.surface,
            tooltipBorder: BorderSide(color: gridColor),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final name = group.x == 0 ? 'Realized' : 'Unrealized';
              return BarTooltipItem(
                '$name\n${label.format(rod.toY)}',
                theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ) ??
                    const TextStyle(),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('0', style: theme.textTheme.labelSmall?.copyWith(color: labelColor)),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    NumberFormat.compact().format(value),
                    style: theme.textTheme.labelSmall?.copyWith(color: labelColor),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final v = value.toInt();
                final text = v == 0 ? 'Realized' : v == 1 ? 'Unrealized' : '';
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    text,
                    style: theme.textTheme.labelSmall?.copyWith(color: labelColor),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: gridColor, strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: gridColor),
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: realized,
                width: 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(8)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    realizedColor.withValues(alpha: 0.55),
                    realizedColor,
                  ],
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: unrealized,
                width: 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(8)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    unrealizedColor.withValues(alpha: 0.55),
                    unrealizedColor,
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
