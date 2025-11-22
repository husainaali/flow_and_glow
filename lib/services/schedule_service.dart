import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';
import '../models/program_model.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate sessions for a regular program subscription
  Future<List<SessionModel>> generateRegularProgramSessions({
    required String subscriptionId,
    required String userId,
    required ProgramModel program,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final sessions = <SessionModel>[];
    
    // Get the days of week the program runs
    final programDays = program.weeklyDays;
    if (programDays.isEmpty) return sessions;

    DateTime currentDate = startDate;
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      // Check if current day is in the program's schedule
      final currentDayOfWeek = _getDayOfWeek(currentDate.weekday);
      
      if (programDays.contains(currentDayOfWeek)) {
        // Create a session for this day
        final session = SessionModel(
          id: '', // Will be set by Firestore
          userId: userId,
          subscriptionId: subscriptionId,
          centerId: program.centerId,
          centerName: program.centerName,
          programId: program.id,
          programName: program.title,
          date: currentDate,
          startTime: program.startTime,
          endTime: program.endTime,
          instructorName: program.trainer,
          location: null, // Can be added later
          status: SessionStatus.scheduled,
        );
        
        sessions.add(session);
      }
      
      // Move to next day
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return sessions;
  }

  /// Generate sessions for a nutrition program subscription
  Future<List<SessionModel>> generateNutritionProgramSessions({
    required String subscriptionId,
    required String userId,
    required ProgramModel program,
    required int selectedMonths,
    required int selectedDaysPerWeek,
    required int selectedMealsPerDay,
  }) async {
    final sessions = <SessionModel>[];
    
    // For nutrition programs, create delivery sessions
    final startDate = DateTime.now();
    final endDate = startDate.add(Duration(days: selectedMonths * 30));
    
    // Define which days of the week (e.g., Mon-Fri for 5 days, or all 7 days)
    final deliveryDays = _getDeliveryDays(selectedDaysPerWeek);
    
    DateTime currentDate = startDate;
    
    while (currentDate.isBefore(endDate)) {
      final currentDayOfWeek = _getDayOfWeek(currentDate.weekday);
      
      if (deliveryDays.contains(currentDayOfWeek)) {
        // Create a meal delivery session for this day
        final session = SessionModel(
          id: '',
          userId: userId,
          subscriptionId: subscriptionId,
          centerId: program.centerId,
          centerName: program.centerName,
          programId: program.id,
          programName: '${program.title} - Meal Delivery',
          date: currentDate,
          startTime: '09:00', // Default delivery time
          endTime: '10:00',
          instructorName: program.trainer,
          location: 'Delivery',
          status: SessionStatus.scheduled,
        );
        
        sessions.add(session);
      }
      
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return sessions;
  }

  /// Save sessions to Firestore
  Future<void> saveSessions(List<SessionModel> sessions) async {
    final batch = _firestore.batch();
    
    for (final session in sessions) {
      final docRef = _firestore.collection('sessions').doc();
      batch.set(docRef, session.toFirestore());
    }
    
    await batch.commit();
  }

  /// Get sessions for a user
  Stream<List<SessionModel>> getUserSessions(String userId) {
    return _firestore
        .collection('sessions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final sessions = snapshot.docs
              .map((doc) => SessionModel.fromFirestore(doc))
              .toList();
          
          // Sort by date in the app to avoid composite index requirement
          sessions.sort((a, b) => a.date.compareTo(b.date));
          
          return sessions;
        });
  }

  /// Get sessions for a specific date
  Stream<List<SessionModel>> getSessionsForDate(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return _firestore
        .collection('sessions')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromFirestore(doc))
            .toList());
  }

  /// Get sessions for a date range (for calendar view)
  Stream<List<SessionModel>> getSessionsForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection('sessions')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromFirestore(doc))
            .toList());
  }

  /// Update session status
  Future<void> updateSessionStatus(String sessionId, SessionStatus status) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'status': status.toString().split('.').last,
    });
  }

  /// Helper: Convert weekday number to DayOfWeek enum
  DayOfWeek _getDayOfWeek(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return DayOfWeek.monday;
      case DateTime.tuesday:
        return DayOfWeek.tuesday;
      case DateTime.wednesday:
        return DayOfWeek.wednesday;
      case DateTime.thursday:
        return DayOfWeek.thursday;
      case DateTime.friday:
        return DayOfWeek.friday;
      case DateTime.saturday:
        return DayOfWeek.saturday;
      case DateTime.sunday:
        return DayOfWeek.sunday;
      default:
        return DayOfWeek.monday;
    }
  }

  /// Helper: Get delivery days based on days per week
  List<DayOfWeek> _getDeliveryDays(int daysPerWeek) {
    switch (daysPerWeek) {
      case 3:
        return [DayOfWeek.monday, DayOfWeek.wednesday, DayOfWeek.friday];
      case 5:
        return [
          DayOfWeek.monday,
          DayOfWeek.tuesday,
          DayOfWeek.wednesday,
          DayOfWeek.thursday,
          DayOfWeek.friday,
        ];
      case 7:
        return DayOfWeek.values;
      default:
        return [
          DayOfWeek.monday,
          DayOfWeek.tuesday,
          DayOfWeek.wednesday,
          DayOfWeek.thursday,
          DayOfWeek.friday,
        ];
    }
  }
}
