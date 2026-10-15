import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/data/dummy_data.dart';
import 'package:proyecto_entrega1/models/trip.dart';

class _Balance {
  _Balance(this.name, this.amount);
  final String name;
  double amount;
}

class _Transfer {
  _Transfer(this.from, this.to, this.amount);
  final String from;
  final String to;
  final double amount;
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selectedTripId;

  static const _border = BorderSide(color: Color.fromARGB(255, 219, 215, 211));

  /// Algoritmo simple: el que más debe le paga al que más le deben.
  List<_Transfer> _settle(Map<String, double> balances) {
    final debtors = balances.entries
        .where((e) => e.value < -0.005)
        .map((e) => _Balance(e.key, -e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final creditors = balances.entries
        .where((e) => e.value > 0.005)
        .map((e) => _Balance(e.key, e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final transfers = <_Transfer>[];
    var d = 0;
    var c = 0;

    while (d < debtors.length && c < creditors.length) {
      final debtor = debtors[d];
      final creditor = creditors[c];
      final amount =
          debtor.amount < creditor.amount ? debtor.amount : creditor.amount;

      transfers.add(_Transfer(debtor.name, creditor.name, amount));
      debtor.amount -= amount;
      creditor.amount -= amount;

      if (debtor.amount < 0.005) d++;
      if (creditor.amount < 0.005) c++;
    }
    return transfers;
  }

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Reportes")),
        body: const Center(child: Text("Aún no hay viajes para reportar")),
      );
    }

    final Trip trip = trips.firstWhere(
      (t) => t.id == _selectedTripId,
      orElse: () => trips.first,
    );

    final tripExpenses = expenses.where((e) => e.tripId == trip.id).toList();
    final double total =
        tripExpenses.fold<double>(0, (sum, e) => sum + e.amount);

    final people = trip.userIds;
    final double share = people.isEmpty ? 0 : total / people.length;

    // Cuánto pagó cada persona
    final Map<String, double> paid = {for (final p in people) p: 0};
    for (final e in tripExpenses) {
      paid[e.paidBy] = (paid[e.paidBy] ?? 0) + e.amount;
    }

    // Balance = lo que pagó - lo que le correspondía
    final Map<String, double> balances = {
      for (final entry in paid.entries) entry.key: entry.value - share,
    };

    final transfers = _settle(balances);
    final currency = trip.currency;

    String money(double v) => "\$${v.toStringAsFixed(2)} $currency";

    return Scaffold(
      appBar: AppBar(title: const Text("Reportes")),
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
          const SizedBox(height: 15),

          // Resumen general
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.fromBorderSide(_border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("GASTO TOTAL", style: TextStyle(fontSize: 13)),
                Text(
                  money(total),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.grey, thickness: 0.5, height: 20),
                Text("${tripExpenses.length} gastos • ${people.length} personas"),
                const SizedBox(height: 4),
                Text("Parte por persona: ${money(share)}"),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Balance por persona
          const Text(
            "Balance por persona",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...balances.entries.map((entry) {
            final balance = entry.value;
            final isPositive = balance >= 0;
            return Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: _border,
              ),
              child: ListTile(
                title: Text(entry.key),
                subtitle: Text("Pagó ${money(paid[entry.key] ?? 0)}"),
                trailing: Text(
                  "${isPositive ? '+' : '-'}${money(balance.abs())}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),

          // Liquidación
          const Text(
            "Cómo saldar cuentas",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (transfers.isEmpty)
            const Text("Todo está saldado 🎉")
          else
            ...transfers.map(
              (t) => Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: _border,
                ),
                child: ListTile(
                  leading: const Icon(Icons.arrow_forward),
                  title: Text("${t.from} le paga a ${t.to}"),
                  trailing: Text(
                    money(t.amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}