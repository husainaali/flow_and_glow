import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { customer, centerAdmin, superAdmin }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? centerId; // For center admins
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.centerId,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.customer,
      ),
      centerId: data['centerId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'centerId': centerId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
