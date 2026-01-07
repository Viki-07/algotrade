enum OrderStatus { open, filled, rejected }

enum OrderType { market, limit }

class Order {
  const Order({
    required this.id,
    required this.type,
    required this.status,
    required this.price,
    required this.timestamp,
  });

  final String id;
  final OrderType type;
  final OrderStatus status;
  final double price;
  final DateTime timestamp;
}
