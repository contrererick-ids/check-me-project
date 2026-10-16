import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_entrega1/models/trip.dart';
import 'package:proyecto_entrega1/data/dummy_data.dart';
import 'package:proyecto_entrega1/screens/activity_details.dart';
import 'package:proyecto_entrega1/widgets/sidebar_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _createActivity() async {
    final controller = TextEditingController();

    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nueva actividad"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Nombre de la actividad"),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Crear"),
          ),
        ],
      ),
    );

    if (title == null || title.isEmpty) return;

    setState(() {
      trips.add(
        Trip(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          userIds: [],
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          currency: '',
          status: '',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Actividades",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: trips.isEmpty
                  ? const Center(child: Text("Aún no tienes actividades"))
                  : ListView.builder(
                      itemCount: trips.length,
                      itemBuilder: (context, index) {
                        final trip = trips[index];
                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 219, 215, 211),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              trip.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${trip.userIds.length} personas • "
                              "Activo desde ${DateFormat("MMMM d", "es").format(trip.startDate)}",
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ActivityDetails(trip: trip),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createActivity,
<<<<<<< HEAD
                style: ElevatedButton.styleFrom(
=======
                style: OutlinedButton.styleFrom(
>>>>>>> 26ef33d3ee7a84cb5473b99516402fa8c8aa7019
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: const StadiumBorder(),
                ),
                child: const Text("Crear Actividad"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
