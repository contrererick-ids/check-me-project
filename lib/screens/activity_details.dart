import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/models/trip.dart';
import 'package:proyecto_entrega1/models/expense.dart';
import 'package:proyecto_entrega1/data/dummy_data.dart';
import 'package:proyecto_entrega1/widgets/expense_item.dart';
import 'package:intl/intl.dart';

class ActivityDetails extends StatelessWidget {
  ActivityDetails({super.key, required this.trip});

  final Trip trip;
  late final tripExpenses = expenses.where(
    (expense) => expense.tripId == trip.id,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(), // da el botón de regresar a la lista
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  trip.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "${trip.userIds.length} personas • Activo desde ${DateFormat("MMMM d", "es").format(trip.startDate)}",
                  style: TextStyle(color: Colors.black.withValues(alpha: 0.4)),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color.fromARGB(255, 219, 215, 211),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("GASTO TOTAL DEL GRUPO", style: TextStyle(fontSize: 13)),
                    Text(
                      "\$5000 MXN",
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    Divider(color: Colors.grey, thickness: 0.5, height: 20),
                    Text("TU APORTE", style: TextStyle(fontSize: 13)),
                    Text(
                      "\$750 MXN",
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ExpenseCollapsible(expenses: tripExpenses.toList()),
            ),
            ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pendiente: lleva a pagina de añadir cargos'),
                ),
              ),
              child: const Text("Añadir Cargo"),
            ),
          ],
        ),
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
    final totalItems = widget.expenses.length;
    final visibleItems = _showAll ? totalItems : totalItems.clamp(0, _itemLimit);

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
                  style: const TextStyle(
                    color: Color.fromARGB(255, 237, 108, 69),
                  ),
                ),
              ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: visibleItems,
            itemBuilder: (context, index) =>
                ExpenseItem(expense: widget.expenses[index]),
          ),
        ),
      ],
    );
  }
}