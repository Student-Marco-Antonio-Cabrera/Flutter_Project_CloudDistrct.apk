class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> flavors;
  final int? stock;
  final List<String>? variants;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.flavors,
    this.stock,
    this.variants,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'flavors': flavors,
        'description': description,
        'stock': stock,
        'variants': variants,
      };

  // Convert Firestore DocumentSnapshot to Product
  factory Product.fromFirestore(Map<String, dynamic> json, String documentId) {
    return Product(
      id: documentId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      flavors: List<String>.from(json['flavors'] ?? []),
      stock: json['stock'] as int?,
      variants: (json['variants'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'flavors': flavors,
      'stock': stock,
      'variants': variants,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String? ?? '',
        flavors: List<String>.from(json['flavors'] as List? ?? []),
        stock: json['stock'] as int?,
        variants: (json['variants'] as List?)?.map((e) => e.toString()).toList(),
      );
}
