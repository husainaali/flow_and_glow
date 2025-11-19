import 'package:cloud_firestore/cloud_firestore.dart';

enum ServiceType { program, nutrition }

enum PricingPeriod { week, month, year }

enum DayOfWeek { sunday, monday, tuesday, wednesday, thursday, friday, saturday }

class ServiceModel {
  final String id;
  final String centerId;
  final String centerName;
  final String categoryId;
  final String title;
  final String description;
  final double price;
  final String trainer;
  final DateTime createdAt;
  
  // Service type
  final ServiceType serviceType;
  
  // Schedule fields (for programs)
  final List<DayOfWeek> weeklyDays; // e.g., [Sunday, Tuesday]
  final String startTime; // e.g., "14:00" (2:00 PM)
  final int durationMinutes; // e.g., 120 for 2 hours
  final DateTime? programStartDate;
  final DateTime? programEndDate;
  
  // Pricing fields
  final PricingPeriod pricingPeriod; // week, month, or year
  final int pricingDuration; // e.g., 2 for "2 weeks"
  
  // Header photo
  final String? headerImageUrl;

  ServiceModel({
    required this.id,
    required this.centerId,
    this.centerName = '',
    required this.categoryId,
    required this.title,
    required this.description,
    required this.price,
    required this.trainer,
    required this.createdAt,
    this.serviceType = ServiceType.program,
    this.weeklyDays = const [],
    this.startTime = '',
    this.durationMinutes = 60,
    this.programStartDate,
    this.programEndDate,
    this.pricingPeriod = PricingPeriod.month,
    this.pricingDuration = 1,
    this.headerImageUrl,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map, String id) {
    return ServiceModel(
      id: id,
      centerId: map['centerId'] ?? '',
      centerName: map['centerName'] ?? '',
      categoryId: map['categoryId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      trainer: map['trainer'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      serviceType: ServiceType.values.firstWhere(
        (e) => e.toString().split('.').last == (map['serviceType'] ?? 'program'),
        orElse: () => ServiceType.program,
      ),
      weeklyDays: (map['weeklyDays'] as List<dynamic>?)
              ?.map((day) => DayOfWeek.values.firstWhere(
                    (e) => e.toString().split('.').last == day,
                    orElse: () => DayOfWeek.sunday,
                  ))
              .toList() ??
          [],
      startTime: map['startTime'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 60,
      programStartDate: map['programStartDate'] is Timestamp
          ? (map['programStartDate'] as Timestamp).toDate()
          : null,
      programEndDate: map['programEndDate'] is Timestamp
          ? (map['programEndDate'] as Timestamp).toDate()
          : null,
      pricingPeriod: PricingPeriod.values.firstWhere(
        (e) => e.toString().split('.').last == (map['pricingPeriod'] ?? 'month'),
        orElse: () => PricingPeriod.month,
      ),
      pricingDuration: map['pricingDuration'] ?? 1,
      headerImageUrl: map['headerImageUrl'],
    );
  }

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      centerId: data['centerId'] ?? '',
      centerName: data['centerName'] ?? '',
      categoryId: data['categoryId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      trainer: data['trainer'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      serviceType: ServiceType.values.firstWhere(
        (e) => e.toString().split('.').last == (data['serviceType'] ?? 'program'),
        orElse: () => ServiceType.program,
      ),
      weeklyDays: (data['weeklyDays'] as List<dynamic>?)
              ?.map((day) => DayOfWeek.values.firstWhere(
                    (e) => e.toString().split('.').last == day,
                    orElse: () => DayOfWeek.sunday,
                  ))
              .toList() ??
          [],
      startTime: data['startTime'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 60,
      programStartDate: data['programStartDate'] is Timestamp
          ? (data['programStartDate'] as Timestamp).toDate()
          : null,
      programEndDate: data['programEndDate'] is Timestamp
          ? (data['programEndDate'] as Timestamp).toDate()
          : null,
      pricingPeriod: PricingPeriod.values.firstWhere(
        (e) => e.toString().split('.').last == (data['pricingPeriod'] ?? 'month'),
        orElse: () => PricingPeriod.month,
      ),
      pricingDuration: data['pricingDuration'] ?? 1,
      headerImageUrl: data['headerImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'centerId': centerId,
      'centerName': centerName,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'price': price,
      'trainer': trainer,
      'createdAt': Timestamp.fromDate(createdAt),
      'serviceType': serviceType.toString().split('.').last,
      'weeklyDays': weeklyDays.map((day) => day.toString().split('.').last).toList(),
      'startTime': startTime,
      'durationMinutes': durationMinutes,
      'programStartDate': programStartDate != null ? Timestamp.fromDate(programStartDate!) : null,
      'programEndDate': programEndDate != null ? Timestamp.fromDate(programEndDate!) : null,
      'pricingPeriod': pricingPeriod.toString().split('.').last,
      'pricingDuration': pricingDuration,
      'headerImageUrl': headerImageUrl,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'centerId': centerId,
      'centerName': centerName,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'price': price,
      'trainer': trainer,
      'createdAt': Timestamp.fromDate(createdAt),
      'serviceType': serviceType.toString().split('.').last,
      'weeklyDays': weeklyDays.map((day) => day.toString().split('.').last).toList(),
      'startTime': startTime,
      'durationMinutes': durationMinutes,
      'programStartDate': programStartDate != null ? Timestamp.fromDate(programStartDate!) : null,
      'programEndDate': programEndDate != null ? Timestamp.fromDate(programEndDate!) : null,
      'pricingPeriod': pricingPeriod.toString().split('.').last,
      'pricingDuration': pricingDuration,
      'headerImageUrl': headerImageUrl,
    };
  }

  ServiceModel copyWith({
    String? id,
    String? centerId,
    String? centerName,
    String? categoryId,
    String? title,
    String? description,
    double? price,
    String? trainer,
    DateTime? createdAt,
    ServiceType? serviceType,
    List<DayOfWeek>? weeklyDays,
    String? startTime,
    int? durationMinutes,
    DateTime? programStartDate,
    DateTime? programEndDate,
    PricingPeriod? pricingPeriod,
    int? pricingDuration,
    String? headerImageUrl,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      centerId: centerId ?? this.centerId,
      centerName: centerName ?? this.centerName,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      trainer: trainer ?? this.trainer,
      createdAt: createdAt ?? this.createdAt,
      serviceType: serviceType ?? this.serviceType,
      weeklyDays: weeklyDays ?? this.weeklyDays,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      programStartDate: programStartDate ?? this.programStartDate,
      programEndDate: programEndDate ?? this.programEndDate,
      pricingPeriod: pricingPeriod ?? this.pricingPeriod,
      pricingDuration: pricingDuration ?? this.pricingDuration,
      headerImageUrl: headerImageUrl ?? this.headerImageUrl,
    );
  }
  
  // Helper methods
  String get endTime {
    if (startTime.isEmpty) return '';
    try {
      final parts = startTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final totalMinutes = hour * 60 + minute + durationMinutes;
      final endHour = (totalMinutes ~/ 60) % 24;
      final endMinute = totalMinutes % 60;
      return '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
  
  String get formattedSchedule {
    if (weeklyDays.isEmpty) return 'No schedule';
    final dayNames = weeklyDays.map((day) {
      switch (day) {
        case DayOfWeek.sunday:
          return 'Sun';
        case DayOfWeek.monday:
          return 'Mon';
        case DayOfWeek.tuesday:
          return 'Tue';
        case DayOfWeek.wednesday:
          return 'Wed';
        case DayOfWeek.thursday:
          return 'Thu';
        case DayOfWeek.friday:
          return 'Fri';
        case DayOfWeek.saturday:
          return 'Sat';
      }
    }).join('/');
    return dayNames;
  }
  
  String get formattedPricing {
    final periodName = pricingPeriod.toString().split('.').last;
    final plural = pricingDuration > 1 ? 's' : '';
    return 'BHD ${price.toStringAsFixed(2)} / $pricingDuration $periodName$plural';
  }
}
