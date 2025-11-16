import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionStatus { active, expired, cancelled }
enum PaymentMethod { online, cash }

class SubscriptionModel {
  final String id;
  final String userId;
  final String packageId;
  final String packageTitle;
  final String instructor;
  final double price;
  final String currency;
  final int sessionsPerWeek;
  final int sessionsLeft;
  final SubscriptionStatus status;
  final PaymentMethod paymentMethod;
  final DateTime startDate;
  final DateTime renewalDate;
  final DateTime createdAt;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.packageTitle,
    required this.instructor,
    required this.price,
    this.currency = 'BHD',
    required this.sessionsPerWeek,
    required this.sessionsLeft,
    required this.status,
    required this.paymentMethod,
    required this.startDate,
    required this.renewalDate,
    required this.createdAt,
  });

  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubscriptionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      packageId: data['packageId'] ?? '',
      packageTitle: data['packageTitle'] ?? '',
      instructor: data['instructor'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'BHD',
      sessionsPerWeek: data['sessionsPerWeek'] ?? 0,
      sessionsLeft: data['sessionsLeft'] ?? 0,
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.toString() == 'SubscriptionStatus.${data['status']}',
        orElse: () => SubscriptionStatus.active,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${data['paymentMethod']}',
        orElse: () => PaymentMethod.cash,
      ),
      startDate: (data['startDate'] as Timestamp).toDate(),
      renewalDate: (data['renewalDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'packageId': packageId,
      'packageTitle': packageTitle,
      'instructor': instructor,
      'price': price,
      'currency': currency,
      'sessionsPerWeek': sessionsPerWeek,
      'sessionsLeft': sessionsLeft,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'startDate': Timestamp.fromDate(startDate),
      'renewalDate': Timestamp.fromDate(renewalDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
