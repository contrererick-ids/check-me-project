import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_entrega1/models/expense.dart';
import 'package:proyecto_entrega1/models/settlement.dart';
import 'package:proyecto_entrega1/models/trip.dart';
import 'package:proyecto_entrega1/models/group.dart';
import 'package:proyecto_entrega1/models/group_member.dart';

class TripsService {
  TripsService._();

  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static User? get _user => FirebaseAuth.instance.currentUser;

  static String? get uid => _user?.uid;

  static String get currentName {
    final name = _user?.displayName?.trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return _user?.email ?? 'Yo';
  }

  // Ejecuta operaciones de escritura en Firestore.
  static Future<bool> _write(Future<dynamic> Function() operation) async {
    try {
      await operation().timeout(const Duration(seconds: 10));
      return true;
    } on TimeoutException {
      return false;
    }
  }

  // Obtener las actividades del usuario actual.
  static Stream<List<Trip>> tripsStream() {
    final userId = _user?.uid;

    if (userId == null) {
      return Stream.value(<Trip>[]);
    }

    return _db
        .collection('trips')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final trips = snapshot.docs.map(Trip.fromDoc).toList();

          trips.sort((a, b) => b.startDate.compareTo(a.startDate));

          return trips;
        });
  }

  // Obtener los gastos de una actividad.
  static Stream<List<Expense>> expensesStream(String tripId) {
    return _db
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Expense.fromDoc(tripId, doc)).toList(),
        );
  }

  // pagos registrados de una actividad, mas recientes primero
  static Stream<List<Settlement>> settlementsStream(String tripId) {
    return _db
        .collection('trips')
        .doc(tripId)
        .collection('settlements')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Settlement.fromDoc(tripId, doc))
              .toList(),
        );
  }

  // Crear una actividad sin asociarla a un grupo.
  static Future<bool> createTrip(String title) {
    final user = _user;

    if (user == null) {
      throw StateError('No hay sesión iniciada');
    }

    if (title.trim().isEmpty) {
      throw ArgumentError('El nombre de la actividad es obligatorio');
    }

    return _write(() async {
      final now = Timestamp.now();

      await _db.collection('trips').add({
        'title': title.trim(),
        'ownerId': user.uid,
        'memberIds': [user.uid],
        'members': {user.uid: currentName},
        'startDate': now,
        'endDate': now,
        'currency': 'MXN',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // Asociar o cambiar el grupo y los participantes de una actividad.
  static Future<bool> updateTripGroup({
    required Trip trip,
    required Group group,
    required List<GroupMember> selectedMembers,
  }) {
    final user = _user;

    if (user == null) {
      throw StateError('No hay sesión iniciada');
    }

    return _write(() async {
      final tripRef = _db.collection('trips').doc(trip.id);
      final newGroupRef = _db.collection('groups').doc(group.id);

      // Verificar que el grupo todavía exista.
      final newGroupSnapshot = await newGroupRef.get();

      if (!newGroupSnapshot.exists) {
        throw StateError('El grupo seleccionado ya no existe.');
      }

      // Construir la lista de participantes de esta actividad.
      final membersMap = <String, String>{};
      final memberIds = <String>{user.uid};

      for (final member in selectedMembers) {
        membersMap[member.id] = member.name;

        // Los integrantes registrados tienen userId.
        // Los contactos telefónicos se guardan en members,
        // pero no se agregan a memberIds.
        if (member.userId != null) {
          memberIds.add(member.userId!);
        }
      }

      // El creador siempre forma parte de la actividad.
      membersMap.putIfAbsent(user.uid, () => currentName);

      final batch = _db.batch();

      // Actualizar la actividad.
      batch.update(tripRef, {
        'groupId': group.id,
        'groupName': group.name,
        'members': membersMap,
        'memberIds': memberIds.toList(),
      });

      // Si se cambió de grupo, quitar la actividad del anterior.
      if (trip.groupId != null && trip.groupId != group.id) {
        final oldGroupRef = _db.collection('groups').doc(trip.groupId);

        final oldGroupSnapshot = await oldGroupRef.get();

        if (oldGroupSnapshot.exists) {
          batch.update(oldGroupRef, {
            'tripIds': FieldValue.arrayRemove([trip.id]),
          });
        }
      }

      // Asociar la actividad al grupo nuevo.
      batch.update(newGroupRef, {
        'tripIds': FieldValue.arrayUnion([trip.id]),
      });

      await batch.commit();
    });
  }

  // Agregar un gasto a una actividad.
  static Future<bool> addExpense({
    required Trip trip,
    required String title,
    required String paidById,
    required double amount,
  }) {
    final user = _user;

    if (user == null) {
      throw StateError('No hay sesión iniciada');
    }

    return _write(
      () => _db.collection('trips').doc(trip.id).collection('expenses').add({
        'title': title,
        'paidById': paidById,
        'paidBy': trip.memberNames[paidById] ?? 'Miembro',
        'amount': (amount * 100).round() / 100,
        'date': Timestamp.now(),
        'createdBy': user.uid,
      }),
    );
  }

  // registrar que [fromId] le pago [amount] a [toId].
  static Future<bool> addSettlement({
    required Trip trip,
    required String fromId,
    required String fromName,
    required String toId,
    required String toName,
    required double amount,
  }) {
    final user = _user;

    if (user == null) {
      throw StateError('No hay sesión iniciada');
    }

    if (fromId == toId) {
      throw ArgumentError('No se puede registrar un pago a uno mismo');
    }

    final cents = (amount * 100).round() / 100;

    if (cents <= 0) {
      throw ArgumentError('El monto debe ser mayor a 0');
    }

    return _write(
      () => _db.collection('trips').doc(trip.id).collection('settlements').add({
        'fromId': fromId,
        'fromName': fromName,
        'toId': toId,
        'toName': toName,
        'amount': cents,
        'date': Timestamp.now(),
        'createdBy': user.uid,
      }),
    );
  }

  // eliminar un pago registrado.
  static Future<bool> deleteSettlement({
    required String tripId,
    required String settlementId,
  }) {
    final user = _user;

    if (user == null) {
      throw StateError('No hay sesión iniciada');
    }

    return _write(
      () => _db
          .collection('trips')
          .doc(tripId)
          .collection('settlements')
          .doc(settlementId)
          .delete(),
    );
  }
}
