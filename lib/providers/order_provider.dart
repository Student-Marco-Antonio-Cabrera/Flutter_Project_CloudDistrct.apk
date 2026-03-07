import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

const _keyOrders = 'vapeshop_orders';

class OrderProvider extends Cubit<int> {
  OrderProvider(this._prefs) : super(0) {
    _loadOrders();
  }
  final SharedPreferences _prefs;
  final List<Order> _orders = [];
  List<Order> get orders {
    final sorted = List<Order>.from(_orders);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  List<Order> ordersForEmail(String email) {
    final normalized = email.trim().toLowerCase();
    return orders
        .where(
          (order) => order.customerEmail.trim().toLowerCase() == normalized,
        )
        .toList();
  }

  Future<void> _loadOrders() async {
    final json = _prefs.getString(_keyOrders);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List<dynamic>;
        _orders
          ..clear()
          ..addAll(
            list.map((item) => Order.fromJson(item as Map<String, dynamic>)),
          );
      } catch (_) {
        _orders.clear();
      }
    }
    _notify();
  }

  Future<void> _saveOrders() async {
    final list = _orders.map((order) => order.toJson()).toList();
    await _prefs.setString(_keyOrders, jsonEncode(list));
    _notify();
  }

  Future<Order> placeOrder({
    required String customerEmail,
    required List<CartItem> items,
    required double subtotal,
    required double shippingFee,
    required double discount,
    required double total,
    required String paymentMethod,
    required String shippingMethod,
    required String deliveryAddress,
    String? notes,
  }) async {
    final timestamp = DateTime.now();
    final order = Order(
      id: _buildOrderId(timestamp),
      customerEmail: customerEmail.trim().toLowerCase(),
      createdAt: timestamp,
      items: items.map((item) => item.copyWith()).toList(),
      subtotal: subtotal,
      shippingFee: shippingFee,
      discount: discount,
      total: total,
      paymentMethod: paymentMethod,
      shippingMethod: shippingMethod,
      deliveryAddress: deliveryAddress,
      notes: notes == null || notes.trim().isEmpty ? null : notes.trim(),
    );
    _orders.insert(0, order);
    await _saveOrders();
    return order;
  }

  Future<void> advanceOrderStatus(String orderId) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index < 0) return;
    final current = _orders[index];
    if (current.status == OrderStatus.delivered) return;
    final nextStatus = OrderStatus.values[current.status.index + 1];
    _orders[index] = current.copyWith(status: nextStatus);
    await _saveOrders();
  }

  static String _buildOrderId(DateTime timestamp) {
    final year = timestamp.year;
    final month = timestamp.month.toString().padLeft(2, '0');
    final day = timestamp.day.toString().padLeft(2, '0');
    final suffix = (timestamp.millisecondsSinceEpoch % 1000000)
        .toString()
        .padLeft(6, '0');
    return 'CD-$year$month$day-$suffix';
  }

  void _notify() {
    if (isClosed) return;
    emit(state + 1);
  }
}
