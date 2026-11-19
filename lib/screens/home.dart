
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_entrega1/screens/activity_details.dart';
import 'package:proyecto_entrega1/services/trips_service.dart';
import 'package:proyecto_entrega1/utils/firestore_errors.dart';
import 'package:proyecto_entrega1/utils/snackbar_utils.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_entrega1/providers/trips_provider.dart';

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
          decoration: const InputDecoration(
            hintText: "Nombre de la actividad",
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              context,
              controller.text.trim(),
            ),
            child: const Text("Crear"),
          ),
        ],
      ),
    );

    if (title == null || title.isEmpty) return;

    try {
      final synced = await TripsService.createTrip(title);

      if (!mounted) return;

      if (!synced) {
        showSnackbarMessage(
          context,
          'Sin conexión. La actividad se guardará cuando vuelva el internet.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      showSnackbarMessage(context, firestoreErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
              child: Builder(
                builder: (context) {
                  final tripsProvider = context.watch<TripsProvider>();

                  if (tripsProvider.error != null) {
                    return Center(
                      child: Text(
                        firestoreErrorMessage(tripsProvider.error!),
                      ),
                    );
                  }

                  if (tripsProvider.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final trips = tripsProvider.trips;

                  if (trips.isEmpty) {
                    return const Center(
                      child: Text("Aún no tienes actividades"),
                    );
                  }

                  return ListView.builder(
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final trip = trips[index];

                      return Card(
                        color: cs.surfaceContainer,
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: cs.outlineVariant),
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
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createActivity,
                style: ElevatedButton.styleFrom(
                  foregroundColor: cs.onSurface,
                  side: BorderSide(color: cs.onSurface),
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
