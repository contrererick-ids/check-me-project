import 'package:proyecto_entrega1/models/expense.dart';
import 'package:proyecto_entrega1/models/settlement.dart';
import 'package:proyecto_entrega1/models/trip.dart';

// un pago sugerido: [fromId] le debe [amount] a [toId]
class Transfer {
  const Transfer({
    required this.fromId,
    required this.toId,
    required this.amount,
  });

  final String fromId;
  final String toId;
  final double amount;
}

class TripBalances {
  const TripBalances({
    required this.total,
    required this.share,
    required this.paid,
    required this.balances,
    required this.transfers,
    required this.names,
  });

  // gasto total de la actividad y parte que le toca a cada miembro
  final double total;
  final double share;

  // cuanto gasto cada persona (uid -> monto)
  final Map<String, double> paid;

  // balance de cada persona (uid -> monto): positivo = le deben, negativo = debe
  final Map<String, double> balances;

  // pagos sugeridos para dejar todos los balances en cero
  final List<Transfer> transfers;

  // uid -> nombre
  final Map<String, String> names;

  String nameOf(String id) => names[id] ?? 'Miembro';
}

// pasa un monto a centavos enteros
int _toCents(double value) => (value * 100).round();

// calcula quien debe a quien. los pagos ya registrados (settlements) se descuentan, asi que los pagos sugeridos bajan conforme se va saldando.
//
//   balance = lo que pago - lo que le correspondia + pagos que hizo - pagos que recibio
//
// todo se calcula en centavos enteros.
TripBalances calculateBalances({
  required Trip trip,
  required List<Expense> expenses,
  required List<Settlement> settlements,
}) {
  final members = trip.userIds;

  // nombres por uid; si alguien ya no es miembro usamos el nombre guardado
  final names = <String, String>{...trip.memberNames};
  for (final e in expenses) {
    names.putIfAbsent(e.paidById, () => e.paidBy);
  }
  for (final s in settlements) {
    names.putIfAbsent(s.fromId, () => s.fromName);
    names.putIfAbsent(s.toId, () => s.toName);
  }

  final paidCents = <String, int>{for (final m in members) m: 0};
  var totalCents = 0;
  for (final e in expenses) {
    final cents = _toCents(e.amount);
    totalCents += cents;
    paidCents[e.paidById] = (paidCents[e.paidById] ?? 0) + cents;
  }

  // parte de cada miembro: division entera y el residuo, un centavo a cada uno
  final shareCents = <String, int>{};
  if (members.isNotEmpty) {
    final sorted = [...members]..sort();
    final base = totalCents ~/ members.length;
    final remainder = totalCents % members.length;
    for (var i = 0; i < sorted.length; i++) {
      shareCents[sorted[i]] = base + (i < remainder ? 1 : 0);
    }
  }

  // solo los miembros actuales deben una parte; quien pago y ya no es miembro
  // solo recupera lo que puso
  final balanceCents = <String, int>{
    for (final id in {...members, ...paidCents.keys})
      id: (paidCents[id] ?? 0) - (shareCents[id] ?? 0),
  };

  for (final s in settlements) {
    final cents = _toCents(s.amount);
    balanceCents[s.fromId] = (balanceCents[s.fromId] ?? 0) + cents;
    balanceCents[s.toId] = (balanceCents[s.toId] ?? 0) - cents;
  }

  double toMoney(int cents) => cents / 100;

  return TripBalances(
    total: toMoney(totalCents),
    share: members.isEmpty ? 0 : toMoney(totalCents) / members.length,
    paid: paidCents.map((id, cents) => MapEntry(id, toMoney(cents))),
    balances: balanceCents.map((id, cents) => MapEntry(id, toMoney(cents))),
    transfers: _suggestTransfers(balanceCents),
    names: names,
  );
}

class _Pending {
  _Pending(this.id, this.cents);
  final String id;
  int cents;
}

// Algoritmo simple: el que mas debe le paga al que mas le deben.
List<Transfer> _suggestTransfers(Map<String, int> balanceCents) {
  // se desempata por id para que el resultado no cambie entre renders
  int byAmountThenId(_Pending a, _Pending b) {
    final c = b.cents.compareTo(a.cents);
    return c != 0 ? c : a.id.compareTo(b.id);
  }

  final debtors =
      balanceCents.entries
          .where((e) => e.value < 0)
          .map((e) => _Pending(e.key, -e.value))
          .toList()
        ..sort(byAmountThenId);

  final creditors =
      balanceCents.entries
          .where((e) => e.value > 0)
          .map((e) => _Pending(e.key, e.value))
          .toList()
        ..sort(byAmountThenId);

  final transfers = <Transfer>[];
  var d = 0;
  var c = 0;

  // como todo son enteros, siempre uno de los dos llega exactamente a cero
  while (d < debtors.length && c < creditors.length) {
    final debtor = debtors[d];
    final creditor = creditors[c];
    final cents = debtor.cents < creditor.cents ? debtor.cents : creditor.cents;

    transfers.add(
      Transfer(fromId: debtor.id, toId: creditor.id, amount: cents / 100),
    );

    debtor.cents -= cents;
    creditor.cents -= cents;

    if (debtor.cents == 0) d++;
    if (creditor.cents == 0) c++;
  }

  return transfers;
}
