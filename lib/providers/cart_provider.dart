import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../services/database_service.dart';

const _keyCart = 'vapeshop_cart';

class CartProvider extends Cubit<int> {
  CartProvider(this._prefs)
    : _databaseService = DatabaseService.instance,
      super(0) {
    _ready = _loadCart();
  }

  final SharedPreferences _prefs;
  final DatabaseService _databaseService;
  late final Future<void> _ready;
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  double get total =>
      _items.fold(0.0, (sum, i) => sum + (i.unitPrice * i.quantity));

  Future<void> _loadCart() async {
    final storedItems = await _databaseService.getCartItems();
    if (storedItems.isNotEmpty) {
      _items
        ..clear()
        ..addAll(storedItems);
      _notify();
      return;
    }

    final legacyItems = _readLegacyCart();
    _items
      ..clear()
      ..addAll(legacyItems);

    if (legacyItems.isNotEmpty) {
      await _databaseService.replaceCartItems(legacyItems);
      await _prefs.remove(_keyCart);
    }

    _notify();
  }

  Future<void> _saveCart() async {
    await _databaseService.replaceCartItems(_items);
    _notify();
  }

  Future<void> addItem(CartItem item) async {
    await _ready;
    final existing = _items.indexWhere(
      (i) => i.productId == item.productId && i.flavor == item.flavor,
    );
    if (existing >= 0) {
      _items[existing].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    await _saveCart();
  }

  Future<void> removeItem(int index) async {
    await _ready;
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      await _saveCart();
    }
  }

  Future<void> updateQuantity(int index, int quantity) async {
    await _ready;
    if (index >= 0 && index < _items.length && quantity > 0) {
      _items[index].quantity = quantity;
      await _saveCart();
    }
  }

  Future<void> updateFlavor(int index, String flavor) async {
    await _ready;
    if (index >= 0 && index < _items.length) {
      _items[index].flavor = flavor;
      await _saveCart();
    }
  }

  Future<void> clear() async {
    await _ready;
    _items.clear();
    await _databaseService.clearCart();
    await _prefs.remove(_keyCart);
    _notify();
  }

  List<CartItem> _readLegacyCart() {
    final json = _prefs.getString(_keyCart);
    if (json == null) return [];

    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((entry) => CartItem.fromJson(entry as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void _notify() {
    if (isClosed) return;
    emit(state + 1);
  }
}
