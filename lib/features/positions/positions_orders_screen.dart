import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/order.dart';
import '../../core/models/position.dart';
import '../../core/providers.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/kpi_tile.dart';
import '../../shared/widgets/panel.dart';

class PositionsOrdersScreen extends ConsumerWidget {
  const PositionsOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionsStream = ref.watch(positionsStreamProvider);
    final ordersStream = ref.watch(ordersStreamProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isNarrow = width < 600;

    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: EdgeInsets.all(isNarrow ? 12 : 16),
        child: Panel(
          title: 'Positions & Orders',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryRow(
                positionsStream: positionsStream,
                ordersStream: ordersStream,
              ),
              const SizedBox(height: 12),
              const TabBar(
                tabs: [
                  Tab(text: 'Positions'),
                  Tab(text: 'Orders'),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    _PositionsTab(stream: positionsStream),
                    _OrdersTab(stream: ordersStream),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.positionsStream, required this.ordersStream});

  final Stream<List<Position>> positionsStream;
  final Stream<List<Order>> ordersStream;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        StreamBuilder<List<Position>>(
          stream: positionsStream,
          builder: (context, snapshot) {
            final positions = snapshot.data;
            final count = positions?.length;
            final pnl = positions?.fold<double>(0.0, (sum, p) => sum + p.pnl);

            return KpiTile(
              title: 'Open Positions',
              value: count == null ? '--' : '$count',
              subtitle: pnl == null ? 'PnL --' : 'PnL ${_money(pnl)}',
              icon: Icons.account_balance_wallet_outlined,
              tone: (pnl ?? 0) >= 0 ? KpiTone.positive : KpiTone.negative,
            );
          },
        ),
        StreamBuilder<List<Order>>(
          stream: ordersStream,
          builder: (context, snapshot) {
            final orders = snapshot.data;
            final open = orders?.where((o) => o.status == OrderStatus.open).length;
            return KpiTile(
              title: 'Open Orders',
              value: open == null ? '--' : '$open',
              subtitle: 'Status: OPEN',
              icon: Icons.receipt_long_outlined,
            );
          },
        ),
      ],
    );
  }

  static String _money(double v) {
    final f = NumberFormat.compactCurrency(symbol: '\u20b9');
    final s = f.format(v.abs());
    return v >= 0 ? '+$s' : '-$s';
  }
}

class _PositionsTab extends StatelessWidget {
  const _PositionsTab({required this.stream});

  final Stream<List<Position>> stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Position>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppError(message: snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const AppLoader(message: 'Loading positions...');
        }
        final rows = snapshot.data ?? const <Position>[];

        if (rows.isEmpty) {
          return const Center(child: Text('No open positions'));
        }

        return SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Symbol')),
                DataColumn(label: Text('Side')),
                DataColumn(numeric: true, label: Text('Qty')),
                DataColumn(numeric: true, label: Text('Avg')),
                DataColumn(numeric: true, label: Text('LTP')),
                DataColumn(numeric: true, label: Text('PnL')),
              ],
              rows: rows
                  .map(
                    (p) => DataRow(
                      cells: [
                        DataCell(Text(p.symbol)),
                        DataCell(_SideChip(side: p.side)),
                        DataCell(Text(p.qty.toStringAsFixed(0))),
                        DataCell(Text(p.avgPrice.toStringAsFixed(2))),
                        DataCell(Text(p.ltp.toStringAsFixed(2))),
                        DataCell(
                          Text(
                            NumberFormat.compactCurrency(symbol: '\u20b9').format(p.pnl),
                            style: TextStyle(
                              color: p.pnl >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: FontWeight.w700,
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
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab({required this.stream});

  final Stream<List<Order>> stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppError(message: snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const AppLoader(message: 'Loading orders...');
        }
        final rows = snapshot.data ?? const <Order>[];

        if (rows.isEmpty) {
          return const Center(child: Text('No orders yet'));
        }

        return SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Order ID')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Status')),
                DataColumn(numeric: true, label: Text('Price')),
                DataColumn(label: Text('Timestamp')),
              ],
              rows: rows
                  .map(
                    (o) => DataRow(
                      cells: [
                        DataCell(Text(o.id)),
                        DataCell(Text(o.type.name.toUpperCase())),
                        DataCell(_OrderStatusChip(status: o.status)),
                        DataCell(Text(o.price.toStringAsFixed(2))),
                        DataCell(Text(DateFormat.Hms().format(o.timestamp))),
                      ],
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        );
      },
    );
  }
}

class _SideChip extends StatelessWidget {
  const _SideChip({required this.side});

  final Side side;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBuy = side == Side.buy;
    final color = isBuy ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        isBuy ? 'BUY' : 'SELL',
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _OrderStatusChip extends StatelessWidget {
  const _OrderStatusChip({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = switch (status) {
      OrderStatus.open => ('OPEN', Colors.blue.shade700),
      OrderStatus.filled => ('FILLED', Colors.green.shade700),
      OrderStatus.rejected => ('REJECTED', Colors.red.shade700),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}
