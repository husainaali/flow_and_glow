import 'package:cloud_firestore/cloud_firestore.dart';

class ProgramModel {
  final String id;
  final String userId;
  final String centerId;
  final String centerName;
  final String packageId;
  final String packageName;
  final DateTime startDate;
  final DateTime endDate;
  final List<int> scheduledDays; // 0 = Sunday, 1 = Monday, etc.
  final String startTime;
  final String endTime;
  final String? instructorName;
  final String? location;
  final ProgramStatus status;
  final DateTime createdAt;

  ProgramModel({
    required this.id,
    required this.userId,
    required this.centerId,
    required this.centerName,
    required this.packageId,
    required this.packageName,
    required this.startDate,
    required this.endDate,
    required this.scheduledDays,
    required this.startTime,
    required this.endTime,
    this.instructorName,
    this.location,
    this.status = ProgramStatus.active,
    required this.createdAt,
  });

  factory ProgramModel.fromMap(Map<String, dynamic> map, String id) {
    return ProgramModel(
      id: id,
      userId: map['userId'] ?? '',
      centerId: map['centerId'] ?? '',
      centerName: map['centerName'] ?? '',
      packageId: map['packageId'] ?? '',
      packageName: map['packageName'] ?? '',
      startDate: map['startDate'] is Timestamp
          ? (map['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: map['endDate'] is Timestamp
          ? (map['endDate'] as Timestamp).toDate()
          : DateTime.now(),
      scheduledDays: List<int>.from(map['scheduledDays'] ?? []),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      instructorName: map['instructorName'],
      location: map['location'],
      status: ProgramStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => ProgramStatus.active,
      ),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory ProgramModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgramModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'centerId': centerId,
      'centerName': centerName,
      'packageId': packageId,
      'packageName': packageName,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'scheduledDays': scheduledDays,
      'startTime': startTime,
      'endTime': endTime,
      'instructorName': instructorName,
      'location': location,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toFirestore() => toMap();

  /// Generate all sessions for this program based on scheduled days
  List<DateTime> generateSessionDates() {
    final sessions = <DateTime>[];
    var currentDate = startDate;
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      // Check if current day is in scheduled days
      final weekday = currentDate.weekday % 7; // Convert to 0 = Sunday
      if (scheduledDays.contains(weekday)) {
        sessions.add(currentDate);
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return sessions;
  }
}

enum ProgramStatus {
  active,
  completed,
  cancelled,
  paused,
}
