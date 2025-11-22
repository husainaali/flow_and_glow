import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/center_model.dart';
import '../models/package_model.dart';
import '../models/subscription_model.dart';
import '../models/category_model.dart';
import '../models/program_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

// Centers
final centersProvider = StreamProvider.family<List<CenterModel>, CenterStatus?>((ref, status) {
  return ref.watch(firestoreServiceProvider).getCenters(status: status);
});

final approvedCentersProvider = StreamProvider<List<CenterModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getCenters(status: CenterStatus.approved);
});

// Packages
final packagesProvider = StreamProvider<List<PackageModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getPackages();
});

final packagesByCenterProvider = StreamProvider.family<List<PackageModel>, String>((ref, centerId) {
  return ref.watch(firestoreServiceProvider).getPackages(centerId: centerId);
});

// Subscriptions
final userSubscriptionsProvider = StreamProvider.family<List<SubscriptionModel>, String>((ref, userId) {
  return ref.watch(firestoreServiceProvider).getSubscriptions(userId: userId);
});

final activeSubscriptionsProvider = StreamProvider.family<List<SubscriptionModel>, String>((ref, userId) {
  return ref.watch(firestoreServiceProvider).getSubscriptions(
    userId: userId,
    status: SubscriptionStatus.active,
  );
});

// Categories
final categoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getCategories();
});

// Programs - Extract from centers
final programsProvider = StreamProvider<List<ProgramModel>>((ref) {
  final centersAsync = ref.watch(approvedCentersProvider);
  return centersAsync.when(
    data: (centers) {
      final allPrograms = <ProgramModel>[];
      for (final center in centers) {
        // Add center name to each program
        for (final program in center.programs) {
          allPrograms.add(program.copyWith(
            centerId: center.id,
            centerName: center.name,
          ));
        }
      }
      return Stream.value(allPrograms);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final programsByCategoryProvider = StreamProvider.family<List<ProgramModel>, String>((ref, categoryId) {
  final allProgramsAsync = ref.watch(programsProvider);
  final categoriesAsync = ref.watch(categoriesProvider);
  
  return allProgramsAsync.when(
    data: (programs) {
      // Check if this is the nutrition category by looking up the category name
      return categoriesAsync.when(
        data: (categories) {
          final category = categories.firstWhere(
            (c) => c.id == categoryId,
            orElse: () => categories.first,
          );
          
          // Special handling for nutrition category - filter by programType
          if (category.name.toLowerCase() == 'nutrition') {
            final filtered = programs.where((p) => p.programType == ProgramType.nutrition).toList();
            return Stream.value(filtered);
          }
          
          // For other categories, filter by categoryId as usual
          final filtered = programs.where((p) => p.categoryId == categoryId).toList();
          return Stream.value(filtered);
        },
        loading: () => Stream.value([]),
        error: (_, __) {
          // Fallback: filter by categoryId
          final filtered = programs.where((p) => p.categoryId == categoryId).toList();
          return Stream.value(filtered);
        },
      );
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final programsByCenterProvider = StreamProvider.family<List<ProgramModel>, String>((ref, centerId) {
  final allProgramsAsync = ref.watch(programsProvider);
  return allProgramsAsync.when(
    data: (programs) {
      final filtered = programs.where((p) => p.centerId == centerId).toList();
      return Stream.value(filtered);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// Users
final allUsersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getAllUsers();
});

final superAdminUsersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getUsersByRole(UserRole.superAdmin);
});

final centerAdminUsersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getUsersByRole(UserRole.centerAdmin);
});

final customerUsersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getUsersByRole(UserRole.customer);
});
