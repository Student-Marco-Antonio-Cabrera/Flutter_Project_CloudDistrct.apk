# Cloud District - Flutter E-Commerce App

Cloud District is a Flutter vape shop app with a full shopping flow:
login/register, browse products, add to cart, checkout, and track orders.

This README is written for users and new developers who want to understand
the app quickly without digging deep into the code.

## App Summary

- Built with Flutter + `flutter_bloc` (Cubit pattern).
- Works as a local-first app (data is saved on device using `shared_preferences`).
- Firebase is initialized and ready for backend expansion.
- Includes security features like password change and demo 2FA flow.

## What Users Can Do

- Sign in with email/password, Google, or Facebook.
- Accept Terms and Conditions before login/register.
- Browse products and open detailed product pages.
- Add products to cart, change quantity/flavor, and checkout.
- Use promo codes: `VAPE10`, `SAVE100`, `FREESHIP`.
- View order history and track order status.
- Edit profile, profile photo, and saved addresses.
- Use privacy/security settings (password and 2FA controls).

## Sample Codes (Demo)

### Checkout promo codes

Use these in the promo code field on checkout:

- `VAPE10` -> 10% off item subtotal
- `SAVE100` -> flat `PHP 100` off
- `FREESHIP` -> shipping fee discount (shipping becomes free)

How promo codes work:

- Input is normalized to uppercase before validation.
- Any code outside the three above is rejected as invalid.
- Only one promo code is applied at a time.

### 2FA verification codes

2FA codes are demo-generated and not fixed/hardcoded:

- During 2FA setup (Privacy & Security), the app shows a generated 6-digit `Demo verification code`.
- During login for accounts with 2FA enabled, the app shows a generated 6-digit `Demo code`.
- Each generated code expires after 5 minutes.
- Entering the exact active code completes setup or login verification.

## How the App Was Developed (Simple Version)

1. Foundation setup:
   - Created the Flutter app shell, app theme, routing, and startup logic.
   - Wired dependencies in one place (`main.dart`) using `MultiBlocProvider`.
2. Core shopping flow first:
   - Built the main path: `Splash -> Auth -> Home -> Cart -> Checkout -> Thank You`.
3. State management by feature:
   - Added one Cubit per domain (`Auth`, `Cart`, `Order`, `Profile`, `Settings`).
4. Local persistence:
   - Saved cart, orders, session, and profile locally with `shared_preferences`.
5. Security and account improvements:
   - Added social login, password change, and demo 2FA verification flow.
6. UI and UX refinements:
   - Added reusable widgets, better feedback messages, and clear order tracking.
7. Backend-ready preparation:
   - Initialized Firebase and included Firebase packages for future cloud sync.

## How the UI Was Created

- A shared design system is defined in `lib/theme/app_theme.dart`.
- Most screens use `GradientScaffold` for consistent layout/background.
- UI is built from reusable widgets to avoid repeated code:
  - `ProductCard`, `CartTile`, `SocialSignInButtons`, `TocCheckbox`, etc.
- Screens are feature-based (`login`, `home`, `cart`, `buy`, `profile`, `orders`).
- Light and dark themes are both supported.

## How the UX Was Created

- Designed around one clear journey: browse -> cart -> checkout -> tracking.
- Reduced friction with guest checkout and prefilled profile/address data.
- Broke checkout into clear sections (identity, address, shipping, payment, summary).
- Added immediate feedback (SnackBars, status pills, tracking timeline).
- Improved trust with Terms acceptance and privacy/security controls.
- Added clear post-purchase next steps: show order ID and jump to tracking.

## Runtime App Flow

1. `SplashScreen` checks login state.
2. User goes to `Login/Register` or directly to `Home`.
3. User browses product catalog and adds items to cart.
4. User reviews cart and proceeds to `BuyScreen` checkout.
5. Order is created and stored locally.
6. `ThankYouScreen` shows confirmation and order ID.
7. User can open `MyOrdersScreen` for history and tracking.

## Code Structure (Where to Look)

```text
lib/
  main.dart                # App startup, Firebase init, MultiBlocProvider
  app.dart                 # MaterialApp routes and app-level config
  firebase_options.dart    # FlutterFire generated options

  screens/                 # UI pages
  providers/               # Cubits (business logic + state)
  models/                  # Data models (product, order, address, etc.)
  services/                # Integration/helper services
  widgets/                 # Reusable UI components
  data/                    # Local mock data (products)
  theme/                   # Global app theme
```

### Quick guide for contributors

- Want to change login behavior? Edit `lib/providers/auth_provider.dart` and auth screens.
- Want to change checkout/order logic? Edit `lib/screens/buy_screen.dart` and `lib/providers/order_provider.dart`.
- Want to change cart behavior? Edit `lib/providers/cart_provider.dart` and `lib/screens/cart_screen.dart`.
- Want to change colors/fonts/inputs/buttons? Edit `lib/theme/app_theme.dart`.

## Getting Started

### Requirements

- Flutter SDK (Dart `^3.11.0` or newer)
- Android Studio or VS Code with Flutter extensions
- Emulator/simulator or real device

### Install and run

```bash
flutter pub get
flutter run
```

## Build Commands

```bash
# Android
flutter build apk
flutter build appbundle

# iOS / macOS
flutter build ios
flutter build macos

# Web / Windows / Linux
flutter build web
flutter build windows
flutter build linux
```

## Quality Checks

```bash
flutter analyze
flutter test
```

## Firebase and Social Auth Notes

- Firebase config is included in `lib/firebase_options.dart`.
- Android Firebase file exists: `android/app/google-services.json`.
- iOS/macOS Firebase plist files are not present in this repo:
  - `ios/Runner/GoogleService-Info.plist`
  - `macos/Runner/GoogleService-Info.plist`
- Core app data currently stays local (cart/orders/profile/session).
- Firebase/Auth/Firestore/Storage packages are included for future backend use.

## Current Limitations

- Product catalog uses local mock data (`lib/data/products.dart`).
- Order status advance in tracking is demo-oriented.
- Addresses use bundled local Catanduanes address dataset.
- No remote live sync for orders/profile yet.