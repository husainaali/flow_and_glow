# Subscription & Schedule Implementation Guide

## 🎯 Overview

This guide explains the complete subscription flow with payment, schedule generation, and calendar integration.

---

## ✅ What's Been Created

### 1. **Payment Screen** (`lib/screens/customer/payment_screen.dart`)

Beautiful payment UI matching your design with:
- Order summary with taxes & fees
- Payment method selection (Visa cards)
- Add new card option
- Secure SSL encryption badge
- Coral "Confirm Payment" button

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PaymentScreen(
      programTitle: 'Sunrise Vinyasa Flow',
      price: 120.0,
      currency: 'BD',
    ),
  ),
);
```

### 2. **Session Model** (`lib/models/session_model.dart`)

Updated with:
- `subscriptionId` field to link sessions to subscriptions
- All necessary fields for calendar display
- Status tracking (scheduled, completed, cancelled, missed)

### 3. **Schedule Service** (`lib/services/schedule_service.dart`)

Complete service for:
- **Regular Programs**: Generates sessions based on weekly schedule
- **Nutrition Programs**: Generates meal delivery sessions
- Saving sessions to Firestore
- Retrieving sessions by user, date, or date range
- Updating session status

---

## 🔄 Complete Subscription Flow

### Step 1: Customer Clicks Subscribe

From program detail screen or package detail screen:

```dart
// In your program/package detail screen
ElevatedButton(
  onPressed: () async {
    // Navigate to payment screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          programTitle: program.title,
          price: program.price,
          currency: 'BD',
        ),
      ),
    );
    
    if (result != null && result['success'] == true) {
      // Payment successful, create subscription
      await _createSubscriptionAndSchedule();
    }
  },
  child: const Text('Subscribe Now'),
)
```

### Step 2: Payment Processing

The `PaymentScreen`:
1. Shows order summary
2. Lets user select payment method
3. Processes payment (currently simulated)
4. Returns success result

### Step 3: Create Subscription & Generate Schedule

```dart
Future<void> _createSubscriptionAndSchedule() async {
  final user = FirebaseAuth.instance.currentUser!;
  final scheduleService = ScheduleService();
  
  // 1. Create subscription
  final subscription = SubscriptionModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    userId: user.uid,
    programId: program.id,
    packageId: null,
    packageTitle: program.title,
    instructor: program.trainer,
    price: program.price,
    currency: 'BD',
    sessionsPerWeek: program.weeklyDays.length,
    sessionsLeft: 0, // Will be calculated
    status: SubscriptionStatus.active,
    paymentMethod: 'Visa ****1234',
    startDate: DateTime.now(),
    renewalDate: DateTime.now().add(Duration(days: 30)),
    createdAt: DateTime.now(),
  );
  
  // 2. Save subscription to Firestore
  await FirebaseFirestore.instance
      .collection('subscriptions')
      .doc(subscription.id)
      .set(subscription.toFirestore());
  
  // 3. Generate schedule based on program type
  List<SessionModel> sessions;
  
  if (program.programType == ProgramType.regular) {
    // Regular program - generate sessions based on weekly schedule
    sessions = await scheduleService.generateRegularProgramSessions(
      subscriptionId: subscription.id,
      userId: user.uid,
      program: program,
      startDate: program.programStartDate ?? DateTime.now(),
      endDate: program.programEndDate ?? DateTime.now().add(Duration(days: 90)),
    );
  } else {
    // Nutrition program - generate meal delivery sessions
    sessions = await scheduleService.generateNutritionProgramSessions(
      subscriptionId: subscription.id,
      userId: user.uid,
      program: program,
      selectedMonths: 3, // From customer selection
      selectedDaysPerWeek: 5,
      selectedMealsPerDay: 3,
    );
  }
  
  // 4. Save all sessions to Firestore
  await scheduleService.saveSessions(sessions);
  
  // 5. Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Subscription created! ${sessions.length} sessions scheduled.'),
      backgroundColor: Colors.green,
    ),
  );
  
  // 6. Navigate to calendar or my subscriptions
  Navigator.pushReplacementNamed(context, '/calendar');
}
```

---

## 📅 Calendar Integration

### Calendar Page Requirements

You need to create or update a calendar page that:

1. **Displays a monthly calendar**
2. **Marks days with sessions**
3. **Shows session details when day is tapped**

### Example Calendar Implementation

```dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // Add to pubspec.yaml
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/schedule_service.dart';
import '../../models/session_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _scheduleService = ScheduleService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<SessionModel>> _sessions = {};

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
      ),
      body: StreamBuilder<List<SessionModel>>(
        stream: _scheduleService.getUserSessions(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Group sessions by date
          _sessions = _groupSessionsByDate(snapshot.data!);
          
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: (day) {
                  return _sessions[_normalizeDate(day)] ?? [];
                },
                calendarStyle: CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildSessionsList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSessionsList() {
    if (_selectedDay == null) {
      return const Center(
        child: Text('Select a day to view sessions'),
      );
    }
    
    final sessionsForDay = _sessions[_normalizeDate(_selectedDay!)] ?? [];
    
    if (sessionsForDay.isEmpty) {
      return const Center(
        child: Text('No sessions scheduled for this day'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessionsForDay.length,
      itemBuilder: (context, index) {
        final session = sessionsForDay[index];
        return _buildSessionCard(session);
      },
    );
  }

  Widget _buildSessionCard(SessionModel session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(session.status),
          child: Icon(
            _getStatusIcon(session.status),
            color: Colors.white,
          ),
        ),
        title: Text(session.programName),
        subtitle: Text(
          '${session.startTime} - ${session.endTime}\n${session.centerName}',
        ),
        trailing: Chip(
          label: Text(
            session.status.toString().split('.').last,
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: _getStatusColor(session.status).withOpacity(0.2),
        ),
      ),
    );
  }

  Map<DateTime, List<SessionModel>> _groupSessionsByDate(List<SessionModel> sessions) {
    final grouped = <DateTime, List<SessionModel>>{};
    
    for (final session in sessions) {
      final normalizedDate = _normalizeDate(session.date);
      if (grouped[normalizedDate] == null) {
        grouped[normalizedDate] = [];
      }
      grouped[normalizedDate]!.add(session);
    }
    
    return grouped;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.scheduled:
        return Colors.blue;
      case SessionStatus.completed:
        return Colors.green;
      case SessionStatus.cancelled:
        return Colors.red;
      case SessionStatus.missed:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(SessionStatus status) {
    switch (status) {
      case SessionStatus.scheduled:
        return Icons.schedule;
      case SessionStatus.completed:
        return Icons.check_circle;
      case SessionStatus.cancelled:
        return Icons.cancel;
      case SessionStatus.missed:
        return Icons.warning;
    }
  }
}
```

---

## 📦 Required Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  table_calendar: ^3.0.9  # For calendar widget
```

---

## 🗄️ Firestore Structure

### Collections

#### `subscriptions/{subscriptionId}`
```json
{
  "id": "sub_123",
  "userId": "user_456",
  "programId": "prog_789",
  "status": "active",
  "startDate": "2024-11-22",
  "renewalDate": "2024-12-22",
  ...
}
```

#### `sessions/{sessionId}`
```json
{
  "userId": "user_456",
  "subscriptionId": "sub_123",
  "programId": "prog_789",
  "programName": "Sunrise Vinyasa Flow",
  "date": "2024-11-25",
  "startTime": "09:00",
  "endTime": "10:30",
  "status": "scheduled",
  "centerId": "center_123",
  "centerName": "Flow & Glow Studio",
  "instructorName": "Leana"
}
```

---

## 🎨 UI Flow Summary

```
1. Program Detail Screen
   ↓ (Click Subscribe)
2. Payment Screen
   ↓ (Confirm Payment)
3. Processing...
   ↓ (Create Subscription)
4. Generate Schedule
   ↓ (Save Sessions)
5. Success Message
   ↓ (Navigate)
6. Calendar Screen
   - Shows all scheduled sessions
   - Marks days with appointments
   - Tap day to see session details
```

---

## 🔧 Next Steps

1. **Integrate Payment Screen** into your subscription flow
2. **Call Schedule Service** after successful payment
3. **Create/Update Calendar Page** to display sessions
4. **Add Navigation** from success to calendar
5. **Test** with both regular and nutrition programs

---

## 💡 Tips

- **Regular Programs**: Sessions are generated based on `weeklyDays`, `startTime`, and date range
- **Nutrition Programs**: Meal delivery sessions are generated based on selected days per week
- **Calendar Marks**: Use `eventLoader` in `TableCalendar` to show dots on days with sessions
- **Status Updates**: Allow users to mark sessions as completed or cancelled

---

**Ready to implement!** Follow the code examples above to complete the subscription and calendar integration. 🚀
