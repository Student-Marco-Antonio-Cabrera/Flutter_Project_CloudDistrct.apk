import 'cart_item.dart';

enum OrderStatus { placed, preparing, shipped, outForDelivery, delivered }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }

  String get subtitle {
    switch (this) {
      case OrderStatus.placed:
        return 'We have received your order.';
      case OrderStatus.preparing:
        return 'Your items are being prepared.';
      case OrderStatus.shipped:
        return 'Your package is on the way.';
      case OrderStatus.outForDelivery:
        return 'Rider is heading to your location.';
      case OrderStatus.delivered:
        return 'Order successfully delivered.';
    }
  }

  static OrderStatus fromJsonValue(String? value) {
    if (value == null) return OrderStatus.placed;
    for (final status in OrderStatus.values) {
      if (status.name == value) return status;
    }
    return OrderStatus.placed;
  }
}

class Order {
  const Order({
    required this.id,
    required this.customerEmail,
    required this.createdAt,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.deliveryAddress,
    this.notes,
    this.status = OrderStatus.placed,
  });
  final String id;
  final String customerEmail;
  final DateTime createdAt;
  final List<CartItem> items;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;
  final String paymentMethod;
  final String shippingMethod;
  final String deliveryAddress;
  final String? notes;
  final OrderStatus status;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  Map<String, dynamic> toJson() => {
    'id': id,
    'customerEmail': customerEmail,
    'createdAt': createdAt.toIso8601String(),
    'items': items.map((item) => item.toJson()).toList(),
    'subtotal': subtotal,
    'shippingFee': shippingFee,
    'discount': discount,
    'total': total,
    'paymentMethod': paymentMethod,
    'shippingMethod': shippingMethod,
    'deliveryAddress': deliveryAddress,
    'notes': notes,
    'status': status.name,
  };
  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    customerEmail: json['customerEmail'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    items: (json['items'] as List<dynamic>? ?? [])
        .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
        .toList(),
    subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
    shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0,
    discount: (json['discount'] as num?)?.toDouble() ?? 0,
    total: (json['total'] as num?)?.toDouble() ?? 0,
    paymentMethod: json['paymentMethod'] as String? ?? '',
    shippingMethod: json['shippingMethod'] as String? ?? '',
    deliveryAddress: json['deliveryAddress'] as String? ?? '',
    notes: json['notes'] as String?,
    status: OrderStatusX.fromJsonValue(json['status'] as String?),
  );
  Order copyWith({
    String? id,
    String? customerEmail,
    DateTime? createdAt,
    List<CartItem>? items,
    double? subtotal,
    double? shippingFee,
    double? discount,
    double? total,
    String? paymentMethod,
    String? shippingMethod,
    String? deliveryAddress,
    String? notes,
    OrderStatus? status,
  }) => Order(
    id: id ?? this.id,
    customerEmail: customerEmail ?? this.customerEmail,
    createdAt: createdAt ?? this.createdAt,
    items: items ?? this.items,
    subtotal: subtotal ?? this.subtotal,
    shippingFee: shippingFee ?? this.shippingFee,
    discount: discount ?? this.discount,
    total: total ?? this.total,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    shippingMethod: shippingMethod ?? this.shippingMethod,
    deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    notes: notes ?? this.notes,
    status: status ?? this.status,
  );
}
