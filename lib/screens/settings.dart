import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_entrega1/widgets/account_dialogs.dart';
import 'package:proyecto_entrega1/utils/snackbar_utils.dart';
import 'package:proyecto_entrega1/screens/profile.dart';
import 'package:proyecto_entrega1/services/profile_service.dart';

const String _fotoDefault =
    "https://static.vecteezy.com/system/resources/previews/020/765/399/original/default-profile-account-unknown-icon-black-silhouette-free-vector.jpg";

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User? get _user => FirebaseAuth.instance.currentUser;

  // solo las cuentas con login nativo pueden cambiar correo y contraseña. las de google se administran desde google.
  bool get _isNativeLogin =>
      _user?.providerData.any((p) => p.providerId == 'password') ?? false;

  @override
  void initState() {
    super.initState();
    // refresca los datos del usuario por si el correo cambio desde otro lado
    _user
        ?.reload()
        .then((_) {
          if (mounted) setState(() {});
        })
        .catchError((_) {});
  }

  Future<void> _editEmail() async {
    final newEmail = await showDialog<String>(
      context: context,
      builder: (_) => const ChangeEmailDialog(),
    );

    if (newEmail == null || !mounted) return;
    showSnackbarMessage(
      context,
      'Te enviamos un enlace de verificación a $newEmail. Tu correo cambiará cuando lo confirmes.',
    );
  }

  Future<void> _editPassword() async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => const ChangePasswordDialog(),
    );

    if (updated != true || !mounted) return;
    showSnackbarMessage(context, 'Contraseña actualizada correctamente.');
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final email = user?.email ?? 'Sin correo';

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          ListenableBuilder(
            listenable: ProfileService.instance,
            builder: (context, _) {
              final perfil = ProfileService.instance;
              return ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PerfilScreen()),
                ),
                leading: CircleAvatar(radius: 30, backgroundImage: perfil.foto),
                title: Text(
                  perfil.nombre,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.chevron_right),
              );
            },
          ),
          const SizedBox(height: 16),

          /* Personal Info */
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color.fromARGB(255, 219, 215, 211),
              ),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información personal',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(email),
                    trailing: _isNativeLogin
                        ? IconButton(
                            onPressed: _editEmail,
                            icon: Icon(Icons.edit),
                          )
                        : null,
                  ),
                  ListTile(
                    title: Text(
                      'Contraseña',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _isNativeLogin
                          ? '***********'
                          : 'Inicio de sesión con Google',
                    ),
                    trailing: _isNativeLogin
                        ? IconButton(
                            onPressed: _editPassword,
                            icon: Icon(Icons.edit),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          /* Theme */
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color.fromARGB(255, 219, 215, 211),
              ),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tema de la Aplicación',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: Text('Modo Oscuro'),
                    trailing: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Pendiente función cambiar entre modo oscuro y modo claro',
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.dark_mode),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
