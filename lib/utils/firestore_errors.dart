import 'package:cloud_firestore/cloud_firestore.dart';

// mensajes de error para los errores de firestore
String firestoreErrorMessage(Object error) {
  if (error is FirebaseException) {
    switch (error.code) {
      case 'unavailable':
        return 'Sin conexión con el servidor. Intenta de nuevo.';
      case 'not-found':
        return 'No se encontró la información. Puede que se haya eliminado.';
    }
  }
  return 'Ocurrió un error. Intenta de nuevo.';
}
