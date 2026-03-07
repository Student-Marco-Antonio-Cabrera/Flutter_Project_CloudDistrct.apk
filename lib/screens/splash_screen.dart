import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/vape_shop_logo_image.dart';
import '../widgets/app_footer.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = '/';
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    Navigator.of(context).pushReplacementNamed(
      auth.isLoggedIn ? HomeScreen.routeName : LoginScreen.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.gradientFor(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VapeShopLogoImage(maxWidth: 280, maxHeight: 140),
                    SizedBox(height: 32),
                    CircularProgressIndicator(color: Colors.white),
                  ],
                ),
              ),
            ),
            AppFooter.pleaseWait(),
          ],
        ),
      ),
    );
  }
}
