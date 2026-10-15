import 'package:flutter/material.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  void _mostrarMensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
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
            onPressed: () {
              _mostrarMensaje(context, 'Pendiente: cerrar sesión');
            },
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
