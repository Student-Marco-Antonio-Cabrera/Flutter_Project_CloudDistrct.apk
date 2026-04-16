import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/address.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/sync_operation.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService _instance = DatabaseService._();
  static DatabaseService get instance => _instance;

  static const _databaseName = 'cloud_district.db';
  static const _databaseVersion = 3;

  static const _cartItemsTable = 'cart_items';
  static const _ordersTable = 'orders';
  static const _orderItemsTable = 'order_items';
  static const _userProfilesTable = 'user_profiles';
  static const _addressesTable = 'addresses';
  static const _syncQueueTable = 'sync_queue';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<void> init() async {
    await database;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final databasePath = path.join(databasesPath, _databaseName);

    return openDatabase(
      databasePath,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _upgradeSchema(db, oldVersion, newVersion);
      },
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE $_cartItemsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        position INTEGER NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        unit_price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        flavor TEXT NOT NULL,
        image_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $_ordersTable (
        id TEXT PRIMARY KEY,
        customer_email TEXT NOT NULL,
        created_at TEXT NOT NULL,
        subtotal REAL NOT NULL,
        shipping_fee REAL NOT NULL,
        discount REAL NOT NULL,
        total REAL NOT NULL,
        payment_method TEXT NOT NULL,
        shipping_method TEXT NOT NULL,
        delivery_address TEXT NOT NULL,
        notes TEXT,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_orderItemsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        position INTEGER NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        unit_price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        flavor TEXT NOT NULL,
        image_path TEXT,
        FOREIGN KEY (order_id) REFERENCES $_ordersTable(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $_userProfilesTable (
        user_email TEXT PRIMARY KEY,
        display_name TEXT,
        phone TEXT,
        profile_image_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $_addressesTable (
        id TEXT NOT NULL,
        user_email TEXT NOT NULL,
        position INTEGER NOT NULL,
        label TEXT NOT NULL,
        full_address TEXT NOT NULL,
        city TEXT NOT NULL,
        postal_code TEXT,
        is_default INTEGER NOT NULL DEFAULT 0,
        region TEXT,
        province TEXT,
        city_or_municipality TEXT,
        barangay TEXT,
        street TEXT,
        PRIMARY KEY (user_email, id),
        FOREIGN KEY (user_email) REFERENCES $_userProfilesTable(user_email)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $_syncQueueTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        document_path TEXT NOT NULL,
        action TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        user_uid TEXT,
        merge INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT
      )
    ''');

    await _createIndexes(db);
  }

  Future<void> _upgradeSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2 && newVersion >= 2) {
      await _createIndexes(db);
    }
    if (oldVersion < 3 && newVersion >= 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_syncQueueTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          document_path TEXT NOT NULL,
          action TEXT NOT NULL,
          payload_json TEXT NOT NULL,
          user_uid TEXT,
          merge INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          attempts INTEGER NOT NULL DEFAULT 0,
          last_error TEXT
        )
      ''');
      await _createIndexes(db);
    }
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_${_cartItemsTable}_position '
      'ON $_cartItemsTable(position)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_${_ordersTable}_customer_email '
      'ON $_ordersTable(customer_email)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_${_ordersTable}_created_at '
      'ON $_ordersTable(created_at)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_${_orderItemsTable}_order_id '
      'ON $_orderItemsTable(order_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_${_addressesTable}_user_email '
      'ON $_addressesTable(user_email)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_${_addressesTable}_position '
      'ON $_addressesTable(user_email, position)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_${_syncQueueTable}_created_at '
      'ON $_syncQueueTable(created_at, id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_${_syncQueueTable}_user_uid '
      'ON $_syncQueueTable(user_uid)',
    );
  }

  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final rows = await db.query(
      _cartItemsTable,
      orderBy: 'position ASC, id ASC',
    );
    return rows.map(_cartItemFromRow).toList();
  }

  Future<void> replaceCartItems(List<CartItem> items) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(_cartItemsTable);
      for (var index = 0; index < items.length; index++) {
        await txn.insert(
          _cartItemsTable,
          _cartItemToRow(items[index], position: index),
        );
      }
    });
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete(_cartItemsTable);
  }

  Future<List<Order>> getOrders() async {
    final db = await database;
    final orderRows = await db.query(
      _ordersTable,
      orderBy: 'created_at DESC, id DESC',
    );
    if (orderRows.isEmpty) return const [];

    final orderItemRows = await db.query(
      _orderItemsTable,
      orderBy: 'order_id ASC, position ASC, id ASC',
    );
    final itemsByOrderId = <String, List<CartItem>>{};
    for (final row in orderItemRows) {
      final orderId = row['order_id'] as String;
      itemsByOrderId.putIfAbsent(orderId, () => []).add(_cartItemFromRow(row));
    }

    return orderRows
        .map(
          (row) => _orderFromRow(
            row,
            itemsByOrderId[row['id'] as String] ?? const [],
          ),
        )
        .toList();
  }

  Future<void> insertOrder(Order order) async {
    final db = await database;
    await db.transaction((txn) async {
      await _persistOrder(txn, order);
    });
  }

  Future<void> replaceOrders(List<Order> orders) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(_orderItemsTable);
      await txn.delete(_ordersTable);
      for (final order in orders) {
        await _persistOrder(txn, order);
      }
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final db = await database;
    await db.update(
      _ordersTable,
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<StoredUserProfile?> getUserProfile(String userEmail) async {
    final normalizedEmail = _normalizeEmail(userEmail);
    final db = await database;
    final profileRows = await db.query(
      _userProfilesTable,
      where: 'user_email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    final addressRows = await db.query(
      _addressesTable,
      where: 'user_email = ?',
      whereArgs: [normalizedEmail],
      orderBy: 'position ASC, id ASC',
    );

    if (profileRows.isEmpty && addressRows.isEmpty) {
      return null;
    }

    final profileRow = profileRows.isEmpty
        ? const <String, Object?>{}
        : profileRows.first;

    return StoredUserProfile(
      userEmail: normalizedEmail,
      displayName: profileRow['display_name'] as String?,
      phone: profileRow['phone'] as String?,
      profileImagePath: profileRow['profile_image_path'] as String?,
      addresses: addressRows.map(_addressFromRow).toList(),
    );
  }

  Future<void> saveUserProfile({
    required String userEmail,
    String? displayName,
    String? phone,
    String? profileImagePath,
    required List<Address> addresses,
  }) async {
    final normalizedEmail = _normalizeEmail(userEmail);
    final db = await database;

    await db.transaction((txn) async {
      await txn.insert(_userProfilesTable, {
        'user_email': normalizedEmail,
        'display_name': displayName,
        'phone': phone,
        'profile_image_path': profileImagePath,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await txn.delete(
        _addressesTable,
        where: 'user_email = ?',
        whereArgs: [normalizedEmail],
      );

      for (var index = 0; index < addresses.length; index++) {
        await txn.insert(
          _addressesTable,
          _addressToRow(
            addresses[index],
            userEmail: normalizedEmail,
            position: index,
          ),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> enqueueSyncOperation(SyncOperation operation) async {
    final db = await database;
    await db.insert(
      _syncQueueTable,
      operation.toRow(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SyncOperation>> getPendingSyncOperations({
    String? userUid,
    int limit = 100,
  }) async {
    final db = await database;
    final rows = await db.query(
      _syncQueueTable,
      where: userUid == null ? null : 'user_uid = ?',
      whereArgs: userUid == null ? null : [userUid],
      orderBy: 'created_at ASC, id ASC',
      limit: limit,
    );
    return rows.map(SyncOperation.fromRow).toList();
  }

  Future<void> deleteSyncOperation(int id) async {
    final db = await database;
    await db.delete(
      _syncQueueTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSyncOperationFailed(
    int id, {
    required int attempts,
    required String error,
  }) async {
    final db = await database;
    await db.update(
      _syncQueueTable,
      {
        'attempts': attempts,
        'last_error': error,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearSyncQueue({String? userUid}) async {
    final db = await database;
    await db.delete(
      _syncQueueTable,
      where: userUid == null ? null : 'user_uid = ?',
      whereArgs: userUid == null ? null : [userUid],
    );
  }

  Future<void> _persistOrder(DatabaseExecutor executor, Order order) async {
    await executor.insert(
      _ordersTable,
      _orderToRow(order),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await executor.delete(
      _orderItemsTable,
      where: 'order_id = ?',
      whereArgs: [order.id],
    );
    for (var index = 0; index < order.items.length; index++) {
      await executor.insert(
        _orderItemsTable,
        _cartItemToRow(order.items[index], position: index, orderId: order.id),
      );
    }
  }

  Map<String, Object?> _cartItemToRow(
    CartItem item, {
    required int position,
    String? orderId,
  }) {
    final orderReference = orderId == null
        ? null
        : <String, Object?>{'order_id': orderId};
    return {
      ...?orderReference,
      'position': position,
      'product_id': item.productId,
      'product_name': item.productName,
      'unit_price': item.unitPrice,
      'quantity': item.quantity,
      'flavor': item.flavor,
      'image_path': item.imagePath,
    };
  }

  CartItem _cartItemFromRow(Map<String, Object?> row) {
    return CartItem(
      productId: row['product_id'] as String? ?? '',
      productName: row['product_name'] as String? ?? '',
      unitPrice: (row['unit_price'] as num?)?.toDouble() ?? 0,
      quantity: row['quantity'] as int? ?? 0,
      flavor: row['flavor'] as String? ?? '',
      imagePath: row['image_path'] as String?,
    );
  }

  Map<String, Object?> _orderToRow(Order order) {
    return {
      'id': order.id,
      'customer_email': _normalizeEmail(order.customerEmail),
      'created_at': order.createdAt.toIso8601String(),
      'subtotal': order.subtotal,
      'shipping_fee': order.shippingFee,
      'discount': order.discount,
      'total': order.total,
      'payment_method': order.paymentMethod,
      'shipping_method': order.shippingMethod,
      'delivery_address': order.deliveryAddress,
      'notes': order.notes,
      'status': order.status.name,
    };
  }

  Order _orderFromRow(Map<String, Object?> row, List<CartItem> items) {
    return Order(
      id: row['id'] as String? ?? '',
      customerEmail: row['customer_email'] as String? ?? '',
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      items: items,
      subtotal: (row['subtotal'] as num?)?.toDouble() ?? 0,
      shippingFee: (row['shipping_fee'] as num?)?.toDouble() ?? 0,
      discount: (row['discount'] as num?)?.toDouble() ?? 0,
      total: (row['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: row['payment_method'] as String? ?? '',
      shippingMethod: row['shipping_method'] as String? ?? '',
      deliveryAddress: row['delivery_address'] as String? ?? '',
      notes: row['notes'] as String?,
      status: OrderStatusX.fromJsonValue(row['status'] as String?),
    );
  }

  Map<String, Object?> _addressToRow(
    Address address, {
    required String userEmail,
    required int position,
  }) {
    return {
      'id': address.id,
      'user_email': userEmail,
      'position': position,
      'label': address.label,
      'full_address': address.fullAddress,
      'city': address.city,
      'postal_code': address.postalCode,
      'is_default': address.isDefault ? 1 : 0,
      'region': address.region,
      'province': address.province,
      'city_or_municipality': address.cityOrMunicipality,
      'barangay': address.barangay,
      'street': address.street,
    };
  }

  Address _addressFromRow(Map<String, Object?> row) {
    return Address(
      id: row['id'] as String? ?? '',
      label: row['label'] as String? ?? '',
      fullAddress: row['full_address'] as String? ?? '',
      city: row['city'] as String? ?? '',
      postalCode: row['postal_code'] as String?,
      isDefault: (row['is_default'] as int? ?? 0) == 1,
      region: row['region'] as String?,
      province: row['province'] as String?,
      cityOrMunicipality: row['city_or_municipality'] as String?,
      barangay: row['barangay'] as String?,
      street: row['street'] as String?,
    );
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();
}

class StoredUserProfile {
  const StoredUserProfile({
    required this.userEmail,
    this.displayName,
    this.phone,
    this.profileImagePath,
    this.addresses = const [],
  });

  final String userEmail;
  final String? displayName;
  final String? phone;
  final String? profileImagePath;
  final List<Address> addresses;
}
