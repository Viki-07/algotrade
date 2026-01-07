import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class EquityChart extends StatelessWidget {
  const EquityChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final points = <double>[
      100,
      101.2,
      100.8,
      102.0,
      103.4,
      102.7,
      104.1,
      105.8,
      105.1,
      106.9,
      107.4,
      108.6,
      109.1,
      110.2,
    ];

    if (points.length < 2) {
      return Center(
        child: Text(
          'No data',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final minY = points.reduce((a, b) => a < b ? a : b);
    final maxY = points.reduce((a, b) => a > b ? a : b);
    final span = (maxY - minY).abs() < 1e-6 ? 1.0 : (maxY - minY);

    final lineColor = theme.colorScheme.primary;
    final gridColor = theme.colorScheme.outlineVariant;
    final labelColor = theme.colorScheme.onSurfaceVariant;

    final yFormatter = NumberFormat.compact();
    final tooltipFormatter = NumberFormat.compactCurrency(symbol: '\u20b9');

    final minLabel = yFormatter.format(minY);
    final maxLabel = yFormatter.format(maxY);
    final maxLabelLen = (minLabel.length > maxLabel.length) ? minLabel.length : maxLabel.length;
    final reserved = (16.0 + (maxLabelLen * 7.0)).clamp(44.0, 88.0);

    final spots = <FlSpot>[
      for (int i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i]),
    ];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: minY - span * 0.08,
        maxY: maxY + span * 0.08,
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => theme.colorScheme.surface,
            tooltipBorder: BorderSide(color: gridColor),
            tooltipRoundedRadius: 10,
            getTooltipItems: (touchedSpots) {
              return touchedSpots
                  .map(
                    (s) => LineTooltipItem(
                      tooltipFormatter.format(s.y),
                      theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ) ??
                          const TextStyle(),
                    ),
                  )
                  .toList(growable: false);
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: gridColor,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: reserved,
              interval: span / 4,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      yFormatter.format(value),
                      style: theme.textTheme.labelSmall?.copyWith(color: labelColor),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: gridColor),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.22,
            color: lineColor,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withValues(alpha: 0.22),
                  lineColor.withValues(alpha: 0.00),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
