import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../providers/auth_provider.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/toc_checkbox.dart';
import '../widgets/vape_shop_logo_image.dart';
import '../widgets/social_sign_in_buttons.dart';
import 'home_screen.dart';
import 'toc_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const String routeName = '/register';
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _tocAccepted = false;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<String?> _promptTwoFactorCode(String? demoCode) async {
    final codeController = TextEditingController();
    try {
      return showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Two-Factor Verification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (demoCode != null) ...[
                Text(
                  'Demo code: $demoCode',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
              ],
              const Text('Enter your 6-digit verification code.'),
              const SizedBox(height: 10),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Verification code',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, codeController.text),
              child: const Text('Verify'),
            ),
          ],
        ),
      );
    } finally {
      codeController.dispose();
    }
  }

  Future<bool> _handleTwoFactorIfNeeded(AuthProvider auth) async {
    if (!auth.isTwoFactorVerificationRequired) return true;
    final enteredCode = await _promptTwoFactorCode(
      auth.pendingTwoFactorCodeForDemo,
    );
    if (enteredCode == null) {
      auth.cancelPendingTwoFactorLogin();
      return false;
    }
    final verified = await auth.verifyPendingTwoFactorCode(enteredCode);
    if (!verified) {
      auth.cancelPendingTwoFactorLogin();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Invalid verification code.'),
          ),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> _register() async {
    if (!_tocAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms and Conditions')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _displayNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.errorMessage ??
                'Registration failed. Check your details and try again.',
          ),
        ),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!_tocAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms and Conditions')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithGoogle();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Google sign-in was cancelled.'),
        ),
      );
      return;
    }
    final verified = await _handleTwoFactorIfNeeded(auth);
    if (!mounted || !verified) return;
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }

  Future<void> _signInWithFacebook() async {
    if (!_tocAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms and Conditions')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithFacebook();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Facebook sign-in was cancelled.'),
        ),
      );
      return;
    }
    final verified = await _handleTwoFactorIfNeeded(auth);
    if (!mounted || !verified) return;
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      const Center(
                        child: VapeShopLogoImage(maxWidth: 220, maxHeight: 110),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Display Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Enter email'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirm password';
                          if (v != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone (optional)',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _register,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Register'),
                        ),
                      ),
                      SocialSignInButtons(
                        onGooglePressed: _signInWithGoogle,
                        onFacebookPressed: _signInWithFacebook,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Already have an account? Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: TocCheckbox(
                  value: _tocAccepted,
                  onChanged: (v) => setState(() => _tocAccepted = v ?? false),
                  message: 'By registering you agree to our',
                  onTocTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TocScreen()),
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
