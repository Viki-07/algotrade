import 'dart:async';
import 'dart:math' as math;

import '../models/dashboard_metrics.dart';
import '../models/log_event.dart';
import '../models/order.dart';
import '../models/position.dart';
import '../models/strategy.dart';

class MockRealtimeService {
  late final StreamController<DashboardMetrics> _metricsCtrl;
  late final StreamController<List<Strategy>> _strategiesCtrl;
  late final StreamController<List<Position>> _positionsCtrl;
  late final StreamController<List<Order>> _ordersCtrl;
  late final StreamController<List<LogEvent>> _logsCtrl;

  MockRealtimeService() {
    _metricsCtrl = StreamController<DashboardMetrics>.broadcast(
      onListen: () {
        if (_connected) _metricsCtrl.add(_metrics);
      },
    );
    _strategiesCtrl = StreamController<List<Strategy>>.broadcast(
      onListen: () {
        if (_connected) {
          _strategiesCtrl.add(List<Strategy>.unmodifiable(_strategies));
        }
      },
    );
    _positionsCtrl = StreamController<List<Position>>.broadcast(
      onListen: () {
        if (_connected) {
          _positionsCtrl.add(List<Position>.unmodifiable(_positions));
        }
      },
    );
    _ordersCtrl = StreamController<List<Order>>.broadcast(
      onListen: () {
        if (_connected) {
          _ordersCtrl.add(List<Order>.unmodifiable(_orders));
        }
      },
    );
    _logsCtrl = StreamController<List<LogEvent>>.broadcast(
      onListen: () {
        if (_connected) {
          _logsCtrl.add(List<LogEvent>.unmodifiable(_logs));
        }
      },
    );
  }

  Stream<DashboardMetrics> get metricsStream => _metricsCtrl.stream;
  Stream<List<Strategy>> get strategiesStream => _strategiesCtrl.stream;
  Stream<List<Position>> get positionsStream => _positionsCtrl.stream;
  Stream<List<Order>> get ordersStream => _ordersCtrl.stream;
  Stream<List<LogEvent>> get logsStream => _logsCtrl.stream;

  bool _connected = false;
  Timer? _tick;

  final _rng = math.Random();

  DashboardMetrics _metrics = const DashboardMetrics(
    totalPnl: 12540.25,
    realizedPnl: 4320.10,
    unrealizedPnl: 8220.15,
    activeStrategies: 2,
    openPositions: 5,
    marketStatus: 'OPEN',
    killSwitchArmed: false,
  );

  List<Strategy> _strategies = const [
    Strategy(
      id: 's1',
      name: 'ORB Breakout',
      instrument: 'NIFTY',
      status: StrategyStatus.running,
      currentPnl: 1240.5,
    ),
    Strategy(
      id: 's2',
      name: 'Mean Reversion',
      instrument: 'BANKNIFTY',
      status: StrategyStatus.stopped,
      currentPnl: -220.2,
    ),
    Strategy(
      id: 's3',
      name: 'VWAP Trend',
      instrument: 'NIFTY',
      status: StrategyStatus.stopped,
      currentPnl: 0.0,
    ),
  ];

  final List<Position> _positions = const [
    Position(
      symbol: 'NIFTY',
      side: Side.buy,
      qty: 100,
      avgPrice: 22110.5,
      ltp: 22142.0,
      pnl: 3150.0,
    ),
    Position(
      symbol: 'BANKNIFTY',
      side: Side.sell,
      qty: 30,
      avgPrice: 48210.0,
      ltp: 48180.5,
      pnl: 885.0,
    ),
    Position(
      symbol: 'FINNIFTY',
      side: Side.buy,
      qty: 40,
      avgPrice: 21455.2,
      ltp: 21421.7,
      pnl: -1340.0,
    ),
    Position(
      symbol: 'MIDCPNIFTY',
      side: Side.sell,
      qty: 75,
      avgPrice: 11234.0,
      ltp: 11205.4,
      pnl: 2145.0,
    ),
  ];

  final List<Order> _orders = [
    Order(
      id: 'OID-10021',
      type: OrderType.limit,
      status: OrderStatus.open,
      price: 22155.0,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    Order(
      id: 'OID-10020',
      type: OrderType.market,
      status: OrderStatus.filled,
      price: 48185.5,
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    Order(
      id: 'OID-10019',
      type: OrderType.limit,
      status: OrderStatus.rejected,
      price: 21450.0,
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
    ),
    Order(
      id: 'OID-10018',
      type: OrderType.market,
      status: OrderStatus.filled,
      price: 11208.0,
      timestamp: DateTime.now().subtract(const Duration(minutes: 27)),
    ),
    Order(
      id: 'OID-10017',
      type: OrderType.limit,
      status: OrderStatus.open,
      price: 22120.0,
      timestamp: DateTime.now().subtract(const Duration(minutes: 34)),
    ),
  ];

  final List<LogEvent> _logs = [
    LogEvent(
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      level: LogLevel.info,
      message: 'Session connected',
    ),
    LogEvent(
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      level: LogLevel.info,
      message: 'Strategy ORB Breakout started (paper)',
    ),
  ];

  Future<void> connect({required String token}) async {
    if (_connected) return;
    _connected = true;

    _emitAll();
    _appendLog(LogLevel.info, 'WebSocket connected');

    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      _pulse();
    });
  }

  Future<void> disconnect() async {
    if (!_connected) return;
    _connected = false;
    _tick?.cancel();
    _tick = null;
    _appendLog(LogLevel.warn, 'WebSocket disconnected');
  }

  void setKillSwitch(bool armed) {
    _metrics = _metrics.copyWith(killSwitchArmed: armed);
    _appendLog(LogLevel.warn, armed ? 'Global kill switch ARMED' : 'Global kill switch RELEASED');
    _metricsCtrl.add(_metrics);
  }

  Future<void> startStrategy(String id, StrategyConfig config) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    _strategies = _strategies
        .map(
          (s) => s.id == id ? s.copyWith(status: StrategyStatus.running, instrument: config.instrument) : s,
        )
        .toList(growable: false);

    _appendLog(LogLevel.info, 'Strategy $id started (${config.mode.name})');
    _pushStrategies();
    _recalcCounts();
  }

  Future<void> stopStrategy(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    _strategies = _strategies
        .map(
          (s) => s.id == id ? s.copyWith(status: StrategyStatus.stopped) : s,
        )
        .toList(growable: false);

    _appendLog(LogLevel.info, 'Strategy $id stopped');
    _pushStrategies();
    _recalcCounts();
  }

  void _pulse() {
    if (!_connected) return;

    final drift = (_rng.nextDouble() - 0.5) * 90;
    final realizedDrift = (_rng.nextDouble() - 0.5) * 20;
    final unrealizedDrift = drift - realizedDrift;

    _metrics = _metrics.copyWith(
      totalPnl: _metrics.totalPnl + drift,
      realizedPnl: _metrics.realizedPnl + realizedDrift,
      unrealizedPnl: _metrics.unrealizedPnl + unrealizedDrift,
      marketStatus: _metrics.marketStatus,
    );

    _metricsCtrl.add(_metrics);

    _strategies = _strategies
        .map(
          (s) {
            if (s.status != StrategyStatus.running) return s;
            final dp = (_rng.nextDouble() - 0.5) * 40;
            return s.copyWith(currentPnl: s.currentPnl + dp);
          },
        )
        .toList(growable: false);
    _pushStrategies();

    if (_rng.nextDouble() < 0.12) {
      _appendLog(LogLevel.info, 'Heartbeat OK');
    }
  }

  void _emitAll() {
    _metricsCtrl.add(_metrics);
    _pushStrategies();
    _positionsCtrl.add(_positions);
    _ordersCtrl.add(_orders);
    _logsCtrl.add(List<LogEvent>.unmodifiable(_logs));
  }

  void _pushStrategies() {
    _strategiesCtrl.add(List<Strategy>.unmodifiable(_strategies));
  }

  void _recalcCounts() {
    final active = _strategies.where((s) => s.status == StrategyStatus.running).length;
    _metrics = _metrics.copyWith(activeStrategies: active, openPositions: _positions.length);
    _metricsCtrl.add(_metrics);
  }

  void _appendLog(LogLevel level, String message) {
    _logs.insert(0, LogEvent(timestamp: DateTime.now(), level: level, message: message));
    if (_logs.length > 200) {
      _logs.removeRange(200, _logs.length);
    }
    _logsCtrl.add(List<LogEvent>.unmodifiable(_logs));
  }

  void dispose() {
    _tick?.cancel();
    _metricsCtrl.close();
    _strategiesCtrl.close();
    _positionsCtrl.close();
    _ordersCtrl.close();
    _logsCtrl.close();
  }
}
