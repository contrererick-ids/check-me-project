
import 'package:proyecto_entrega1/models/group_member.dart';

class Group {
  Group({
    required this.id,
    required this.name,
    List<GroupMember>? members,
    List<String>? memberNames,
    List<String>? memberIds,
    required this.tripIds,
    this.createdBy,
    this.createdAt,
  })  : members = members ??
            (memberNames ?? []).asMap().entries.map((entry) {
              return GroupMember(
                id: 'legacy_${entry.key}_${entry.value}',
                name: entry.value,
              );
            }).toList(),
        memberIds = memberIds ??
            (members ?? [])
                .where((member) => member.userId != null)
                .map((member) => member.userId!)
                .toList();

  final String id;
  String name;

  List<GroupMember> members;
  List<String> memberIds;
  List<String> tripIds;

  String? createdBy;
  DateTime? createdAt;

  // Compatibilidad temporal con el código anterior.
  List<String> get memberNames =>
      members.map((member) => member.name).toList();

  set memberNames(List<String> names) {
    members = names.asMap().entries.map((entry) {
      final existing = members.where(
        (member) => member.name == entry.value,
      );

      if (existing.isNotEmpty) {
        return existing.first;
      }

      return GroupMember(
        id: 'legacy_${DateTime.now().microsecondsSinceEpoch}_${entry.key}',
        name: entry.value,
      );
    }).toList();

    memberIds = members
        .where((member) => member.userId != null)
        .map((member) => member.userId!)
        .toList();
  }

  // Convertir el grupo a un mapa para Firebase.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'members': members.map((member) => member.toMap()).toList(),
      'memberIds': memberIds,
      'tripIds': tripIds,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  // Recuperar un grupo desde Firebase.
  factory Group.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final members = (map['members'] as List<dynamic>? ?? [])
        .map(
          (member) => GroupMember.fromMap(
            Map<String, dynamic>.from(member),
          ),
        )
        .toList();

    final createdAtValue = map['createdAt'];

    DateTime? date;

    if (createdAtValue is DateTime) {
      date = createdAtValue;
    } else if (createdAtValue != null) {
      date = createdAtValue.toDate();
    }

    return Group(
      id: id,
      name: map['name'] ?? '',
      members: members,
      memberIds: List<String>.from(
        map['memberIds'] ??
            members
                .where((member) => member.userId != null)
                .map((member) => member.userId!)
                .toList(),
      ),
      tripIds: List<String>.from(map['tripIds'] ?? []),
      createdBy: map['createdBy'],
      createdAt: date,
    );
  }
}
