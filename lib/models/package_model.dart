import 'package:cloud_firestore/cloud_firestore.dart';

enum PackageCategory { yoga, pilates, nutrition, therapy }
enum PackageDuration { monthly, yearly }

class PackageModel {
  final String id;
  final String centerId;
  final String centerName;
  final String title;
  final String description;
  final String instructor;
  final PackageCategory category;
  final PackageDuration duration;
  final double price;
  final String currency;
  final int sessionsPerWeek;
  final DateTime createdAt;

  PackageModel({
    required this.id,
    required this.centerId,
    required this.centerName,
    required this.title,
    required this.description,
    required this.instructor,
    required this.category,
    required this.duration,
    required this.price,
    this.currency = 'BHD',
    required this.sessionsPerWeek,
    required this.createdAt,
  });

  factory PackageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PackageModel(
      id: doc.id,
      centerId: data['centerId'] ?? '',
      centerName: data['centerName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      instructor: data['instructor'] ?? '',
      category: PackageCategory.values.firstWhere(
        (e) => e.toString() == 'PackageCategory.${data['category']}',
        orElse: () => PackageCategory.yoga,
      ),
      duration: PackageDuration.values.firstWhere(
        (e) => e.toString() == 'PackageDuration.${data['duration']}',
        orElse: () => PackageDuration.monthly,
      ),
      price: (data['price'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'BHD',
      sessionsPerWeek: data['sessionsPerWeek'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'centerId': centerId,
      'centerName': centerName,
      'title': title,
      'description': description,
      'instructor': instructor,
      'category': category.toString().split('.').last,
      'duration': duration.toString().split('.').last,
      'price': price,
      'currency': currency,
      'sessionsPerWeek': sessionsPerWeek,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
