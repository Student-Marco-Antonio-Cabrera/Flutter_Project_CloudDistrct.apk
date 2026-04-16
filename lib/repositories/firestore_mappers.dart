import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/address.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/database_service.dart';

class UserProfileSnapshot {
  const UserProfileSnapshot({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phone,
    this.photoUrl,
    this.localProfileImagePath,
    this.addresses = const <Address>[],
  });

  final String uid;
  final String email;
  final String displayName;
  final String? phone;
  final String? photoUrl;
  final String? localProfileImagePath;
  final List<Address> addresses;
}

class FirestoreMappers {
  const FirestoreMappers._();

  static Map<String, dynamic> userDocument({
    required firebase_auth.User authUser,
    StoredUserProfile? localProfile,
  }) {
    final normalizedEmail = (authUser.email ?? '').trim().toLowerCase();
    return {
      'uid': authUser.uid,
      'email': normalizedEmail,
      'displayName':
          localProfile?.displayName ??
          authUser.displayName ??
          _fallbackDisplayName(normalizedEmail),
      'phone': localProfile?.phone ?? authUser.phoneNumber,
      'photoUrl': authUser.photoURL,
      'legacyEmail': normalizedEmail,
      'updatedAt': DateTime.now().toUtc(),
    };
  }

  static Map<String, dynamic> addressDocument(Address address) {
    return {
      ...address.toJson(),
      'updatedAt': DateTime.now().toUtc(),
    };
  }

  static Map<String, dynamic> cartDocument(
    CartItem item, {
    required String userId,
  }) {
    return {
      ...item.toJson(),
      'userId': userId,
      'updatedAt': DateTime.now().toUtc(),
    };
  }

  static String cartDocumentId(CartItem item) {
    final base = '${item.productId}_${item.flavor}';
    return sanitizeIdSegment(base);
  }

  static Map<String, dynamic> orderDocument(
    Order order, {
    required String userId,
  }) {
    return {
      'id': order.id,
      'userId': userId,
      'customerEmailSnapshot': order.customerEmail.trim().toLowerCase(),
      'createdAt': order.createdAt.toUtc(),
      'items': order.items.map((item) => item.toJson()).toList(growable: false),
      'subtotal': order.subtotal,
      'shippingFee': order.shippingFee,
      'discount': order.discount,
      'total': order.total,
      'paymentMethod': order.paymentMethod,
      'shippingMethod': order.shippingMethod,
      'deliveryAddress': order.deliveryAddress,
      'notes': order.notes,
      'status': order.status.name,
      'updatedAt': DateTime.now().toUtc(),
    };
  }

  static Map<String, dynamic> productDocument(Product product) {
    return {
      ...product.toJson(),
      'updatedAt': DateTime.now().toUtc(),
    };
  }

  static UserProfileSnapshot profileFromRemote({
    required firebase_auth.User authUser,
    required Map<String, dynamic>? userData,
    required List<Address> addresses,
    String? localProfileImagePath,
  }) {
    final normalizedEmail = (authUser.email ?? '').trim().toLowerCase();
    return UserProfileSnapshot(
      uid: authUser.uid,
      email: userData?['email'] as String? ?? normalizedEmail,
      displayName:
          userData?['displayName'] as String? ??
          authUser.displayName ??
          _fallbackDisplayName(normalizedEmail),
      phone: userData?['phone'] as String? ?? authUser.phoneNumber,
      photoUrl: userData?['photoUrl'] as String? ?? authUser.photoURL,
      localProfileImagePath: localProfileImagePath,
      addresses: addresses,
    );
  }

  static CartItem cartItemFromFirestore(Map<String, dynamic> data) {
    return CartItem(
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0,
      quantity: data['quantity'] as int? ?? 0,
      flavor: data['flavor'] as String? ?? '',
      imagePath: data['imagePath'] as String?,
    );
  }

  static Address addressFromFirestore(
    Map<String, dynamic> data, {
    String? fallbackId,
  }) {
    return Address(
      id: data['id'] as String? ?? fallbackId ?? '',
      label: data['label'] as String? ?? '',
      fullAddress: data['fullAddress'] as String? ?? '',
      city: data['city'] as String? ?? '',
      postalCode: data['postalCode'] as String?,
      isDefault: data['isDefault'] as bool? ?? false,
      region: data['region'] as String?,
      province: data['province'] as String?,
      cityOrMunicipality: data['cityOrMunicipality'] as String?,
      barangay: data['barangay'] as String?,
      street: data['street'] as String?,
    );
  }

  static Order orderFromFirestore(
    Map<String, dynamic> data, {
    required String documentId,
  }) {
    final rawItems = data['items'] as List<dynamic>? ?? const <dynamic>[];
    return Order(
      id: data['id'] as String? ?? documentId,
      customerEmail: data['customerEmailSnapshot'] as String? ?? '',
      createdAt: readDateTime(data['createdAt']),
      items: rawItems
          .map((item) => cartItemFromFirestore(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false),
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
      shippingFee: (data['shippingFee'] as num?)?.toDouble() ?? 0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: data['paymentMethod'] as String? ?? '',
      shippingMethod: data['shippingMethod'] as String? ?? '',
      deliveryAddress: data['deliveryAddress'] as String? ?? '',
      notes: data['notes'] as String?,
      status: OrderStatusX.fromJsonValue(data['status'] as String?),
    );
  }

  static Product productFromFirestore(
    Map<String, dynamic> data, {
    required String documentId,
  }) {
    String imageUrlStr = 'assets/images/default.png';
    final imageUrlRaw = data['imageUrl'] ?? data['imagePath'];
    if (imageUrlRaw != null) {
      imageUrlStr = imageUrlRaw.toString();
    }

    return Product(
      id: documentId,
      name: data['name'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      imageUrl: imageUrlStr,
      flavors: List<String>.from(data['flavors'] ?? data['availableFlavors'] ?? []),
      description: data['description'] as String? ?? '',
      stock: data['stock'] as int?,
      variants: (data['variants'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }

  static DateTime readDateTime(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String sanitizeIdSegment(String raw) {
    return raw
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  static String _fallbackDisplayName(String normalizedEmail) {
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return '';
    }
    return normalizedEmail.split('@').first;
  }
}
