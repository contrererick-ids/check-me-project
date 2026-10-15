import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/widgets/sidebar_drawer.dart';
import 'package:proyecto_entrega1/screens/home.dart';
import 'package:proyecto_entrega1/screens/my_expenses.dart';
import 'package:proyecto_entrega1/screens/groups.dart';
import 'package:proyecto_entrega1/screens/settings.dart';
import 'package:proyecto_entrega1/screens/profile.dart';

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
              child: const CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  "https://static.vecteezy.com/system/resources/previews/020/765/399/original/default-profile-account-unknown-icon-black-silhouette-free-vector.jpg",
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
