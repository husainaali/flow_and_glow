# Flow and Glow

A Flutter app connecting wellness centers (Yoga, Meditation, Pilates, Nutrition) with customers.

## Features

### User Roles
- **Customer**: Browse and subscribe to wellness packages
- **Center Admin**: Manage center profile and packages
- **Super Admin**: Oversee entire platform

### Tech Stack
- Flutter (UI Framework)
- Firebase (Backend)
  - Authentication
  - Firestore (Database)
  - Storage (Images)
- Riverpod (State Management)

## Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Firebase

#### Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

#### Configure Firebase for your project
```bash
flutterfire configure
```

This will:
- Create a Firebase project (or select existing)
- Register your Flutter app
- Generate `firebase_options.dart`
- Download configuration files

### 3. Firebase Console Setup

Go to [Firebase Console](https://console.firebase.google.com/) and:

1. **Enable Authentication**
   - Go to Authentication → Sign-in method
   - Enable Email/Password

2. **Create Firestore Database**
   - Go to Firestore Database → Create database
   - Start in test mode (change rules later)

3. **Enable Storage**
   - Go to Storage → Get started
   - Start in test mode (change rules later)

4. **Firestore Security Rules** (Update after testing)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /centers/{centerId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /packages/{packageId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /subscriptions/{subscriptionId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 4. Run the App
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_model.dart
│   ├── center_model.dart
│   ├── package_model.dart
│   └── subscription_model.dart
├── providers/                # Riverpod providers
│   ├── auth_provider.dart
│   └── firestore_provider.dart
├── services/                 # Firebase services
│   ├── auth_service.dart
│   └── firestore_service.dart
├── screens/                  # UI screens
│   ├── auth/
│   ├── customer/
│   ├── center_admin/
│   └── super_admin/
├── utils/                    # Utilities
│   ├── app_colors.dart
│   └── app_theme.dart
└── widgets/                  # Reusable widgets
```

## Color Scheme

- Primary: `#B8907D` (Tan/beige brown)
- Secondary: `#F5E6DC` (Light beige)
- Accent: `#E89B8A` (Coral/salmon)
- Background: `#FAF4F0` (Off-white/cream)

## Testing

### Create Test Users

You can create test users directly in Firebase Console:
1. Go to Authentication → Users
2. Add user manually with email/password

Or register through the app and update the role in Firestore:
1. Register as customer
2. Go to Firestore → users → [user_id]
3. Change `role` field to `centerAdmin` or `superAdmin`

## Next Steps

- [ ] Add Firebase Cloud Functions for backend logic
- [ ] Implement payment gateway integration
- [ ] Add push notifications
- [ ] Implement image upload for centers
- [ ] Add search and filter functionality
- [ ] Create admin panels for center and super admin
- [ ] Add analytics and monitoring

## Support

For issues or questions, please create an issue in the repository.
