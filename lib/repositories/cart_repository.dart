import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/cart_item.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import 'firestore_mappers.dart';
import 'firestore_paths.dart';

class CartRepository {
  CartRepository({
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

  Future<List<CartItem>> loadLocalCart() => _databaseService.getCartItems();

  Future<List<CartItem>> syncFromRemote(firebase_auth.User authUser) async {
    final snapshot = await _firestore
        .collection('${FirestorePaths.user(authUser.uid)}/cart')
        .get();
    final items = snapshot.docs
        .map((doc) => FirestoreMappers.cartItemFromFirestore(doc.data()))
        .toList(growable: false);

    await _databaseService.replaceCartItems(items);

    return items;
  }

  Future<void> replaceCartForUser({
    required firebase_auth.User authUser,
    required List<CartItem> items,
  }) async {
    await _databaseService.replaceCartItems(items);

    final desiredIds = items
        .map(FirestoreMappers.cartDocumentId)
        .toSet();

    try {
      final remoteSnapshot = await _firestore
          .collection('${FirestorePaths.user(authUser.uid)}/cart')
          .get();
      for (final document in remoteSnapshot.docs) {
        if (!desiredIds.contains(document.id)) {
          await _syncService.writeThroughDelete(
            documentPath: FirestorePaths.cart(authUser.uid, document.id),
            userUid: authUser.uid,
          );
        }
      }
    } catch (_) {}

    for (final item in items) {
      final documentId = FirestoreMappers.cartDocumentId(item);
      await _syncService.writeThroughSet(
        documentPath: FirestorePaths.cart(authUser.uid, documentId),
        data: FirestoreMappers.cartDocument(item, userId: authUser.uid),
        userUid: authUser.uid,
      );
    }
  }

  Future<void> clearCartForUser(firebase_auth.User authUser) async {
    final localItems = await _databaseService.getCartItems();
    await _databaseService.clearCart();

    for (final item in localItems) {
      await _syncService.writeThroughDelete(
        documentPath: FirestorePaths.cart(
          authUser.uid,
          FirestoreMappers.cartDocumentId(item),
        ),
        userUid: authUser.uid,
      );
    }
  }
}
