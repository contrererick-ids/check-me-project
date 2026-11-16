import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:proyecto_entrega1/models/trip.dart';
import 'package:proyecto_entrega1/services/trips_service.dart';

// guarda las actividades del usuario con una subscripcion a firestore, compartida por las pantallas
class TripsProvider extends ChangeNotifier {
  TripsProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onUserChanged);
  }

  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<Trip>>? _tripsSub;
  List<Trip> _trips = const [];
  bool _loading = true;
  Object? _error;
  List<Trip> get trips => _trips;
  bool get loading =>
      _loading; // true mientras llega la primera respuesta de Firestore
  Object? get error => _error;

  // se escuchan los cambios de sesion, si el usuario cierra sesion cancela la subscripcion anterior para que se abra una nueva
  void _onUserChanged(User? user) {
    _tripsSub?.cancel();
    _tripsSub = null;
    _trips = const [];
    _error = null;

    if (user == null) {
      _loading = false;
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();

    _tripsSub = TripsService.tripsStream().listen(
      (trips) {
        _trips = trips;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _error = e;
        _loading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _tripsSub?.cancel();
    super.dispose();
  }
}
