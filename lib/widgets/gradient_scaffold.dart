import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.extendBodyBehindAppBar = true,
  });
  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool extendBodyBehindAppBar;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.gradientFor(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        appBar: appBar,
        body: body,
      ),
    );
  }
}
