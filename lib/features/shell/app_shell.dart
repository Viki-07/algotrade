import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';

enum AppNavItem {
  dashboard('Dashboard', Icons.dashboard_outlined, '/dashboard'),
  strategies('Strategies', Icons.bolt_outlined, '/strategies'),
  positions('Positions / Orders', Icons.account_balance_wallet_outlined, '/positions'),
  logs('Logs', Icons.list_alt_outlined, '/logs');

  const AppNavItem(this.label, this.icon, this.path);
  final String label;
  final IconData icon;
  final String path;
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  AppNavItem _activeForLocation(String location) {
    if (location.startsWith('/strategies')) return AppNavItem.strategies;
    if (location.startsWith('/positions')) return AppNavItem.positions;
    if (location.startsWith('/logs')) return AppNavItem.logs;
    return AppNavItem.dashboard;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1100;
    final isNarrow = width < 520;
    final location = GoRouterState.of(context).uri.toString();
    final active = _activeForLocation(location);

    void go(AppNavItem item) {
      if (item == active) return;
      context.go(item.path);
    }

    final railDestinations = AppNavItem.values
        .map(
          (i) => NavigationRailDestination(
            icon: Icon(i.icon),
            label: Text(i.label),
          ),
        )
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(active.label, overflow: TextOverflow.ellipsis),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: isNarrow
                ? IconButton(
                    tooltip: 'Logout',
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).logout();
                    },
                    icon: const Icon(Icons.logout_outlined),
                  )
                : FilledButton.tonalIcon(
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).logout();
                    },
                    icon: const Icon(Icons.logout_outlined),
                    label: const Text('Logout'),
                  ),
          )
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
                          for (final item in AppNavItem.values)
                            ListTile(
                              leading: Icon(item.icon),
                              title: Text(item.label),
                              selected: item == active,
                              onTap: () {
                                Navigator.of(context).pop();
                                go(item);
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
              selectedIndex: AppNavItem.values.indexOf(active),
              onDestinationSelected: (i) => go(AppNavItem.values[i]),
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
              destinations: railDestinations,
            ),
          Expanded(
            child: Container(
              color: theme.colorScheme.surface,
              child: SafeArea(
                top: false,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
