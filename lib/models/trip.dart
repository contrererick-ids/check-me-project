import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  const Trip({
    required this.id,
    required this.title,
    required this.ownerId,
    required this.memberNames,
    required this.startDate,
    required this.endDate,
    required this.currency,
    required this.status,
  });

  final String id;
  final String title;
  final String ownerId;
  final Map<String, String> memberNames;
  final DateTime startDate;
  final DateTime endDate;
  final String currency;
  final String status;

  List<String> get userIds => memberNames.keys.toList();

  factory Trip.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final members = Map<String, dynamic>.from(
      (data['members'] as Map<String, dynamic>?) ?? {},
    );

    return Trip(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      ownerId: (data['ownerId'] as String?) ?? '',
      memberNames: members.map((uid, nombre) => MapEntry(uid, '$nombre')),
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      currency: (data['currency'] as String?) ?? 'MXN',
      status: (data['status'] as String?) ?? 'active',
    );
  }
}
