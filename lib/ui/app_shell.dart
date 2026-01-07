import 'package:flutter/material.dart';

import 'pages/dashboard_page.dart';
import 'pages/orders_page.dart';
import 'pages/positions_page.dart';
import 'pages/risk_page.dart';
import 'pages/settings_page.dart';
import 'pages/strategies_page.dart';

enum AppSection {
  dashboard('Dashboard', Icons.dashboard_outlined),
  strategies('Strategies', Icons.bolt_outlined),
  positions('Positions', Icons.account_balance_wallet_outlined),
  orders('Orders', Icons.receipt_long_outlined),
  risk('Risk', Icons.shield_outlined),
  settings('Settings', Icons.settings_outlined);

  const AppSection(this.label, this.icon);
  final String label;
  final IconData icon;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppSection _section = AppSection.dashboard;

  void _select(AppSection next) {
    if (_section == next) return;
    setState(() {
      _section = next;
    });
  }

  Widget _pageFor(AppSection section) {
    return switch (section) {
      AppSection.dashboard => const DashboardPage(),
      AppSection.strategies => const StrategiesPage(),
      AppSection.positions => const PositionsPage(),
      AppSection.orders => const OrdersPage(),
      AppSection.risk => const RiskPage(),
      AppSection.settings => const SettingsPage(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 1100;

    final content = _pageFor(_section);

    final destinations = AppSection.values
        .map(
          (s) => NavigationRailDestination(
            icon: Icon(s.icon),
            label: Text(s.label),
          ),
        )
        .toList(growable: false);

    final selectedIndex = AppSection.values.indexOf(_section);

    return Scaffold(
      appBar: AppBar(
        title: Text(_section.label),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.tonalIcon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow_outlined),
              label: const Text('Run'),
            ),
          ),
        ],
      ),
      drawer: isWide
          ? null
          : Drawer(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Text(
                        'AlgoTrade',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          for (final s in AppSection.values)
                            ListTile(
                              leading: Icon(s.icon),
                              title: Text(s.label),
                              selected: s == _section,
                              onTap: () {
                                Navigator.of(context).pop();
                                _select(s);
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => _select(AppSection.values[i]),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    const Icon(Icons.auto_graph_outlined, size: 28),
                    const SizedBox(height: 8),
                    Text('AlgoTrade', style: theme.textTheme.titleSmall),
                  ],
                ),
              ),
              destinations: destinations,
            ),
          Expanded(
            child: Container(
              color: theme.colorScheme.surface,
              child: SafeArea(
                top: false,
                child: content,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
