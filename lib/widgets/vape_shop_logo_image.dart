import 'package:flutter/material.dart';

/// Reusable Cloud District logo wordmark for splash, login, and app bars.
class VapeShopLogoImage extends StatelessWidget {
  const VapeShopLogoImage({
    super.key,
    this.maxWidth = 280,
    this.maxHeight = 140,
    this.fit = BoxFit.contain,
  });

  final double maxWidth;
  final double maxHeight;
  final BoxFit fit;

  static const String brandName = 'Cloud District';

  @override
  Widget build(BuildContext context) {
    final iconSize = (maxHeight * 0.55).clamp(14.0, 56.0);
    final fontSize = (maxHeight * 0.44).clamp(11.0, 42.0);

    return SizedBox(
      width: maxWidth,
      height: maxHeight,
      child: FittedBox(
        fit: fit,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_queue_rounded,
              size: iconSize,
              color: Colors.white,
            ),
            SizedBox(width: (maxHeight * 0.18).clamp(3.0, 12.0)),
            Text(
              brandName,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
