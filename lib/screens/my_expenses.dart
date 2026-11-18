import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/models/expense.dart';
import 'package:proyecto_entrega1/models/trip.dart';
import 'package:proyecto_entrega1/widgets/expense_item.dart';
import 'package:proyecto_entrega1/services/trips_service.dart';
import 'package:proyecto_entrega1/utils/firestore_errors.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_entrega1/providers/trips_provider.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  void _showSettlementMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La funcionalidad para saldar cuentas se agregará próximamente.',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mis Gastos",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Builder(
        builder: (context) {
          // llamada provider
          final tripsProvider = context.watch<TripsProvider>();

          if (tripsProvider.error != null) {
            return Center(
              child: Text(firestoreErrorMessage(tripsProvider.error!)),
            );
          }
          if (tripsProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final trips = tripsProvider.trips;
          if (trips.isEmpty) {
            return const Center(child: Text("Aún no tienes gastos"));
          }

          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) => _TripExpensesSection(
              // la key evita que se mezclen los streams si cambia el orden
              key: ValueKey(trips[index].id),
              trip: trips[index],
              onSettle: () => _showSettlementMessage(context),
            ),
          );
        },
      ),
    );
  }
}

// una actividad con sus gastos. cada una obtiene sus propios cargos desde firestore.
class _TripExpensesSection extends StatefulWidget {
  const _TripExpensesSection({
    super.key,
    required this.trip,
    required this.onSettle,
  });

  final Trip trip;
  final VoidCallback onSettle;

  @override
  State<_TripExpensesSection> createState() => _TripExpensesSectionState();
}

class _TripExpensesSectionState extends State<_TripExpensesSection> {
  late final Stream<List<Expense>> _expensesStream =
      TripsService.expensesStream(widget.trip.id);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Expense>>(
      stream: _expensesStream,
      builder: (context, snapshot) {
        final expenses = snapshot.data ?? const <Expense>[];

        // solo mostramos actividades que ya tienen gastos
        if (expenses.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.trip.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.onSettle,
                    label: const Text("Saldar cuenta"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...expenses.map((expense) => ExpenseItem(expense: expense)),
          ],
        );
      },
    );
  }
}
