import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/widgets/sidebar_drawer.dart';
import 'package:proyecto_entrega1/screens/home.dart';
import 'package:proyecto_entrega1/screens/my_expenses.dart';
import 'package:proyecto_entrega1/screens/groups.dart';
import 'package:proyecto_entrega1/screens/settings.dart';
import 'package:proyecto_entrega1/screens/profile.dart';
import 'package:proyecto_entrega1/services/profile_service.dart';

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  int _currentPageIndex = 0;

  late final List<Widget> _pages = [
    HomePage(),
    GroupsScreen(),
    ExpensesPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // carga nombre, celular y foto del usuario que acaba de entrar
    ProfileService.instance.cargar();
  }

  void _selectPage(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 244, 239, 234),
        actions: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PerfilScreen(),
                  ),
                );
              },
              child: ListenableBuilder(
                listenable: ProfileService.instance,
                builder: (context, _) => CircleAvatar(
                  radius: 30,
                  backgroundImage: ProfileService.instance.foto,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _pages[_currentPageIndex],
      drawer: Sidebar(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentPageIndex,
        onTap: _selectPage,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Grupos'),
          BottomNavigationBarItem(icon: Icon(Icons.moving), label: 'Mis Gastos'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
