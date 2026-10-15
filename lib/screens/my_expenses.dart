import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/models/expense.dart';
import 'package:proyecto_entrega1/models/trip.dart';
import 'package:proyecto_entrega1/data/dummy_data.dart';
import 'package:proyecto_entrega1/widgets/expense_item.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

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
                padding: const EdgeInsets.all(15),
                child: Text(
                  trip?.title ?? "N/A",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
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
