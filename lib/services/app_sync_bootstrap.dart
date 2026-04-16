import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../repositories/cart_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/user_profile_repository.dart';
import 'local_to_firestore_migration_service.dart';
import 'sync_service.dart';

class AppSyncBootstrap {
  AppSyncBootstrap({
    firebase_auth.FirebaseAuth? auth,
    required SyncService syncService,
    required LocalToFirestoreMigrationService migrationService,
    required UserProfileRepository userProfileRepository,
    required CartRepository cartRepository,
    required OrderRepository orderRepository,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _syncService = syncService,
       _migrationService = migrationService,
       _userProfileRepository = userProfileRepository,
       _cartRepository = cartRepository,
       _orderRepository = orderRepository;

  final firebase_auth.FirebaseAuth _auth;
  final SyncService _syncService;
  final LocalToFirestoreMigrationService _migrationService;
  final UserProfileRepository _userProfileRepository;
  final CartRepository _cartRepository;
  final OrderRepository _orderRepository;
  final Set<String> _activeSyncUsers = <String>{};

  StreamSubscription<firebase_auth.User?>? _authSubscription;

  void start() {
    if (_authSubscription != null) {
      return;
    }

    _authSubscription = _auth.authStateChanges().listen((authUser) {
      if (authUser == null) {
        return;
      }
      unawaited(_syncSignedInUser(authUser));
    });
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    _authSubscription = null;
  }

  Future<void> _syncSignedInUser(firebase_auth.User authUser) async {
    if (!_activeSyncUsers.add(authUser.uid)) {
      return;
    }

    try {
      await _migrationService.migrateCurrentUser(authUser);
      await _syncService.flushPendingOperations(userUid: authUser.uid);
      await _userProfileRepository.syncFromRemote(authUser);
      await _cartRepository.syncFromRemote(authUser);
      await _orderRepository.syncFromRemote(authUser);
    } catch (_) {
      // Startup sync is best-effort so the existing local-first UX keeps working.
    } finally {
      _activeSyncUsers.remove(authUser.uid);
    }
  }
}
