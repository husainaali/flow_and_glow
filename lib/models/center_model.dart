import 'package:cloud_firestore/cloud_firestore.dart';
import 'trainer_model.dart';
import 'service_model.dart';

enum CenterStatus { pending, approved, rejected }

class CenterModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final String imageUrl;
  final double rating;
  final CenterStatus status;
  final String adminId;
  final DateTime createdAt;
  final String? title; // e.g., "Flow and Grow Wellness"
  final List<TrainerModel> trainers;
  final List<ServiceModel> services;

  CenterModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.imageUrl,
    this.rating = 0.0,
    required this.status,
    required this.adminId,
    required this.createdAt,
    this.title,
    this.trainers = const [],
    this.services = const [],
  });

  factory CenterModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse trainers
    List<TrainerModel> trainers = [];
    if (data['trainers'] != null) {
      final trainersData = data['trainers'] as List;
      trainers = trainersData.asMap().entries.map((entry) {
        return TrainerModel.fromMap(entry.value as Map<String, dynamic>, entry.key.toString());
      }).toList();
    }
    
    // Parse services
    List<ServiceModel> services = [];
    if (data['services'] != null) {
      final servicesData = data['services'] as List;
      services = servicesData.asMap().entries.map((entry) {
        return ServiceModel.fromMap(entry.value as Map<String, dynamic>, entry.key.toString());
      }).toList();
    }
    
    return CenterModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      status: CenterStatus.values.firstWhere(
        (e) => e.toString() == 'CenterStatus.${data['status']}',
        orElse: () => CenterStatus.pending,
      ),
      adminId: data['adminId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      title: data['title'],
      trainers: trainers,
      services: services,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'imageUrl': imageUrl,
      'rating': rating,
      'status': status.toString().split('.').last,
      'adminId': adminId,
      'createdAt': Timestamp.fromDate(createdAt),
      'title': title,
      'trainers': trainers.map((t) => t.toMap()).toList(),
      'services': services.map((s) => s.toMap()).toList(),
    };
  }
}
