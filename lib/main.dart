import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app.dart';
import 'data/products.dart';
import 'firebase_options.dart';
import 'providers/app_settings_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/user_profile_provider.dart';
import 'repositories/app_repositories.dart';
import 'services/app_sync_bootstrap.dart';
import 'services/database_service.dart';

late final AppSyncBootstrap _appSyncBootstrap;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _configureDatabaseFactory();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('INIT: Firebase initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('INIT: Firebase init FAILED: $e');
    debugPrint('Stack trace: $stackTrace');
    // Rethrow to see in logs
    rethrow;
  }

  try {
    await DatabaseService.instance.init();
    debugPrint('INIT: Database OK');
  } catch (e, stackTrace) {
    debugPrint('INIT: Database FAILED: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
  late SharedPreferences prefs;
  try {
    prefs = await SharedPreferences.getInstance();
    debugPrint('INIT: SharedPreferences OK');
  } catch (e, stackTrace) {
    debugPrint('INIT: SharedPreferences FAILED: $e');
    debugPrint('Stack trace: $stackTrace');
    prefs = await SharedPreferences.getInstance(); // force second try
  }
  debugPrint('INIT: SharedPreferences ready');
  final repositories = AppRepositories(
    databaseService: DatabaseService.instance,
  );

  // Auto-seed products to Firestore if empty (runs once)
  try {
    await repositories.productRepository.seedRemoteCatalogIfEmpty();
    debugPrint('INIT: Product seeding OK');
  } catch (e, stackTrace) {
    debugPrint('INIT: Product seeding FAILED: $e');
    debugPrint('Stack trace: $stackTrace');
    // Don't rethrow, best-effort
  }

  // AuthProvider will automatically listen to Firebase auth changes
  final authCubit = AuthProvider(prefs);
  _appSyncBootstrap = AppSyncBootstrap(
    syncService: repositories.syncService,
    migrationService: repositories.migrationService,
    userProfileRepository: repositories.userProfileRepository,
    cartRepository: repositories.cartRepository,
    orderRepository: repositories.orderRepository,
  );
  try {
    _appSyncBootstrap.start();
    debugPrint('INIT: AppSyncBootstrap started');
  } catch (e, stackTrace) {
    debugPrint('INIT: AppSyncBootstrap FAILED: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: repositories.databaseService),
        RepositoryProvider.value(value: repositories.syncService),
        RepositoryProvider.value(value: repositories.productRepository),
        RepositoryProvider.value(value: repositories.userProfileRepository),
        RepositoryProvider.value(value: repositories.cartRepository),
        RepositoryProvider.value(value: repositories.orderRepository),
        RepositoryProvider.value(value: repositories.migrationService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authCubit),
          BlocProvider(create: (_) => CartProvider(prefs)),
          BlocProvider(create: (_) => OrderProvider(prefs)),
          BlocProvider(create: (_) => AppSettingsProvider(prefs)),
          BlocProvider(create: (_) => UserProfileProvider(prefs, authCubit)),
        ],
        child: const App(),
      ),
    ),
  );
}

void _configureDatabaseFactory() {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
