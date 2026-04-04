import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// Handles Google and Facebook OAuth flows.
/// Returns a [SocialAuthResult] on success, null if the user cancelled.
/// Throws a [SocialAuthException] on failure.
class SocialAuthService {
  SocialAuthService._();

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // ── Google ───────────────────────────────────────────────────────────────

  static Future<SocialAuthResult?> signInWithGoogle() async {
    try {
      // Force account picker every time so the user can switch accounts
      await _googleSignIn.signOut();

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return null; // user cancelled

      return SocialAuthResult(
        email: account.email,
        displayName: account.displayName ?? account.email.split('@').first,
        photoUrl: account.photoUrl,
        provider: SocialProvider.google,
      );
    } catch (e) {
      throw SocialAuthException('Google sign-in failed: $e');
    }
  }

  static Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  // ── Facebook ─────────────────────────────────────────────────────────────

  static Future<SocialAuthResult?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      switch (result.status) {
        case LoginStatus.cancelled:
          return null;
        case LoginStatus.failed:
          throw SocialAuthException(
              result.message ?? 'Facebook sign-in failed');
        case LoginStatus.operationInProgress:
          throw SocialAuthException('A Facebook login is already in progress');
        case LoginStatus.success:
          break;
      }

      // Fetch profile data
      final userData = await FacebookAuth.instance.getUserData(
        fields: 'name,email,picture.width(200)',
      );

      final email = userData['email'] as String? ?? '';
      final name = userData['name'] as String? ?? email.split('@').first;
      final photoUrl =
          (userData['picture']?['data']?['url']) as String?;

      if (email.isEmpty) {
        throw SocialAuthException(
            'Could not retrieve email from Facebook. '
            'Please ensure your Facebook account has a verified email.');
      }

      return SocialAuthResult(
        email: email,
        displayName: name,
        photoUrl: photoUrl,
        provider: SocialProvider.facebook,
      );
    } on SocialAuthException {
      rethrow;
    } catch (e) {
      throw SocialAuthException('Facebook sign-in failed: $e');
    }
  }

  static Future<void> signOutFacebook() async {
    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {}
  }
}

// ── Supporting types ─────────────────────────────────────────────────────────

enum SocialProvider { google, facebook }

class SocialAuthResult {
  const SocialAuthResult({
    required this.email,
    required this.displayName,
    required this.provider,
    this.photoUrl,
  });
  final String email;
  final String displayName;
  final String? photoUrl;
  final SocialProvider provider;
}

class SocialAuthException implements Exception {
  const SocialAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}