import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/center_model.dart';
import '../models/package_model.dart';
import '../models/subscription_model.dart';
import '../models/category_model.dart';
import '../models/program_model.dart';
import '../models/service_type_model.dart';
import '../models/user_model.dart';

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

  Future<CenterModel?> getCenterByAdminId(String adminId) async {
    final querySnapshot = await _firestore
        .collection('centers')
        .where('adminId', isEqualTo: adminId)
        .limit(1)
        .get();
    
    if (querySnapshot.docs.isNotEmpty) {
      return CenterModel.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }

  Future<String> createCenter(CenterModel center) async {
    final docRef = await _firestore.collection('centers').add(center.toFirestore());
    return docRef.id;
  }

  Future<void> updateCenter(String centerId, Map<String, dynamic> data) async {
    await _firestore.collection('centers').doc(centerId).update(data);
  }

  // Packages
  Stream<List<PackageModel>> getPackages({String? centerId}) {
    Query query = _firestore.collection('packages');
    
    if (centerId != null) {
      query = query.where('centerId', isEqualTo: centerId);
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

  // Categories
  Stream<List<CategoryModel>> getCategories() {
    return _firestore
        .collection('categories')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList());
  }

  Future<CategoryModel?> getCategory(String categoryId) async {
    final doc = await _firestore.collection('categories').doc(categoryId).get();
    if (doc.exists) {
      return CategoryModel.fromFirestore(doc);
    }
    return null;
  }

  Future<String> createCategory(CategoryModel category) async {
    final docRef = await _firestore.collection('categories').add(category.toFirestore());
    return docRef.id;
  }

  Future<void> updateCategory(String categoryId, Map<String, dynamic> data) async {
    await _firestore.collection('categories').doc(categoryId).update(data);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).delete();
  }

  // Programs (formerly Services)
  Stream<List<ProgramModel>> getPrograms({String? centerId, String? categoryId}) {
    Query query = _firestore.collection('services');
    
    if (centerId != null) {
      query = query.where('centerId', isEqualTo: centerId);
    }
    
    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ProgramModel.fromFirestore(doc)).toList());
  }

  Future<ProgramModel?> getProgram(String programId) async {
    final doc = await _firestore.collection('programs').doc(programId).get();
    if (doc.exists) {
      return ProgramModel.fromFirestore(doc);
    }
    return null;
  }

  Future<String> createProgram(ProgramModel program) async {
    final docRef = await _firestore.collection('programs').add(program.toFirestore());
    return docRef.id;
  }

  Future<void> updateProgram(String programId, Map<String, dynamic> data) async {
    await _firestore.collection('programs').doc(programId).update(data);
  }

  Future<void> deleteProgram(String programId) async {
    await _firestore.collection('programs').doc(programId).delete();
  }

  // Service Types
  Stream<List<ServiceTypeModel>> getServiceTypes() {
    return _firestore
        .collection('serviceTypes')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ServiceTypeModel.fromFirestore(doc)).toList());
  }

  Future<ServiceTypeModel?> getServiceType(String serviceTypeId) async {
    final doc = await _firestore.collection('serviceTypes').doc(serviceTypeId).get();
    if (doc.exists) {
      return ServiceTypeModel.fromFirestore(doc);
    }
    return null;
  }

  Future<String> createServiceType(ServiceTypeModel serviceType) async {
    final docRef = await _firestore.collection('serviceTypes').add(serviceType.toFirestore());
    return docRef.id;
  }

  Future<void> updateServiceType(String serviceTypeId, Map<String, dynamic> data) async {
    await _firestore.collection('serviceTypes').doc(serviceTypeId).update(data);
  }

  Future<void> deleteServiceType(String serviceTypeId) async {
    await _firestore.collection('serviceTypes').doc(serviceTypeId).delete();
  }

  // Users
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      // Sort in memory instead of using Firestore orderBy
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return users;
    });
  }

  Stream<List<UserModel>> getUsersByRole(UserRole role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role.toString().split('.').last)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      // Sort in memory instead of using Firestore orderBy to avoid composite index
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return users;
    });
  }
}
