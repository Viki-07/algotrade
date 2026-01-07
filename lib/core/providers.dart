import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/auth_api.dart';
import 'models/dashboard_metrics.dart';
import 'models/log_event.dart';
import 'models/order.dart';
import 'models/position.dart';
import 'models/strategy.dart';
import 'session/session_store.dart';
import 'websocket/mock_realtime.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError('SharedPreferences must be overridden in main()');
});

final sessionStoreProvider = Provider<SessionStore>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SessionStore(prefs: prefs);
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi();
});

typedef AsyncVoidCallback = Future<void> Function();

class AuthState {
  const AuthState({required this.token, required this.loading, this.error});

  final String? token;
  final bool loading;
  final String? error;

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  AuthState copyWith({String? token, bool? loading, String? error}) {
    return AuthState(
      token: token ?? this.token,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required SessionStore store,
    required AuthApi api,
    required MockRealtimeService realtime,
  })  : _store = store,
        _api = api,
        _realtime = realtime,
        super(AuthState(token: store.token, loading: false)) {
    final token = _store.token;
    if (token != null && token.isNotEmpty) {
      // Fire-and-forget: if a token exists, establish realtime connection.
      _realtime.connect(token: token);
    }
  }

  final SessionStore _store;
  final AuthApi _api;
  final MockRealtimeService _realtime;

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final token = await _api.login(email: email, password: password);
      await _store.setToken(token);
      await _realtime.connect(token: token);
      state = state.copyWith(token: token, loading: false, error: null);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(loading: true, error: null);
    await _realtime.disconnect();
    await _store.clear();
    state = const AuthState(token: null, loading: false);
  }
}

final mockRealtimeProvider = Provider<MockRealtimeService>((ref) {
  final svc = MockRealtimeService();
  ref.onDispose(svc.dispose);
  return svc;
});

final dashboardMetricsStreamProvider = Provider<Stream<DashboardMetrics>>((ref) {
  return ref.watch(mockRealtimeProvider).metricsStream;
});

final strategiesStreamProvider = Provider<Stream<List<Strategy>>>((ref) {
  return ref.watch(mockRealtimeProvider).strategiesStream;
});

final positionsStreamProvider = Provider<Stream<List<Position>>>((ref) {
  return ref.watch(mockRealtimeProvider).positionsStream;
});

final ordersStreamProvider = Provider<Stream<List<Order>>>((ref) {
  return ref.watch(mockRealtimeProvider).ordersStream;
});

final logsStreamProvider = Provider<Stream<List<LogEvent>>>((ref) {
  return ref.watch(mockRealtimeProvider).logsStream;
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = ref.watch(authApiProvider);
  final realtime = ref.watch(mockRealtimeProvider);
  return AuthController(store: store, api: api, realtime: realtime);
});

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    _sub = ref.listen<AuthState>(authControllerProvider, (prev, next) {
      notifyListeners();
    });
  }

  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
