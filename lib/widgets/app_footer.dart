import 'package:flutter/material.dart';

import '../screens/toc_screen.dart';

/// App-wide footer. Use [AppFooter.pleaseWait] on loading screen or
/// [AppFooter.toc] for Terms and Conditions link.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key, required this.child});

  final Widget child;

  /// Footer with "Please wait" for loading/splash screen.
  factory AppFooter.pleaseWait() {
    return AppFooter(
      child: Text(
        'Please wait',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 14,
        ),
      ),
    );
  }

  /// Footer with tappable Terms and Conditions link.
  factory AppFooter.toc(BuildContext context) {
    return AppFooter(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TocScreen()),
        ),
        child: Text(
          'Terms and Conditions',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontSize: 13,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(child: child),
      ),
    );
  }
}
