import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/products.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/product_card.dart';
import '../widgets/vape_shop_logo_image.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const String routeName = '/home';
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return GradientScaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        leadingWidth: 110,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: VapeShopLogoImage(maxWidth: 100, maxHeight: 40),
        ),
        title: const Text(
          'Cloud District',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () =>
                    Navigator.pushNamed(context, CartScreen.routeName),
                color: Colors.white,
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () =>
                Navigator.pushNamed(context, ProfileScreen.routeName),
            color: Colors.white,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Products',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const crossAxisCount = 2;
                    const spacing = 12.0;
                    final itemWidth =
                        (constraints.maxWidth -
                            ((crossAxisCount - 1) * spacing)) /
                        crossAxisCount;
                    final childAspectRatio = _cardAspectRatio(itemWidth);
                    return GridView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: mockProducts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final product = mockProducts[index];
                        return ProductCard(
                          product: product,
                          onAddToCart: (CartItem item) => cart.addItem(item),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static double _cardAspectRatio(double itemWidth) {
    if (itemWidth < 140) return 0.42;
    if (itemWidth < 155) return 0.46;
    if (itemWidth < 175) return 0.50;
    if (itemWidth < 195) return 0.54;
    return 0.58;
  }
}
