import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/screens/home.dart';
import 'package:proyecto_entrega1/screens/my_expenses.dart';
import 'package:proyecto_entrega1/screens/groups.dart';
import 'package:proyecto_entrega1/screens/reports.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context); // Cierra el drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 244, 239, 234),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 200,
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Image.asset('assets/Logo_CheckMe!.png',
                width: 300,
                height: 200,
                fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text("Home"),
            onTap: () => _navigateTo(context, const HomePage()),
          ),
          ListTile(
            title: const Text("Grupos"),
            onTap: () => _navigateTo(context, const GroupsScreen()),
          ),
          ListTile(
            title: const Text("Mis Gastos"),
            onTap: () => _navigateTo(context, const ExpensesPage()),
          ),
          ListTile(
            title: const Text("Reportes"),
            onTap: () => _navigateTo(context, const ReportsScreen()),
          ),
        ],
      ),
    );
  }
}