import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/app_theme.dart';
import 'screens/auth/onboarding_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/center_admin/center_admin_dashboard.dart';
import 'screens/super_admin/super_admin_dashboard.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // Note: You need to configure Firebase first
  // Run: flutterfire configure (install flutterfire_cli first)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flow and Glow',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const OnboardingScreen();
        }
        
        final currentUserAsync = ref.watch(currentUserProvider);
        return currentUserAsync.when(
          data: (userData) {
            if (userData == null) {
              return const OnboardingScreen();
            }
            
            switch (userData.role) {
              case UserRole.customer:
                return const CustomerHomeScreen();
              case UserRole.centerAdmin:
                return const CenterAdminDashboard();
              case UserRole.superAdmin:
                return const SuperAdminDashboard();
            }
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const OnboardingScreen(),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const OnboardingScreen(),
    );
  }
}
