import 'dart:convert';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/social_auth_service.dart';

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
  }

  final SharedPreferences _prefs;
  final Map<String, _StoredAccount> _accounts = {};
  final Random _random = Random();

  User? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  // ── Two-factor state ──────────────────────────────────────────────────────
  User? _pendingTwoFactorUser;
  String? _pendingTwoFactorCode;
  DateTime? _pendingTwoFactorExpiry;
  String? _setupTwoFactorCode;
  DateTime? _setupTwoFactorExpiry;

  // ── Public getters ────────────────────────────────────────────────────────
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

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _normalizeEmail(String email) => email.trim().toLowerCase();

  User _userFromAccount(_StoredAccount account) => User(
        id: account.id,
        email: account.email,
        displayName: account.displayName,
        phone: account.phone,
        profileImagePath: null,
        addresses: const [],
      );

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

  // ── Persistence ───────────────────────────────────────────────────────────
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

  // ── Two-factor helpers ────────────────────────────────────────────────────
  String _generateSixDigitCode() =>
      (_random.nextInt(900000) + 100000).toString();

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
    _pendingTwoFactorExpiry =
        DateTime.now().add(const Duration(minutes: 5));
  }

  void _clearPendingTwoFactor({bool notify = true}) {
    _pendingTwoFactorUser = null;
    _pendingTwoFactorCode = null;
    _pendingTwoFactorExpiry = null;
    if (notify) _notify();
  }

  // ── Email / password login ────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    final normalizedEmail = _normalizeEmail(email);
    if (normalizedEmail.isEmpty || password.isEmpty) {
      _setError('Email and password are required.');
      return false;
    }

    _setLoading(true);

    var account = _accounts[normalizedEmail];
    if (account == null) {
      // Auto-create account on first login (original behaviour preserved)
      account = _StoredAccount(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: normalizedEmail,
        displayName: normalizedEmail.split('@').first,
        phone: null,
        password: password,
        twoFactorEnabled: false,
      );
      _accounts[normalizedEmail] = account;
      await _saveAccounts();
    }

    if (!account.hasPassword) {
      _setError(
          'This account uses social sign-in. Please use Google or Facebook.');
      return false;
    }
    if (account.password != password) {
      _setError('Incorrect password. Please try again.');
      return false;
    }

    final resolvedUser = _userFromAccount(account);
    if (account.twoFactorEnabled) {
      _startTwoFactorChallenge(resolvedUser);
      _isLoading = false;
      _notify();
      return true;
    }
    await _completeLogin(resolvedUser);
    return true;
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    String? phone,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final cleanDisplayName = displayName.trim();
    final cleanPhone =
        (phone == null || phone.trim().isEmpty) ? null : phone.trim();

    if (normalizedEmail.isEmpty ||
        password.isEmpty ||
        cleanDisplayName.isEmpty) {
      _setError('All fields are required.');
      return false;
    }

    _setLoading(true);

    final existing = _accounts[normalizedEmail];
    if (existing != null && existing.hasPassword) {
      _setError(
          'An account with this email already exists. Please log in instead.');
      return false;
    }

    final account = _StoredAccount(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      email: normalizedEmail,
      displayName: cleanDisplayName,
      phone: cleanPhone,
      password: password,
      twoFactorEnabled: existing?.twoFactorEnabled ?? false,
    );
    _accounts[normalizedEmail] = account;
    await _saveAccounts();
    await _completeLogin(_userFromAccount(account));
    return true;
  }

  // ── Google sign-in ────────────────────────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      final result = await SocialAuthService.signInWithGoogle();
      if (result == null) {
        // User cancelled — just stop loading, no error
        _isLoading = false;
        _notify();
        return false;
      }
      return await signInWithProvider(
        email: result.email,
        displayName: result.displayName,
      );
    } on SocialAuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Google sign-in failed. Please try again.');
      return false;
    }
  }

  // ── Facebook sign-in ──────────────────────────────────────────────────────
  Future<bool> signInWithFacebook() async {
    _setLoading(true);
    try {
      final result = await SocialAuthService.signInWithFacebook();
      if (result == null) {
        // User cancelled
        _isLoading = false;
        _notify();
        return false;
      }
      return await signInWithProvider(
        email: result.email,
        displayName: result.displayName,
      );
    } on SocialAuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Facebook sign-in failed. Please try again.');
      return false;
    }
  }

  // ── Generic social provider completion (shared by Google & Facebook) ──────
  Future<bool> signInWithProvider({
    required String email,
    required String displayName,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    if (normalizedEmail.isEmpty) {
      _setError('Could not retrieve email from social account.');
      return false;
    }

    final existing = _accounts[normalizedEmail];
    final account = _StoredAccount(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      email: normalizedEmail,
      displayName: displayName.trim().isEmpty
          ? normalizedEmail.split('@').first
          : displayName.trim(),
      phone: existing?.phone,
      password: existing?.password,
      twoFactorEnabled: existing?.twoFactorEnabled ?? false,
    );
    _accounts[normalizedEmail] = account;
    await _saveAccounts();

    final resolvedUser = _userFromAccount(account);
    if (account.twoFactorEnabled) {
      _startTwoFactorChallenge(resolvedUser);
      _isLoading = false;
      _notify();
      return true;
    }
    await _completeLogin(resolvedUser);
    return true;
  }

  // ── Two-factor verification ───────────────────────────────────────────────
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

  // ── Two-factor setup ──────────────────────────────────────────────────────
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

  // ── Password change ───────────────────────────────────────────────────────
  Future<PasswordChangeResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final account = _accountForCurrentUser;
    if (_user == null || account == null) {
      return PasswordChangeResult.notLoggedIn;
    }
    if (!account.hasPassword) return PasswordChangeResult.unsupportedAccount;
    if (account.password != currentPassword) {
      return PasswordChangeResult.wrongCurrentPassword;
    }
    if (newPassword.length < 6) return PasswordChangeResult.weakPassword;
    final key = _normalizeEmail(account.email);
    _accounts[key] = account.copyWith(password: newPassword);
    await _saveAccounts();
    _notify();
    return PasswordChangeResult.success;
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _user = null;
    _isLoggedIn = false;
    _isLoading = false;
    _errorMessage = null;
    _clearPendingTwoFactor(notify: false);
    cancelTwoFactorSetup();
    await _prefs.remove(_keyUser);
    await _prefs.remove(_keyLoggedIn);
    await SocialAuthService.signOutGoogle();
    await SocialAuthService.signOutFacebook();
    _notify();
  }

  void _notify() {
    if (isClosed) return;
    emit(state + 1);
  }
}

// ── Internal account model ────────────────────────────────────────────────────
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