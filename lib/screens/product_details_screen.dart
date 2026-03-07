import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/products.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../widgets/gradient_scaffold.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});
  static const String routeName = '/product-details';
  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  String? _selectedFlavor;
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final productId = args is String ? args : null;
    final product = productId != null ? getProductById(productId) : null;
    if (product == null) {
      return GradientScaffold(
        appBar: AppBar(
          title: const Text('Product Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const SafeArea(
          child: Center(
            child: Text(
              'Product not found',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }
    _selectedFlavor ??= product.availableFlavors.isNotEmpty
        ? product.availableFlavors.first
        : null;
    final cart = context.watch<CartProvider>();
    final theme = Theme.of(context);
    CartItem buildCartItem() => CartItem(
      productId: product.id,
      productName: product.name,
      unitPrice: product.price,
      quantity: _quantity,
      flavor: _selectedFlavor ?? 'Default',
      imagePath: product.imagePath,
    );
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.1),
                        child:
                            product.imagePath != null &&
                                product.imagePath!.isNotEmpty
                            ? Image.asset(product.imagePath!, fit: BoxFit.cover)
                            : const Icon(
                                Icons.smoking_rooms_rounded,
                                color: Colors.white70,
                                size: 56,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₱${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (product.stock != null)
                    Text(
                      product.stock! > 0
                          ? 'In stock: ${product.stock} pcs'
                          : 'Out of stock',
                      style: TextStyle(
                        color: product.stock! > 0
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    product.description ??
                        'Detailed description will appear here once configured.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (product.availableFlavors.isNotEmpty ||
                      (product.variants?.isNotEmpty ?? false)) ...[
                    Text(
                      'Variants',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...product.availableFlavors.map(
                          (flavor) => ChoiceChip(
                            label: Text(flavor),
                            selected: _selectedFlavor == flavor,
                            onSelected: (_) {
                              setState(() {
                                _selectedFlavor = flavor;
                              });
                            },
                          ),
                        ),
                        if (product.availableFlavors.isEmpty)
                          ...?product.variants?.map(
                            (variant) => ChoiceChip(
                              label: Text(variant),
                              selected: _selectedFlavor == variant,
                              onSelected: (_) {
                                setState(() {
                                  _selectedFlavor = variant;
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                  Text(
                    'Quantity',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton.filledTonal(
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () => setState(() => _quantity++),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Reviews',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reviews and ratings will appear here once connected to your backend.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          cart.addItem(buildCartItem());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added $_quantity x ${product.name} to cart',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
