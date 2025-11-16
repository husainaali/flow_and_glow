# Flow and Glow - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Install Dependencies
```bash
cd /Users/husainnusuf/CascadeProjects/flow_and_glow
flutter pub get
```

### Step 2: Configure Firebase
```bash
# Install FlutterFire CLI (one-time setup)
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

**What this does:**
- Creates/selects Firebase project
- Generates `firebase_options.dart`
- Configures Android & iOS apps

### Step 3: Enable Firebase Services

Go to [Firebase Console](https://console.firebase.google.com/):

1. **Authentication** → Enable Email/Password
2. **Firestore Database** → Create database (test mode)
3. **Storage** → Enable storage (test mode)

### Step 4: Create Super Admin User

In Firebase Console:
1. **Authentication** → **Users** → **Add user**
   - Email: `admin@flowandglow.com`
   - Password: `Admin123!`
2. Copy the User UID
3. **Firestore** → **users** collection → Create document:
   - Document ID: [paste UID]
   - Fields:
     ```
     email: "admin@flowandglow.com"
     name: "Super Admin"
     role: "superAdmin"
     createdAt: [current timestamp]
     ```

### Step 5: Run the App
```bash
flutter run
```

## 🎯 Test the App

### Login Credentials
- **Email**: `admin@flowandglow.com`
- **Password**: `Admin123!`

### Or Register New User
1. Tap "Register" on login screen
2. Fill in details
3. Select role (Customer/Center Admin)
4. Create account

## 📱 What You'll See

### Customer Flow
1. **Onboarding** → Swipe through 3 intro screens
2. **Login/Register** → Create account or sign in
3. **Home** → Browse packages by category
4. **Package Detail** → View details and subscribe
5. **Subscriptions** → Manage active subscriptions
6. **Profile** → View profile and logout

### Center Admin Flow
1. **Login** → Sign in as center admin
2. **Dashboard** → Access center management tools
3. Manage center, packages, subscribers

### Super Admin Flow
1. **Login** → Sign in as super admin
2. **Dashboard** → Platform-wide management
3. Approve centers, manage users, monitor transactions

## 🎨 Design Features

- **Color Scheme**: Warm earth tones (tan, beige, coral)
- **UI Style**: Modern, clean, minimal
- **Navigation**: Bottom tab bar for customers
- **Cards**: Rounded corners, soft shadows
- **Buttons**: Rounded, coral accent color

## 📦 What's Included

### ✅ Implemented
- User authentication (login, register, logout)
- Role-based access (customer, center admin, super admin)
- Package browsing with category filters
- Subscription management
- Real-time data updates
- Responsive UI matching design

### 🚧 To Be Implemented
- Image upload for centers
- Payment processing
- Admin CRUD operations
- Advanced search
- Push notifications

## 🔧 Common Commands

```bash
# Clean build
flutter clean && flutter pub get

# Run on specific device
flutter run -d ios
flutter run -d android

# Build release
flutter build apk
flutter build ios

# Check for issues
flutter doctor
```

## 📚 Documentation

- **README.md** - Project overview
- **SETUP_GUIDE.md** - Detailed setup instructions
- **IMPLEMENTATION_SUMMARY.md** - Complete feature list

## 🆘 Troubleshooting

### Firebase not initialized?
```bash
flutterfire configure
```

### Build errors?
```bash
flutter clean
flutter pub get
flutter run
```

### Permission denied in Firestore?
- Check Firebase security rules in SETUP_GUIDE.md
- Ensure user is authenticated

## 📞 Need Help?

1. Check SETUP_GUIDE.md for detailed instructions
2. Review IMPLEMENTATION_SUMMARY.md for architecture
3. Check Firebase Console for errors
4. Run `flutter doctor` for environment issues

---

**You're all set!** 🎉 The app is ready to run after Firebase configuration.
