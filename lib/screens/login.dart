
import 'package:flutter/material.dart';
import 'register.dart';
import 'package:proyecto_entrega1/screens/nav.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _mostrarMensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 20,
        ),
        children: [
          const SizedBox(height: 50),

          // Titulo
          const Text(
            'Bienvenido',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 55),

          // Campo de correo
          TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Correo',
              hintStyle: const TextStyle(
                color: Color(0xFFD6D6D6),
              ),
              suffixIcon: const Icon(
                Icons.mail_outline,
                color: Color(0xFFD6D6D6),
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
                borderSide: const BorderSide(
                  color: Color(0xFFD6D6D6),
                ),
              ),
            ),
          ),

          const SizedBox(height: 26),

          // Campo de contraseña
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Contraseña',
              hintStyle: const TextStyle(
                color: Color(0xFFD6D6D6),
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
                borderSide: const BorderSide(
                  color: Color(0xFFD6D6D6),
                ),
              ),
            ),
          ),

          // Recuperar contraseña
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _mostrarMensaje(
                  context,
                  'Pendiente: recuperar contraseña',
                );
              },
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(height: 35),

          // Boton de inicio de sesion
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NavPage(),
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
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),

          const SizedBox(height: 120),

          // Acceso al registro
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              const Text(
                '¿No tienes una cuenta? ',
                style: TextStyle(fontSize: 15),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Crea una cuenta',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}