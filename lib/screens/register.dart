import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _campo({
    required String etiqueta,
    bool password = false,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(fontSize: 15, color: Color(0xFF808080)),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: controller,
          obscureText: password,
          enabled: !_loading,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
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

  void _mostrarMensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _createAccount() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _mostrarMensaje(context, "Completa todos los campos");
      return;
    }
    if (password.length < 6) {
      _mostrarMensaje(
        context,
        "La contraseña debe tener al menos 6 caracteres",
      );
      return;
    }
    if (password != confirm) {
      _mostrarMensaje(context, "Las contraseñas no coinciden");
      return;
    }

    setState(() => _loading = true);

    try {
      final credentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await credentials.user?.updateDisplayName(username);

      if (!mounted) return;
      // si firebase ya inicio sesion, volvemos a la raiz
      Navigator.of(context).popUntil((route) => route.isFirst);

      if(mounted) {
        _mostrarMensaje(context, "Cuenta creada correctamente");
      }
      
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _mostrarMensaje(context, "Ocurrio un error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
          _campo(etiqueta: 'Nombre', controller: _usernameController),

          const SizedBox(height: 18),

          // Correo
          _campo(
            etiqueta: 'Correo',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 18),

          // Contraseña
          _campo(
            etiqueta: 'Contraseña',
            controller: _passwordController,
            password: true,
          ),

          const SizedBox(height: 18),

          // Confirmacion de contraseña
          _campo(
            etiqueta: 'Confirmar contraseña',
            controller: _confirmController,
            password: true,
          ),

          const SizedBox(height: 60),

          // Boton para crear cuenta
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _createAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF808080),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
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
