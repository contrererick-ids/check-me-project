
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:proyecto_entrega1/models/group.dart';
import 'package:proyecto_entrega1/models/group_member.dart';

class GroupService {
  GroupService._();

  static FirebaseFirestore get _db =>
      FirebaseFirestore.instance;

  static User? get _user =>
      FirebaseAuth.instance.currentUser;

  // Obtener los grupos donde participa el usuario actual.
  static Stream<List<Group>> groupsStream() {
    final user = _user;

    if (user == null) {
      return Stream.value(<Group>[]);
    }

    return _db
        .collection('groups')
        .where('memberIds', arrayContains: user.uid)
        .snapshots()
        .map((snapshot) {
      final groups = snapshot.docs
          .map((doc) => Group.fromMap(doc.id, doc.data()))
          .toList();

      groups.sort((a, b) {
        return (b.createdAt ?? DateTime(2000))
            .compareTo(a.createdAt ?? DateTime(2000));
      });

      return groups;
    });
  }

  // Forzar una consulta de los grupos directamente a Firebase.
  static Future<void> refreshGroups() async {
    final user = _user;

    if (user == null) {
      throw StateError('No hay sesión iniciada');
    }

    await _db
        .collection('groups')
        .where('memberIds', arrayContains: user.uid)
        .get(
          const GetOptions(source: Source.server),
        );
  }


  // Crear un grupo agregando automáticamente al creador.
  static Future<String> createGroup(String name) async {
    final user = _user;

    if (user == null) {
      throw StateError('No hay sesión iniciada');
    }

    if (name.trim().isEmpty) {
      throw ArgumentError('El nombre del grupo es obligatorio');
    }

    // Consultar los datos del perfil del creador.
    final userDoc = await _db
        .collection('usuarios')
        .doc(user.uid)
        .get();

    final userData = userDoc.data();

    final nombre =
        (userData?['nombre'] as String?)?.trim().isNotEmpty == true
            ? (userData!['nombre'] as String).trim()
            : user.displayName ?? user.email ?? 'Usuario';

    final celular = userData?['celular'] as String?;

    // Crear identificador del grupo.
    final groupRef = _db.collection('groups').doc();

    // Crear al integrante que representa al creador.
    final creator = GroupMember(
      id: user.uid,
      name: nombre,
      phone: celular,
      userId: user.uid,
    );

    // Construir el grupo.
    final group = Group(
      id: groupRef.id,
      name: name.trim(),
      members: [creator],
      memberIds: [user.uid],
      tripIds: [],
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    // Guardar en Firebase.
    final data = group.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();

    await groupRef.set(data);

    return groupRef.id;
  }

  // Eliminar un grupo de Firebase.
  static Future<void> deleteGroup(String groupId) async {
    final user = _user;

    if (user == null) {
      throw StateError('No hay sesión iniciada');
    }

    final groupRef = _db.collection('groups').doc(groupId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(groupRef);

      if (!snapshot.exists) {
        throw Exception('El grupo no existe');
      }

      final data = snapshot.data()!;

      // Solo el creador puede eliminar el grupo.
      if (data['createdBy'] != user.uid) {
        throw Exception(
          'Solo el administrador puede eliminar el grupo',
        );
      }

      transaction.delete(groupRef);
    });
  }

  // Buscar si un número telefónico pertenece a un usuario registrado.
  static Future<GroupMember?> findUserByPhone(String phone) async {
    final normalizedPhone = _normalizePhone(phone);

    if (normalizedPhone.isEmpty) {
      return null;
    }

    final result = await _db
        .collection('usuarios')
        .where(
          'celularNormalizado',
          isEqualTo: normalizedPhone,
        )
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return null;
    }

    final userDoc = result.docs.first;
    final data = userDoc.data();

    return GroupMember(
      id: userDoc.id,
      name: data['nombre'] ?? 'Usuario',
      phone: data['celular'] ?? phone,
      userId: userDoc.id,
    );
  }

  // Agregar un integrante al grupo.
  static Future<void> addMember(
    String groupId,
    GroupMember member,
  ) async {
    final user = _user;

    if (user == null) {
      throw StateError('No hay sesión iniciada');
    }

    final groupRef = _db.collection('groups').doc(groupId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(groupRef);

      if (!snapshot.exists) {
        throw Exception('El grupo no existe');
      }

      final data = snapshot.data()!;

      // Solo el creador puede administrar integrantes.
      if (data['createdBy'] != user.uid) {
        throw Exception(
          'Solo el creador puede administrar los integrantes',
        );
      }

      final members = List<Map<String, dynamic>>.from(
        (data['members'] as List<dynamic>? ?? []).map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );

      final memberIds = List<String>.from(
        data['memberIds'] ?? [],
      );

      // Evitar agregar dos veces al mismo integrante.
      final alreadyExists = members.any((item) {
        if (item['id'] == member.id) return true;

        final existingPhone = _normalizePhone(item['phone']);
        final newPhone = _normalizePhone(member.phone);

        return existingPhone.isNotEmpty &&
            newPhone.isNotEmpty &&
            existingPhone == newPhone;
      });

      if (alreadyExists) {
        throw Exception('Esta persona ya pertenece al grupo');
      }

      members.add(member.toMap());

      // Si tiene cuenta, agregar su UID.
      if (member.userId != null &&
          !memberIds.contains(member.userId)) {
        memberIds.add(member.userId!);
      }

      transaction.update(groupRef, {
        'members': members,
        'memberIds': memberIds,
      });
    });
  }

  // Eliminar un integrante del grupo.
  static Future<void> removeMember(
    String groupId,
    String memberId,
  ) async {
    final user = _user;

    if (user == null) {
      throw StateError('No hay sesión iniciada');
    }

    final groupRef = _db.collection('groups').doc(groupId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(groupRef);

      if (!snapshot.exists) {
        throw Exception('El grupo no existe');
      }

      final data = snapshot.data()!;

      // Solo el creador puede administrar integrantes.
      if (data['createdBy'] != user.uid) {
        throw Exception(
          'Solo el creador puede administrar los integrantes',
        );
      }

      // No permitir eliminar al creador.
      if (memberId == data['createdBy']) {
        throw Exception(
          'No puedes eliminar al creador del grupo',
        );
      }

      final members = List<Map<String, dynamic>>.from(
        (data['members'] as List<dynamic>? ?? []).map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );

      final member = members.where(
        (item) => item['id'] == memberId,
      );

      if (member.isEmpty) {
        throw Exception('El integrante no existe');
      }

      final memberUserId = member.first['userId'];

      members.removeWhere(
        (item) => item['id'] == memberId,
      );

      final memberIds = List<String>.from(
        data['memberIds'] ?? [],
      );

      if (memberUserId != null) {
        memberIds.remove(memberUserId);
      }

      transaction.update(groupRef, {
        'members': members,
        'memberIds': memberIds,
      });
    });
  }

  // Normalizar teléfonos mexicanos.
  static String _normalizePhone(String? phone) {
    if (phone == null) return '';

    String number = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (number.length == 12 && number.startsWith('52')) {
      number = number.substring(2);
    }

    if (number.length == 13 && number.startsWith('521')) {
      number = number.substring(3);
    }

    return number;
  }
}
