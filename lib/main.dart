import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:proyecto_entrega1/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_entrega1/firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:proyecto_entrega1/screens/nav.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_entrega1/providers/trips_provider.dart';
import 'package:proyecto_entrega1/providers/theme_provider.dart';
import 'package:proyecto_entrega1/theme/app_theme.dart';
import 'package:proyecto_entrega1/services/token_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize();
  PushTokenService.instance.init();
  await initializeDateFormatting('es', null);
  final themeProvider = ThemeProvider();
  await themeProvider.load();
  runApp(MyApp(themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.themeProvider});

  final ThemeProvider themeProvider;
  static final Stream<User?> _authStream = FirebaseAuth.instance
      .authStateChanges();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripsProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.themeMode,
          home: StreamBuilder<User?>(
            stream: _authStream,
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
        ),
      ),
    );
  }
}
