import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color.fromARGB(255,219,215,211))
            ), 
            child: ListTile(
              leading: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                      "https://static.vecteezy.com/system/resources/previews/020/765/399/original/default-profile-account-unknown-icon-black-silhouette-free-vector.jpg")
              ),
              title: Text('User 1',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              subtitle: Text('email@dummy.com',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          
          /* Personal Info */
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color.fromARGB(255,219,215,211)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personal Information',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  ListTile(
                    title: Text('Email'),
                    subtitle: Text('email@dummy.com'),
                    trailing: IconButton(
                      onPressed: () => (),
                    icon: Icon(Icons.edit)),
                  ),
                  ListTile(
                    title: Text('Password'),
                    subtitle: Text('***********'),
                    trailing: IconButton(
                      onPressed: () => (),
                    icon: Icon(Icons.edit)),
                  ),
                  /* const Text('Name'),
                  const Text('Email'),
                  const Text('Password'), */
                ],
              ),
            )
          ),
          const SizedBox(
            height: 16,
          ),

          /* Theme */
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color.fromARGB(255,219,215,211)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tema de la Aplicación',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  ListTile(
                    title: Text('Modo Oscuro'),
                    trailing: IconButton(
                      onPressed: () => (),
                    icon: Icon(Icons.dark_mode)),
                  ),
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}
