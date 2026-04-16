import 'dart:convert';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/user.dart';

const _keyUser = 'vapeshop_user';
const _keyLoggedIn = 'vapeshop_logged_in';
const _keyAccounts = 'vapeshop_accounts';

enum PasswordChangeResult {
  success,
  notLoggedIn,
  unsupportedAccount,
  wrongCurrentPassword,
  weakPassword,
}

class AuthProvider extends Cubit<int> {
  AuthProvider(this._prefs) : super(0) {
    _loadAccounts();
    _loadStoredUser();
    _listenToFirebaseAuth();
  }

  final SharedPreferences _prefs;
  final Map<String, _StoredAccount> _accounts = {};
  final Random _random = Random();

  User? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  final firebase.FirebaseAuth _firebaseAuth = firebase.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  // Two-factor state (used)
  User? _pendingTwoFactorUser;
  String? _pendingTwoFactorCode;
  DateTime? _pendingTwoFactorExpiry;
  String? _setupTwoFactorCode;
  DateTime? _setupTwoFactorExpiry;

  // ── Public getters ────────────────────────────────────────────────
  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isTwoFactorVerificationRequired => _pendingTwoFactorUser != null;
  String? get pendingTwoFactorCodeForDemo => _pendingTwoFactorCode;

  bool get canChangePassword {
    final account = _accountForCurrentUser;
    return account != null && account.hasPassword;
  }

  bool get isTwoFactorEnabled {
    final account = _accountForCurrentUser;
    return account?.twoFactorEnabled ?? false;
  }

  _StoredAccount? get _accountForCurrentUser {
    final current = _user;
    if (current == null) return null;
    return _accounts[_normalizeEmail(current.email)];
  }

  // ── Firebase Auth listener ───────────────────────────────────────
  void _listenToFirebaseAuth() {
    _firebaseAuth.authStateChanges().listen((firebase.User? fbUser) async {
      if (fbUser == null) {
        if (_isLoggedIn) await _localLogout();
      } else {
        final email = fbUser.email;
        if (email != null) {
          await _syncFirebaseUserToLocal(fbUser);
        }
      }
      _notify();
    });
  }

  Future<void> _syncFirebaseUserToLocal(firebase.User fbUser) async {
    final email = fbUser.email;
    if (email == null) return;

    final normalizedEmail = _normalizeEmail(email);
    final displayName = fbUser.displayName ?? normalizedEmail.split('@').first;
    final photoUrl = fbUser.photoURL;

    var account = _accounts[normalizedEmail];
    if (account == null) {
      account = _StoredAccount(
        id: fbUser.uid,
        email: normalizedEmail,
        displayName: displayName,
        phone: fbUser.phoneNumber,
        password: null,
        twoFactorEnabled: false,
      );
      _accounts[normalizedEmail] = account;
      await _saveAccounts();
    } else if (account.id != fbUser.uid) {
      account = account.copyWith(id: fbUser.uid);
      _accounts[normalizedEmail] = account;
      await _saveAccounts();
    }

    final localUser = User(
      id: fbUser.uid,
      email: email,
      displayName: displayName,
      phone: fbUser.phoneNumber,
      profileImagePath: photoUrl,
      addresses: const [],
    );

    _user = localUser;
    _isLoggedIn = true;
    await _prefs.setBool(_keyLoggedIn, true);
    await _prefs.setString(_keyUser, jsonEncode(localUser.toJson()));
  }

  // ── Helpers ─────────────────────────────────────────────────────
  String _normalizeEmail(String email) => email.trim().toLowerCase();

  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null;
    _notify();
  }

  void _setError(String message) {
    _isLoading = false;
    _errorMessage = message;
    _notify();
  }

  void clearError() {
    _errorMessage = null;
    _notify();
  }

  // ── Persistence ─────────────────────────────────────────────────
  void _loadAccounts() {
    final json = _prefs.getString(_keyAccounts);
    if (json == null) return;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      _accounts
        ..clear()
        ..addEntries(
          map.entries.map(
            (entry) => MapEntry(
              entry.key,
              _StoredAccount.fromJson(entry.value as Map<String, dynamic>),
            ),
          ),
        );
    } catch (_) {
      _accounts.clear();
    }
  }

  Future<void> _saveAccounts() async {
    final map = <String, dynamic>{};
    for (final entry in _accounts.entries) {
      map[entry.key] = entry.value.toJson();
    }
    await _prefs.setString(_keyAccounts, jsonEncode(map));
  }

  Future<void> _loadStoredUser() async {
    final json = _prefs.getString(_keyUser);
    final loggedIn = _prefs.getBool(_keyLoggedIn) ?? false;
    if (json != null && loggedIn) {
      try {
        _user = User.fromJson(jsonDecode(json) as Map<String, dynamic>);
        _isLoggedIn = true;
        await _ensureAccountExistsForUser(_user!);
      } catch (_) {
        _user = null;
        _isLoggedIn = false;
      }
    }
    _notify();
  }

  Future<void> _ensureAccountExistsForUser(User user) async {
    final key = _normalizeEmail(user.email);
    if (_accounts.containsKey(key)) return;
    _accounts[key] = _StoredAccount(
      id: user.id,
      email: key,
      displayName: user.displayName,
      phone: user.phone,
      password: null,
      twoFactorEnabled: false,
    );
    await _saveAccounts();
  }

  // ── Two-factor helpers ──────────────────────────────────────────
  String _generateSixDigitCode() => (_random.nextInt(900000) + 100000).toString();

  bool _isExpired(DateTime? expiry) {
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  Future<void> _completeLogin(User user) async {
    _user = user;
    _isLoggedIn = true;
    _isLoading = false;
    _errorMessage = null;
    _clearPendingTwoFactor(notify: false);
    await _prefs.setBool(_keyLoggedIn, true);
    await _prefs.setString(_keyUser, jsonEncode(user.toJson()));
    _notify();
  }

  void _startTwoFactorChallenge(User user) {
    _pendingTwoFactorUser = user;
    _pendingTwoFactorCode = _generateSixDigitCode();
    _pendingTwoFactorExpiry = DateTime.now().add(const Duration(minutes: 5));
  }

  void _clearPendingTwoFactor({bool notify = true}) {
    _pendingTwoFactorUser = null;
    _pendingTwoFactorCode = null;
    _pendingTwoFactorExpiry = null;
    if (notify) _notify();
  }

  // ── Email / password login (Firebase) ───────────────────────────
  Future<bool> login(String email, String password) async {
    final normalizedEmail = _normalizeEmail(email);
    if (normalizedEmail.isEmpty || password.isEmpty) {
      _setError('Email and password are required.');
      return false;
    }

    _setLoading(true);

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = userCredential.user;
      if (fbUser == null) {
        _setError('Login failed. Please try again.');
        return false;
      }

      await _syncFirebaseUserToLocal(fbUser);

      final account = _accounts[normalizedEmail];
      if (account != null && account.twoFactorEnabled) {
        _startTwoFactorChallenge(_user!);
        _isLoading = false;
        _notify();
        return true;
      }

      await _completeLogin(_user!);
      return true;
    } on firebase.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        default:
          message = 'Login failed: ${e.message}';
      }
      _setError(message);
      return false;
    } catch (e) {
      _setError('An error occurred. Please try again.');
      return false;
    }
  }

  // ── Register (Firebase) ─────────────────────────────────────────
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    String? phone,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final cleanDisplayName = displayName.trim();
    final cleanPhone = (phone == null || phone.trim().isEmpty)
        ? null
        : phone.trim();

    if (normalizedEmail.isEmpty || password.isEmpty || cleanDisplayName.isEmpty) {
      _setError('All fields are required.');
      return false;
    }

    _setLoading(true);

    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = userCredential.user;
      if (fbUser == null) {
        _setError('Registration failed. Please try again.');
        return false;
      }

      await fbUser.updateDisplayName(cleanDisplayName);
      await _syncFirebaseUserToLocal(fbUser);

      final account = _accounts[normalizedEmail];
      if (account != null &&
          (account.displayName != cleanDisplayName ||
              account.phone != cleanPhone)) {
        _accounts[normalizedEmail] = account.copyWith(
          displayName: cleanDisplayName,
          phone: cleanPhone,
        );
        await _saveAccounts();
        _user = _user?.copyWith(
          displayName: cleanDisplayName,
          phone: cleanPhone,
        );
      }

      await _completeLogin(_user!);
      return true;
    } on firebase.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'weak-password':
          message = 'Password is too weak. Use at least 6 characters.';
          break;
        default:
          message = 'Registration failed: ${e.message}';
      }
      _setError(message);
      return false;
    } catch (e) {
      _setError('An error occurred. Please try again.');
      return false;
    }
  }

  // ── Google Sign-In (Firebase) ───────────────────────────────────
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      final googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = firebase.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      await _syncFirebaseUserToLocal(userCredential.user!);
      await _completeLogin(_user!);
      return true;
    } catch (e) {
      _setError('Google sign-in failed. Please try again.');
      return false;
    }
  }

  // ── Facebook Sign-In (Firebase) ─────────────────────────────────
  Future<bool> signInWithFacebook() async {
    _setLoading(true);
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) {
        _isLoading = false;
        _notify();
        return false;
      }
      final AccessToken accessToken = result.accessToken!;
      final credential = firebase.FacebookAuthProvider.credential(accessToken.tokenString);
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      await _syncFirebaseUserToLocal(userCredential.user!);
      await _completeLogin(_user!);
      return true;
    } catch (e) {
      _setError('Facebook sign-in failed. Please try again.');
      return false;
    }
  }

  // ── Generic social provider sign-in (used by screens) ───────────
  Future<bool> signInWithProvider({
    required String email,
    required String displayName,
  }) async {
    // This method is called from login_screen.dart for social sign-in.
    // However, with Firebase, we already have dedicated Google/Facebook methods.
    // To support the old flow, we can create a Firebase user with email/password? Not recommended.
    // Better to redirect to the specific social methods.
    // Since login_screen calls this with email/displayName from social auth,
    // we'll assume the user is already signed in via the specific method.
    // For now, we'll check if a Firebase user exists with that email.
    _setLoading(true);
    try {
      // Check if already signed in
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null && currentUser.email == email) {
        await _syncFirebaseUserToLocal(currentUser);
        await _completeLogin(_user!);
        return true;
      }
      // Otherwise, we need to sign in. But without password, we can't.
      // So we'll just return false and let the UI use dedicated methods.
      _setError('Please use Google or Facebook sign-in button.');
      return false;
    } catch (e) {
      _setError('Social sign-in failed. Please try again.');
      return false;
    }
  }

  // ── Two-factor verification ─────────────────────────────────────
  Future<bool> verifyPendingTwoFactorCode(String code) async {
    final pendingUser = _pendingTwoFactorUser;
    final expectedCode = _pendingTwoFactorCode;
    if (pendingUser == null || expectedCode == null) return false;
    if (_isExpired(_pendingTwoFactorExpiry)) {
      _clearPendingTwoFactor();
      _setError('Verification code expired. Please log in again.');
      return false;
    }
    if (code.trim() != expectedCode) {
      _setError('Incorrect verification code.');
      return false;
    }
    await _completeLogin(pendingUser);
    return true;
  }

  void cancelPendingTwoFactorLogin() => _clearPendingTwoFactor();

  String startTwoFactorSetup() {
    final account = _accountForCurrentUser;
    if (account == null) return '';
    _setupTwoFactorCode = _generateSixDigitCode();
    _setupTwoFactorExpiry = DateTime.now().add(const Duration(minutes: 5));
    return _setupTwoFactorCode!;
  }

  void cancelTwoFactorSetup() {
    _setupTwoFactorCode = null;
    _setupTwoFactorExpiry = null;
  }

  Future<bool> confirmTwoFactorSetup(String code) async {
    final account = _accountForCurrentUser;
    final expectedCode = _setupTwoFactorCode;
    if (account == null || expectedCode == null) return false;
    if (_isExpired(_setupTwoFactorExpiry)) {
      cancelTwoFactorSetup();
      _setError('Setup code expired. Please try again.');
      return false;
    }
    if (code.trim() != expectedCode) {
      _setError('Incorrect verification code.');
      return false;
    }
    final key = _normalizeEmail(account.email);
    _accounts[key] = account.copyWith(twoFactorEnabled: true);
    cancelTwoFactorSetup();
    await _saveAccounts();
    _notify();
    return true;
  }

  Future<void> setTwoFactorEnabled(bool enabled) async {
    final account = _accountForCurrentUser;
    if (account == null) return;
    final key = _normalizeEmail(account.email);
    _accounts[key] = account.copyWith(twoFactorEnabled: enabled);
    await _saveAccounts();
    _notify();
  }

  // ── Password change (Firebase) ──────────────────────────────────
  Future<PasswordChangeResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || _user == null) {
      return PasswordChangeResult.notLoggedIn;
    }
    final account = _accountForCurrentUser;
    if (account != null && !account.hasPassword) {
      return PasswordChangeResult.unsupportedAccount;
    }
    try {
      final cred = firebase.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      if (account != null && account.hasPassword) {
        final key = _normalizeEmail(account.email);
        _accounts[key] = account.copyWith(password: newPassword);
        await _saveAccounts();
      }
      _notify();
      return PasswordChangeResult.success;
    } on firebase.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return PasswordChangeResult.wrongCurrentPassword;
      } else if (e.code == 'weak-password') {
        return PasswordChangeResult.weakPassword;
      }
      return PasswordChangeResult.notLoggedIn;
    }
  }

  // ── Logout (Firebase) ───────────────────────────────────────────
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
    await _localLogout();
  }

  Future<void> _localLogout() async {
    _user = null;
    _isLoggedIn = false;
    _isLoading = false;
    _errorMessage = null;
    _clearPendingTwoFactor(notify: false);
    cancelTwoFactorSetup();
    await _prefs.remove(_keyUser);
    await _prefs.remove(_keyLoggedIn);
    _notify();
  }

  void _notify() {
    if (isClosed) return;
    emit(state + 1);
  }
}

// ── Internal account model (must be at the end) ─────────────────────────────
class _StoredAccount {
  const _StoredAccount({
    required this.id,
    required this.email,
    required this.displayName,
    required this.phone,
    required this.password,
    required this.twoFactorEnabled,
  });

  final String id;
  final String email;
  final String displayName;
  final String? phone;
  final String? password;
  final bool twoFactorEnabled;

  bool get hasPassword => password != null && password!.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'phone': phone,
        'password': password,
        'twoFactorEnabled': twoFactorEnabled,
      };

  factory _StoredAccount.fromJson(Map<String, dynamic> json) => _StoredAccount(
        id: json['id'] as String? ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        email: (json['email'] as String? ?? '').trim().toLowerCase(),
        displayName: json['displayName'] as String? ?? '',
        phone: json['phone'] as String?,
        password: json['password'] as String?,
        twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      );

  _StoredAccount copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phone,
    String? password,
    bool? twoFactorEnabled,
  }) =>
      _StoredAccount(
        id: id ?? this.id,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        phone: phone ?? this.phone,
        password: password ?? this.password,
        twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      );
}
