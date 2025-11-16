import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String centerId;
  final String categoryId;
  final String title;
  final String description;
  final double price;
  final String trainer;
  final DateTime createdAt;

  ServiceModel({
    required this.id,
    required this.centerId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.price,
    required this.trainer,
    required this.createdAt,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map, String id) {
    return ServiceModel(
      id: id,
      centerId: map['centerId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      trainer: map['trainer'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      centerId: data['centerId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      trainer: data['trainer'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'centerId': centerId,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'price': price,
      'trainer': trainer,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'centerId': centerId,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'price': price,
      'trainer': trainer,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ServiceModel copyWith({
    String? id,
    String? centerId,
    String? categoryId,
    String? title,
    String? description,
    double? price,
    String? trainer,
    DateTime? createdAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      centerId: centerId ?? this.centerId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      trainer: trainer ?? this.trainer,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
