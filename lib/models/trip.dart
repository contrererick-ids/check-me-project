
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
    this.groupId,
    this.groupName,
  });

  final String id;
  final String title;
  final String ownerId;
  final Map<String, String> memberNames;
  final DateTime startDate;
  final DateTime endDate;
  final String currency;
  final String status;

  final String? groupId;
  final String? groupName;

  List<String> get userIds => memberNames.keys.toList();

  Trip copyWith({
    String? groupId,
    String? groupName,
    Map<String, String>? memberNames,
  }) {
    return Trip(
      id: id,
      title: title,
      ownerId: ownerId,
      memberNames: memberNames ?? this.memberNames,
      startDate: startDate,
      endDate: endDate,
      currency: currency,
      status: status,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
    );
  }

  factory Trip.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final members = Map<String, dynamic>.from(
      (data['members'] as Map<String, dynamic>?) ?? {},
    );

    return Trip(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      ownerId: (data['ownerId'] as String?) ?? '',
      memberNames: members.map(
        (id, name) => MapEntry(id, '$name'),
      ),
      startDate:
          (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate:
          (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      currency: (data['currency'] as String?) ?? 'MXN',
      status: (data['status'] as String?) ?? 'active',
      groupId: data['groupId'] as String?,
      groupName: data['groupName'] as String?,
    );
  }
}
