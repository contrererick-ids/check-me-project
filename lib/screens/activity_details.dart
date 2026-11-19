import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/models/trip.dart';
import 'package:proyecto_entrega1/models/expense.dart';
import 'package:proyecto_entrega1/widgets/expense_item.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_entrega1/screens/new_bill.dart';
import 'package:proyecto_entrega1/services/trips_service.dart';
import 'package:proyecto_entrega1/utils/firestore_errors.dart';
import 'package:proyecto_entrega1/utils/format.dart';

class ActivityDetails extends StatefulWidget {
  const ActivityDetails({super.key, required this.trip});

  final Trip trip;

  @override
  State<ActivityDetails> createState() => _ActivityDetailsState();
}

class _ActivityDetailsState extends State<ActivityDetails> {
  Trip get trip => widget.trip;

  // los cargos se actualizan solos en tiempo real desde firestore
  late final Stream<List<Expense>> _expensesStream =
      TripsService.expensesStream(widget.trip.id);

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La función para ver los gastos por persona se agregará próximamente.',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ), // da el botón de regresar a la lista
      body: StreamBuilder<List<Expense>>(
        stream: _expensesStream,
        builder: (context, snapshot) {
          final expenses = snapshot.data ?? const <Expense>[];
          final cargando = !snapshot.hasData && !snapshot.hasError;

          final totalExpense = expenses.fold<double>(
            0,
            (suma, e) => suma + e.amount,
          );
          final yourShare = expenses
              .where((e) => e.paidById == TripsService.uid)
              .fold<double>(0, (suma, e) => suma + e.amount);

          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        trip.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "${trip.userIds.length} personas • Activo desde ${DateFormat("MMMM d", "es").format(trip.startDate)}",
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    height: 210,
                    width: 450,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "GASTO TOTAL DEL GRUPO",
                          style: TextStyle(fontSize: 13),
                        ),
                        Text(
                          "\$${formatExpense(totalExpense)} ${trip.currency}",
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(
                          color: cs.outlineVariant,
                          thickness: 0.5,
                          height: 20,
                        ),
                        const Text("TU APORTE", style: TextStyle(fontSize: 13)),
                        Text(
                          "\$${formatExpense(yourShare)} ${trip.currency}",
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showComingSoon(context);
                    },
                    label: const Text(
                      "Ver gastos por persona",
                      style: TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),

                Expanded(
                  child: snapshot.hasError
                      ? Center(
                          child: Text(firestoreErrorMessage(snapshot.error!)),
                        )
                      : cargando
                      ? const Center(child: CircularProgressIndicator())
                      : ExpenseCollapsible(expenses: expenses),
                ),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      // no hace falta refrescar al volver: el stream lo hace solo
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NuevoCargoScreen(trip: trip),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: cs.onSurface,
                      side: BorderSide(color: cs.onSurface),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      "Añadir Cargo",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ExpenseCollapsible extends StatefulWidget {
  const ExpenseCollapsible({super.key, required this.expenses});

  final List<Expense> expenses;

  @override
  State<ExpenseCollapsible> createState() => _ExpenseCollapsibleState();
}

class _ExpenseCollapsibleState extends State<ExpenseCollapsible> {
  bool _showAll = false;
  final int _itemLimit = 3;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalItems = widget.expenses.length;
    final visibleItems = _showAll
        ? totalItems
        : totalItems.clamp(0, _itemLimit);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Gastos Recientes",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (totalItems > _itemLimit)
              TextButton(
                onPressed: () => setState(() => _showAll = !_showAll),
                child: Text(
                  _showAll ? "Ver menos" : "Ver todo",
                  style: TextStyle(color: cs.primary),
                ),
              ),
          ],
        ),
        Expanded(
          child: totalItems == 0
              ? const Center(child: Text("Aún no hay gastos"))
              : ListView.builder(
                  itemCount: visibleItems,
                  itemBuilder: (context, index) =>
                      ExpenseItem(expense: widget.expenses[index]),
                ),
        ),
      ],
    );
  }
}
