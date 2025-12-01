# Flow & Glow - Flutter Fitness App

## 🏗️ **Architecture Overview**

### **Project Structure**
```
lib/
├── main.dart                    # App entry point with Firebase init & AuthWrapper
├── models/                      # Data models and enums
├── providers/                   # Riverpod state management
├── services/                    # Business logic & API calls
├── screens/                     # UI screens organized by user roles
│   ├── auth/                    # Authentication screens
│   ├── customer/                # Customer-facing features
│   ├── center_admin/            # Center management features
│   └── super_admin/             # Admin dashboard features
├── utils/                       # Utilities (colors, themes)
└── widgets/                     # Reusable UI components
```

### **Technology Stack**
- **Framework:** Flutter
- **State Management:** Riverpod
- **Backend:** Firebase (Auth, Firestore)
- **UI Design:** Material Design with custom theming
- **Architecture:** MVVM with Provider pattern

### **Multi-Role System**
- **Customers:** Browse programs, subscribe, schedule sessions, add reviews
- **Center Admins:** Manage center programs, view subscriptions, handle reviews
- **Super Admins:** System-wide management, user oversight, center approvals

---

## 🔧 **Core Functions & Services**

### **1. Authentication Service (`AuthService`)**

**Key Functions:**
```dart
// Authentication
Future<UserModel?> signIn(String email, String password)
Future<UserModel?> register(String email, String password, String name, UserRole role)
Future<void> signOut()
Future<void> resetPassword(String email)

// User Management
Future<UserModel?> getUserData(String uid)
Stream<User?> get authStateChanges
User? get currentUser
```

**Purpose:** Handles all Firebase Authentication operations and user data retrieval.

### **2. Firestore Service (`FirestoreService`)**

**CRUD Operations for All Entities:**

**Centers:**
```dart
Stream<List<CenterModel>> getCenters({CenterStatus? status})
Future<CenterModel?> getCenter(String centerId)
Future<String> createCenter(CenterModel center)
Future<void> updateCenter(String centerId, Map<String, dynamic> data)
```

**Programs:**
```dart
Future<ProgramModel?> getProgram(String centerId, String programId)
Stream<List<ProgramModel>> getPrograms({String? centerId, String? categoryId})
Future<String> createProgram(ProgramModel program)
Future<void> updateProgram(String programId, Map<String, dynamic> data)
```

**Subscriptions:**
```dart
Stream<List<SubscriptionModel>> getSubscriptions({String? userId, SubscriptionStatus? status})
Future<void> createSubscription(SubscriptionModel subscription)
Future<void> updateSubscription(String subscriptionId, Map<String, dynamic> data)
```

**Sessions:**
```dart
Future<void> saveSessions(List<SessionModel> sessions)
Stream<List<SessionModel>> getUserSessions(String userId)
Stream<List<SessionModel>> getSessionsForDate(String userId, DateTime date)
Future<void> updateSessionStatus(String sessionId, SessionStatus status)
```

### **3. Schedule Service (`ScheduleService`)**

**Session Generation:**
```dart
Future<List<SessionModel>> generateRegularProgramSessions({
  required String subscriptionId,
  required String userId,
  required ProgramModel program,
  required DateTime startDate,
  required DateTime endDate,
})

Future<List<SessionModel>> generateNutritionProgramSessions({
  required String subscriptionId,
  required String userId,
  required ProgramModel program,
  required int selectedMonths,
  required int selectedDaysPerWeek,
  required int selectedMealsPerDay,
})
```

**Helper Functions:**
```dart
DayOfWeek _getDayOfWeek(int weekday)
List<DayOfWeek> _getDeliveryDays(int daysPerWeek)
```

---

## 🎨 **UI Widgets & Components**

### **Screen Architecture**

#### **1. Customer Home Screen (`CustomerHomeScreen`)**
**Structure:**
- Bottom Navigation Bar with 4 tabs: Home, Schedule, Subscriptions, Profile
- Tab-based navigation using `IndexedStack`
- Role-based routing through `AuthWrapper`

**Key Widgets:**
```dart
class _HomeTab extends ConsumerStatefulWidget  // Main home content
class _ServicesTab extends ConsumerWidget      // Programs/Services view
class _CentersTab extends ConsumerWidget       // Centers directory
```

#### **2. Program Detail Screen (`ProgramDetailScreen`)**
**Features:**
- Program header with image and details
- Price and duration cards
- Trainer information section
- Conditional subscribe button (shows "Already Subscribed" for active users)
- Reviews section with "Add Review" button (for subscribers)
- Interactive star rating system (1-5 stars)

**Key Methods:**
```dart
void _checkSubscriptionStatus()      // Check if user is subscribed
void _checkReviewEligibility()       // Check 50% completion rule
void _showAddReviewDialog()          // Interactive review dialog
void _saveReview(double rating, String comment)  // Save to Firestore
void _createSubscriptionAndSchedule()  // Handle new subscriptions
```

#### **3. Schedule Screen (`ScheduleScreen`)**
**Features:**
- Calendar widget for date selection
- Session list filtered by selected date
- Tappable session cards that navigate to program details
- Status badges (scheduled, completed, cancelled)

**Key Methods:**
```dart
Future<void> _navigateToProgramDetail(SessionModel session)
Widget _buildSessionCard(SessionModel session)
Widget _buildStatusBadge(SessionStatus status)
```

#### **4. Center Detail Screen (`CenterDetailScreen`)**
**Features:**
- Tab-based layout (About Us, Services)
- Reviews section for center feedback
- Service previews with navigation to program details
- Package subscription options

### **Reusable Components**

#### **Card Components:**
```dart
Widget _buildServiceCard(ProgramModel service)    // Program listing card
Widget _buildCenterCard(CenterModel center)       // Center listing card
Widget _buildReviewCard(ReviewModel review)       // Review display card
```

#### **Form Components:**
```dart
Widget _buildPriceAndDuration()     // Price/duration display cards
Widget _buildTrainerInfo()          // Trainer details section
Widget _buildSubscribeButton()      // Conditional subscribe button
Widget _buildReviewsSection()       // Reviews list with add button
```

#### **Interactive Elements:**
```dart
Widget _buildCategoryChip(String label, String? categoryId, String? iconUrl)
void _showAddReviewDialog()    // Modal review form
```

---

## 📊 **Data Models**

### **Core Entities:**

#### **1. User Model (`UserModel`)**
```dart
class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;        // customer, centerAdmin, superAdmin
  final String? centerId;     // For center admins
  final DateTime createdAt;
}
```

#### **2. Program Model (`ProgramModel`)**
```dart
class ProgramModel {
  final String id;
  final String centerId;
  final String centerName;
  final String title;
  final String description;
  final double price;
  final String trainer;
  final ProgramType programType;     // regular, nutrition
  final List<DayOfWeek> weeklyDays;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final String? headerImageUrl;
  final DateTime? programStartDate;
  final DateTime? programEndDate;
}
```

#### **3. Session Model (`SessionModel`)**
```dart
class SessionModel {
  final String id;
  final String userId;
  final String subscriptionId;
  final String centerId;
  final String centerName;
  final String programId;
  final String programName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String? instructorName;
  final String? location;
  final SessionStatus status;  // scheduled, completed, cancelled, missed
}
```

#### **4. Subscription Model (`SubscriptionModel`)**
```dart
class SubscriptionModel {
  final String id;
  final String userId;
  final String packageId;      // References program ID
  final String packageTitle;
  final String? instructor;
  final double price;
  final String currency;
  final int sessionsPerWeek;
  final int sessionsLeft;
  final SubscriptionStatus status;  // active, cancelled, expired
  final PaymentMethod paymentMethod;
  final DateTime startDate;
  final DateTime renewalDate;
  final DateTime createdAt;
}
```

#### **5. Review Model (`ReviewModel`)**
```dart
class ReviewModel {
  final String id;
  final String centerId;
  final String? programId;     // Optional - can be center or program review
  final String userId;
  final String userName;
  final String userImageUrl;
  final double rating;         // 1-5 stars
  final String comment;
  final DateTime createdAt;
}
```

#### **6. Center Model (`CenterModel`)**
```dart
class CenterModel {
  final String id;
  final String name;
  final String title;
  final String description;
  final String address;
  final double rating;
  final String imageUrl;
  final CenterStatus status;   // pending, approved, rejected
  final String? adminId;
  final List<ProgramModel> programs;  // Embedded programs
  final List<TrainerModel> trainers;
}
```

---

## 🔄 **State Management (Riverpod)**

### **Provider Architecture:**

#### **Authentication Providers:**
```dart
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final authStateProvider = StreamProvider<User?>((ref) => ref.watch(authServiceProvider).authStateChanges);
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  // Gets user data from Firestore based on auth state
});
```

#### **Data Providers:**
```dart
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

// Centers
final centersProvider = StreamProvider.family<List<CenterModel>, CenterStatus?>((ref, status) => ...);
final approvedCentersProvider = StreamProvider<List<CenterModel>>((ref) => ...);

// Programs
final programsProvider = StreamProvider<List<ProgramModel>>((ref) => ...);  // All programs
final programsByCategoryProvider = StreamProvider.family<List<ProgramModel>, String>((ref, categoryId) => ...);
final programsByCenterProvider = StreamProvider.family<List<ProgramModel>, String>((ref, centerId) => ...);

// Subscriptions
final userSubscriptionsProvider = StreamProvider.family<List<SubscriptionModel>, String>((ref, userId) => ...);
final activeSubscriptionsProvider = StreamProvider.family<List<SubscriptionModel>, String>((ref, userId) => ...);

// Users (for admin)
final allUsersStreamProvider = StreamProvider<List<UserModel>>((ref) => ...);
final customerUsersStreamProvider = StreamProvider<List<UserModel>>((ref) => ...);
```

### **State Management Pattern:**
1. **Service Layer:** Pure business logic (FirestoreService, AuthService, ScheduleService)
2. **Provider Layer:** Riverpod providers that expose data streams
3. **UI Layer:** Widgets consume providers using `ref.watch()` or `ref.read()`
4. **State Updates:** Local state managed with `setState()` for UI interactions

---

## 🔐 **Authentication & Authorization**

### **Role-Based Access Control:**
```dart
enum UserRole {
  customer,      // Can browse, subscribe, review
  centerAdmin,   // Can manage center programs and data
  superAdmin     // Can manage all centers and users
}
```

### **AuthWrapper Logic:**
```dart
class AuthWrapper extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return OnboardingScreen();

        return currentUserProvider.when(
          data: (userData) {
            switch (userData!.role) {
              case UserRole.customer: return CustomerHomeScreen();
              case UserRole.centerAdmin: return CenterAdminDashboard();
              case UserRole.superAdmin: return SuperAdminDashboard();
            }
          }
        );
      }
    );
  }
}
```

---

## 🗂️ **Firebase Data Structure**

### **Collections:**
```
users/                          # User profiles
centers/                        # Wellness centers with embedded programs
subscriptions/                  # User subscriptions
sessions/                       # Scheduled sessions
reviews/                        # User reviews (center/program level)
categories/                     # Service categories
serviceTypes/                   # Service type definitions
```

### **Key Relationships:**
- **Centers → Programs:** Programs embedded within center documents (indexed by array position)
- **Users → Subscriptions:** Users can have multiple active subscriptions
- **Subscriptions → Sessions:** Each subscription generates multiple sessions
- **Programs → Reviews:** Reviews can be for specific programs or centers
- **Users → Reviews:** Users can review programs they've subscribed to

---

## 🚀 **Key Features Implementation**

### **1. Program Subscription Flow:**
1. User browses programs on home screen
2. Clicks "View" → navigates to `ProgramDetailScreen`
3. Checks subscription status → shows "Subscribe Now" or "Already Subscribed"
4. Payment processing → creates subscription and generates sessions
5. Sessions appear in user's schedule

### **2. Session Management:**
1. **Regular Programs:** Weekly recurring sessions based on selected days
2. **Nutrition Programs:** Meal delivery sessions based on frequency settings
3. **Status Tracking:** Scheduled → Completed/Cancelled/Missed
4. **Calendar Integration:** Date-filtered session views

### **3. Review System:**
1. **Eligibility:** Subscribers can review immediately upon subscription
2. **Rating:** 5-star interactive rating system
3. **Persistence:** Reviews stored in Firestore with user and program references
4. **Display:** Horizontal scrolling review cards with ratings and comments

### **4. Multi-Role Dashboard:**
- **Customers:** Program discovery, subscriptions, scheduling, reviews
- **Center Admins:** Program management, subscription monitoring, customer service
- **Super Admins:** System oversight, center approvals, user management

---

## 🛠️ **Utility Classes**

### **App Colors (`app_colors.dart`):**
```dart
class AppColors {
  static const Color primary = Color(0xFF4A90E2);
  static const Color secondary = Color(0xFFF5F5F5);
  static const Color accent = Color(0xFF5CB85C);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
}
```

### **App Theme (`app_theme.dart`):**
- Light theme configuration
- Custom text styles
- Button themes
- Input decoration themes

---

## 📱 **UI/UX Patterns**

### **Navigation Patterns:**
- Bottom navigation for main app sections
- Tab-based content organization
- Modal dialogs for forms and confirmations
- Push navigation for detail screens

### **Design System:**
- **Colors:** Consistent color palette with semantic meanings
- **Typography:** Hierarchical text styles (headings, body, captions)
- **Spacing:** Consistent padding and margins (4, 8, 12, 16, 20, 24)
- **Components:** Reusable card layouts, buttons, form elements

### **Loading & Error States:**
- Circular progress indicators for async operations
- Skeleton loading for lists
- SnackBar notifications for user feedback
- Error boundaries with fallback UI

---

## 🔄 **Business Logic Flow**

### **Subscription Creation:**
1. **Validation:** Check user authentication
2. **Payment:** Process payment through external gateway
3. **Subscription:** Create subscription record in Firestore
4. **Schedule:** Generate session schedule based on program type
5. **Persistence:** Batch save all sessions to Firestore
6. **Feedback:** Show success message and navigate to schedule

### **Session Completion:**
1. **Status Update:** Mark session as completed
2. **Progress Tracking:** Calculate completion percentage
3. **Review Eligibility:** Enable reviews after 50% completion (or immediately for subscribers)
4. **UI Updates:** Refresh schedule and enable review buttons

### **Review Submission:**
1. **Validation:** Check user authentication and subscription status
2. **Data Collection:** Gather rating (1-5) and comment
3. **Persistence:** Save review to Firestore
4. **UI Update:** Refresh reviews list and show confirmation

---

This documentation provides a comprehensive overview of the Flow & Glow Flutter application's architecture, covering all major components, functions, and patterns used in development.
