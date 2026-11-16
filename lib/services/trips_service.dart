import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_entrega1/models/expense.dart';
import 'package:proyecto_entrega1/models/trip.dart';

// acceso a Firestore para actividades (trips) y sus cargos (expenses).
class TripsService {
  TripsService._();

  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static User? get _user => FirebaseAuth.instance.currentUser;

  static String? get uid => _user?.uid;

  // nombre con el que aparece el usuario actual en las actividades
  static String get currentName {
    final name = _user?.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return _user?.email ?? 'Yo';
  }

  static Future<bool> _write(Future<dynamic> operation) async {
    try {
      await operation.timeout(const Duration(seconds: 10));
      return true;
    } on TimeoutException {
      return false;
    }
  }

  // actividades donde participa el usuario actual, mas recientes primero
  static Stream<List<Trip>> tripsStream() {
    final uid = _user?.uid;
    if (uid == null) return Stream.value(<Trip>[]);

    return _db
        .collection('trips')
        .where('memberIds', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
          final trips = snapshot.docs.map(Trip.fromDoc).toList();
          // se ordena aqui para no requerir un indice compuesto en firestore
          trips.sort((a, b) => b.startDate.compareTo(a.startDate));
          return trips;
        });
  }

  // gastos de una actividad, mas recientes primero
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

  // crea la actividad con el usuario actual como dueño y miembro.
  static Future<bool> createTrip(String title) {
    final user = _user;
    if (user == null) throw StateError('No hay sesión iniciada');

    final ahora = Timestamp.now();

    return _write(
      _db.collection('trips').add({
        'title': title,
        'ownerId': user.uid,
        'memberIds': [user.uid],
        'members': {user.uid: currentName},
        'startDate': ahora,
        'endDate': ahora,
        'currency': 'MXN',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      }),
    );
  }

  // agrega gasto
  static Future<bool> addExpense({
    required Trip trip,
    required String title,
    required String paidById,
    required double amount,
  }) {
    final user = _user;
    if (user == null) throw StateError('No hay sesión iniciada');

    return _write(
      _db.collection('trips').doc(trip.id).collection('expenses').add({
        'title': title,
        'paidById': paidById,
        'paidBy': trip.memberNames[paidById] ?? 'Miembro',
        'amount': (amount * 100).round() / 100, // redondeado a centavos
        'date': Timestamp.now(),
        'createdBy': user.uid,
      }),
    );
  }
}
