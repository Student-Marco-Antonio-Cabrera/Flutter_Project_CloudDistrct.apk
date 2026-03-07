import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 40});
  final double size;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Icon(Icons.smoking_rooms_rounded, size: size, color: Colors.white),
    );
  }
}
