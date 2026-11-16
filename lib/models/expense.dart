import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  Expense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.paidById,
    required this.paidBy,
    required this.amount,
    required this.date,
  });

  final String id;
  final String tripId;
  final String title;
  final String paidById;
  final String paidBy;
  final double amount;
  final DateTime date;

  factory Expense.fromDoc(
    String tripId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return Expense(
      id: doc.id,
      tripId: tripId,
      title: (data['title'] as String?) ?? '',
      paidById: (data['paidById'] as String?) ?? '',
      paidBy: (data['paidBy'] as String?) ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
