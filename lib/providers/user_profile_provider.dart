import 'dart:convert';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/address.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';

const _keyProfile = 'vapeshop_profile';

class UserProfileProvider extends Cubit<int> {
  UserProfileProvider(this._prefs, this._authProvider)
    : _databaseService = DatabaseService.instance,
      super(0) {
    _authSubscription = _authProvider.stream.listen((_) {
      unawaited(_onAuthChanged());
    });
    _ready = _loadProfile();
  }

  final SharedPreferences _prefs;
  final AuthProvider _authProvider;
  final DatabaseService _databaseService;
  late final StreamSubscription<int> _authSubscription;
  late Future<void> _ready;
  String? _displayName;
  String? _phone;
  String? _profileImagePath;
  List<Address> _addresses = [];

  String? get displayName => _displayName ?? _authProvider.user?.displayName;
  String? get phone => _phone ?? _authProvider.user?.phone;
  String? get profileImagePath => _profileImagePath;
  List<Address> get addresses => List.unmodifiable(_addresses);

  Future<void> _onAuthChanged() async {
    if (!_authProvider.isLoggedIn || _currentUserEmail == null) {
      _displayName = null;
      _phone = null;
      _profileImagePath = null;
      _addresses = [];
      _notify();
    } else {
      _ready = _loadProfile();
      await _ready;
    }
  }

  Future<void> _loadProfile() async {
    final user = _authProvider.user;
    if (user == null) {
      _displayName = null;
      _phone = null;
      _profileImagePath = null;
      _addresses = [];
      _notify();
      return;
    }

    final userEmail = _normalizeEmail(user.email);
    final storedProfile = await _databaseService.getUserProfile(userEmail);

    if (storedProfile != null) {
      _displayName = storedProfile.displayName;
      _phone = storedProfile.phone;
      _profileImagePath = storedProfile.profileImagePath;
      _addresses = List<Address>.from(storedProfile.addresses);
      _notify();
      return;
    }

    final legacyProfile = _readLegacyProfile();
    if (legacyProfile != null) {
      _displayName = legacyProfile.displayName;
      _phone = legacyProfile.phone;
      _profileImagePath = legacyProfile.profileImagePath;
      _addresses = legacyProfile.addresses;
      await _databaseService.saveUserProfile(
        userEmail: userEmail,
        displayName: displayName,
        phone: phone,
        profileImagePath: profileImagePath,
        addresses: _addresses,
      );
      await _prefs.remove(_keyProfile);
    } else {
      _displayName = user.displayName;
      _phone = user.phone;
      _profileImagePath = user.profileImagePath;
      _addresses = List<Address>.from(user.addresses);
    }

    _notify();
  }

  Future<void> _saveProfile() async {
    final userEmail = _currentUserEmail;
    if (userEmail == null) {
      _notify();
      return;
    }

    await _databaseService.saveUserProfile(
      userEmail: userEmail,
      displayName: displayName,
      phone: phone,
      profileImagePath: profileImagePath,
      addresses: _addresses,
    );
    await _prefs.remove(_keyProfile);
    _notify();
  }

  Future<void> updateProfile({
    String? displayName,
    String? phone,
    String? profileImagePath,
  }) async {
    await _ready;
    if (displayName != null) _displayName = displayName;
    if (phone != null) _phone = phone;
    if (profileImagePath != null) _profileImagePath = profileImagePath;
    await _saveProfile();
  }

  Future<void> setProfileImage(String? path) async {
    await _ready;
    _profileImagePath = path;
    await _saveProfile();
  }

  Future<void> addAddress(Address address) async {
    await _ready;
    _addresses.add(address);
    await _saveProfile();
  }

  Future<void> updateAddress(int index, Address address) async {
    await _ready;
    if (index >= 0 && index < _addresses.length) {
      _addresses[index] = address;
      await _saveProfile();
    }
  }

  Future<void> removeAddress(int index) async {
    await _ready;
    if (index >= 0 && index < _addresses.length) {
      _addresses.removeAt(index);
      await _saveProfile();
    }
  }

  Future<void> setDefaultAddress(String id) async {
    await _ready;
    var changed = false;
    _addresses = _addresses
        .map(
          (a) => a.id == id
              ? a.copyWith(isDefault: true)
              : a.copyWith(isDefault: false),
        )
        .toList();
    changed = _addresses.any((a) => a.id == id && a.isDefault);
    if (changed) {
      await _saveProfile();
    }
  }

  _LegacyProfileData? _readLegacyProfile() {
    final json = _prefs.getString(_keyProfile);
    if (json == null) return null;

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final addressList = (map['addresses'] as List<dynamic>? ?? [])
          .map((entry) => Address.fromJson(entry as Map<String, dynamic>))
          .toList();
      return _LegacyProfileData(
        displayName: map['displayName'] as String?,
        phone: map['phone'] as String?,
        profileImagePath: map['profileImagePath'] as String?,
        addresses: addressList,
      );
    } catch (_) {
      return null;
    }
  }

  String? get _currentUserEmail {
    final email = _authProvider.user?.email;
    if (email == null || email.trim().isEmpty) return null;
    return _normalizeEmail(email);
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  Address? getAddressById(String id) {
    try {
      return _addresses.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription.cancel();
    return super.close();
  }

  void _notify() {
    if (isClosed) return;
    emit(state + 1);
  }
}

class _LegacyProfileData {
  const _LegacyProfileData({
    this.displayName,
    this.phone,
    this.profileImagePath,
    required this.addresses,
  });

  final String? displayName;
  final String? phone;
  final String? profileImagePath;
  final List<Address> addresses;
}
