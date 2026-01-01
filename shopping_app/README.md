# ShopEase 🛍️

ShopEase is a modern, feature-rich E-commerce mobile application built with Flutter and Firebase. It provides a seamless shopping experience with real-time updates, secure authentication, and an intuitive user interface.

## ✨ Features

- **User Authentication**: Secure sign-in and registration using Firebase Authentication (Email/Password & Google Sign-In).
- **Product Catalog**: Browse a wide range of products with detailed descriptions and high-quality images.
- **Cart Management**: Add, remove, and manage items in your shopping cart with real-time total calculation.
- **Favorites**: Save your favorite items to a personalized wishlist for quick access.
- **Orders Tracking**: View and manage your previous orders.
- **Push Notifications**: Stay updated with the latest offers and order status.
- **Responsive Design**: optimized for various screen sizes and orientations.

## 🚀 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (3.7.0+)
- **Backend/Database**: [Firebase](https://firebase.google.com/) (Firestore, Storage, Auth)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Storage**: [SharedPreferences](https://pub.dev/packages/shared_preferences)
- **Styling**: Material 18 & Custom Lato Typography

## 🛠️ Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code
- A Firebase Project

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/MahiderAb/ShopEase.git
   cd ShopEase/shopping_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Create a new project in the [Firebase Console](https://console.firebase.google.com/).
   - Add Android/iOS apps to your Firebase project.
   - Run `flutterfire configure` to set up your Firebase environment.

4. **Run the application**:
   ```bash
   flutter run
   ```

## 📂 Project Structure

```text
lib/
├── main.dart             # Application entry point & configuration
├── global_variables.dart # Global constants and mock data
├── firebase_options.dart # Firebase generated configuration
├── page/                 # UI screens and business logic
│   ├── auth_service.dart     # Firebase Auth integration
│   ├── cart_provider.dart    # Cart state management
│   ├── favorites_provider.dart # Wishlist state management
│   └── ...                   # Various screens (login, profile, product lists)
├── screens/              # Additional screen components (e.g., Splash)
└── service/              # Utility services
```

## 🛡️ License

This project is for educational purposes. All rights reserved.
