import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_entrega1/models/expense.dart';
import 'package:proyecto_entrega1/models/settlement.dart';
import 'package:proyecto_entrega1/models/trip.dart';
import 'package:proyecto_entrega1/providers/trips_provider.dart';
import 'package:proyecto_entrega1/services/trips_service.dart';
import 'package:proyecto_entrega1/theme/semantic_colors.dart';
import 'package:proyecto_entrega1/utils/balance.dart';
import 'package:proyecto_entrega1/utils/firestore_errors.dart';
import 'package:proyecto_entrega1/utils/format.dart';
import 'package:proyecto_entrega1/utils/snackbar_utils.dart';

// saldar cuentas de una actividad. muestra quien le debe a quien, permite registrar los pagos que ya se hicieron y guarda el historial.
class SettleUpScreen extends StatefulWidget {
  const SettleUpScreen({super.key, required this.trip});

  final Trip trip;

  @override
  State<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends State<SettleUpScreen> {
  // se guardan para no volver a suscribirse a firestore en cada rebuild
  late final Stream<List<Expense>> _expensesStream =
      TripsService.expensesStream(widget.trip.id);
  late final Stream<List<Settlement>> _settlementsStream =
      TripsService.settlementsStream(widget.trip.id);

  bool _saving = false;

  // version mas reciente de la actividad (por si cambian los miembros)
  Trip _currentTrip(BuildContext context) {
    final trips = context.watch<TripsProvider>().trips;
    return trips.firstWhere(
      (t) => t.id == widget.trip.id,
      orElse: () => widget.trip,
    );
  }

  // puede registrar el pago quien paga, quien recibe o el dueño de la actividad
  bool _canRegister(Trip trip, Transfer transfer) {
    final me = TripsService.uid;
    if (me == null) return false;
    return me == transfer.fromId || me == transfer.toId || me == trip.ownerId;
  }

  Future<void> _registerPayment(
    Trip trip,
    TripBalances balances,
    Transfer transfer,
  ) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => _RegisterPaymentDialog(
        fromName: balances.nameOf(transfer.fromId),
        toName: balances.nameOf(transfer.toId),
        maxAmount: transfer.amount,
        currency: trip.currency,
      ),
    );

    if (amount == null || !mounted) return;
    setState(() => _saving = true);

    try {
      final synced = await TripsService.addSettlement(
        trip: trip,
        fromId: transfer.fromId,
        fromName: balances.nameOf(transfer.fromId),
        toId: transfer.toId,
        toName: balances.nameOf(transfer.toId),
        amount: amount,
      );

      if (!mounted) return;
      showSnackbarMessage(
        context,
        synced
            ? 'Pago registrado.'
            : 'Sin conexión: el pago se guardará cuando vuelva el internet.',
      );
    } catch (e) {
      if (!mounted) return;
      showSnackbarMessage(context, firestoreErrorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _undoPayment(Settlement settlement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deshacer pago'),
        content: Text(
          '¿Quitar el pago de ${settlement.fromName} a ${settlement.toName}? '
          'La deuda volverá a aparecer como pendiente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deshacer pago'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await TripsService.deleteSettlement(
        tripId: settlement.tripId,
        settlementId: settlement.id,
      );
      if (!mounted) return;
      showSnackbarMessage(context, 'Pago eliminado.');
    } catch (e) {
      if (!mounted) return;
      showSnackbarMessage(context, firestoreErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = _currentTrip(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saldar cuentas'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _expensesStream,
        builder: (context, expensesSnap) {
          return StreamBuilder<List<Settlement>>(
            stream: _settlementsStream,
            builder: (context, settlementsSnap) {
              final error = expensesSnap.error ?? settlementsSnap.error;
              if (error != null) {
                return Center(child: Text(firestoreErrorMessage(error)));
              }
              if (!expensesSnap.hasData || !settlementsSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return _buildContent(
                trip,
                expensesSnap.data!,
                settlementsSnap.data!,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(
    Trip trip,
    List<Expense> expenses,
    List<Settlement> settlements,
  ) {
    final cs = Theme.of(context).colorScheme;
    final me = TripsService.uid;

    final balances = calculateBalances(
      trip: trip,
      expenses: expenses,
      settlements: settlements,
    );

    String money(double v) => '\$${v.toStringAsFixed(2)} ${trip.currency}';

    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        Text(
          trip.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _BalanceHeader(balance: balances.balances[me] ?? 0, money: money),
        const SizedBox(height: 20),

        // pagos pendientes
        const Text(
          'Pagos pendientes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (trip.userIds.length < 2)
          _InfoCard(
            icon: Icons.group_add_outlined,
            text: 'Para saldar cuentas necesitas al menos a otra persona en la actividad.',
          )
        else if (expenses.isEmpty && settlements.isEmpty)
          const _InfoCard(
            icon: Icons.receipt_long_outlined,
            text: 'Aún no hay gastos en esta actividad.',
          )
        else if (balances.transfers.isEmpty)
          const _InfoCard(
            icon: Icons.celebration_outlined,
            text: 'Todo está saldado 🎉',
          )
        else
          ...balances.transfers.map(
            (transfer) => _TransferCard(
              transfer: transfer,
              balances: balances,
              money: money,
              canRegister: _canRegister(trip, transfer),
              saving: _saving,
              onRegister: () => _registerPayment(trip, balances, transfer),
            ),
          ),

        // historial
        if (settlements.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Pagos registrados',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...settlements.map(
            (settlement) => Card(
              color: cs.surfaceContainer,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: cs.outlineVariant),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.surfaceContainerHighest,
                  foregroundColor: cs.onSurfaceVariant,
                  child: const Icon(Icons.check),
                ),
                title: Text(
                  '${settlement.fromName} → ${settlement.toName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  DateFormat('dd-MM-y, hh:mm a').format(settlement.date),
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      money(settlement.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    // solo quien registro el pago lo puede deshacer
                    if (settlement.createdBy == me)
                      IconButton(
                        tooltip: 'Deshacer pago',
                        icon: const Icon(Icons.undo),
                        onPressed: () => _undoPayment(settlement),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// resumen de la situacion del usuario en la actividad
class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.balance, required this.money});

  final double balance;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final success = SuccessColors.of(context);

    final settled = balance.abs() < 0.005;
    final positive = balance > 0;

    final String label = settled
        ? 'ESTÁS AL CORRIENTE'
        : positive
        ? 'TE DEBEN'
        : 'DEBES';
    final Color color = settled
        ? cs.onSurface
        : positive
        ? success.color
        : cs.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            settled ? money(0) : money(balance.abs()),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Un pago pendiente ("A le paga a B") con su boton para registrarlo
class _TransferCard extends StatelessWidget {
  const _TransferCard({
    required this.transfer,
    required this.balances,
    required this.money,
    required this.canRegister,
    required this.saving,
    required this.onRegister,
  });

  final Transfer transfer;
  final TripBalances balances;
  final String Function(double) money;
  final bool canRegister;
  final bool saving;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final success = SuccessColors.of(context);
    final me = TripsService.uid;

    final iPay = transfer.fromId == me;
    final iReceive = transfer.toId == me;

    // rojo = tu pagas, verde = tu recibes, neutro = pago entre otras personas
    final Color avatarBg = iPay
        ? cs.errorContainer
        : iReceive
        ? success.container
        : cs.surfaceContainerHighest;
    final Color avatarFg = iPay
        ? cs.onErrorContainer
        : iReceive
        ? success.onContainer
        : cs.onSurfaceVariant;
    final IconData icon = iPay
        ? Icons.arrow_upward
        : iReceive
        ? Icons.arrow_downward
        : Icons.swap_horiz;

    const bold = TextStyle(fontWeight: FontWeight.bold);
    final from = balances.nameOf(transfer.fromId);
    final to = balances.nameOf(transfer.toId);

    final InlineSpan sentence = iPay
        ? TextSpan(
            children: [
              const TextSpan(text: 'Tú', style: bold),
              const TextSpan(text: ' le pagas a '),
              TextSpan(text: to, style: bold),
            ],
          )
        : iReceive
        ? TextSpan(
            children: [
              TextSpan(text: from, style: bold),
              const TextSpan(text: ' te paga'),
            ],
          )
        : TextSpan(
            children: [
              TextSpan(text: from, style: bold),
              const TextSpan(text: ' le paga a '),
              TextSpan(text: to, style: bold),
            ],
          );

    return Card(
      color: cs.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: avatarBg,
                  foregroundColor: avatarFg,
                  child: Icon(icon),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text.rich(sentence)),
                const SizedBox(width: 8),
                Text(
                  money(transfer.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (canRegister) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: saving ? null : onRegister,
                  child: Text(
                    iPay ? 'Registrar pago' : 'Registrar pago recibido',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: cs.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: cs.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

// dialogo para confirmar el monto del pago (permite pagos parciales).
class _RegisterPaymentDialog extends StatefulWidget {
  const _RegisterPaymentDialog({
    required this.fromName,
    required this.toName,
    required this.maxAmount,
    required this.currency,
  });

  final String fromName;
  final String toName;

  // lo que se debe: no se permite registrar mas que esto
  final double maxAmount;
  final String currency;

  @override
  State<_RegisterPaymentDialog> createState() => _RegisterPaymentDialogState();
}

class _RegisterPaymentDialogState extends State<_RegisterPaymentDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: formatExpense(widget.maxAmount),
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    // aceptamos coma o punto como separador decimal
    final amount = double.tryParse(
      _controller.text.trim().replaceAll(',', '.'),
    );

    if (amount == null || amount <= 0) {
      setState(() => _error = 'Ingresa un monto válido mayor a 0.');
      return;
    }
    if (amount > widget.maxAmount + 0.005) {
      setState(
        () => _error =
            'No puede ser mayor a lo que se debe (\$${formatExpense(widget.maxAmount)}).',
      );
      return;
    }

    Navigator.pop(context, (amount * 100).round() / 100);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar pago'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${widget.fromName} le pagó a ${widget.toName}.'),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Monto (${widget.currency})',
              prefixText: '\$ ',
              errorText: _error,
              errorMaxLines: 3,
            ),
            onSubmitted: (_) => _confirm(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _confirm, child: const Text('Registrar')),
      ],
    );
  }
}
