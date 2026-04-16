import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/order.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import 'firestore_mappers.dart';
import 'firestore_paths.dart';

class OrderRepository {
  OrderRepository({
    FirebaseFirestore? firestore,
    DatabaseService? databaseService,
    SyncService? syncService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _databaseService = databaseService ?? DatabaseService.instance,
       _syncService =
           syncService ??
           SyncService(
             firestore: firestore,
             databaseService: databaseService,
           );

  final FirebaseFirestore _firestore;
  final DatabaseService _databaseService;
  final SyncService _syncService;

  Future<List<Order>> loadLocalOrders() => _databaseService.getOrders();

  Future<List<Order>> syncFromRemote(firebase_auth.User authUser) async {
    final snapshot = await _firestore
        .collection('${FirestorePaths.user(authUser.uid)}/orders')
        .orderBy('createdAt', descending: true)
        .get();

    final orders = snapshot.docs
        .map(
          (doc) => FirestoreMappers.orderFromFirestore(
            doc.data(),
            documentId: doc.id,
          ),
        )
        .toList(growable: false);

    for (final order in orders) {
      await _databaseService.insertOrder(order);
    }

    return orders;
  }

  Future<void> saveOrder({
    required firebase_auth.User authUser,
    required Order order,
  }) async {
    await _databaseService.insertOrder(order);
    await _syncService.writeThroughSet(
      documentPath: FirestorePaths.order(authUser.uid, order.id),
      data: FirestoreMappers.orderDocument(order, userId: authUser.uid),
      userUid: authUser.uid,
    );
  }

  Future<void> updateOrderStatus({
    required firebase_auth.User authUser,
    required String orderId,
    required OrderStatus status,
  }) async {
    await _databaseService.updateOrderStatus(orderId, status);
    await _syncService.writeThroughUpdate(
      documentPath: FirestorePaths.order(authUser.uid, orderId),
      data: {
        'status': status.name,
        'updatedAt': DateTime.now().toUtc(),
      },
      userUid: authUser.uid,
    );
  }
}
