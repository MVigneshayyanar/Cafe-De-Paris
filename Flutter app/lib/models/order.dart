/// Order model for Cafe De Paris
enum OrderStatus { newOrder, preparing, ready, served, awaitingPayment }

class OrderItem {
  final String name;
  final int quantity;

  const OrderItem({required this.name, required this.quantity});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'] as String? ?? 'Item',
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'quantity': quantity};
}

class Order {
  final String id;
  final String tableId;
  final String tableName;
  final OrderStatus status;
  final List<OrderItem> items;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.tableId,
    required this.tableName,
    required this.status,
    required this.items,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'new';
    OrderStatus status;
    switch (statusStr) {
      case 'new': status = OrderStatus.newOrder; break;
      case 'preparing': status = OrderStatus.preparing; break;
      case 'ready': case 'ready_to_serve': status = OrderStatus.ready; break;
      case 'served': status = OrderStatus.served; break;
      case 'awaiting_payment': status = OrderStatus.awaitingPayment; break;
      default: status = OrderStatus.preparing;
    }

    final itemsList = json['items'] as List? ?? [];
    return Order(
      id: json['id']?.toString() ?? '',
      tableId: json['tableId']?.toString() ?? '',
      tableName: json['tableName'] as String? ?? 'Table',
      status: status,
      items: itemsList.map((i) => OrderItem.fromJson(i as Map<String, dynamic>)).toList(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  String get itemsSummary => items.map((i) => '${i.quantity}× ${i.name}').join(', ');
}
