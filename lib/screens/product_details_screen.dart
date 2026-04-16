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

    _selectedFlavor ??= product.flavors.isNotEmpty ? product.flavors.first : 'Default';

    final cart = context.watch<CartProvider>();
    final theme = Theme.of(context);

    CartItem buildCartItem() => CartItem(
          productId: product.id,
          productName: product.name,
          unitPrice: product.price,
          quantity: _quantity,
          flavor: _selectedFlavor ?? 'Default',
          imagePath: product.imageUrl,  // Note: CartItem uses imagePath field
        );

    void addToCart() {
      cart.addItem(buildCartItem());
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Added $_quantity × ${product.name} to cart',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
    }

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
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
                        child: product.imageUrl.isNotEmpty
                            ? Image.asset(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) =>
                                    const Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        color: Colors.white54,
                                        size: 56,
                                      ),
                                    ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.smoking_rooms_rounded,
                                  color: Colors.white70,
                                  size: 56,
                                ),
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
                    product.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (product.flavors.isNotEmpty) ...[
                    const Text(
                      'Flavors',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.flavors.map((flavor) => ChoiceChip(
                            label: Text(flavor),
                            selected: _selectedFlavor == flavor,
                            onSelected: (_) => setState(() => _selectedFlavor = flavor),
                          )).toList(),
                    ),
                    const SizedBox(height: 18),
                  ],
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      const Spacer(),
                      Text(
                        '₱${(product.price * _quantity).toStringAsFixed(0)}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Reviews',
                    style: TextStyle(
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
              child: SafeArea(
                top: false,
                child: FilledButton.icon(
                  onPressed: addToCart,
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
            ),
          ],
        ),
      ),
    );
  }
}
