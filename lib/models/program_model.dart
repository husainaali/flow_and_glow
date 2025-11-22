import 'package:cloud_firestore/cloud_firestore.dart';

enum ProgramType { regular, nutrition }

enum PricingPeriod { week, month, year }

enum DayOfWeek { sunday, monday, tuesday, wednesday, thursday, friday, saturday }

class ProgramModel {
  final String id;
  final String centerId;
  final String centerName;
  final String categoryId; // Keep for backward compatibility
  final String serviceTypeId; // New: Reference to ServiceTypeModel (Yoga, Pilates, etc.)
  final String title;
  final String description;
  final double price;
  final String trainer;
  final DateTime createdAt;
  
  // Program type
  final ProgramType programType; // regular or nutrition
  
  // Schedule fields (for regular programs)
  final List<DayOfWeek> weeklyDays; // e.g., [Sunday, Tuesday]
  final String startTime; // e.g., "14:00" (2:00 PM)
  final int durationMinutes; // e.g., 120 for 2 hours
  final DateTime? programStartDate;
  final DateTime? programEndDate;
  
  // Nutrition fields (for nutrition programs)
  final int? mealsPerDay; // e.g., 3 meals per day
  final int? daysPerWeek; // e.g., 5 days per week
  final int? subscriptionMonths; // e.g., 3 months
  
  // Pricing fields
  final PricingPeriod pricingPeriod; // week, month, or year
  final int pricingDuration; // e.g., 2 for "2 weeks"
  
  // Header photo
  final String? headerImageUrl;

  ProgramModel({
    required this.id,
    required this.centerId,
    this.centerName = '',
    required this.categoryId,
    this.serviceTypeId = '',
    required this.title,
    required this.description,
    required this.price,
    required this.trainer,
    required this.createdAt,
    this.programType = ProgramType.regular,
    this.weeklyDays = const [],
    this.startTime = '',
    this.durationMinutes = 60,
    this.programStartDate,
    this.programEndDate,
    this.mealsPerDay,
    this.daysPerWeek,
    this.subscriptionMonths,
    this.pricingPeriod = PricingPeriod.month,
    this.pricingDuration = 1,
    this.headerImageUrl,
  });

  factory ProgramModel.fromMap(Map<String, dynamic> map, String id) {
    return ProgramModel(
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
      serviceTypeId: map['serviceTypeId'] ?? '',
      programType: ProgramType.values.firstWhere(
        (e) => e.toString().split('.').last == (map['programType'] ?? 'regular'),
        orElse: () => ProgramType.regular,
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
      mealsPerDay: map['mealsPerDay'],
      daysPerWeek: map['daysPerWeek'],
      subscriptionMonths: map['subscriptionMonths'],
      pricingPeriod: PricingPeriod.values.firstWhere(
        (e) => e.toString().split('.').last == (map['pricingPeriod'] ?? 'month'),
        orElse: () => PricingPeriod.month,
      ),
      pricingDuration: map['pricingDuration'] ?? 1,
      headerImageUrl: map['headerImageUrl'],
    );
  }

  factory ProgramModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgramModel(
      id: doc.id,
      centerId: data['centerId'] ?? '',
      centerName: data['centerName'] ?? '',
      categoryId: data['categoryId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      trainer: data['trainer'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      serviceTypeId: data['serviceTypeId'] ?? '',
      programType: ProgramType.values.firstWhere(
        (e) => e.toString().split('.').last == (data['programType'] ?? 'regular'),
        orElse: () => ProgramType.regular,
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
      mealsPerDay: data['mealsPerDay'],
      daysPerWeek: data['daysPerWeek'],
      subscriptionMonths: data['subscriptionMonths'],
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
      'serviceTypeId': serviceTypeId,
      'programType': programType.toString().split('.').last,
      'weeklyDays': weeklyDays.map((day) => day.toString().split('.').last).toList(),
      'startTime': startTime,
      'durationMinutes': durationMinutes,
      'programStartDate': programStartDate != null ? Timestamp.fromDate(programStartDate!) : null,
      'programEndDate': programEndDate != null ? Timestamp.fromDate(programEndDate!) : null,
      'mealsPerDay': mealsPerDay,
      'daysPerWeek': daysPerWeek,
      'subscriptionMonths': subscriptionMonths,
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
      'serviceTypeId': serviceTypeId,
      'programType': programType.toString().split('.').last,
      'weeklyDays': weeklyDays.map((day) => day.toString().split('.').last).toList(),
      'startTime': startTime,
      'durationMinutes': durationMinutes,
      'programStartDate': programStartDate != null ? Timestamp.fromDate(programStartDate!) : null,
      'programEndDate': programEndDate != null ? Timestamp.fromDate(programEndDate!) : null,
      'mealsPerDay': mealsPerDay,
      'daysPerWeek': daysPerWeek,
      'subscriptionMonths': subscriptionMonths,
      'pricingPeriod': pricingPeriod.toString().split('.').last,
      'pricingDuration': pricingDuration,
      'headerImageUrl': headerImageUrl,
    };
  }

  ProgramModel copyWith({
    String? id,
    String? centerId,
    String? centerName,
    String? categoryId,
    String? title,
    String? description,
    double? price,
    String? trainer,
    DateTime? createdAt,
    String? serviceTypeId,
    ProgramType? programType,
    List<DayOfWeek>? weeklyDays,
    String? startTime,
    int? durationMinutes,
    DateTime? programStartDate,
    DateTime? programEndDate,
    int? mealsPerDay,
    int? daysPerWeek,
    int? subscriptionMonths,
    PricingPeriod? pricingPeriod,
    int? pricingDuration,
    String? headerImageUrl,
  }) {
    return ProgramModel(
      id: id ?? this.id,
      centerId: centerId ?? this.centerId,
      centerName: centerName ?? this.centerName,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      trainer: trainer ?? this.trainer,
      createdAt: createdAt ?? this.createdAt,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      programType: programType ?? this.programType,
      weeklyDays: weeklyDays ?? this.weeklyDays,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      programStartDate: programStartDate ?? this.programStartDate,
      programEndDate: programEndDate ?? this.programEndDate,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      subscriptionMonths: subscriptionMonths ?? this.subscriptionMonths,
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
  
  // Nutrition program helpers
  bool get isNutritionProgram => programType == ProgramType.nutrition;
  
  String get nutritionDetails {
    if (!isNutritionProgram) return '';
    return '${mealsPerDay ?? 0} meals/day • ${daysPerWeek ?? 0} days/week';
  }
  
  // Calculate price for custom nutrition subscription
  // Base price is for the default configuration set by admin
  // This calculates adjusted price based on customer selection
  double calculateNutritionPrice({
    required int selectedMonths,
    required int selectedDaysPerWeek,
    required int selectedMealsPerDay,
  }) {
    if (!isNutritionProgram) return price;
    
    // Base configuration (what admin set)
    final baseDays = daysPerWeek ?? 7;
    final baseMeals = mealsPerDay ?? 3;
    final baseMonths = subscriptionMonths ?? 1;
    
    // Calculate per-meal price
    final totalBaseMeals = baseDays * baseMeals * baseMonths * 4; // 4 weeks per month
    final pricePerMeal = price / totalBaseMeals;
    
    // Calculate price for selected configuration
    final selectedTotalMeals = selectedDaysPerWeek * selectedMealsPerDay * selectedMonths * 4;
    return pricePerMeal * selectedTotalMeals;
  }
}
