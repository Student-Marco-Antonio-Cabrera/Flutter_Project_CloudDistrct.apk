# Cloud District

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-vapeshop--ecommerce-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Cloud District is a Flutter e-commerce application built as a capstone and portfolio-ready project for a vape and lifestyle storefront. The app combines a polished mobile shopping experience with offline-friendly local storage, Firebase authentication, Cubit-based state management, themed UI, and a complete order flow from catalog browsing to checkout and delivery tracking.

This repository reflects both the final application state and the major development milestones that shaped it, including UI/UX improvements, authentication fixes, address-form stability work, order-tracking enhancements, platform compatibility fixes, and the later migration from simple key-value persistence to a structured `sqflite` offline database.

## Table of Contents

- [App Overview](#app-overview)
- [Screenshots](#screenshots)
- [Feature Highlights](#feature-highlights)
- [Architecture and Tech Stack](#architecture-and-tech-stack)
- [Project Structure](#project-structure)
- [Development Log](#development-log)
- [Dependencies](#dependencies)
- [Setup and Installation](#setup-and-installation)
- [Known Issues and Limitations](#known-issues-and-limitations)
- [License](#license)

## App Overview

Cloud District was designed as a modern Flutter storefront experience with strong emphasis on:

- clean product browsing and product-detail interactions
- responsive cart and checkout flows
- local-first persistence for essential user data
- Firebase-powered authentication
- reusable components and maintainable state management
- presentation quality suitable for a college capstone or public portfolio

Project Snapshot

| Item | Details |
| --- | --- |
| App name | Cloud District |
| Package name | `com.example.vapeshop` |
| Firebase project | `vapeshop-ecommerce` |
| Platform targets | Android, Windows |
| Language | Dart |
| Framework | Flutter |
| State management | BLoC / Cubit |
| Authentication | Firebase Auth, Google Sign-In, Facebook Login |
| Local persistence | `sqflite` for cart, orders, profile, and addresses; `SharedPreferences` for auth/session flags, settings, and legacy migration |
| Typography | Montserrat via `google_fonts` |
| Theme support | Light mode and dark mode |

### Application Scope

The application includes a full e-commerce flow for a vape shop experience:

- product catalog browsing
- product details with flavor selection and quantity control
- add-to-cart and cart management
- checkout with payment and shipping options
- order placement, order history, and delivery tracking
- profile editing and local profile image selection
- address book management using cascading Philippine address data
- Firebase-backed email/password and social authentication

## Screenshots

Add screenshots or short GIF demos to the paths below for a polished GitHub presentation.

| Screen | Suggested Asset |
| --- | --- |
| Splash / Login | `docs/screenshots/login.png` |
| Home / Product Catalog | `docs/screenshots/home.png` |
| Product Details | `docs/screenshots/product-details.png` |
| Cart / Checkout | `docs/screenshots/cart-checkout.png` |
| Profile / Addresses | `docs/screenshots/profile-addresses.png` |
| My Orders / Tracking | `docs/screenshots/my-orders.png` |

Example placeholder:

```text
docs/
  screenshots/
    login.png
    home.png
    product-details.png
    cart-checkout.png
    profile-addresses.png
    my-orders.png
```

## Feature Highlights

### Shopping Experience

- Product listing screen with reusable product cards
- Product details screen with flavor or variant selection
- Quantity stepper with live subtotal calculation
- Sticky bottom "Add to Cart" action bar
- Cart icon badge on the product details screen with live item count
- Snackbar feedback with a quick "View Cart" action
- Shopping cart with swipe-to-delete support and confirmation dialog

### Checkout and Orders

- Checkout flow with payment method selection
- Shipping method selection
- Delivery address selection
- Order placement summary with subtotal, shipping fee, discount, and total
- Order history tab for previously placed orders
- Track Order tab with timeline UI
- Five order statuses:
  - Placed
  - Preparing
  - Shipped
  - Out for Delivery
  - Delivered
- Color-coded status pills and timeline indicators
- Demo advance button for progressing orders during testing or presentation

### User Profile and Address Book

- Profile screen with editable display name and phone number
- Local profile image selection via image picker
- Dedicated profile edit screen
- Address book CRUD operations
- Cascading Philippine address dropdowns:
  - Region
  - Province
  - City or Municipality
  - Barangay
- Address source loaded from local JSON asset for offline usability
- Default address management

### Authentication and App Experience

- Firebase Auth integration
- Email and password sign-in
- Google Sign-In
- Facebook Login
- Auth loading states with disabled social buttons and inline progress indicators
- Password visibility toggle on the login screen
- Themed UI with Montserrat typography in both light and dark mode
- Floating dismissible snackbars configured globally in the app theme

### Offline Data and Maintainability

- Cubit-based providers for cart, orders, authentication, profile, and settings
- Structured offline persistence through a centralized `DatabaseService` singleton
- Async CRUD operations across cart, orders, user profile, and address records
- Database versioning and upgrade hooks via `onUpgrade`
- Reusable widgets for shared UI patterns such as branded scaffolds, form fields, checkboxes, and cards

## Architecture and Tech Stack

### High-Level Architecture

The app follows a layered Flutter structure:

```text
UI Screens and Widgets
        |
     Cubit / Providers
        |
  Services and Data Layer
        |
Firebase Auth + Local Storage
```

### State Management

- `AuthProvider` handles login, registration, social auth, and related auth state
- `CartProvider` manages cart contents and totals
- `OrderProvider` manages order creation, history, and status progression
- `UserProfileProvider` manages profile details and addresses
- `AppSettingsProvider` manages app-level preferences such as theme mode

### Data Layer Evolution

Cloud District originally used `SharedPreferences` for cart and profile persistence. As the project grew, the local storage layer was upgraded to `sqflite` to support:

- normalized cart storage
- local order history with order-item records
- user profile persistence
- address storage with better structure and future scalability
- database versioning and migration support

`SharedPreferences` is still used for lightweight app/session data such as settings and auth-related local flags.

## Project Structure

```text
lib/
  app.dart
  main.dart
  firebase_options.dart
  data/
    products.dart
  models/
    address.dart
    cart_item.dart
    order.dart
    product.dart
    user.dart
  providers/
    app_settings_provider.dart
    auth_provider.dart
    cart_provider.dart
    order_provider.dart
    user_profile_provider.dart
  screens/
    addresses_screen.dart
    buy_screen.dart
    cart_screen.dart
    home_screen.dart
    login_screen.dart
    my_orders_screen.dart
    privacy_settings_screen.dart
    product_details_screen.dart
    profile_edit_screen.dart
    profile_screen.dart
    register_screen.dart
    splash_screen.dart
    thank_you_screen.dart
    toc_screen.dart
  services/
    address_service.dart
    database_service.dart
    social_auth_service.dart
  theme/
    app_theme.dart
  widgets/
    app_footer.dart
    app_logo.dart
    cart_tile.dart
    email_field.dart
    gradient_scaffold.dart
    password_field.dart
    product_card.dart
    social_sign_in_buttons.dart
    toc_checkbox.dart
    vape_shop_logo_image.dart

assets/
  data/
    catanduanes_addresses.json
  icon/
    logo.jpg
  images/
    products/
```

## Development Log

This section documents the major features, fixes, and improvements delivered during development.

### 1. Initial App Foundation

- Set up the Flutter application structure for a vape shop storefront concept.
- Organized the codebase into `models`, `providers`, `screens`, `services`, `widgets`, `theme`, and `data`.
- Established a Cubit-based state-management pattern for maintainability and predictable UI updates.
- Added support for Android and Windows builds.

### 2. UI Branding and Theme Improvements

- Integrated Montserrat using `google_fonts` and applied it consistently in `app_theme.dart` for both light and dark themes.
- Added a global floating snackbar configuration so notifications feel less intrusive and more polished.
- Standardized the visual style through reusable theme settings, elevated buttons, cards, form fields, and branded gradients.

### 3. Catalog, Product Details, and Cart Experience

- Built the product listing flow using reusable product-card widgets.
- Added a product details screen with flavor or variant selection.
- Implemented quantity controls and a running subtotal for clearer purchase feedback.
- Added a sticky bottom action area for "Add to Cart" to keep the primary action accessible.
- Added a snackbar with a "View Cart" shortcut after adding an item.
- Added a cart icon with a live count badge in the product-details AppBar.
- Removed the shadow or dark overlay from the sticky add-to-cart bar for a cleaner appearance.
- Implemented cart persistence so users can leave and return without losing items.
- Added swipe-to-delete behavior with an `AlertDialog` confirmation step to prevent accidental removals.

### 4. Checkout and Order Flow

- Implemented a checkout screen with payment method selection.
- Added shipping method options and delivery address selection.
- Added order creation with subtotal, shipping fee, discount, and total calculations.
- Built order history so users can revisit previous purchases.
- Built order tracking with a timeline-based delivery status display.
- Reworked the My Orders screen into a more complete tabbed interface with:
  - Order History
  - Track Order
- Added color-coded status pills for quick visual scanning.
- Added order selector support for tracking a chosen order.
- Added a demo advance button to help present or test order status transitions.

### 5. Order Status Logic Fixes

- Corrected `OrderStatus` values to match the real workflow:
  - `placed`
  - `preparing`
  - `shipped`
  - `outForDelivery`
  - `delivered`
- Removed logic tied to outdated or unreachable enum values such as `pending` and `confirmed`.
- Cleaned up unreachable default clauses in related switch logic.

### 6. Profile and Address Management

- Added a user profile screen and dedicated profile edit screen.
- Supported editing of display name and phone number.
- Added profile photo selection using `image_picker`.
- Added address management for creating, editing, deleting, and setting default addresses.
- Integrated cascading Philippine address dropdowns driven by `assets/data/catanduanes_addresses.json`.
- Fixed address form state loss by moving the bottom-sheet form logic out of temporary local variables and into a dedicated stateful widget, ensuring text fields and dropdown selections survive rebuilds and keyboard events.

### 7. Authentication and Social Sign-In

- Integrated Firebase Auth for email and password authentication.
- Added Google Sign-In support.
- Added Facebook Login support.
- Added proper loading states to social sign-in buttons so users receive clear visual feedback and duplicate taps are prevented.
- Added password visibility toggle support on the login screen.
- Improved authentication flow resilience and user messaging during sign-in failures or cancellations.

### 8. Google Sign-In Compatibility Work

- During development, the project was pinned to `google_sign_in ^6.2.2` to avoid the breaking API changes introduced in version 7, especially the removal of the old constructor-and-sign-in flow.
- The current repository has since been updated to the newer API style using `GoogleSignIn.instance`, `initialize()`, and `authenticate()`, preserving the same user-facing Google login experience while aligning with newer package behavior.

### 9. Form and Widget Maintenance Fixes

- Replaced deprecated `DropdownButtonFormField.value` usage with `initialValue` where applicable.
- Updated `TocCheckbox` callback typing from `ValueChanged<bool?>` to `ValueChanged<bool?>?` so the widget can be disabled safely during loading states.
- Continued refactoring reusable widgets to keep forms and input flows more maintainable.

### 10. Platform and Build Compatibility Fixes

- Adjusted Android build configuration to reduce or silence obsolete Java source and target warnings in Gradle.
- Added `CMAKE_POLICY_VERSION_MINIMUM` to the Windows CMake configuration to address compatibility warnings when working with Firebase C++ SDK tooling.
- Continued aligning platform build files to improve reliability for classroom demos, portfolio presentation, and local development.

### 11. Local Persistence Upgrade to SQLite

- Added `sqflite` and `path` to support structured local database storage.
- Introduced a centralized `DatabaseService` singleton to handle:
  - database initialization
  - table creation
  - CRUD operations
  - versioning
  - migration hooks through `onUpgrade`
- Migrated cart persistence away from a single JSON blob in `SharedPreferences` to a normalized cart table.
- Added local order storage with dedicated order and order-item tables.
- Added local storage for user profile data and addresses.
- Preserved the existing Cubit/provider interfaces so the UI layer did not need to change.
- Kept all database work asynchronous to fit Flutter best practices and avoid blocking the UI thread.

## Dependencies

### Main Dependencies

| Package | Version | Purpose |
| --- | --- | --- |
| `flutter_bloc` | `^9.1.1` | Cubit/BLoC state management across authentication, cart, orders, profile, and settings |
| `firebase_core` | `^4.5.0` | Firebase initialization |
| `firebase_auth` | `^6.2.0` | Email/password and provider-based authentication |
| `cloud_firestore` | `^6.1.3` | Firebase backend data support and future cloud extension |
| `firebase_storage` | `^13.1.0` | Firebase storage support for future media or file workflows |
| `google_fonts` | `^8.0.2` | Montserrat typography integration |
| `google_sign_in` | `^7.2.0` | Google account authentication |
| `flutter_facebook_auth` | `^7.0.0` | Facebook Login integration |
| `image_picker` | `^1.0.7` | Profile image selection from device storage |
| `shared_preferences` | `^2.2.3` | Lightweight local settings, auth/session flags, and legacy persistence support |
| `sqflite` | `^2.3.0` | Structured offline database for cart, orders, profile, and addresses |
| `path` | `^1.9.0` | Local database path resolution |

### Development Dependencies

| Package | Version | Purpose |
| --- | --- | --- |
| `flutter_test` | SDK | Widget and unit testing |
| `flutter_lints` | `^6.0.0` | Linting and code-quality rules |
| `flutter_launcher_icons` | `^0.14.4` | App icon generation |

## Setup and Installation

### Prerequisites

- Flutter SDK installed and configured
- Dart SDK available through Flutter
- Android Studio or Visual Studio Code
- Firebase project access
- Android SDK and Windows desktop toolchain configured

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/cloud_district.git
cd cloud_district
```

### 2. Get Packages

```bash
flutter pub get
```

### 3. Configure Firebase

Use the Firebase project `vapeshop-ecommerce` or create an equivalent replacement.

- Add an Android app with package name `com.example.vapeshop`
- Enable Authentication providers:
  - Email/Password
  - Google
  - Facebook
- Download platform configuration files as needed
- Regenerate or replace `lib/firebase_options.dart` if your Firebase project differs

If you use FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### 4. Configure Social Sign-In Providers

For Google Sign-In:

- set up OAuth credentials in Firebase and the Google Cloud Console
- ensure the Android SHA keys are registered

For Facebook Login:

- create a Facebook app
- connect it to Firebase Authentication
- add the required app ID, client token, and platform-specific manifest or string resources

### 5. Run the App

For Android:

```bash
flutter run -d android
```

For Windows:

```bash
flutter run -d windows
```

### 6. Optional Release Preparation

- replace placeholder screenshots in the README
- update package name and app identifiers if needed
- verify Firebase config for release builds
- review icons, splash assets, and brand copy

## Known Issues and Limitations

- Product data is currently local and app-driven rather than managed from an admin dashboard.
- Cart, orders, profile, and addresses are stored locally on the device and are not automatically synced across multiple devices.
- `SharedPreferences` is still present for lightweight settings and auth/session state, even though major offline records now use `sqflite`.
- Social sign-in requires correct Firebase, Google, and Facebook configuration before it will work on physical devices.
- Profile image handling currently stores local file paths; a full cloud upload flow can be added later using Firebase Storage.
- Order status progression is demo-friendly and manually advanced in the current app flow rather than driven by a live fulfillment backend.
- Some Firebase-related dependencies are included for future scalability even if not all cloud features are fully wired yet.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

