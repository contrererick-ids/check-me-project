import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/models/group.dart';
import 'package:proyecto_entrega1/data/dummy_data.dart';

class ConfigGrupos extends StatefulWidget {
  const ConfigGrupos({super.key, required this.group});

  final Group group;

  @override
  State<ConfigGrupos> createState() => _ConfigGruposState();
}

class _ConfigGruposState extends State<ConfigGrupos> {
  // Datos de prueba de los miembros del grupo.
  final List<Map<String, String>> amigos = amigosGrupoDummy
      .map((amigo) => Map<String, String>.from(amigo))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(13, 20, 13, 24),
        children: [
          // Nombre del grupo
          Text(
            widget.group.name,
            style: TextStyle(
              fontSize: 28,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 34),

          // titulo de miembros:
          const Text(
            'Miembros:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          // Barra decorativa
          Container(
            width: 90,
            height: 7,
            decoration: BoxDecoration(
              color: const Color(0xFF888888),
              borderRadius: BorderRadius.circular(6),
            ),
          ),

          const SizedBox(height: 4),

          // Contador de miembros
          Text(
            '${amigos.length}/5 miembros',
            style: const TextStyle(fontSize: 15, color: Color(0xFF888888)),
          ),

          const SizedBox(height: 24),

          // Boton para agregar miembros
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pendiente: agregar miembros al grupo'),
                  ),
                );
              },
              icon: const Icon(
                Icons.person_add_alt_1,
                size: 18,
                color: Colors.black,
              ),
              label: const Text(
                'Agregar miembros',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black, width: 2),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 8,
                ),
                minimumSize: const Size(0, 36),
              ),
            ),
          ),

          const SizedBox(height: 43),

          // titulo de mis amigos:
          const Padding(
            padding: EdgeInsets.only(left: 7),
            child: Text(
              'Mis amigos:',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Lista de amigos
          ...amigos.map((amigo) {
            return Padding(
              padding: const EdgeInsets.only(left: 30, right: 27, bottom: 26),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Nombre y celular
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          amigo['nombre']!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          amigo['celular']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Boton de eliminar
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Pendiente agregar función de eliminar',
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF888888),
                        width: 1,
                      ),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      minimumSize: const Size(0, 25),
                    ),
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
