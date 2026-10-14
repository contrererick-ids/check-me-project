import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/models/expense.dart';
import 'package:proyecto_entrega1/models/trip.dart';
import 'package:proyecto_entrega1/data/dummy_data.dart';
import 'package:proyecto_entrega1/widgets/expense_item.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
