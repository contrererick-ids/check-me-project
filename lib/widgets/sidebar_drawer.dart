import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 244, 239, 234),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    "https://static.vecteezy.com/system/resources/previews/020/765/399/original/default-profile-account-unknown-icon-black-silhouette-free-vector.jpg",
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Lorem Ipsum1", style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text("Amigos"),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Pendiente: lleva a pagina de administracion de amigos',
                ),
              ),
            ),
          ),
          ListTile(
            title: Text("Historial de viajes"),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Pendiente: lleva a pagina de historial de viajes de usuario',
                ),
              ),
            ),
          ),
          ListTile(
            title: Text("Mis saldos"),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Pendiente: lleva a pagina de resumen global de cuentas',
                ),
              ),
            ),
          ),
          ListTile(
            title: Text("Reportes"),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pendiente: resumen de un viaje')),
            ),
          ),
        ],
      ),
    );
  }
}
