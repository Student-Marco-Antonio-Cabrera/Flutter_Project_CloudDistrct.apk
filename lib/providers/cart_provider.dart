import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

const _keyCart = 'vapeshop_cart';

class CartProvider extends Cubit<int> {
  CartProvider(this._prefs) : super(0) {
    _loadCart();
  }
  final SharedPreferences _prefs;
  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  double get total =>
      _items.fold(0.0, (sum, i) => sum + (i.unitPrice * i.quantity));
  Future<void> _loadCart() async {
    final json = _prefs.getString(_keyCart);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List<dynamic>;
        _items.clear();
        for (final e in list) {
          _items.add(CartItem.fromJson(e as Map<String, dynamic>));
        }
      } catch (_) {}
    }
    _notify();
  }

  Future<void> _saveCart() async {
    final list = _items.map((e) => e.toJson()).toList();
    await _prefs.setString(_keyCart, jsonEncode(list));
    _notify();
  }

  Future<void> addItem(CartItem item) async {
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
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      await _saveCart();
    }
  }

  Future<void> updateQuantity(int index, int quantity) async {
    if (index >= 0 && index < _items.length && quantity > 0) {
      _items[index].quantity = quantity;
      await _saveCart();
    }
  }

  Future<void> updateFlavor(int index, String flavor) async {
    if (index >= 0 && index < _items.length) {
      _items[index].flavor = flavor;
      await _saveCart();
    }
  }

  Future<void> clear() async {
    _items.clear();
    await _prefs.remove(_keyCart);
    _notify();
  }

  void _notify() {
    if (isClosed) return;
    emit(state + 1);
  }
}
