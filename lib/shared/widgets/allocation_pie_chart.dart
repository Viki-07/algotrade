import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllocationPieChart extends StatelessWidget {
  const AllocationPieChart({super.key, required this.weights});

  final Map<String, double> weights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = theme.colorScheme.onSurfaceVariant;

    if (weights.isEmpty) {
      return Center(
        child: Text(
          'No positions',
          style: theme.textTheme.bodyMedium?.copyWith(color: labelColor),
        ),
      );
    }

    final total = weights.values.fold<double>(0.0, (a, b) => a + b.abs());
    final safeTotal = total <= 1e-6 ? 1.0 : total;

    final palette = <Color>[
      const Color(0xFF22C55E),
      const Color(0xFF3B82F6),
      const Color(0xFFA855F7),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
    ];

    final entries = weights.entries.toList(growable: false);

    final sections = <PieChartSectionData>[];
    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      final value = e.value.abs();
      final pct = (value / safeTotal) * 100;
      final color = palette[i % palette.length];

      sections.add(
        PieChartSectionData(
          value: value,
          color: color,
          radius: 62,
          title: pct >= 10 ? '${pct.toStringAsFixed(0)}%' : '',
          titleStyle: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w800,
              ) ??
              const TextStyle(),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth.isFinite && constraints.maxWidth < 520;

        final chart = PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 38,
            sections: sections,
            pieTouchData: PieTouchData(
              enabled: true,
              touchCallback: (event, response) {},
            ),
          ),
        );

        final legend = _Legend(entries: entries, palette: palette);

        if (isNarrow) {
          return Column(
            children: [
              SizedBox(height: 220, child: chart),
              const SizedBox(height: 12),
              legend,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: chart),
            const SizedBox(width: 12),
            SizedBox(
              width: 170,
              child: legend,
            ),
          ],
        );
      },
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.entries, required this.palette});

  final List<MapEntry<String, double>> entries;
  final List<Color> palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = NumberFormat.compact();

    final total = entries.fold<double>(0.0, (a, b) => a + b.value.abs());
    final safeTotal = total <= 1e-6 ? 1.0 : total;

    return ListView.separated(
      shrinkWrap: true,
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final e = entries[i];
        final color = palette[i % palette.length];
        final pct = (e.value.abs() / safeTotal) * 100;

        return Row(
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                e.key,
                style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${pct.toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 8),
            Text(
              compact.format(e.value.abs()),
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        );
      },
    );
  }
}
