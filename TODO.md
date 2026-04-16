# Fix App Stuck on Loading - Approved Plan

Status: In Progress

## Detailed Steps from Plan:

1. **Add logging/error handling in main.dart**
   - Wrap Firebase.initializeApp()
   - Wrap DatabaseService.instance.init()
   - Wrap SharedPreferences.getInstance()
   - Wrap repositories.productRepository.seedRemoteCatalogIfEmpty()
   - Wrap AppSyncBootstrap.start()
   - Use debugPrint for success/error, rethrow errors.

2. **Update SplashScreen to wait dynamically**
   - Use BlocListener on AuthProvider to detect when auth state stable.
   - Fallback Timer(5s)
   - Show error Text if auth.errorMessage

3. **Rebuild and test**
   - flutter clean && flutter pub get && flutter build apk --debug
   - Install and test with flutter logs

## Current Progress:
- [x] Created this TODO.md
- [x] Edit lib/main.dart - logging added to all init steps.

[x] 2. Update lib/screens/splash_screen.dart - dynamic wait + error display.

Ready for rebuild and test:
- Run `cd c:/flutter/Flutter_Project_CloudDistrict_SQFLITE.apk` (if not)
- `flutter clean && flutter pub get && flutter build apk --debug`
- Connect phone USB, `flutter devices` confirm, `flutter install`
- `flutter logs` in another terminal, open app, reproduce stuck, check logs for "INIT:" lines or errors.
- Share logs if still issues.

