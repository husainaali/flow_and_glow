import 'package:cloud_firestore/cloud_firestore.dart';

class PackageModel {
  final String id;
  final String centerId;
  final String centerName;
  final String title;
  final String description;
  final List<String> programIds; // IDs of programs included in this package
  final String? headerImageUrl;
  final double price; // Special bundled price for all programs
  final String currency;
  final DateTime createdAt;

  PackageModel({
    required this.id,
    required this.centerId,
    required this.centerName,
    required this.title,
    required this.description,
    required this.programIds,
    this.headerImageUrl,
    required this.price,
    this.currency = 'BHD',
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
      programIds: List<String>.from(data['programIds'] ?? []),
      headerImageUrl: data['headerImageUrl'],
      price: (data['price'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'BHD',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  factory PackageModel.fromMap(Map<String, dynamic> data, String id) {
    return PackageModel(
      id: id,
      centerId: data['centerId'] ?? '',
      centerName: data['centerName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      programIds: List<String>.from(data['programIds'] ?? []),
      headerImageUrl: data['headerImageUrl'],
      price: (data['price'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'BHD',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'centerId': centerId,
      'centerName': centerName,
      'title': title,
      'description': description,
      'programIds': programIds,
      'headerImageUrl': headerImageUrl,
      'price': price,
      'currency': currency,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'centerId': centerId,
      'centerName': centerName,
      'title': title,
      'description': description,
      'programIds': programIds,
      'headerImageUrl': headerImageUrl,
      'price': price,
      'currency': currency,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PackageModel copyWith({
    String? id,
    String? centerId,
    String? centerName,
    String? title,
    String? description,
    List<String>? programIds,
    String? headerImageUrl,
    double? price,
    String? currency,
    DateTime? createdAt,
  }) {
    return PackageModel(
      id: id ?? this.id,
      centerId: centerId ?? this.centerId,
      centerName: centerName ?? this.centerName,
      title: title ?? this.title,
      description: description ?? this.description,
      programIds: programIds ?? this.programIds,
      headerImageUrl: headerImageUrl ?? this.headerImageUrl,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
