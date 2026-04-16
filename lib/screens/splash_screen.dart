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
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), _navigate);
  }

  void _navigate() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    final auth = context.read<AuthProvider>();
    Navigator.of(context).pushReplacementNamed(
      auth.isLoggedIn ? HomeScreen.routeName : LoginScreen.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.gradientFor(context),
        child: BlocConsumer<AuthProvider, int>(
          listener: (context, state) {
            final auth = context.read<AuthProvider>();
            if (!_hasNavigated && !auth.isLoading && auth.errorMessage == null) {
              Future.delayed(const Duration(milliseconds: 500), _navigate);
            }
          },
          builder: (context, state) {
            final auth = context.watch<AuthProvider>();
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  Column(
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
                  if (auth.errorMessage != null)
                    Positioned(
                      bottom: 200,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          auth.errorMessage!,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
    );
  }
}
