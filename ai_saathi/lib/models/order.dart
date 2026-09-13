class Order {
  final String id;
  final String userId;
  final String buyerName;
  final String? buyerPhone;
  final String? buyerEmail;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String? shippingAddress;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.buyerName,
    this.buyerPhone,
    this.buyerEmail,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.shippingAddress,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      buyerName: json['buyer_name'],
      buyerPhone: json['buyer_phone'],
      buyerEmail: json['buyer_email'],
      items: (json['items'] as List?)
          ?.map((e) => OrderItem.fromJson(e))
          .toList() ?? [],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      shippingAddress: json['shipping_address'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'buyer_name': buyerName,
      'buyer_phone': buyerPhone,
      'buyer_email': buyerEmail,
      'items': items.map((e) => e.toJson()).toList(),
      'total_amount': totalAmount,
      'status': status,
      'shipping_address': shippingAddress,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Order copyWith({
    String? status,
    String? notes,
  }) {
    return Order(
      id: id,
      userId: userId,
      buyerName: buyerName,
      buyerPhone: buyerPhone,
      buyerEmail: buyerEmail,
      items: items,
      totalAmount: totalAmount,
      status: status ?? this.status,
      shippingAddress: shippingAddress,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'],
      productName: json['product_name'],
      productImage: json['product_image'],
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }
}
