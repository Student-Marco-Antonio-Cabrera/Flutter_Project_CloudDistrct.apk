import '../models/product.dart';

final List<Product> mockProducts = [
  Product(
    id: '1',
    name: 'Classic Vape Pen',
    price: 349,
    imageUrl: 'assets/images/products/classic_vape_pen.png',
    flavors: ['Mint', 'Berry', 'Tobacco', 'Mango', 'Vanilla'],
    description:
        'A reliable everyday vape pen with smooth airflow and long-lasting battery life.',
    stock: 24,
    variants: ['Standard Kit', 'Starter Bundle'],
  ),
  Product(
    id: '2',
    name: 'Premium Pod Kit',
    price: 499,
    imageUrl: 'assets/images/products/premium_pod_kit.png',
    flavors: [
      'Ice Mint',
      'Strawberry',
      'Blueberry',
      'Coffee',
      'Melon',
    ],
    description:
        'A compact pod system with fast charging and leak-resistant pods for daily use.',
    stock: 18,
    variants: ['Device Only', 'With 3 Pods'],
  ),
  Product(
    id: '3',
    name: 'Disposable Vape',
    price: 329,
    imageUrl: 'assets/images/products/disposable_vape_peach.png',
    flavors: ['Peach', 'Grape', 'Pineapple', 'Watermelon', 'Cherry'],
    description:
        'Convenient disposable device pre-filled with rich flavors, perfect for on-the-go.',
    stock: 60,
    variants: ['1500 Puffs', '2500 Puffs'],
  ),
  Product(
    id: '4',
    name: 'Starter Kit Pro',
    price: 479,
    imageUrl: 'assets/images/products/starter_kit_pro.png',
    flavors: ['Menthol', 'Apple', 'Banana', 'Citrus', 'Caramel'],
    description:
        'An all-in-one starter kit with adjustable wattage and easy refill tank.',
    stock: 12,
    variants: ['Black', 'Silver'],
  ),
  Product(
    id: '5',
    name: 'Cloud Chaser Mod',
    price: 499,
    imageUrl: 'assets/images/products/cloud_chaser_mod_tobacco.png',
    flavors: [
      'Tobacco',
      'Mint',
      'Mixed Berry',
      'Cola',
      'Cotton Candy',
    ],
    description:
        'High-performance mod engineered for dense clouds and advanced customisation.',
    stock: 8,
    variants: ['Single Battery', 'Dual Battery'],
  ),
  Product(
    id: '6',
    name: 'Slim Pod Device',
    price: 399,
    imageUrl: 'assets/images/products/slim_pod_device_lemon.png',
    flavors: ['Lemon', 'Orange', 'Pomegranate', 'Lychee', 'Honey'],
    description:
        'Ultra-slim pod device that fits easily in your pocket with quick magnetic pods.',
    stock: 30,
    variants: ['Matte Black', 'Ocean Blue'],
  ),
];
Product? getProductById(String id) {
  try {
    return mockProducts.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}
