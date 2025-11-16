# Flow and Glow - Complete Setup Guide

## Prerequisites
- Flutter SDK installed (3.9.2 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Firebase account

## Step-by-Step Setup

### 1. Clone and Install Dependencies

```bash
cd /Users/husainnusuf/CascadeProjects/flow_and_glow
flutter pub get
```

### 2. Firebase Configuration

#### A. Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

#### B. Login to Firebase
```bash
firebase login
```

#### C. Configure Firebase for Flutter
```bash
flutterfire configure
```

Select or create a Firebase project when prompted. This will:
- Generate `lib/firebase_options.dart`
- Configure Android and iOS apps
- Download configuration files

### 3. Firebase Console Configuration

Visit [Firebase Console](https://console.firebase.google.com/)

#### A. Enable Authentication
1. Go to **Authentication** → **Sign-in method**
2. Enable **Email/Password** provider
3. Click **Save**

#### B. Create Firestore Database
1. Go to **Firestore Database**
2. Click **Create database**
3. Select **Start in test mode** (for development)
4. Choose a location (closest to your users)
5. Click **Enable**

#### C. Enable Firebase Storage
1. Go to **Storage**
2. Click **Get started**
3. Start in **test mode** (for development)
4. Click **Done**

#### D. Update Firestore Security Rules

Go to **Firestore Database** → **Rules** and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Centers collection
    match /centers/{centerId} {
      allow read: if true; // Anyone can read approved centers
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'superAdmin' ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.centerId == centerId);
    }
    
    // Packages collection
    match /packages/{packageId} {
      allow read: if true; // Anyone can read packages
      allow create, update, delete: if request.auth != null;
    }
    
    // Subscriptions collection
    match /subscriptions/{subscriptionId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['centerAdmin', 'superAdmin']);
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }
  }
}
```

#### E. Update Storage Security Rules

Go to **Storage** → **Rules** and paste:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /centers/{centerId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4. Create Initial Super Admin User

Since the app requires authentication, you need to create an initial super admin:

#### Option 1: Via Firebase Console
1. Go to **Authentication** → **Users**
2. Click **Add user**
3. Enter email: `admin@flowandglow.com`
4. Enter password: `Admin123!`
5. Click **Add user**
6. Copy the User UID
7. Go to **Firestore Database**
8. Create a new document in `users` collection:
   - Document ID: [paste the User UID]
   - Fields:
     ```
     email: "admin@flowandglow.com"
     name: "Super Admin"
     role: "superAdmin"
     createdAt: [current timestamp]
     ```

#### Option 2: Via App (Temporary)
1. Temporarily modify `register_screen.dart` to allow super admin registration
2. Register through the app
3. Go to Firestore and change the user's role to `superAdmin`
4. Revert the code changes

### 5. Run the App

```bash
# For iOS
flutter run -d ios

# For Android
flutter run -d android

# For web
flutter run -d chrome
```

### 6. Test the App

#### Test Accounts
Create these test accounts for different roles:

1. **Customer**
   - Email: `customer@test.com`
   - Password: `Test123!`
   - Role: `customer`

2. **Center Admin**
   - Email: `center@test.com`
   - Password: `Test123!`
   - Role: `centerAdmin`
   - centerId: `[create a center first]`

3. **Super Admin**
   - Email: `admin@flowandglow.com`
   - Password: `Admin123!`
   - Role: `superAdmin`

## Project Structure Overview

```
flow_and_glow/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── models/                            # Data models
│   │   ├── user_model.dart               # User data structure
│   │   ├── center_model.dart             # Center data structure
│   │   ├── package_model.dart            # Package data structure
│   │   └── subscription_model.dart       # Subscription data structure
│   ├── providers/                         # Riverpod state management
│   │   ├── auth_provider.dart            # Authentication state
│   │   └── firestore_provider.dart       # Firestore data providers
│   ├── services/                          # Business logic
│   │   ├── auth_service.dart             # Authentication operations
│   │   └── firestore_service.dart        # Database operations
│   ├── screens/                           # UI screens
│   │   ├── auth/                         # Authentication screens
│   │   │   ├── splash_screen.dart
│   │   │   ├── onboarding_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── customer/                     # Customer screens
│   │   │   ├── customer_home_screen.dart
│   │   │   ├── centers_screen.dart
│   │   │   ├── package_detail_screen.dart
│   │   │   ├── subscriptions_screen.dart
│   │   │   └── profile_screen.dart
│   │   ├── center_admin/                 # Center admin screens
│   │   │   └── center_admin_dashboard.dart
│   │   └── super_admin/                  # Super admin screens
│   │       └── super_admin_dashboard.dart
│   └── utils/                             # Utilities
│       ├── app_colors.dart               # Color constants
│       └── app_theme.dart                # App theme
├── pubspec.yaml                           # Dependencies
└── README.md                              # Documentation
```

## Common Issues and Solutions

### Issue 1: Firebase not initialized
**Error:** `[core/no-app] No Firebase App '[DEFAULT]' has been created`

**Solution:**
- Run `flutterfire configure` again
- Ensure `firebase_options.dart` exists
- Check that `Firebase.initializeApp()` is called in `main()`

### Issue 2: Permission denied in Firestore
**Error:** `PERMISSION_DENIED: Missing or insufficient permissions`

**Solution:**
- Check Firestore security rules
- Ensure user is authenticated
- Verify user role in Firestore

### Issue 3: Build errors
**Error:** Various build errors

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Issue 4: iOS build issues
**Error:** CocoaPods errors

**Solution:**
```bash
cd ios
pod install
cd ..
flutter run
```

## Next Development Steps

1. **Implement Center Admin Features**
   - Center profile editing with image upload
   - Package creation and management
   - Subscriber list view
   - Transaction history

2. **Implement Super Admin Features**
   - Center approval workflow
   - User management
   - Platform-wide analytics
   - Support ticket system

3. **Add Payment Integration**
   - Stripe/PayPal integration
   - Payment processing
   - Receipt generation

4. **Enhance Customer Experience**
   - Advanced search and filters
   - Favorites/bookmarks
   - Reviews and ratings
   - Push notifications

5. **Add Analytics**
   - Firebase Analytics
   - User behavior tracking
   - Conversion tracking

## Support

For questions or issues:
1. Check the README.md
2. Review Firebase documentation
3. Check Flutter documentation
4. Create an issue in the repository

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
