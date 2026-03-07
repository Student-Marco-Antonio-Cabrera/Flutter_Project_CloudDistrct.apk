import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/address.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/gradient_scaffold.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'thank_you_screen.dart';
import 'toc_screen.dart';

class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key});
  static const String routeName = '/buy';
  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _billingAddressController = TextEditingController();
  final _promoController = TextEditingController();
  final _orderNotesController = TextEditingController();
  String? _selectedAddressId;
  String _selectedPaymentMethodId = 'cod';
  String _selectedShippingMethodId = 'standard';
  String? _appliedPromoCode;
  bool _checkoutAsGuest = true;
  bool _billingSameAsDelivery = true;
  bool _agreeToTerms = false;
  static const List<_PaymentMethod> _paymentMethods = [
    _PaymentMethod(
      id: 'cod',
      label: 'Cash on Delivery',
      subtitle: 'Pay once your order arrives',
      icon: Icons.payments_outlined,
    ),
    _PaymentMethod(
      id: 'gcash',
      label: 'GCash',
      subtitle: 'Fast wallet checkout',
      icon: Icons.account_balance_wallet_outlined,
    ),
    _PaymentMethod(
      id: 'card',
      label: 'Credit / Debit Card',
      subtitle: 'Visa, Mastercard, and more',
      icon: Icons.credit_card_outlined,
    ),
    _PaymentMethod(
      id: 'maya',
      label: 'Maya',
      subtitle: 'Pay securely with Maya wallet',
      icon: Icons.qr_code_2_outlined,
    ),
  ];
  static const List<_ShippingMethod> _shippingMethods = [
    _ShippingMethod(
      id: 'standard',
      label: 'Standard Delivery',
      fee: 79,
      minDays: 3,
      maxDays: 5,
      icon: Icons.local_shipping_outlined,
    ),
    _ShippingMethod(
      id: 'express',
      label: 'Express Delivery',
      fee: 129,
      minDays: 1,
      maxDays: 2,
      icon: Icons.flash_on_outlined,
    ),
    _ShippingMethod(
      id: 'same_day',
      label: 'Same-day Delivery',
      fee: 199,
      minDays: 0,
      maxDays: 0,
      icon: Icons.bolt_outlined,
    ),
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fillFromProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _deliveryAddressController.dispose();
    _billingAddressController.dispose();
    _promoController.dispose();
    _orderNotesController.dispose();
    super.dispose();
  }

  void _fillFromProfile() {
    final auth = context.read<AuthProvider>();
    final profile = context.read<UserProfileProvider>();
    _nameController.text = profile.displayName ?? auth.user?.displayName ?? '';
    _emailController.text = auth.user?.email ?? '';
    _phoneController.text = profile.phone ?? auth.user?.phone ?? '';
    final addresses = profile.addresses;
    if (addresses.isNotEmpty) {
      final defaultAddress = addresses.any((a) => a.isDefault)
          ? addresses.firstWhere((a) => a.isDefault)
          : addresses.first;
      _selectedAddressId ??= defaultAddress.id;
      final selected =
          _addressById(addresses, _selectedAddressId) ?? defaultAddress;
      _deliveryAddressController.text = _formatAddress(selected);
      if (_billingAddressController.text.trim().isEmpty) {
        _billingAddressController.text = _deliveryAddressController.text;
      }
    }
    if (auth.isLoggedIn) {
      _checkoutAsGuest = false;
    }
    if (mounted) setState(() {});
  }

  Address? _addressById(List<Address> addresses, String? id) {
    if (id == null) return null;
    for (final a in addresses) {
      if (a.id == id) return a;
    }
    return null;
  }

  String _formatAddress(Address address) {
    final postal =
        address.postalCode == null || address.postalCode!.trim().isEmpty
        ? ''
        : ' ${address.postalCode}';
    return '${address.fullAddress}, ${address.city}$postal';
  }

  _ShippingMethod get _selectedShippingMethod =>
      _shippingMethods.firstWhere((m) => m.id == _selectedShippingMethodId);
  _PaymentMethod get _selectedPaymentMethod =>
      _paymentMethods.firstWhere((m) => m.id == _selectedPaymentMethodId);
  double _discountValue({
    required double subtotal,
    required double shippingFee,
  }) {
    switch (_appliedPromoCode) {
      case 'VAPE10':
        return subtotal * 0.10;
      case 'SAVE100':
        return 100;
      case 'FREESHIP':
        return shippingFee;
      default:
        return 0;
    }
  }

  Future<void> _applyPromo({
    required double subtotal,
    required double shippingFee,
  }) async {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a promo code first')));
      return;
    }
    if (code != 'VAPE10' && code != 'SAVE100' && code != 'FREESHIP') {
      setState(() => _appliedPromoCode = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid promo code')));
      return;
    }
    setState(() => _appliedPromoCode = code);
    final discount = _discountValue(
      subtotal: subtotal,
      shippingFee: shippingFee,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Promo applied: -₱${discount.toStringAsFixed(0)}'),
      ),
    );
  }

  String _shippingEta(_ShippingMethod method) {
    if (method.minDays == 0 && method.maxDays == 0) {
      return 'Arrives today';
    }
    final from = DateTime.now().add(Duration(days: method.minDays));
    final to = DateTime.now().add(Duration(days: method.maxDays));
    if (method.minDays == method.maxDays) {
      return 'Estimated: ${_shortDate(from)}';
    }
    return 'Estimated: ${_shortDate(from)} - ${_shortDate(to)}';
  }

  String _shortDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}';
  }

  Future<void> _openSupportDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout Support'),
        content: const Text(
          'Need help with payment or delivery?\\n\\n'
          'Email: support@clouddistrict.shop\\n'
          'Hotline: +63 917 555 0199',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }
    if (!auth.isLoggedIn && !_checkoutAsGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in or continue as guest')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to terms and policies')),
      );
      return;
    }
    final subtotal = cart.total;
    final shippingFee = _selectedShippingMethod.fee;
    final discount = _discountValue(
      subtotal: subtotal,
      shippingFee: shippingFee,
    );
    final grandTotal = (subtotal + shippingFee - discount)
        .clamp(0, double.infinity)
        .toDouble();
    final createdOrder = await orders.placeOrder(
      customerEmail: auth.user?.email ?? _emailController.text.trim(),
      items: cart.items,
      subtotal: subtotal,
      shippingFee: shippingFee,
      discount: discount,
      total: grandTotal,
      paymentMethod: _selectedPaymentMethod.label,
      shippingMethod: _selectedShippingMethod.label,
      deliveryAddress: _deliveryAddressController.text.trim(),
      notes: _orderNotesController.text.trim(),
    );
    await cart.clear();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      ThankYouScreen.routeName,
      arguments: createdOrder.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final profile = context.watch<UserProfileProvider>();
    final auth = context.watch<AuthProvider>();
    final subtotal = cart.total;
    final shippingFee = _selectedShippingMethod.fee;
    final discount = _discountValue(
      subtotal: subtotal,
      shippingFee: shippingFee,
    );
    final grandTotal = (subtotal + shippingFee - discount)
        .clamp(0, double.infinity)
        .toDouble();
    if (cart.items.isEmpty) {
      return GradientScaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your cart is empty',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              const _CheckoutHeaderCard(
                shopName: 'vapeshop',
                title: 'Checkout',
              ),
              Divider(color: Colors.white.withValues(alpha: 0.25), height: 18),
              if (!auth.isLoggedIn) ...[
                _SectionCard(
                  icon: Icons.person_outline,
                  title: 'Guest Checkout',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'You can continue as guest or sign in for faster checkout.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        value: _checkoutAsGuest,
                        onChanged: (v) => setState(() => _checkoutAsGuest = v),
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: Colors.white,
                        activeTrackColor: Colors.white38,
                        title: const Text(
                          'Continue as guest',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                LoginScreen.routeName,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white70),
                              ),
                              child: const Text('Sign In'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                RegisterScreen.routeName,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white70),
                              ),
                              child: const Text('Sign Up'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.white.withValues(alpha: 0.25),
                  height: 18,
                ),
              ],
              _SectionCard(
                icon: Icons.person_outline,
                title: 'Personal Information',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter full name'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone_outlined),
                        helperText: 'Use an active number for delivery updates',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter phone';
                        if (v.trim().length < 7) return 'Enter a valid phone';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Delivery address',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (profile.addresses.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        key: ValueKey(
                          '${_selectedAddressId ?? 'none'}_${profile.addresses.length}',
                        ),
                        initialValue: _selectedAddressId,
                        decoration: const InputDecoration(
                          labelText: 'Saved addresses',
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
                        items: profile.addresses
                            .map(
                              (address) => DropdownMenuItem(
                                value: address.id,
                                child: Text(
                                  address.isDefault
                                      ? '${address.label} (Default)'
                                      : address.label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (id) {
                          final picked = _addressById(profile.addresses, id);
                          setState(() {
                            _selectedAddressId = id;
                            if (picked != null) {
                              _deliveryAddressController.text = _formatAddress(
                                picked,
                              );
                              if (_billingSameAsDelivery) {
                                _billingAddressController.text =
                                    _deliveryAddressController.text;
                              }
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                    TextFormField(
                      controller: _deliveryAddressController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Delivery address',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter delivery address'
                          : null,
                      onChanged: (value) {
                        if (_billingSameAsDelivery) {
                          _billingAddressController.text = value;
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _billingSameAsDelivery,
                      onChanged: (value) {
                        setState(() {
                          _billingSameAsDelivery = value;
                          if (value) {
                            _billingAddressController.text =
                                _deliveryAddressController.text;
                          }
                        });
                      },
                      title: const Text(
                        'Billing address same as delivery',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      activeThumbColor: Colors.white,
                      activeTrackColor: Colors.white38,
                    ),
                    if (!_billingSameAsDelivery)
                      TextFormField(
                        controller: _billingAddressController,
                        minLines: 2,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Billing address',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.receipt_long_outlined),
                        ),
                        validator: (v) =>
                            !_billingSameAsDelivery &&
                                (v == null || v.trim().isEmpty)
                            ? 'Enter billing address'
                            : null,
                      ),
                  ],
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.25), height: 18),
              _SectionCard(
                icon: Icons.local_shipping,
                title: 'Shipping Method',
                child: Column(
                  children: _shippingMethods.map((method) {
                    return _SelectableTile(
                      selected: _selectedShippingMethodId == method.id,
                      icon: method.icon,
                      title: Text(
                        method.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${_shippingEta(method)} • ₱${method.fee.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 12,
                        ),
                      ),
                      onTap: () =>
                          setState(() => _selectedShippingMethodId = method.id),
                    );
                  }).toList(),
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.25), height: 18),
              _SectionCard(
                icon: Icons.payments_outlined,
                title: 'Payment Method',
                child: Column(
                  children: _paymentMethods.map((method) {
                    return _SelectableTile(
                      selected: _selectedPaymentMethodId == method.id,
                      icon: method.icon,
                      title: Text(
                        method.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        method.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 12,
                        ),
                      ),
                      onTap: () =>
                          setState(() => _selectedPaymentMethodId = method.id),
                    );
                  }).toList(),
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.25), height: 18),
              _SectionCard(
                icon: Icons.local_offer_outlined,
                title: 'Promo Code',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _promoController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'Promo code',
                              prefixIcon: Icon(Icons.discount_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: FilledButton(
                            onPressed: () => _applyPromo(
                              subtotal: subtotal,
                              shippingFee: shippingFee,
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                    if (_appliedPromoCode != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: Colors.green.shade200,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Applied: $_appliedPromoCode',
                            style: TextStyle(
                              color: Colors.green.shade100,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Special instructions',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _orderNotesController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Order notes (optional)',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.sticky_note_2_outlined),
                        hintText: 'Special instructions for rider or packing',
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.25), height: 18),
              _SectionCard(
                icon: Icons.shopping_cart_outlined,
                title: 'Order Summary',
                trailing: TextButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, CartScreen.routeName),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit cart'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                ),
                child: Column(
                  children: [
                    ...cart.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Qty ${item.quantity} • ${item.flavor}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.82,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '₱${item.subtotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.25), height: 18),
              _SectionCard(
                icon: Icons.receipt_long_outlined,
                title: 'Price Breakdown',
                child: Column(
                  children: [
                    _PriceLine(label: 'Subtotal', value: subtotal),
                    const SizedBox(height: 8),
                    _PriceLine(label: 'Shipping Fee', value: shippingFee),
                    const SizedBox(height: 8),
                    _PriceLine(
                      label: 'Discount',
                      value: -discount,
                      valueColor: Colors.green.shade100,
                    ),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.25),
                      height: 22,
                    ),
                    _PriceLine(
                      label: 'Grand Total',
                      value: grandTotal,
                      isEmphasis: true,
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.25), height: 18),
              _SectionCard(
                icon: Icons.verified_user_outlined,
                title: 'Policies & Support',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _agreeToTerms,
                      activeColor: Colors.white,
                      checkColor: Colors.black87,
                      title: const Text(
                        'I agree to store terms and conditions',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onChanged: (v) =>
                          setState(() => _agreeToTerms = v ?? false),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TocScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.policy_outlined, size: 18),
                          label: const Text('View terms'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _openSupportDialog,
                          icon: const Icon(
                            Icons.support_agent_outlined,
                            size: 18,
                          ),
                          label: const Text('Contact support'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _placeOrder,
                icon: const Icon(Icons.lock_outline),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Place Order Securely',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A00),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.84),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Secure checkout powered by Cloud District',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.84),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutHeaderCard extends StatelessWidget {
  const _CheckoutHeaderCard({required this.shopName, required this.title});
  final String shopName;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shopName,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const _CheckoutProgress(),
        ],
      ),
    );
  }
}

class _CheckoutProgress extends StatelessWidget {
  const _CheckoutProgress();
  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFFFB55A);
    final idleColor = Colors.white.withValues(alpha: 0.35);
    Widget dot(bool active) => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: active ? activeColor : idleColor,
        shape: BoxShape.circle,
      ),
    );
    Widget connector(bool active) => Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: active ? activeColor : idleColor,
      ),
    );
    Widget label(String text, bool active) => Text(
      text,
      style: TextStyle(
        color: active ? Colors.white : Colors.white70,
        fontSize: 11,
        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
      ),
    );
    return Column(
      children: [
        Row(
          children: [
            dot(false),
            connector(true),
            dot(true),
            connector(false),
            dot(false),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            label('Cart', false),
            const Spacer(),
            label('Checkout', true),
            const Spacer(),
            label('Confirmation', false),
          ],
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              trailing ?? const SizedBox.shrink(),
            ],
          ),
          Divider(color: Colors.white.withValues(alpha: 0.25), height: 18),
          child,
        ],
      ),
    );
  }
}

class _SelectableTile extends StatelessWidget {
  const _SelectableTile({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final bool selected;
  final IconData icon;
  final Widget title;
  final Widget subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white.withValues(alpha: 0.95)),
      title: title,
      subtitle: subtitle,
      trailing: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? Colors.white : Colors.white54,
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({
    required this.label,
    required this.value,
    this.isEmphasis = false,
    this.valueColor,
  });
  final String label;
  final double value;
  final bool isEmphasis;
  final Color? valueColor;
  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Colors.white,
      fontSize: isEmphasis ? 17 : 14,
      fontWeight: isEmphasis ? FontWeight.w800 : FontWeight.w600,
    );
    final sign = value < 0 ? '-' : '';
    final formatted = '₱${value.abs().toStringAsFixed(0)}';
    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(
          '$sign$formatted',
          style: style.copyWith(color: valueColor ?? style.color),
        ),
      ],
    );
  }
}

class _PaymentMethod {
  const _PaymentMethod({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
  });
  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
}

class _ShippingMethod {
  const _ShippingMethod({
    required this.id,
    required this.label,
    required this.fee,
    required this.minDays,
    required this.maxDays,
    required this.icon,
  });
  final String id;
  final String label;
  final double fee;
  final int minDays;
  final int maxDays;
  final IconData icon;
}
