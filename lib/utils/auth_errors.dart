import 'package:firebase_auth/firebase_auth.dart';

// mensajes de error mas para errores de autenticacion con firebase
String authErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'El correo no tiene un formato válido.';
    case 'user-not-found':
      return 'No existe una cuenta con ese correo.';
    case 'user-disabled':
      return 'Esta cuenta está deshabilitada.';
    case 'wrong-password':
    case 'invalid-credential':
      return 'La contraseña actual es incorrecta.';
    case 'weak-password':
      return 'La contraseña nueva es muy débil.';
    case 'email-already-in-use':
      return 'Ese correo ya está en uso por otra cuenta.';
    case 'requires-recent-login':
      return 'Por seguridad, cierra sesión y vuelve a iniciar para hacer este cambio.';
    case 'too-many-requests':
      return 'Demasiados intentos. Espera un momento e intenta de nuevo.';
    case 'network-request-failed':
      return 'Sin conexión. Revisa tu internet e intenta de nuevo.';
    default:
      return 'Ocurrió un error. Intenta de nuevo.';
  }
}
