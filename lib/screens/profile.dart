import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_entrega1/screens/login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  void _mostrarMensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _signOut(BuildContext context) async {
    // confirmacion antes de cerrar sesion
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesion'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cerrar sesion',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();

      if (!context.mounted) return;
      // quita todas las pantallas anteriores y regresa al login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!context.mounted) return;
      _mostrarMensaje(context, 'No se pudo cerrar sesion. Intenta de nuevo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar Mi Perfil',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 43, vertical: 20),
        children: [
          const SizedBox(height: 20),

          // Foto de perfil
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 175,
                  height: 175,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        _mostrarMensaje(
                          context,
                          'Pendiente: cambiar foto de perfil',
                        );
                      },
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // Nombre
          const Text(
            'Nombre',
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
          const SizedBox(height: 6),

          TextField(
            decoration: InputDecoration(
              hintText: 'Nombre',
              hintStyle: const TextStyle(
                color: Color.fromARGB(255, 151, 150, 150),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Celular
          const Text(
            'Celular',
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
          const SizedBox(height: 6),

          TextField(
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Celular',
              hintStyle: const TextStyle(
                color: Color.fromARGB(255, 151, 150, 150),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
          ),

          const SizedBox(height: 55),

          // Cerrar sesion
          ElevatedButton(
            onPressed: () => _signOut(context),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: const StadiumBorder(),
            ),
            child: const Text('Cerrar sesión', style: TextStyle(fontSize: 18)),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
