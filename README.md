# Cloud District - E-Commerce App

A Flutter-based e-commerce application for browsing and purchasing vape products. The app features user authentication, product catalog, shopping cart, and user profile management.

 Overview

Cloud District is built using Flutter, a cross-platform mobile framework. The application provides a complete shopping experience with authentication, product browsing, cart management, checkout process, and user profile functionality. All user data is saved locally on the device, so the app works smoothly even without internet connection for cached data.

 How the App Was Built

 Architecture Approach

The app follows a layered architecture pattern with clear separation of concerns:

1. Presentation Layer (Screens)
The user interface is divided into separate screen files that handle different parts of the app. Each screen is responsible for displaying data and capturing user interactions. Screens include:
- Splash screen for app initialization
- Login and registration screens for authentication
- Home screen for product browsing
- Cart screen for shopping cart management
- Profile screens for user information
- Checkout screens for payment process

2. State Management Layer (Providers)
Instead of managing data directly in screens, the app uses providers to handle all state changes. Each provider manages a specific part of the application state:
- Authentication provider handles login and user sessions
- Cart provider manages shopping cart operations
- App settings provider stores user preferences like theme selection
- User profile provider manages user information and addresses

When data in a provider changes, it automatically updates all screens that are watching that data. This prevents having to pass data between screens manually.

3. Data Layer (Models)
Data is structured using model classes that represent real-world objects like products, users, and cart items. These models define what information each object contains and how it can be converted to and from stored format.

4. Persistence Layer
User data is saved locally using SharedPreferences, a simple key-value storage system. This allows user sessions, shopping cart, and preferences to persist even after closing the app.

 Design System

The app uses Material Design 3, Google's latest design standard. A custom theme file defines all colors, typography, button styles, and other visual elements. The design system includes:
- Violet color as primary accent
- Blue color as secondary accent
- Dark theme support for night mode
- Consistent component styling across the entire app
- Gradient backgrounds for visual appeal

 Navigation

The app uses named routes for navigation. Instead of directly instantiating screens, screens are registered with route names, and navigation happens by pushing route names onto the navigation stack. This makes the app structure clearer and navigation more predictable.

 Packages Used

 Core Framework
flutter- The main framework for building the user interface. Provides all the basic UI widgets and tools needed to create mobile applications. Everything visual in the app comes from Flutter widgets.

 State Management
provider 6.1.2 - This package provides a straightforward way to manage application state. Instead of having data scattered throughout the app, Provider centralizes state in objects called providers. When data changes in a provider, all widgets watching that provider automatically rebuild with the new data. This eliminates the need for complex state passing between screens.

 Data Storage
shared_preferences 2.2.3 - This package provides simple local storage for the device. It's like a basic database that stores key-value pairs. The app uses it to save user login tokens, shopping cart items, and theme preferences. Data saved with SharedPreferences persists even after the app closes.

Image Handling
image_picker 1.0.7 - This package provides access to the device's image gallery and camera. The app uses it to allow users to pick profile pictures or upload images. It handles the complexity of accessing device photos on different platforms (Android, iOS, Web).

Authentication
google_sign_in 6.2.2 - This package enables users to sign in using their Google account. Instead of creating a separate password for the app, users can use their existing Google credentials for authentication.

flutter_facebook_auth 7.0.0 - This package enables Facebook login. Similar to Google Sign In, it allows users to authenticate using their Facebook account.

 Development Tools
flutter_test - Testing framework included with Flutter. Allows writing tests to verify that the app works correctly.

flutter_lints 6.0.0 - A set of code quality rules that help maintain clean and consistent code style across the project.

 Project Structure

```
lib/
  main.dart                    - Entry point, initializes providers
  app.dart                     - App configuration and routes
  
  screens/                     - User interface pages
    home_screen.dart
    login_screen.dart
    cart_screen.dart
    profile_screen.dart
    ... (other screens)
  
  providers/                   - State management
    auth_provider.dart
    cart_provider.dart
    app_settings_provider.dart
    user_profile_provider.dart
  
  widgets/                     - Reusable UI components
    product_card.dart
    gradient_scaffold.dart
    cart_tile.dart
    ... (other widgets)
  
  models/                      - Data structures
    product.dart
    user.dart
    cart_item.dart
    address.dart
  
  theme/                       - Design system
    app_theme.dart
  
  data/                        - Static data
    products.dart
```

App Flow

When users open the app, they are first shown a splash screen that checks if they are already logged in. If not, they see the login page. After logging in, they go to the home screen where they can browse products. They can add products to their cart, view their cart, and proceed to checkout. The app saves their cart and profile information locally, so when they close and reopen the app, their data is still there.

 How to Run the App

 Prerequisites
- Flutter SDK version 3.11.0 or higher
- Dart programming language (comes with Flutter)

 Running the Application

1. Open a terminal in the project directory

2. Install dependencies by running:
   ```
   flutter pub get
   ```

3. Run the app on a device or emulator:
   ```
   flutter run
   ```

4. To build for specific platforms:
   - Android: flutter build apk
   - iOS: flutter build ios
   - Web: flutter build web

 Summary

The Cloud District app demonstrates modern mobile app development practices by using proper state management, local data persistence, and clean architecture patterns. The use of established packages like Provider and SharedPreferences makes the codebase maintainable and scalable. All components work together to create a smooth shopping experience with responsive UI and reliable data handling.
