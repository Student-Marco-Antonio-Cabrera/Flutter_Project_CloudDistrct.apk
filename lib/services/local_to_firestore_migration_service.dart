import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../repositories/firestore_mappers.dart';
import '../repositories/firestore_paths.dart';
import 'database_service.dart';

class LocalToFirestoreMigrationService {
  LocalToFirestoreMigrationService({
    FirebaseFirestore? firestore,
    DatabaseService? databaseService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _databaseService = databaseService ?? DatabaseService.instance;

  final FirebaseFirestore _firestore;
  final DatabaseService _databaseService;

  Future<bool> migrateCurrentUser(firebase_auth.User authUser) async {
    final email = (authUser.email ?? '').trim().toLowerCase();
    if (email.isEmpty) {
      return false;
    }

    final userRef = _firestore.doc(FirestorePaths.user(authUser.uid));
    final migrationRef = _firestore.doc('${FirestorePaths.user(authUser.uid)}/meta/local_v1');
    final migrationSnapshot = await migrationRef.get();
    if (migrationSnapshot.data()?['status'] == 'completed') {
      return false;
    }

    await migrationRef.set({
      'status': 'running',
      'startedAt': DateTime.now().toUtc(),
    }, SetOptions(merge: true));

    try {
      final profile = await _databaseService.getUserProfile(email);
      final cartItems = await _databaseService.getCartItems();
      final orders = (await _databaseService.getOrders())
          .where((order) => order.customerEmail.trim().toLowerCase() == email)
          .toList(growable: false);

      final operationCount =
          2 + (profile?.addresses.length ?? 0) + cartItems.length + orders.length;
      if (operationCount > 450) {
        throw StateError(
          'Migration requires $operationCount Firestore writes. '
          'Chunking is not implemented in this scaffold yet.',
        );
      }

      final batch = _firestore.batch();

      batch.set(
        userRef,
        FirestoreMappers.userDocument(
          authUser: authUser,
          localProfile: profile,
        ),
        SetOptions(merge: true),
      );

      for (final address in profile?.addresses ?? const []) {
        batch.set(
          _firestore.doc(FirestorePaths.address(authUser.uid, address.id)),
          FirestoreMappers.addressDocument(address),
          SetOptions(merge: true),
        );
      }

      for (final item in cartItems) {
        batch.set(
          _firestore.doc(
            FirestorePaths.cart(
              authUser.uid,
              FirestoreMappers.cartDocumentId(item),
            ),
          ),
          FirestoreMappers.cartDocument(item, userId: authUser.uid),
          SetOptions(merge: true),
        );
      }

      for (final order in orders) {
        batch.set(
          _firestore.doc(FirestorePaths.order(authUser.uid, order.id)),
          FirestoreMappers.orderDocument(order, userId: authUser.uid),
          SetOptions(merge: true),
        );
      }

      batch.set(
        migrationRef,
        {
          'status': 'completed',
          'completedAt': DateTime.now().toUtc(),
          'addressCount': profile?.addresses.length ?? 0,
          'cartCount': cartItems.length,
          'orderCount': orders.length,
        },
        SetOptions(merge: true),
      );

      await batch.commit();
      return true;
    } catch (error) {
      await migrationRef.set({
        'status': 'failed',
        'failedAt': DateTime.now().toUtc(),
        'error': error.toString(),
      }, SetOptions(merge: true));
      rethrow;
    }
  }
}
