import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/center_model.dart';
import '../models/package_model.dart';
import '../models/subscription_model.dart';
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
