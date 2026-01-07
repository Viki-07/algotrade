import 'package:flutter/material.dart';

import '../widgets/positions_table.dart';

class PositionsPage extends StatelessWidget {
  const PositionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: const PositionsTable(),
    );
  }
}
