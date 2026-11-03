import 'package:flutter/material.dart';

import 'register.dart';

import 'package:proyecto_entrega1/screens/nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';

// svg del logo official de google
const String _googleLogoSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
</svg>
''';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _loadingGoogle = false; // tenemos uno separado para que se vea la animacioncita solo en el boton de continuar con google si se usa google

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _mostrarMensaje(context, 'Ingresa tu correo.');
      return;
    } else if (password.isEmpty) {
      _mostrarMensaje(context, 'Ingresa tu contraseña.');
      return;
    } else if (email.isEmpty && password.isEmpty) {
      _mostrarMensaje(context, 'Ingresa tu correo y contraseña.');
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _mostrarMensaje(context, 'Ocurrio un error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginGoogle() async {
    setState(() => _loadingGoogle = true);

    try {
      final cuenta = await GoogleSignIn.instance.authenticate();

      final credential = GoogleAuthProvider.credential(
        idToken: cuenta.authentication.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavPage()),
      );
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      // si el usuario cancela, no mostramos error
      if (e.code != GoogleSignInExceptionCode.canceled) {
        _mostrarMensaje(context, 'No se pudo iniciar sesion con Google.');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _mostrarMensaje(context, 'Ocurrio un error: $e');
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  void _mostrarMensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
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
            controller: _emailController,
            enabled: !_loading,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Correo',
              hintStyle: const TextStyle(color: Color(0xFFD6D6D6)),
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
                borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
              ),
            ),
          ),

          const SizedBox(height: 26),

          // Campo de contraseña
          TextField(
            controller: _passwordController,
            enabled: !_loading,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Contraseña',
              hintStyle: const TextStyle(color: Color(0xFFD6D6D6)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
              ),
            ),
          ),

          // Recuperar contraseña
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _mostrarMensaje(context, 'Pendiente: recuperar contraseña');
              },
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),

          const SizedBox(height: 35),

          // Boton de inicio de sesion
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (_loading || _loadingGoogle) ? null : _login, // esta condicion evita que toquemos el boton de iniciar sesion si ya tocamos el de continuar con google
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF808080),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 25),

          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFFD6D6D6))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('o', style: TextStyle(color: Color(0xFF808080))),
              ),
              Expanded(child: Divider(color: Color(0xFFD6D6D6))),
            ],
          ),

          const SizedBox(height: 25),

          // Boton de Google
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: (_loading || _loadingGoogle) ? null : _loginGoogle, // esta condicion evita que toquemos el boton de continuar con google si ya tocamos el de iniciar sesion
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(
                  color: Color.fromARGB(255, 188, 188, 188),
                ),
                shape: const StadiumBorder(),
              ),
              child: _loadingGoogle
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color.fromARGB(255, 103, 103, 103),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.string(
                          _googleLogoSvg,
                          width: 22,
                          height: 22,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Continuar con Google',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
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
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
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
