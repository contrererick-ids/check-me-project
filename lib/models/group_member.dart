 
class GroupMember {
  GroupMember({
    required this.id,
    required this.name,
    this.phone,
    this.userId,
  });

  final String id;
  final String name;
  final String? phone;
  final String? userId;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'userId': userId,
    };
  }

  factory GroupMember.fromMap(Map<String, dynamic> map) {
    return GroupMember(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'],
      userId: map['userId'],
    );
  }
}
