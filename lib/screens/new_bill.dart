
import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/data/dummy_data.dart';

class NuevoCargoScreen extends StatefulWidget {
  const NuevoCargoScreen({super.key});

  @override
  State<NuevoCargoScreen> createState() => _NuevoCargoScreenState();
}

class _NuevoCargoScreenState extends State<NuevoCargoScreen> {
  final TextEditingController _conceptoController =
      TextEditingController();

  final TextEditingController _montoController =
      TextEditingController();

  String? _miembroSeleccionado;

  @override
  void dispose() {
    _conceptoController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  void _cancelar() {
    Navigator.pop(context);
  }

  void _agregarCargo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Próximamente: función para agregar cargos',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 239, 234),

      // AppBar con el estilo de la aplicacion
      appBar: AppBar(),

      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        children: [


          // Titulo de la seccion
          const Text(
            'Cargos:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          // Indicador de pestaña
          Stack(
            children: [
              Container(
                height: 1,
                color: const Color(0xFFD6D6D6),
              ),
              Container(
                width: 100,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF808080),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

           // Nombre del viaje
          const Text(
            'Viaje a Puerto Vallarta',
            style: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 72, 72, 72),
            ),
          ),

          const SizedBox(height: 20),

          // Formulario
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.fromLTRB(18, 25, 18, 25),
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Nuevo cargo',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Concepto
                const Text(
                  'Concepto:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: _conceptoController,
                  decoration: const InputDecoration(
                    hintText: 'Describe el cargo que vas a agregar...',
                  ),
                ),

                const SizedBox(height: 20),

                // Miembro
                const Text(
                  'Miembro:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: _miembroSeleccionado,
                  isExpanded: true,
                  hint: const Text(
                    'Selecciona el miembro responsable...',
                  ),
                  items: amigosGrupoDummy.map((amigo) {
                    final nombre = amigo['nombre']!;

                    return DropdownMenuItem<String>(
                      value: nombre,
                      child: Text(
                        nombre,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    setState(() {
                      _miembroSeleccionado = valor;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Monto
                const Text(
                  'Monto:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: _montoController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Ingresa el monto total que pagaste...',
                  ),
                ),

                const SizedBox(height: 30),

                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: _cancelar,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(
                          color: Color(0xFF808080),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Cancelar'),
                    ),

                    OutlinedButton(
                      onPressed: _agregarCargo,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(
                          color: Color(0xFF808080),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Agregar'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
