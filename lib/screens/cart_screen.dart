import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_tile.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/vape_shop_logo_image.dart';
import 'buy_screen.dart';
import 'home_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  static const String routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return GradientScaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        leadingWidth: 130,
        title: const Text('Cart'),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(
              width: 72,
              height: 28,
              child: VapeShopLogoImage(maxWidth: 72, maxHeight: 28),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: cart.items.isEmpty
            ? const _EmptyCartContent()
            : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 2),
                      itemBuilder: (context, index) {
                        return CartTile(
                          item: cart.items[index],
                          index: index,
                          onUpdateQuantity: (i, q) => cart.updateQuantity(i, q),
                          onUpdateFlavor: (i, f) => cart.updateFlavor(i, f),
                          onRemove: (i) => cart.removeItem(i),
                        );
                      },
                    ),
                  ),
                  _CartSummaryPanel(
                    total: cart.total,
                    onAddMoreProducts: () =>
                        Navigator.pushNamed(context, HomeScreen.routeName),
                    onBuyNow: () =>
                        Navigator.pushNamed(context, BuyScreen.routeName),
                  ),
                ],
              ),
      ),
    );
  }
}

class _EmptyCartContent extends StatelessWidget {
  const _EmptyCartContent();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        HomeScreen.routeName,
                      ),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add products'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CartSummaryPanel extends StatelessWidget {
  const _CartSummaryPanel({
    required this.total,
    required this.onAddMoreProducts,
    required this.onBuyNow,
  });
  final double total;
  final VoidCallback onAddMoreProducts;
  final VoidCallback onBuyNow;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '₱${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onAddMoreProducts,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Add More Products',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: onBuyNow,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Buy Now'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
