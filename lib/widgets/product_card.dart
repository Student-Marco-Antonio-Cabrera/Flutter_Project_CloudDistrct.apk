import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

final Uint8List _transparentPng = Uint8List.fromList(const <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
]);

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });
  final Product product;
  final void Function(CartItem item) onAddToCart;
  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _quantity = 1;
  late String _selectedFlavor;

  @override
  void initState() {
    super.initState();
    _selectedFlavor = widget.product.flavors.isNotEmpty
        ? widget.product.flavors.first
        : 'Default';
  }

  CartItem get _cartItem => CartItem(
        productId: widget.product.id,
        productName: widget.product.name,
        unitPrice: widget.product.price,
        quantity: _quantity,
        flavor: _selectedFlavor,
        imagePath: widget.product.imageUrl,
      );

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final theme = Theme.of(context);
    final inputFillColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.92)
        : Colors.white;
    final inputTextColor = theme.colorScheme.onSurface;
    final imageBgColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.58)
        : const Color(0xFFF2F3F5);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 320;
        final gap = isCompact ? 6.0 : 8.0;
        final buttonHeight = isCompact ? 40.0 : 44.0;
        final iconSize = isCompact ? 18.0 : 20.0;
        return Card(
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.pushNamed(context, '/product-details', arguments: p.id),
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 10 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: imageBgColor,
                        child: p.imageUrl.isNotEmpty
                            ? FadeInImage(
                                placeholder: MemoryImage(_transparentPng),
                                image: ResizeImage(
                                  AssetImage(p.imageUrl),
                                  width: 900,
                                ),
                                fit: BoxFit.cover,
                                placeholderFit: BoxFit.cover,
                                fadeInDuration: const Duration(milliseconds: 180),
                                imageErrorBuilder: (context, error, stackTrace) => Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: isCompact ? 32 : 40,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.smoking_rooms_rounded,
                                  size: isCompact ? 38 : 46,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: gap),
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: isCompact ? 14 : 16,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱${p.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: isCompact ? 14 : 15,
                    ),
                  ),
                  SizedBox(height: gap),
                  if (p.flavors.isNotEmpty)
                    DropdownButtonFormField<String>(
                      isDense: true,
                      initialValue: _selectedFlavor,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputFillColor,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 10 : 12,
                          vertical: isCompact ? 8 : 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: TextStyle(
                        color: inputTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                      items: p.flavors.map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(
                              f,
                              maxLines: 1,
                              style: TextStyle(
                                color: inputTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )).toList(),
                      onChanged: (v) => v != null ? setState(() => _selectedFlavor = v) : null,
                    )
                  else
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 10 : 12,
                        vertical: isCompact ? 8 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: inputFillColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        'Default',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: inputTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  SizedBox(height: gap),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        icon: Icon(Icons.remove, size: iconSize),
                        visualDensity: VisualDensity.compact,
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14),
                        child: Text(
                          '$_quantity',
                          style: TextStyle(
                            fontSize: isCompact ? 15 : 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton.filledTonal(
                        icon: Icon(Icons.add, size: iconSize),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                  SizedBox(height: gap),
                  SizedBox(
                    height: buttonHeight,
                    child: FilledButton.icon(
                      onPressed: () => widget.onAddToCart(_cartItem),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add to Cart', maxLines: 1),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
