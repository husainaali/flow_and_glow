import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceTypeModel {
  final String id;
  final String name; // e.g., "Yoga", "Pilates", "Nutrition", "Therapy"
  final String description;
  final String? iconName; // Optional icon identifier
  final DateTime createdAt;

  ServiceTypeModel({
    required this.id,
    required this.name,
    required this.description,
    this.iconName,
    required this.createdAt,
  });

  factory ServiceTypeModel.fromMap(Map<String, dynamic> map, String id) {
    return ServiceTypeModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconName: map['iconName'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory ServiceTypeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceTypeModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconName: data['iconName'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'iconName': iconName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'iconName': iconName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ServiceTypeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    DateTime? createdAt,
  }) {
    return ServiceTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
