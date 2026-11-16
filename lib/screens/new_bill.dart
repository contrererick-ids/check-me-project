import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/models/trip.dart';
import 'package:proyecto_entrega1/services/trips_service.dart';
import 'package:proyecto_entrega1/utils/firestore_errors.dart';
import 'package:proyecto_entrega1/utils/snackbar_utils.dart';

class NuevoCargoScreen extends StatefulWidget {
  const NuevoCargoScreen({super.key, required this.trip});

  final Trip trip;

  @override
  State<NuevoCargoScreen> createState() => _NuevoCargoScreenState();
}

class _NuevoCargoScreenState extends State<NuevoCargoScreen> {
  final TextEditingController _conceptoController = TextEditingController();

  final TextEditingController _montoController = TextEditingController();

  String? _miembroSeleccionado;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // por defecto, el que paga es el usuario actual (si es miembro del viaje)
    final uid = TripsService.uid;
    if (uid != null && widget.trip.memberNames.containsKey(uid)) {
      _miembroSeleccionado = uid;
    }
  }

  @override
  void dispose() {
    _conceptoController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  void _cancelar() {
    Navigator.pop(context);
  }

  Future<void> _agregarCargo() async {
    final concepto = _conceptoController.text.trim();
    // aceptamos coma o punto como separador decimal
    final monto = double.tryParse(
      _montoController.text.trim().replaceAll(',', '.'),
    );

    if (concepto.isEmpty) {
      showSnackbarMessage(context, 'Describe el concepto del cargo.');
      return;
    }
    if (_miembroSeleccionado == null) {
      showSnackbarMessage(context, 'Selecciona el miembro responsable.');
      return;
    }
    if (monto == null || monto <= 0) {
      showSnackbarMessage(context, 'Ingresa un monto válido mayor a 0.');
      return;
    }

    setState(() => _loading = true);

    try {
      final sincronizado = await TripsService.addExpense(
        trip: widget.trip,
        title: concepto,
        paidById: _miembroSeleccionado!,
        amount: monto,
      );

      if (!mounted) return;
      showSnackbarMessage(
        context,
        sincronizado
            ? 'Cargo agregado correctamente.'
            : 'Sin conexión: el cargo se guardará cuando vuelva el internet.',
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showSnackbarMessage(context, firestoreErrorMessage(e));
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 239, 234),

      // AppBar con el estilo de la aplicacion
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        children: [
          // Titulo de la seccion
          const Text(
            'Cargos:',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          // Indicador de pestaña
          Stack(
            children: [
              Container(height: 1, color: const Color(0xFFD6D6D6)),
              Container(
                width: 100,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF808080),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // Nombre del viaje
          const Text(
            'Viaje a Puerto Vallarta',
            style: TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 72, 72, 72),
            ),
          ),

          const SizedBox(height: 20),

          // Formulario
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.fromLTRB(18, 25, 18, 25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color.fromARGB(255, 219, 215, 211),
              ),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: _conceptoController,
                  enabled: !_loading,
                  decoration: const InputDecoration(
                    hintText: 'Describe el cargo que vas a agregar...',
                  ),
                ),

                const SizedBox(height: 20),

                // Miembro
                const Text(
                  'Miembro:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: _miembroSeleccionado,
                  isExpanded: true,
                  hint: const Text('Selecciona el miembro responsable...'),
                  items: widget.trip.memberNames.entries.map((miembro) {
                    return DropdownMenuItem<String>(
                      value: miembro.key,
                      child: Text(
                        miembro.value,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _loading
                      ? null
                      : (valor) {
                          setState(() {
                            _miembroSeleccionado = valor;
                          });
                        },
                ),

                const SizedBox(height: 20),

                // Monto
                const Text(
                  'Monto:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: _montoController,
                  keyboardType: const TextInputType.numberWithOptions(
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
                      onPressed: _loading ? null : _cancelar,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Color(0xFF808080)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Cancelar'),
                    ),

                    OutlinedButton(
                      onPressed: _loading ? null : _agregarCargo,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Color(0xFF808080)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Agregar'),
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
