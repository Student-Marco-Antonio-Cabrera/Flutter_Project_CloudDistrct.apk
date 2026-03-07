class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.imagePath,
    this.availableFlavors = const [],
    this.description,
    this.stock,
    this.variants,
  });

  final String id;
  final String name;
  final double price;
  final String? imagePath;
  final List<String> availableFlavors;

  // Optional extended fields for product details.
  final String? description;
  final int? stock;
  final List<String>? variants;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'imagePath': imagePath,
    'availableFlavors': availableFlavors,
    'description': description,
    'stock': stock,
    'variants': variants,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    imagePath: json['imagePath'] as String?,
    availableFlavors: List<String>.from(
      json['availableFlavors'] as List? ?? [],
    ),
    description: json['description'] as String?,
    stock: json['stock'] as int?,
    variants: (json['variants'] as List?)?.map((e) => e.toString()).toList(),
  );
}
