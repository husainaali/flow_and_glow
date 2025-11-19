import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id;
  final String userId;
  final String centerId;
  final String centerName;
  final String programId;
  final String programName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String? instructorName;
  final String? location;
  final SessionStatus status;

  SessionModel({
    required this.id,
    required this.userId,
    required this.centerId,
    required this.centerName,
    required this.programId,
    required this.programName,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.instructorName,
    this.location,
    this.status = SessionStatus.scheduled,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map, String id) {
    return SessionModel(
      id: id,
      userId: map['userId'] ?? '',
      centerId: map['centerId'] ?? '',
      centerName: map['centerName'] ?? '',
      programId: map['programId'] ?? '',
      programName: map['programName'] ?? '',
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      instructorName: map['instructorName'],
      location: map['location'],
      status: SessionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => SessionStatus.scheduled,
      ),
    );
  }

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SessionModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'centerId': centerId,
      'centerName': centerName,
      'programId': programId,
      'programName': programName,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'instructorName': instructorName,
      'location': location,
      'status': status.toString().split('.').last,
    };
  }

  Map<String, dynamic> toFirestore() => toMap();
}

enum SessionStatus {
  scheduled,
  completed,
  cancelled,
  missed,
}
