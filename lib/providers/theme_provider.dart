import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mantiene el tema actual y lo guarda
class ThemeProvider extends ChangeNotifier {
  static const _key = 'is_dark_mode';

  bool _isDark = false; // light by default
  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  // se llama antes de runApp para no cargar el tema incorrecto
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDark = prefs.getBool(_key) ?? false;
    } catch (_) {
      // por default el tema claro
    }
  }

  Future<void> toggle() async {
    _isDark = !_isDark;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, _isDark);
    } catch (_) {
      // El tema sigue activo para la sesión aunque no se guarde exitosamente
    }
  }
}