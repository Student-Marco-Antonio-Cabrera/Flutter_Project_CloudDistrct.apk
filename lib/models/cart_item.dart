class CartItem {
  CartItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.flavor,
    this.imagePath,
  });
  final String productId;
  final String productName;
  final double unitPrice;
  int quantity;
  String flavor;
  final String? imagePath;
  double get subtotal => unitPrice * quantity;
  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'unitPrice': unitPrice,
    'quantity': quantity,
    'flavor': flavor,
    'imagePath': imagePath,
  };
  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    productId: json['productId'] as String,
    productName: json['productName'] as String,
    unitPrice: (json['unitPrice'] as num).toDouble(),
    quantity: json['quantity'] as int,
    flavor: json['flavor'] as String,
    imagePath: json['imagePath'] as String?,
  );
  CartItem copyWith({
    String? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
    String? flavor,
    String? imagePath,
  }) => CartItem(
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    unitPrice: unitPrice ?? this.unitPrice,
    quantity: quantity ?? this.quantity,
    flavor: flavor ?? this.flavor,
    imagePath: imagePath ?? this.imagePath,
  );
}
