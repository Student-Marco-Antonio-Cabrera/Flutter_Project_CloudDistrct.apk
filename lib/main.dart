import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // ← ADDED
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/user_profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // ← ADDED
    );
  } catch (error) {
    debugPrint('Firebase initialization skipped: $error');
  }

  final prefs = await SharedPreferences.getInstance();
  final authCubit = AuthProvider(prefs);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authCubit),
        BlocProvider(create: (_) => CartProvider(prefs)),
        BlocProvider(create: (_) => OrderProvider(prefs)),
        BlocProvider(create: (_) => AppSettingsProvider(prefs)),
        BlocProvider(create: (_) => UserProfileProvider(prefs, authCubit)),
      ],
      child: const App(),
    ),
  );
}