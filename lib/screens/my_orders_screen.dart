import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/gradient_scaffold.dart';

enum MyOrdersInitialTab { history, tracking }

class MyOrdersRouteArgs {
  const MyOrdersRouteArgs({
    this.initialTab = MyOrdersInitialTab.history,
    this.orderId,
  });

  final MyOrdersInitialTab initialTab;
  final String? orderId;
}

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({
    super.key,
    this.initialTab = MyOrdersInitialTab.history,
  });

  static const String routeName = '/my-orders';
  final MyOrdersInitialTab initialTab;

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _didApplyArgs = false;
  String? _selectedOrderId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex:
          widget.initialTab == MyOrdersInitialTab.tracking ? 1 : 0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didApplyArgs) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    final routeArgs = _resolveRouteArgs(args);
    _tabController.index =
        routeArgs.initialTab == MyOrdersInitialTab.tracking ? 1 : 0;
    _selectedOrderId = routeArgs.orderId;
    _didApplyArgs = true;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  MyOrdersRouteArgs _resolveRouteArgs(Object? args) {
    if (args is MyOrdersRouteArgs) return args;
    if (args is MyOrdersInitialTab) return MyOrdersRouteArgs(initialTab: args);
    return MyOrdersRouteArgs(initialTab: widget.initialTab);
  }

  Order? _resolveSelectedOrder(List<Order> orders) {
    if (orders.isEmpty) return null;
    final selectedId = _selectedOrderId;
    if (selectedId == null) {
      _selectedOrderId = orders.first.id;
      return orders.first;
    }
    for (final order in orders) {
      if (order.id == selectedId) return order;
    }
    _selectedOrderId = orders.first.id;
    return orders.first;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final userEmail = auth.user?.email.trim().toLowerCase();
    final orders = userEmail == null || userEmail.isEmpty
        ? orderProvider.orders
        : orderProvider.ordersForEmail(userEmail);
    final selectedOrder = _resolveSelectedOrder(orders);

    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          // ── Fix: make tab labels clearly visible on gradient ──────────
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Order History'),
            Tab(text: 'Track Order'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _OrderHistoryView(
              orders: orders,
              onTrackOrder: (orderId) {
                setState(() => _selectedOrderId = orderId);
                _tabController.animateTo(1);
              },
            ),
            _TrackOrderView(
              orders: orders,
              selectedOrder: selectedOrder,
              onOrderSelected: (orderId) {
                setState(() => _selectedOrderId = orderId);
              },
              onAdvanceOrder: (orderId) =>
                  context.read<OrderProvider>().advanceOrderStatus(orderId),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Order History Tab ─────────────────────────────────────────────────────────

class _OrderHistoryView extends StatelessWidget {
  const _OrderHistoryView({
    required this.orders,
    required this.onTrackOrder,
  });

  final List<Order> orders;
  final ValueChanged<String> onTrackOrder;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 56, color: Colors.white.withValues(alpha: 0.6)),
              const SizedBox(height: 16),
              Text(
                'No orders yet.',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Complete checkout to see your order history here.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _OrderHistoryCard(
            order: order,
            onTrackOrder: () => onTrackOrder(order.id),
          ),
        );
      },
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  const _OrderHistoryCard({
    required this.order,
    required this.onTrackOrder,
  });

  final Order order;
  final VoidCallback onTrackOrder;

  @override
  Widget build(BuildContext context) {
    // High-contrast card so text is always readable on gradient
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID + status pill
          Row(
            children: [
              Expanded(
                child: Text(
                  order.id,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _OrderStatusPill(status: order.status),
            ],
          ),
          const SizedBox(height: 6),

          // Date
          Text(
            _formatDate(order.createdAt),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),

          // Items + total
          Row(
            children: [
              Text(
                '${order.itemCount} item(s)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                _formatPrice(order.total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Track button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTrackOrder,
              icon: const Icon(Icons.local_shipping_outlined,
                  size: 18, color: Colors.white),
              label: const Text(
                'Track this order',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Track Order Tab ───────────────────────────────────────────────────────────

class _TrackOrderView extends StatelessWidget {
  const _TrackOrderView({
    required this.orders,
    required this.selectedOrder,
    required this.onOrderSelected,
    required this.onAdvanceOrder,
  });

  final List<Order> orders;
  final Order? selectedOrder;
  final ValueChanged<String> onOrderSelected;
  final Future<void> Function(String orderId) onAdvanceOrder;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_shipping_outlined,
                  size: 56, color: Colors.white.withValues(alpha: 0.6)),
              const SizedBox(height: 16),
              const Text(
                'No active orders to track.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final order = selectedOrder ?? orders.first;
    final currentStep = order.status.index;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Order selector dropdown
        DropdownButtonFormField<String>(
          initialValue: order.id,
          dropdownColor: Theme.of(context).colorScheme.surface,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            labelText: 'Select Order',
            labelStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(Icons.receipt_long_outlined, color: Colors.white),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            filled: true,
            fillColor: Color(0x26FFFFFF), // white 15% opacity
          ),
          items: orders
              .map(
                (entry) => DropdownMenuItem(
                  value: entry.id,
                  child: Text(
                    '${entry.id} — ${_formatDate(entry.createdAt)}',
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onOrderSelected(value);
          },
        ),
        const SizedBox(height: 14),

        // Order info card
        _OrderStatusCard(order: order),
        const SizedBox(height: 14),

        // Tracking timeline
        ...OrderStatus.values.asMap().entries.map((entry) {
          final index = entry.key;
          final status = entry.value;
          return _TrackingTile(
            status: status,
            isDone: index <= currentStep,
            isCurrent: index == currentStep,
            isLast: index == OrderStatus.values.length - 1,
          );
        }),

        // Demo advance button
        if (order.status != OrderStatus.delivered) ...[
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => onAdvanceOrder(order.id),
            icon: const Icon(Icons.play_arrow_outlined),
            label: const Text(
              'Advance Status (Demo)',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ],
    );
  }
}

class _OrderStatusCard extends StatelessWidget {
  const _OrderStatusCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.id,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _OrderStatusPill(status: order.status),
            ],
          ),
          const Divider(color: Colors.white24, height: 20),
          _InfoRow(label: 'Payment', value: order.paymentMethod),
          const SizedBox(height: 4),
          _InfoRow(label: 'Shipping', value: order.shippingMethod),
          const SizedBox(height: 4),
          _InfoRow(label: 'Address', value: order.deliveryAddress),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackingTile extends StatelessWidget {
  const _TrackingTile({
    required this.status,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
  });

  final OrderStatus status;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final doneColor = Colors.white;
    final pendingColor = Colors.white.withValues(alpha: 0.30);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDone ? doneColor : pendingColor,
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
              ),
              child: isDone
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: isDone ? doneColor : pendingColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),

        // Status label
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        isCurrent ? FontWeight.w800 : FontWeight.w600,
                    fontSize: isCurrent ? 15 : 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  status.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.80),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderStatusPill extends StatelessWidget {
  const _OrderStatusPill({required this.status});

  final OrderStatus status;

  Color _pillColor() {
    switch (status) {
      case OrderStatus.placed:
        return const Color(0xFFFFD700).withValues(alpha: 0.85);
      case OrderStatus.preparing:
        return const Color(0xFFFB923C).withValues(alpha: 0.85);
      case OrderStatus.shipped:
        return const Color(0xFF60A5FA).withValues(alpha: 0.85);
      case OrderStatus.outForDelivery:
        return const Color(0xFFA78BFA).withValues(alpha: 0.85);
      case OrderStatus.delivered:
        return const Color(0xFF4ADE80).withValues(alpha: 0.85);
    }
  }

  Color _textColor() {
    switch (status) {
      case OrderStatus.placed:
        return const Color(0xFF78350F);
      case OrderStatus.delivered:
        return const Color(0xFF14532D);
      case OrderStatus.preparing:
      case OrderStatus.shipped:
      case OrderStatus.outForDelivery:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _pillColor(),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _textColor(),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final month = months[date.month - 1];
  final day = date.day.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$month $day, ${date.year} – $hour:$minute';
}

String _formatPrice(double value) => 'PHP ${value.toStringAsFixed(0)}';