import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Guarda el perfil de la app (nombre y celular en Firestore, foto en local)
/// y avisa a todas las pantallas cuando algo cambia.
class ProfileService extends ChangeNotifier {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  User? get _user => FirebaseAuth.instance.currentUser;

  String? _uid;
  String? _nombreApp;
  String _celular = '';
  File? _fotoLocal;
  bool _cargado = false;

  bool get cargado => _cargado;
  String get celular => _celular;
  bool get tieneFotoLocal => _fotoLocal != null;

  /// Nombre de la app; si no existe, el de Google/Auth; si no, cadena vacía.
  String get nombreParaEditar {
    final app = _nombreApp?.trim() ?? '';
    if (app.isNotEmpty) return app;
    return _user?.displayName?.trim() ?? '';
  }

  /// Nombre para mostrar en pantalla.
  String get nombre {
    final n = nombreParaEditar;
    return n.isEmpty ? 'Usuario' : n;
  }

  /// Foto local > foto de Google > imagen por defecto.
  ImageProvider? get foto {
    final local = _fotoLocal;
    if (local != null) return FileImage(local);
    final url = _user?.photoURL;
    return url != null ? NetworkImage(url) : null;
  }

  Future<File> _archivoFoto(String uid) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/foto_perfil_$uid.jpg');
  }

  void _reiniciar() {
    _nombreApp = null;
    _celular = '';
    _fotoLocal = null;
    _cargado = false;
  }

  /// Carga nombre/celular desde Firestore y busca la foto local.
  Future<void> cargar() async {
    final user = _user;
    if (user == null) {
      limpiar();
      return;
    }
    if (_uid != user.uid) {
      _reiniciar();
      _uid = user.uid;
    }

    try {
      final doc = await _db.collection('usuarios').doc(user.uid).get();
      final datos = doc.data();
      _nombreApp = datos?['nombre'] as String?;
      _celular = (datos?['celular'] as String?) ?? '';
    } catch (_) {
      // sin conexión o sin documento: se usan los datos de Auth
    }

    final archivo = await _archivoFoto(user.uid);
    _fotoLocal = await archivo.exists() ? archivo : null;

    _cargado = true;
    notifyListeners();
  }

  /// Llamar al cerrar sesión para no mostrar datos del usuario anterior.
  void limpiar() {
    _uid = null;
    _reiniciar();
    notifyListeners();
  }

  /// Guarda nombre y celular en Firestore. Lanza excepción si falla.
  Future<void> guardarDatos({
    required String nombre,
    required String celular,
  }) async {
    final user = _user;
    if (user == null) throw StateError('No hay sesión iniciada');

    await _db
        .collection('usuarios')
        .doc(user.uid)
        .set({
          'nombre': nombre,
          'celular': celular,
          'actualizado': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        .timeout(const Duration(seconds: 10));

    _nombreApp = nombre;
    _celular = celular;
    notifyListeners();
  }

  /// Abre cámara o galería y guarda la foto. Devuelve false si el usuario cancela.
  Future<bool> cambiarFoto(ImageSource fuente) async {
    final user = _user;
    if (user == null) throw StateError('No hay sesión iniciada');

    final elegida = await ImagePicker().pickImage(
      source: fuente,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (elegida == null) return false;

    final destino = await _archivoFoto(user.uid);
    await File(elegida.path).copy(destino.path);

    // el nombre del archivo no cambia, así que hay que sacar la versión vieja del caché
    await FileImage(destino).evict();

    _fotoLocal = destino;
    notifyListeners();
    return true;
  }

  /// Elimina la foto de la app; se vuelve a mostrar la de Google (o la default).
  Future<void> eliminarFoto() async {
    final user = _user;
    if (user == null) throw StateError('No hay sesión iniciada');

    final archivo = await _archivoFoto(user.uid);
    await FileImage(archivo).evict();
    if (await archivo.exists()) await archivo.delete();

    _fotoLocal = null;
    notifyListeners();
  }
}
