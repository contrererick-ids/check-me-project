import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/screens/nav.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:proyecto_entrega1/screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      //home: NavPage(),
      home: LoginScreen(),

    );
  }
}
