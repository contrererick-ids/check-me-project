import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// obtiene el token del dispositivo y lo guarda en el documento del usuario

class PushTokenService {
  PushTokenService._();
  static final PushTokenService instance = PushTokenService._();

  StreamSubscription<User?>? _authSub;
  StreamSubscription<String>? _refreshSub;

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // se inicia con authStateChanges, de esta forma funciona igual al registrar cuenta, si se hace login nativo, con Google o si la app se arranca con una sesion ya iniciada
  void init() {
    _authSub ??= FirebaseAuth.instance.authStateChanges().listen(
      _onSessionChange,
    );
  }

  Future<void> _onSessionChange(User? user) async {
    // siempre se cancela la escucha anterior (cierre de sesión o cambio de usuario)
    await _refreshSub?.cancel();
    _refreshSub = null;

    if (user == null) return;

    final uid = user.uid;

    // actualizar token en firestore si cambia mientras la sesion sigue abierta
    _refreshSub = _messaging.onTokenRefresh.listen(
      (token) => _save(uid, token),
      onError: (Object e) => debugPrint('onTokenRefresh error: $e'),
    );

    await _registerToken(uid);
  }

  Future<void> _registerToken(String uid) async {
    try {
      await _messaging.requestPermission(); // solo porque se debe pedir permiso para mostrar notificaciones, pero el token se guarda igual

      final token = await _messaging.getToken();
      if (token != null) await _save(uid, token);
    } catch (e) {
      debugPrint('No se pudo obtener el token: $e');
    }
  }

  Future<void> _save(String uid, String token) async {
    try {
      await _db
          .collection('usuarios')
          .doc(uid)
          .set({
            'token': token,
            'tokenUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('No se pudo guardar el token: $e');
    }
  }

  // nota: se debe llamar antes de FirebaseAuth.signOut() para que el siguiente usuario de este dispositivo no herede las notificaciones
  Future<void> deleteToken() async {
    await _refreshSub?.cancel();
    _refreshSub = null;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await _db
          .collection('usuarios')
          .doc(uid)
          .set({
            'token': FieldValue.delete(),
            'tokenUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('No se pudo borrar el token: $e');
    }
  }
}
