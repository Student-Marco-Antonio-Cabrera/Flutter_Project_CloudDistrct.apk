import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Result of a social sign-in attempt.
class SocialAuthResult {
  const SocialAuthResult({required this.email, required this.displayName});

  final String email;
  final String displayName;
}

/// Handles Google and Facebook sign-in and returns email + display name.
class SocialAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _googleInitialized = false;

  static Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  /// Sign in with Google. Returns [SocialAuthResult] on success, null if cancelled or error.
  static Future<SocialAuthResult?> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final account = await _googleSignIn.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final email = account.email;
      if (email.isEmpty) return null;

      return SocialAuthResult(
        email: email,
        displayName: account.displayName ?? email.split('@').first,
      );
    } on GoogleSignInException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Sign in with Facebook. Returns [SocialAuthResult] on success, null if cancelled or error.
  static Future<SocialAuthResult?> signInWithFacebook() async {
    try {
      final loginResult = await FacebookAuth.instance.login(
        loginBehavior: LoginBehavior.nativeOnly,
        permissions: ['email', 'public_profile'],
      );
      if (loginResult.status != LoginStatus.success) return null;

      final userData = await FacebookAuth.instance.getUserData();
      final email = (userData['email'] as String?) ?? '';
      final name = (userData['name'] as String?) ?? '';
      if (email.isEmpty) return null;

      return SocialAuthResult(
        email: email,
        displayName: name.isEmpty ? email.split('@').first : name,
      );
    } catch (_) {
      return null;
    }
  }

  /// Sign out from Google (call on app logout if you want to disconnect Google).
  static Future<void> signOutGoogle() async {
    try {
      await _ensureGoogleInitialized();
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  /// Sign out from Facebook.
  static Future<void> signOutFacebook() async {
    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {}
  }
}
