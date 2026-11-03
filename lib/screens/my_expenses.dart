import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/models/expense.dart';
import 'package:proyecto_entrega1/models/trip.dart';
import 'package:proyecto_entrega1/data/dummy_data.dart';
import 'package:proyecto_entrega1/widgets/expense_item.dart';

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
    final List<Expense> sortedExpenses = [...expenses];

    sortedExpenses.sort((firstExpense, secondExpense) {
      return secondExpense.date.compareTo(firstExpense.date);
    });

    final Map<String, Trip> tripsById = {};

    for (final trip in trips) {
      tripsById[trip.id] = trip;
    }

    final Map<String, List<Expense>> groupedExpenses = {};

    for (final expense in sortedExpenses) {
      groupedExpenses.putIfAbsent(expense.tripId, () => []).add(expense);
    }

    final List<String> tripIds = groupedExpenses.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mis Gastos",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView.builder(
        itemCount: tripIds.length,
        itemBuilder: (context, index) {
          final tripId = tripIds[index];
          final tripExpenses = groupedExpenses[tripId]!;
          final trip = tripsById[tripId];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        trip?.title ?? "N/A",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ),

                    OutlinedButton.icon(
                      onPressed: () {
                        _showSettlementMessage(context);
                      },
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
              ...tripExpenses.map((expense) => ExpenseItem(expense: expense)),
            ],
          );
        },
      ),
    );
  }
}
