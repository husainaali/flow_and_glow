import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/center_model.dart';
import '../models/package_model.dart';
import '../models/subscription_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Centers
  Stream<List<CenterModel>> getCenters({CenterStatus? status}) {
    Query query = _firestore.collection('centers');
    
    if (status != null) {
      query = query.where('status', isEqualTo: status.toString().split('.').last);
    }
    
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CenterModel.fromFirestore(doc)).toList());
  }

  Future<CenterModel?> getCenter(String centerId) async {
    final doc = await _firestore.collection('centers').doc(centerId).get();
    if (doc.exists) {
      return CenterModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> createCenter(CenterModel center) async {
    await _firestore.collection('centers').add(center.toFirestore());
  }

  Future<void> updateCenter(String centerId, Map<String, dynamic> data) async {
    await _firestore.collection('centers').doc(centerId).update(data);
  }

  // Packages
  Stream<List<PackageModel>> getPackages({String? centerId, PackageCategory? category}) {
    Query query = _firestore.collection('packages');
    
    if (centerId != null) {
      query = query.where('centerId', isEqualTo: centerId);
    }
    
    if (category != null) {
      query = query.where('category', isEqualTo: category.toString().split('.').last);
    }
    
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => PackageModel.fromFirestore(doc)).toList());
  }

  Future<PackageModel?> getPackage(String packageId) async {
    final doc = await _firestore.collection('packages').doc(packageId).get();
    if (doc.exists) {
      return PackageModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> createPackage(PackageModel package) async {
    await _firestore.collection('packages').add(package.toFirestore());
  }

  Future<void> updatePackage(String packageId, Map<String, dynamic> data) async {
    await _firestore.collection('packages').doc(packageId).update(data);
  }

  Future<void> deletePackage(String packageId) async {
    await _firestore.collection('packages').doc(packageId).delete();
  }

  // Subscriptions
  Stream<List<SubscriptionModel>> getSubscriptions({
    String? userId,
    SubscriptionStatus? status,
  }) {
    Query query = _firestore.collection('subscriptions');
    
    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    
    if (status != null) {
      query = query.where('status', isEqualTo: status.toString().split('.').last);
    }
    
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => SubscriptionModel.fromFirestore(doc)).toList());
  }

  Future<void> createSubscription(SubscriptionModel subscription) async {
    await _firestore.collection('subscriptions').add(subscription.toFirestore());
  }

  Future<void> updateSubscription(String subscriptionId, Map<String, dynamic> data) async {
    await _firestore.collection('subscriptions').doc(subscriptionId).update(data);
  }
}
