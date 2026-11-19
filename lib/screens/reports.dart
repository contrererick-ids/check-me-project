import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/models/expense.dart';
import 'package:proyecto_entrega1/models/trip.dart';
import 'package:proyecto_entrega1/services/trips_service.dart';
import 'package:proyecto_entrega1/utils/firestore_errors.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_entrega1/providers/trips_provider.dart';
import 'package:proyecto_entrega1/utils/balance.dart';
import 'package:proyecto_entrega1/screens/settle.dart';
import 'package:proyecto_entrega1/models/settlement.dart';
import 'package:proyecto_entrega1/theme/semantic_colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selectedTripId;

  // los streams se crean una vez por viaje seleccionado
  String? _streamsTripId;
  Stream<List<Expense>>? _expensesStream;
  Stream<List<Settlement>>? _settlementsStream;

  void _ensureStreams(String tripId) {
    if (_streamsTripId != tripId) {
      _streamsTripId = tripId;
      _expensesStream = TripsService.expensesStream(tripId);
      _settlementsStream = TripsService.settlementsStream(tripId);
    }
  }

  BorderSide get _border =>
      BorderSide(color: Theme.of(context).colorScheme.outlineVariant);

  Widget _reportsMessage(String mensaje) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reportes"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Center(child: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // llamada provider
    final tripsProvider = context.watch<TripsProvider>();

    if (tripsProvider.error != null) {
      return _reportsMessage(firestoreErrorMessage(tripsProvider.error!));
    }
    if (tripsProvider.loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Reportes")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final trips = tripsProvider.trips;
    if (trips.isEmpty) {
      return _reportsMessage("Aún no hay viajes para reportar");
    }

    final Trip trip = trips.firstWhere(
      (t) => t.id == _selectedTripId,
      orElse: () => trips.first,
    );
    _ensureStreams(trip.id);

    return StreamBuilder<List<Expense>>(
      stream: _expensesStream,
      builder: (context, expSnap) {
        if (expSnap.hasError) {
          return _reportsMessage(firestoreErrorMessage(expSnap.error!));
        }

        return StreamBuilder<List<Settlement>>(
          stream: _settlementsStream,
          builder: (context, setSnap) {
            // si los pagos no cargan el reporte sigue funcionando, solo sin descontarlos.
            final settlementsFailed = setSnap.hasError;
            final loading =
                !expSnap.hasData || (!setSnap.hasData && !settlementsFailed);

            return _buildReport(
              trips,
              trip,
              expSnap.data ?? const <Expense>[],
              setSnap.data ?? const <Settlement>[],
              loading: loading,
              settlementsFailed: settlementsFailed,
            );
          },
        );
      },
    );
  }

  Widget _buildReport(
    List<Trip> trips,
    Trip trip,
    List<Expense> expenses,
    List<Settlement> settlements, {
    required bool loading,
    required bool settlementsFailed,
  }) {
    final cs = Theme.of(context).colorScheme;
    final success = SuccessColors.of(context);
    final me = TripsService.uid;

    final report = calculateBalances(
      trip: trip,
      expenses: expenses,
      settlements: settlements,
    );
    final people = trip.userIds;
    final currency = trip.currency;

    String money(double v) => "\$${v.toStringAsFixed(2)} $currency";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reportes"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          DropdownButtonFormField<String>(
            initialValue: trip.id,
            decoration: const InputDecoration(labelText: "Viaje"),
            items: trips
                .map((t) => DropdownMenuItem(value: t.id, child: Text(t.title)))
                .toList(),
            onChanged: (id) => setState(() => _selectedTripId = id),
          ),
          if (loading) const LinearProgressIndicator(),
          const SizedBox(height: 15),

          if (settlementsFailed) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "No se pudieron cargar los pagos registrados. "
                "Los balances podrían no reflejarlos.",
                style: TextStyle(color: cs.onErrorContainer),
              ),
            ),
            const SizedBox(height: 15),
          ],

          // Resumen general
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.fromBorderSide(_border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("GASTO TOTAL", style: TextStyle(fontSize: 13)),
                Text(
                  money(report.total),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(color: cs.outlineVariant, thickness: 0.5, height: 20),
                Text("${expenses.length} gastos • ${people.length} personas"),
                const SizedBox(height: 4),
                Text("Parte por persona: ${money(report.share)}"),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // balance por persona
          const Text(
            "Balance por persona",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...report.balances.entries.map((entry) {
            final balance = entry.value;
            final settled = balance.abs() < 0.005;
            final positive = balance > 0;

            final Color amountColor = settled
                ? cs.onSurfaceVariant
                : positive
                ? success.color
                : cs.error;
            final Color avatarBg = settled
                ? cs.surfaceContainerHighest
                : positive
                ? success.container
                : cs.errorContainer;
            final Color avatarFg = settled
                ? cs.onSurfaceVariant
                : positive
                ? success.onContainer
                : cs.onErrorContainer;
            final IconData icon = settled
                ? Icons.check
                : positive
                ? Icons.arrow_downward
                : Icons.arrow_upward;
            final String label = settled
                ? "Al corriente"
                : positive
                ? "A favor"
                : "Debe";
            final String sign = settled
                ? ""
                : positive
                ? "+"
                : "-";

            return Card(
              color: cs.surfaceContainer,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: _border,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: avatarBg,
                  foregroundColor: avatarFg,
                  child: Icon(icon),
                ),
                title: Text(
                  entry.key == me
                      ? "${report.nameOf(entry.key)} (tú)"
                      : report.nameOf(entry.key),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Pagó ${money(report.paid[entry.key] ?? 0)}",
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$sign${money(balance.abs())}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: amountColor,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),

          // liquidacion
          const Text(
            "Cómo saldar cuentas",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (report.transfers.isEmpty)
            const Text("Todo está saldado 🎉")
          else
            ...report.transfers.map(
              (t) => Card(
                color: cs.surfaceContainer,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: _border,
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.arrow_forward,
                    color: cs.onSurfaceVariant,
                  ),
                  title: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: report.nameOf(t.fromId),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' le paga a '),
                        TextSpan(
                          text: report.nameOf(t.toId),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  trailing: Text(
                    money(t.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          if (people.length >= 2) ...[
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettleUpScreen(trip: trip)),
              ),
              icon: const Icon(Icons.payments_outlined),
              label: const Text("Saldar cuentas"),
            ),
          ],
        ],
      ),
    );
  }
}
