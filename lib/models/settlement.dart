import 'package:cloud_firestore/cloud_firestore.dart';

// representa un pago registrado entre dos miembros para saldar una deuda.
class Settlement {
  Settlement({
    required this.id,
    required this.tripId,
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.amount,
    required this.date,
    required this.createdBy,
  });

  final String id;
  final String tripId;

  // quien pago y quien recibio (uid y nombre)
  final String fromId;
  final String fromName;
  final String toId;
  final String toName;
  final double amount;
  final DateTime date;

  // uid de quien registro el pago
  final String createdBy;

  factory Settlement.fromDoc(
    String tripId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return Settlement(
      id: doc.id,
      tripId: tripId,
      fromId: (data['fromId'] as String?) ?? '',
      fromName: (data['fromName'] as String?) ?? '',
      toId: (data['toId'] as String?) ?? '',
      toName: (data['toName'] as String?) ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: (data['createdBy'] as String?) ?? '',
    );
  }
}
