/// Menu item model for Cafe De Paris
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isSoldOut;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.isSoldOut = false,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      category: json['category'] as String? ?? 'mains',
      isSoldOut: json['soldOut'] as bool? ?? !(json['is_available'] as bool? ?? true),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'quantity': 1,
  };
}
