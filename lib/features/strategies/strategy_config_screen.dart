import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/strategy.dart';
import '../../core/providers.dart';
import '../../shared/widgets/panel.dart';

class StrategyConfigScreen extends ConsumerStatefulWidget {
  const StrategyConfigScreen({super.key, required this.strategyId});

  final String strategyId;

  @override
  ConsumerState<StrategyConfigScreen> createState() => _StrategyConfigScreenState();
}

class _StrategyConfigScreenState extends ConsumerState<StrategyConfigScreen> {
  String _instrument = 'NIFTY';
  TradeMode _mode = TradeMode.paper;

  final _qtyCtrl = TextEditingController(text: '50');
  final _slCtrl = TextEditingController(text: '1.0');
  final _targetCtrl = TextEditingController(text: '1.5');

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _slCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  StrategyConfig _buildConfig() {
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final sl = double.tryParse(_slCtrl.text.trim()) ?? 0;
    final target = double.tryParse(_targetCtrl.text.trim()) ?? 0;
    return StrategyConfig(
      instrument: _instrument,
      quantity: qty,
      stopLossPercent: sl,
      targetPercent: target,
      mode: _mode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Panel(
        title: 'Strategy Configuration',
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/strategies'),
            icon: const Icon(Icons.arrow_back_outlined),
            label: const Text('Back'),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Strategy: ${widget.strategyId}', style: theme.textTheme.labelLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _instrument,
                    decoration: const InputDecoration(
                      labelText: 'Instrument',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'NIFTY', child: Text('NIFTY')),
                      DropdownMenuItem(value: 'BANKNIFTY', child: Text('BANKNIFTY')),
                    ],
                    onChanged: _saving ? null : (v) => setState(() => _instrument = v ?? 'NIFTY'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _qtyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !_saving,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _slCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Stop Loss %',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !_saving,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _targetCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Target %',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !_saving,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TradeMode>(
              initialValue: _mode,
              decoration: const InputDecoration(
                labelText: 'Mode',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: TradeMode.paper, child: Text('Paper')),
                DropdownMenuItem(value: TradeMode.live, child: Text('Live')),
              ],
              onChanged: _saving ? null : (v) => setState(() => _mode = v ?? TradeMode.paper),
            ),
            const SizedBox(height: 14),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () {
                            setState(() {
                              _error = null;
                            });
                          },
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _saving
                        ? null
                        : () async {
                            final router = GoRouter.of(context);
                            setState(() {
                              _saving = true;
                              _error = null;
                            });

                            final cfg = _buildConfig();
                            if (cfg.quantity <= 0) {
                              setState(() {
                                _saving = false;
                                _error = 'Quantity must be > 0';
                              });
                              return;
                            }

                            try {
                              await ref.read(mockRealtimeProvider).startStrategy(widget.strategyId, cfg);
                              if (mounted) {
                                router.go('/strategies');
                              }
                            } catch (e) {
                              setState(() {
                                _error = e.toString();
                              });
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _saving = false;
                                });
                              }
                            }
                          },
                    icon: const Icon(Icons.play_arrow_outlined),
                    label: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Start Strategy'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
