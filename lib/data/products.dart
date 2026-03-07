import '../models/product.dart';

final List<Product> mockProducts = [
  const Product(
    id: '1',
    name: 'Classic Vape Pen',
    price: 349,
    imagePath: 'assets/images/products/classic_vape_pen.png',
    availableFlavors: ['Mint', 'Berry', 'Tobacco', 'Mango', 'Vanilla'],
    description:
        'A reliable everyday vape pen with smooth airflow and long-lasting battery life.',
    stock: 24,
    variants: ['Standard Kit', 'Starter Bundle'],
  ),
  const Product(
    id: '2',
    name: 'Premium Pod Kit',
    price: 499,
    imagePath: 'assets/images/products/premium_pod_kit.png',
    availableFlavors: [
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
  const Product(
    id: '3',
    name: 'Disposable Vape',
    price: 329,
    imagePath: 'assets/images/products/disposable_vape_peach.png',
    availableFlavors: ['Peach', 'Grape', 'Pineapple', 'Watermelon', 'Cherry'],
    description:
        'Convenient disposable device pre-filled with rich flavors, perfect for on-the-go.',
    stock: 60,
    variants: ['1500 Puffs', '2500 Puffs'],
  ),
  const Product(
    id: '4',
    name: 'Starter Kit Pro',
    price: 479,
    imagePath: 'assets/images/products/starter_kit_pro.png',
    availableFlavors: ['Menthol', 'Apple', 'Banana', 'Citrus', 'Caramel'],
    description:
        'An all-in-one starter kit with adjustable wattage and easy refill tank.',
    stock: 12,
    variants: ['Black', 'Silver'],
  ),
  const Product(
    id: '5',
    name: 'Cloud Chaser Mod',
    price: 499,
    imagePath: 'assets/images/products/cloud_chaser_mod_tobacco.png',
    availableFlavors: [
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
  const Product(
    id: '6',
    name: 'Slim Pod Device',
    price: 399,
    imagePath: 'assets/images/products/slim_pod_device_lemon.png',
    availableFlavors: ['Lemon', 'Orange', 'Pomegranate', 'Lychee', 'Honey'],
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
