import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/database_service.dart';
import '../services/local_to_firestore_migration_service.dart';
import '../services/sync_service.dart';
import 'cart_repository.dart';
import 'order_repository.dart';
import 'product_repository.dart';
import 'user_profile_repository.dart';

class AppRepositories {
  AppRepositories({
    FirebaseFirestore? firestore,
    DatabaseService? databaseService,
  }) : firestore = firestore ?? FirebaseFirestore.instance,
       databaseService = databaseService ?? DatabaseService.instance,
       syncService = SyncService(
         firestore: firestore ?? FirebaseFirestore.instance,
         databaseService: databaseService ?? DatabaseService.instance,
       ),
       productRepository = ProductRepository(
         firestore: firestore ?? FirebaseFirestore.instance,
       ),
       userProfileRepository = UserProfileRepository(
         firestore: firestore ?? FirebaseFirestore.instance,
         databaseService: databaseService ?? DatabaseService.instance,
         syncService: SyncService(
           firestore: firestore ?? FirebaseFirestore.instance,
           databaseService: databaseService ?? DatabaseService.instance,
         ),
       ),
       cartRepository = CartRepository(
         firestore: firestore ?? FirebaseFirestore.instance,
         databaseService: databaseService ?? DatabaseService.instance,
         syncService: SyncService(
           firestore: firestore ?? FirebaseFirestore.instance,
           databaseService: databaseService ?? DatabaseService.instance,
         ),
       ),
       orderRepository = OrderRepository(
         firestore: firestore ?? FirebaseFirestore.instance,
         databaseService: databaseService ?? DatabaseService.instance,
         syncService: SyncService(
           firestore: firestore ?? FirebaseFirestore.instance,
           databaseService: databaseService ?? DatabaseService.instance,
         ),
       ),
       migrationService = LocalToFirestoreMigrationService(
         firestore: firestore ?? FirebaseFirestore.instance,
         databaseService: databaseService ?? DatabaseService.instance,
       );

  final FirebaseFirestore firestore;
  final DatabaseService databaseService;
  final SyncService syncService;
  final ProductRepository productRepository;
  final UserProfileRepository userProfileRepository;
  final CartRepository cartRepository;
  final OrderRepository orderRepository;
  final LocalToFirestoreMigrationService migrationService;
}
