/*import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../data/products.dart';

class CartTile extends StatelessWidget {
  const CartTile({
    super.key,
    required this.item,
    required this.index,
    required this.onUpdateQuantity,
    required this.onUpdateFlavor,
    required this.onRemove,
  });
  final CartItem item;
  final int index;
  final void Function(int index, int quantity) onUpdateQuantity;
  final void Function(int index, String flavor) onUpdateFlavor;
  final void Function(int index) onRemove;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark
        ? theme.colorScheme.surface.withValues(alpha: 0.94)
        : Colors.white.withValues(alpha: 0.97);
    final inputFillColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.92)
        : Colors.white;
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final product = getProductById(item.productId);
    final flavors = product?.availableFlavors ?? [item.flavor];
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.14),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => onRemove(index),
                  style: IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    backgroundColor: theme.colorScheme.errorContainer
                        .withValues(alpha: 0.30),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Flavor',
              style: theme.textTheme.labelMedium?.copyWith(
                color: onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            if (flavors.length > 1)
              DropdownButtonFormField<String>(
                key: ValueKey('${item.productId}_${item.flavor}'),
                initialValue: item.flavor,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: inputFillColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(color: onSurface, fontWeight: FontWeight.w500),
                items: flavors
                    .map(
                      (f) => DropdownMenuItem(
                        value: f,
                        child: Text(
                          f,
                          style: TextStyle(
                            color: onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onUpdateFlavor(index, v);
                },
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: inputFillColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  item.flavor,
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.remove),
                  onPressed: item.quantity > 1
                      ? () => onUpdateQuantity(index, item.quantity - 1)
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: 22,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.add),
                  onPressed: () => onUpdateQuantity(index, item.quantity + 1),
                ),
                const Spacer(),
                Text(
                  '₱${item.subtotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../data/products.dart';

class CartTile extends StatelessWidget {
  const CartTile({
    super.key,
    required this.item,
    required this.index,
    required this.onUpdateQuantity,
    required this.onUpdateFlavor,
    required this.onRemove,
  });
  final CartItem item;
  final int index;
  final void Function(int index, int quantity) onUpdateQuantity;
  final void Function(int index, String flavor) onUpdateFlavor;
  final void Function(int index) onRemove;

  Future<void> _confirmRemove(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove Item?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Remove "${item.productName}" from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) onRemove(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark
        ? theme.colorScheme.surface.withValues(alpha: 0.94)
        : Colors.white.withValues(alpha: 0.97);
    final inputFillColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.92)
        : Colors.white;
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final product = getProductById(item.productId);
    final flavors = product?.availableFlavors ?? [item.flavor];
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.14),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  // ← Now shows confirmation dialog before removing
                  onPressed: () => _confirmRemove(context),
                  style: IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    backgroundColor: theme.colorScheme.errorContainer
                        .withValues(alpha: 0.30),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Flavor',
              style: theme.textTheme.labelMedium?.copyWith(
                color: onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            if (flavors.length > 1)
              DropdownButtonFormField<String>(
                key: ValueKey('${item.productId}_${item.flavor}'),
                initialValue: item.flavor,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: inputFillColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(color: onSurface, fontWeight: FontWeight.w500),
                items: flavors
                    .map(
                      (f) => DropdownMenuItem(
                        value: f,
                        child: Text(
                          f,
                          style: TextStyle(
                            color: onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onUpdateFlavor(index, v);
                },
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: inputFillColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  item.flavor,
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.remove),
                  onPressed: item.quantity > 1
                      ? () => onUpdateQuantity(index, item.quantity - 1)
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: 22,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.add),
                  onPressed: () => onUpdateQuantity(index, item.quantity + 1),
                ),
                const Spacer(),
                Text(
                  '₱${item.subtotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
