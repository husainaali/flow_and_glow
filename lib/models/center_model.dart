import 'package:cloud_firestore/cloud_firestore.dart';
import 'trainer_model.dart';
import 'program_model.dart';
import 'service_type_model.dart';

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
  final List<ServiceTypeModel> serviceTypes; // Types: Yoga, Pilates, Nutrition, Therapy
  final List<ProgramModel> programs; // Scheduled programs with trainer, dates

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
    this.serviceTypes = const [],
    this.programs = const [],
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
    
    // Parse service types
    List<ServiceTypeModel> serviceTypes = [];
    if (data['serviceTypes'] != null) {
      final serviceTypesData = data['serviceTypes'] as List;
      serviceTypes = serviceTypesData.asMap().entries.map((entry) {
        return ServiceTypeModel.fromMap(entry.value as Map<String, dynamic>, entry.key.toString());
      }).toList();
    }
    
    // Parse programs
    List<ProgramModel> programs = [];
    if (data['programs'] != null) {
      final programsData = data['programs'] as List;
      programs = programsData.asMap().entries.map((entry) {
        return ProgramModel.fromMap(entry.value as Map<String, dynamic>, entry.key.toString());
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
      serviceTypes: serviceTypes,
      programs: programs,
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
      'serviceTypes': serviceTypes.map((s) => s.toMap()).toList(),
      'programs': programs.map((p) => p.toMap()).toList(),
    };
  }
}
