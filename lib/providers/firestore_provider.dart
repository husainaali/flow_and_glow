import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/center_model.dart';
import '../models/package_model.dart';
import '../models/subscription_model.dart';
import '../models/category_model.dart';
import '../models/service_model.dart';
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

final packagesByCategoryProvider = StreamProvider.family<List<PackageModel>, PackageCategory>((ref, category) {
  return ref.watch(firestoreServiceProvider).getPackages(category: category);
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

// Services - Extract from centers
final servicesProvider = StreamProvider<List<ServiceModel>>((ref) {
  final centersAsync = ref.watch(approvedCentersProvider);
  return centersAsync.when(
    data: (centers) {
      final allServices = <ServiceModel>[];
      for (final center in centers) {
        // Add center name to each service
        for (final service in center.services) {
          allServices.add(service.copyWith(
            centerId: center.id,
            centerName: center.name,
          ));
        }
      }
      return Stream.value(allServices);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final servicesByCategoryProvider = StreamProvider.family<List<ServiceModel>, String>((ref, categoryId) {
  final allServicesAsync = ref.watch(servicesProvider);
  return allServicesAsync.when(
    data: (services) {
      final filtered = services.where((s) => s.categoryId == categoryId).toList();
      return Stream.value(filtered);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final servicesByCenterProvider = StreamProvider.family<List<ServiceModel>, String>((ref, centerId) {
  final allServicesAsync = ref.watch(servicesProvider);
  return allServicesAsync.when(
    data: (services) {
      final filtered = services.where((s) => s.centerId == centerId).toList();
      return Stream.value(filtered);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});
