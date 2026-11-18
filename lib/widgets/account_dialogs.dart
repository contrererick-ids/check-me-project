import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_entrega1/utils/auth_errors.dart';

// funcion para reautenticar con contraseña
Future<void> _reauthenticate(User user, String currentPassword) {
  final credential = EmailAuthProvider.credential(
    email: user.email!,
    password: currentPassword,
  );
  return user.reauthenticateWithCredential(credential);
}

// animacionsita
Widget _isLoading() => const SizedBox(
  width: 18,
  height: 18,
  child: CircularProgressIndicator(strokeWidth: 2),
);

// widget cambiar correo
class ChangeEmailDialog extends StatefulWidget {
  const ChangeEmailDialog({super.key});

  @override
  State<ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<ChangeEmailDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final user = FirebaseAuth.instance.currentUser;
    final newEmail = _emailController.text.trim();
    final password = _passwordController.text;

    if (user == null || user.email == null) {
      setState(
        () => _error = 'No se encontró tu sesión. Vuelve a iniciar sesión.',
      );
      return;
    }
    if (newEmail.isEmpty || password.isEmpty) {
      setState(() => _error = 'Completa todos los campos.');
      return;
    }
    if (newEmail.toLowerCase() == user.email!.toLowerCase()) {
      setState(() => _error = 'Ese ya es tu correo actual.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _reauthenticate(user, password);
      // manda un enlace de verificacion al correo nuevo
      await user.verifyBeforeUpdateEmail(newEmail);

      if (!mounted) return;
      Navigator.pop(context, newEmail);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = authErrorMessage(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar correo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _emailController,
              enabled: !_loading,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Correo nuevo'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              enabled: !_loading,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Contraseña actual',
                errorText: _error,
                errorMaxLines: 3,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _loading ? null : _guardar,
          child: _loading
              ? _isLoading()
              : const Text(
                  'Guardar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}

// widget cambiar contraseña
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    final currentPassword = _currentController.text;
    final newPassword = _newController.text;
    final confirm = _confirmController.text;

    if (user == null || user.email == null) {
      setState(
        () => _error = 'No se encontró tu sesión. Vuelve a iniciar sesión.',
      );
      return;
    }
    if (currentPassword.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Completa todos los campos.');
      return;
    }
    if (newPassword.length < 6) {
      setState(
        () => _error = 'La contraseña debe tener al menos 6 caracteres.',
      );
      return;
    }
    if (newPassword != confirm) {
      setState(() => _error = 'Las contraseñas nuevas no coinciden.');
      return;
    }
    if (newPassword == currentPassword) {
      setState(
        () => _error = 'La contraseña nueva debe ser diferente a la actual.',
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _reauthenticate(user, currentPassword);
      await user.updatePassword(newPassword);

      if (!mounted) return;
      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = authErrorMessage(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar contraseña'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _currentController,
              enabled: !_loading,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Contraseña actual'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newController,
              enabled: !_loading,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Contraseña nueva'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              enabled: !_loading,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Confirmar contraseña nueva',
                errorText: _error,
                errorMaxLines: 3,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _loading ? null : _save,
          child: _loading
              ? _isLoading()
              : const Text(
                  'Guardar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}
