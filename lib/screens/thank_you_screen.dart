import 'package:flutter/material.dart';
import '../widgets/gradient_scaffold.dart';
import 'home_screen.dart';
import 'my_orders_screen.dart';

class ThankYouScreen extends StatelessWidget {
  const ThankYouScreen({super.key});
  static const String routeName = '/thank-you';
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final orderId = args is String ? args : null;
    return GradientScaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Thank you for your order!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your order will be processed as fast as possible.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 16,
                  ),
                ),
                if (orderId != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Order ID: $orderId',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (orderId != null)
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacementNamed(
                      MyOrdersScreen.routeName,
                      arguments: MyOrdersInitialTab.tracking,
                    ),
                    icon: const Icon(Icons.local_shipping_outlined),
                    label: const Text('Track Order'),
                  ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        HomeScreen.routeName,
                        (route) => false,
                      ),
                  icon: const Icon(Icons.home),
                  label: const Text('Return to Home'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
