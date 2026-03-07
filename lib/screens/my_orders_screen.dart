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
      initialIndex: widget.initialTab == MyOrdersInitialTab.tracking ? 1 : 0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didApplyArgs) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    final routeArgs = _resolveRouteArgs(args);
    _tabController.index = routeArgs.initialTab == MyOrdersInitialTab.tracking
        ? 1
        : 0;
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
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
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

class _OrderHistoryView extends StatelessWidget {
  const _OrderHistoryView({required this.orders, required this.onTrackOrder});

  final List<Order> orders;
  final ValueChanged<String> onTrackOrder;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'No orders yet. Complete checkout to see history.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
          textAlign: TextAlign.center,
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
  const _OrderHistoryCard({required this.order, required this.onTrackOrder});

  final Order order;
  final VoidCallback onTrackOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
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
                  ),
                ),
              ),
              _OrderStatusPill(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(order.createdAt),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${order.itemCount} item(s)',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
              ),
              const Spacer(),
              Text(
                _formatPrice(order.total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTrackOrder,
              icon: const Icon(Icons.local_shipping_outlined, size: 18),
              label: const Text('Track this order'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.75)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        child: Text(
          'No active order to track yet.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
        ),
      );
    }

    final order = selectedOrder ?? orders.first;
    final currentStep = order.status.index;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: order.id,
          dropdownColor: Theme.of(context).colorScheme.surface,
          decoration: const InputDecoration(
            labelText: 'Select Order',
            prefixIcon: Icon(Icons.receipt_long_outlined),
          ),
          items: orders
              .map(
                (entry) => DropdownMenuItem(
                  value: entry.id,
                  child: Text('${entry.id} - ${_formatDate(entry.createdAt)}'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onOrderSelected(value);
          },
        ),
        const SizedBox(height: 12),
        _OrderStatusCard(order: order),
        const SizedBox(height: 12),
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
        if (order.status != OrderStatus.delivered) ...[
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => onAdvanceOrder(order.id),
            icon: const Icon(Icons.play_arrow_outlined),
            label: const Text('Advance Status (Demo)'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
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
                  ),
                ),
              ),
              _OrderStatusPill(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Payment: ${order.paymentMethod}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 4),
          Text(
            'Shipping: ${order.shippingMethod}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 4),
          Text(
            'Address: ${order.deliveryAddress}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
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
    final doneColor = Colors.white.withValues(alpha: 0.95);
    final pendingColor = Colors.white.withValues(alpha: 0.38);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isDone ? doneColor : pendingColor,
                shape: BoxShape.circle,
              ),
              child: isDone
                  ? Icon(
                      Icons.check,
                      size: 13,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: isDone ? doneColor : pendingColor,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 13,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[date.month - 1];
  final day = date.day.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$month $day, ${date.year} - $hour:$minute';
}

String _formatPrice(double value) => 'PHP ${value.toStringAsFixed(0)}';
