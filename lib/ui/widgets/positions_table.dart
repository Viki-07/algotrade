import 'package:flutter/material.dart';

class PositionsTable extends StatelessWidget {
  const PositionsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final rows = <_PositionRowData>[
      const _PositionRowData('BTCUSDT', 'Long', 0.35, 43210.3, 44102.7, 312.8),
      const _PositionRowData('ETHUSDT', 'Short', 2.1, 2331.0, 2298.4, 68.5),
      const _PositionRowData('SOLUSDT', 'Long', 55, 98.42, 101.06, 145.2),
      const _PositionRowData('AAPL', 'Long', 40, 189.44, 191.10, 66.4),
      const _PositionRowData('TSLA', 'Short', 10, 252.70, 249.31, 33.9),
    ];

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingTextStyle: theme.textTheme.labelLarge,
                  columns: const [
                    DataColumn(label: Text('Symbol')),
                    DataColumn(label: Text('Side')),
                    DataColumn(numeric: true, label: Text('Qty')),
                    DataColumn(numeric: true, label: Text('Avg')),
                    DataColumn(numeric: true, label: Text('Mark')),
                    DataColumn(numeric: true, label: Text('Unreal. P&L')),
                  ],
                  rows: rows
                      .map(
                        (r) => DataRow(
                          cells: [
                            DataCell(Text(r.symbol)),
                            DataCell(Text(r.side)),
                            DataCell(Text(_fmt(r.qty))),
                            DataCell(Text(_fmt(r.avg))),
                            DataCell(Text(_fmt(r.mark))),
                            DataCell(
                              Text(
                                _fmtSigned(r.pnl),
                                style: TextStyle(
                                  color: r.pnl >= 0
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static String _fmt(num v) {
    final s = v.toStringAsFixed(v.abs() >= 100 ? 2 : 4);
    if (!s.contains('.')) return s;
    final trimmed = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    return trimmed;
  }

  static String _fmtSigned(num v) {
    final abs = v.abs();
    final s = abs.toStringAsFixed(abs >= 100 ? 2 : 4);
    final prefix = v >= 0 ? '+' : '-';
    return '$prefix$s';
  }
}

class _PositionRowData {
  const _PositionRowData(
    this.symbol,
    this.side,
    this.qty,
    this.avg,
    this.mark,
    this.pnl,
  );

  final String symbol;
  final String side;
  final double qty;
  final double avg;
  final double mark;
  final double pnl;
}
