import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/providers.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/logs/logs_screen.dart';
import 'features/positions/positions_orders_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/strategies/strategies_list_screen.dart';
import 'features/strategies/strategy_config_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  final refresh = RouterRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login';
      if (!auth.isLoggedIn) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/strategies',
            pageBuilder: (context, state) => const NoTransitionPage(child: StrategiesListScreen()),
            routes: [
              GoRoute(
                path: ':id/config',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return StrategyConfigScreen(strategyId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/positions',
            pageBuilder: (context, state) => const NoTransitionPage(child: PositionsOrdersScreen()),
          ),
          GoRoute(
            path: '/logs',
            pageBuilder: (context, state) => const NoTransitionPage(child: LogsScreen()),
          ),
        ],
      ),
    ],
  );
});
