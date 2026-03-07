import 'package:flutter/material.dart';

/// Google and Facebook sign-in buttons for login/register screens.
class SocialSignInButtons extends StatelessWidget {
  const SocialSignInButtons({
    super.key,
    required this.onGooglePressed,
    required this.onFacebookPressed,
  });

  final VoidCallback onGooglePressed;
  final VoidCallback onFacebookPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Divider(color: Colors.white.withValues(alpha: 0.6)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or continue with',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onGooglePressed,
          icon: const Icon(
            Icons.g_mobiledata_rounded,
            size: 24,
            color: Colors.white,
          ),
          label: const Text('Continue with Google'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white70),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onFacebookPressed,
          icon: const Icon(Icons.facebook, size: 24, color: Colors.white),
          label: const Text('Continue with Facebook'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white70),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}
