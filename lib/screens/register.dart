
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  Widget _campo({
    required String etiqueta,
    bool password = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF808080),
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          obscureText: password,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFFD6D6D6),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Crear cuenta',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        children: [
          const SizedBox(height: 15),

          // Nombre
          _campo(
            etiqueta: 'Nombre',
          ),

          const SizedBox(height: 18),

          // Correo
          _campo(
            etiqueta: 'Correo',
          ),

          const SizedBox(height: 18),

          // Contraseña
          _campo(
            etiqueta: 'Contraseña',
            password: true,
          ),

          const SizedBox(height: 18),

          // Confirmacion de contraseña
          _campo(
            etiqueta: 'Confirmar contraseña',
            password: true,
          ),

          const SizedBox(height: 60),

          // Boton para crear cuenta
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pendiente: crear cuenta'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF808080),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: const Text(
                'Crear cuenta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}