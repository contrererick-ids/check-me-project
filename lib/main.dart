import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:proyecto_entrega1/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_entrega1/firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:proyecto_entrega1/screens/nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize();
  await initializeDateFormatting('es', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 244, 239, 234),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // si ya hay sesion iniciada, va directo a NavPage. si no, a LoginScreen
          if (snapshot.hasData) {
            return const NavPage();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
