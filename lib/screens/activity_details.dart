
import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/models/trip.dart';
import 'package:proyecto_entrega1/models/expense.dart';
import 'package:proyecto_entrega1/models/group.dart';
import 'package:proyecto_entrega1/models/group_member.dart';
import 'package:proyecto_entrega1/widgets/expense_item.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_entrega1/screens/new_bill.dart';
import 'package:proyecto_entrega1/services/trips_service.dart';
import 'package:proyecto_entrega1/services/group_service.dart';
import 'package:proyecto_entrega1/utils/firestore_errors.dart';
import 'package:proyecto_entrega1/utils/format.dart';

class ActivityDetails extends StatefulWidget {
  const ActivityDetails({super.key, required this.trip});

  final Trip trip;

  @override
  State<ActivityDetails> createState() => _ActivityDetailsState();
}

class _ActivityDetailsState extends State<ActivityDetails> {
  late Trip _trip;

  Trip get trip => _trip;

  // Los cargos se actualizan automáticamente desde Firestore.
  late final Stream<List<Expense>> _expensesStream =
      TripsService.expensesStream(widget.trip.id);

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
  }

  @override
  void didUpdateWidget(covariant ActivityDetails oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.trip.id != widget.trip.id) {
      _trip = widget.trip;
    }
  }

  // Muestra cuánto ha pagado cada participante, sin dividir los gastos.
  void _showExpensesByPerson(
    BuildContext context,
    List<Expense> expenses,
  ) {
    final names = <String, String>{
      for (final entry in trip.memberNames.entries)
        entry.key: entry.value,
    };

    final totals = <String, double>{
      for (final id in trip.memberNames.keys) id: 0,
    };

    for (final expense in expenses) {
      totals[expense.paidById] =
          (totals[expense.paidById] ?? 0) + expense.amount;

      // Si quien pagó no está actualmente en memberNames, también lo mostramos.
      names.putIfAbsent(
        expense.paidById,
        () => expense.paidBy.isNotEmpty ? expense.paidBy : 'Miembro',
      );
    }

    final entries = totals.entries.toList()
      ..sort((a, b) => names[a.key]!.compareTo(names[b.key]!));

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final dialogColors = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          title: const Text(
            'Gastos por persona',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: entries.isEmpty
                ? const Text('No hay participantes registrados.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: dialogColors.primaryContainer,
                          child: Icon(
                            Icons.person,
                            color: dialogColors.onPrimaryContainer,
                          ),
                        ),
                        title: Text(names[entry.key] ?? 'Miembro'),
                        trailing: Text(
                          '\$${formatExpense(entry.value)} ${trip.currency}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Abrir el diálogo para seleccionar grupo y participantes.
  Future<void> _openGroupDialog() async {
    final selection = await showDialog<_GroupSelection>(
      context: context,
      builder: (context) => _GroupSelectionDialog(
        initialGroupId: _trip.groupId,
        initialMemberIds: _trip.memberNames.keys.toSet(),
      ),
    );

    if (selection == null || !mounted) return;

    try {
      final saved = await TripsService.updateTripGroup(
        trip: _trip,
        group: selection.group,
        selectedMembers: selection.members,
      );

      if (!mounted) return;

      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo guardar. Inténtalo nuevamente.',
            ),
          ),
        );
        return;
      }

      // Actualizar los participantes que se muestran en pantalla.
      final updatedMembers = <String, String>{
        for (final member in selection.members)
          member.id: member.name,
      };

      // El creador siempre forma parte de la actividad.
      updatedMembers.putIfAbsent(
        TripsService.uid ?? _trip.ownerId,
        () => TripsService.currentName,
      );

      setState(() {
        _trip = _trip.copyWith(
          groupId: selection.group.id,
          groupName: selection.group.name,
          memberNames: updatedMembers,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Grupo y participantes actualizados.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo actualizar el grupo: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
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
              .fold<double>(
                0,
                (suma, e) => suma + e.amount,
              );

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

                // Botón para añadir o editar el grupo.
                Padding(
                  padding: const EdgeInsets.only(
                    top: 12,
                    bottom: 5,
                  ),
                  child: OutlinedButton.icon(
                    onPressed: _openGroupDialog,
                    icon: Icon(
                      trip.groupId == null
                          ? Icons.group_add_outlined
                          : Icons.edit_outlined,
                    ),
                    label: Text(
                      trip.groupId == null
                          ? 'Añadir grupo'
                          : 'Editar grupo',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.primary,
                      side: BorderSide(color: cs.primary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),

                // Mostrar el nombre del grupo asociado.
                if (trip.groupName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'Grupo: ${trip.groupName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ),

                // Contenedor original de gastos.
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    height: 210,
                    width: 450,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: cs.outlineVariant,
                      ),
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
                        const Text(
                          "TU APORTE",
                          style: TextStyle(fontSize: 13),
                        ),
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

                // Botón original de gastos por persona.
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showExpensesByPerson(context, expenses);
                    },
                    label: const Text(
                      "Ver gastos por persona",
                      style: TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.primary,
                      side: BorderSide(color: cs.primary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),

                // Gastos recientes.
                Expanded(
                  child: snapshot.hasError
                      ? Center(
                          child: Text(
                            firestoreErrorMessage(snapshot.error!),
                          ),
                        )
                      : cargando
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : ExpenseCollapsible(
                              expenses: expenses,
                            ),
                ),

                // Botón original para añadir cargos.
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NuevoCargoScreen(trip: trip),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: cs.onSurface,
                      side: BorderSide(color: cs.onSurface),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
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

// Resultado del diálogo de selección.
class _GroupSelection {
  const _GroupSelection({
    required this.group,
    required this.members,
  });

  final Group group;
  final List<GroupMember> members;
}

// Diálogo para seleccionar grupo y participantes.
class _GroupSelectionDialog extends StatefulWidget {
  const _GroupSelectionDialog({
    super.key,
    required this.initialGroupId,
    required this.initialMemberIds,
  });

  final String? initialGroupId;
  final Set<String> initialMemberIds;

  @override
  State<_GroupSelectionDialog> createState() =>
      _GroupSelectionDialogState();
}

class _GroupSelectionDialogState
    extends State<_GroupSelectionDialog> {
  String? _selectedGroupId;

  final Set<String> _selectedMemberIds = {};

  List<Group> _availableGroups = [];

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.initialGroupId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar grupo'),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<List<Group>>(
          stream: GroupService.groupsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text(
                'No se pudieron cargar los grupos.',
              );
            }

            if (!snapshot.hasData) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Evitar grupos duplicados.
            final groups = {
              for (final group in snapshot.data!)
                group.id: group,
            }.values.toList();

            _availableGroups = groups;

            if (groups.isEmpty) {
              return const Text(
                'Todavía no perteneces a ningún grupo. '
                'Primero crea o únete a un grupo.',
              );
            }

            // Verificar que el grupo inicial todavía exista.
            final validGroup = groups.where(
              (group) => group.id == _selectedGroupId,
            );

            final selectedGroup =
                validGroup.isNotEmpty ? validGroup.first : null;

            // Recuperar la selección anterior al editar.
            if (!_initialized) {
              _initialized = true;

              if (selectedGroup != null) {
                if (selectedGroup.id == widget.initialGroupId) {
                  _selectedMemberIds.addAll(
                    widget.initialMemberIds,
                  );
                } else {
                  _selectedMemberIds.addAll(
                    selectedGroup.members.map(
                      (member) => member.id,
                    ),
                  );
                }
              }
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey(_selectedGroupId),
                  initialValue: selectedGroup?.id,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Grupo',
                    border: OutlineInputBorder(),
                  ),
                  items: groups.map((group) {
                    return DropdownMenuItem<String>(
                      value: group.id,
                      child: Text(
                        group.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (groupId) {
                    if (groupId == null) return;

                    setState(() {
                      _selectedGroupId = groupId;
                      _selectedMemberIds.clear();

                      final newGroup = groups.firstWhere(
                        (group) => group.id == groupId,
                      );

                      // Al cambiar de grupo, seleccionar
                      // todos sus integrantes inicialmente.
                      _selectedMemberIds.addAll(
                        newGroup.members.map(
                          (member) => member.id,
                        ),
                      );
                    });
                  },
                ),

                const SizedBox(height: 18),

                if (selectedGroup != null) ...[
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Participantes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            final allIds = selectedGroup.members
                                .map((member) => member.id)
                                .toSet();

                            if (_selectedMemberIds
                                .containsAll(allIds)) {
                              _selectedMemberIds.clear();
                            } else {
                              _selectedMemberIds
                                ..clear()
                                ..addAll(allIds);
                            }
                          });
                        },
                        child: const Text('Seleccionar todos'),
                      ),
                    ],
                  ),

                  const Divider(),

                  if (selectedGroup.members.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Este grupo todavía no tiene integrantes.',
                      ),
                    )
                  else
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: selectedGroup.members.length,
                        itemBuilder: (context, index) {
                          final member =
                              selectedGroup.members[index];

                          final selected =
                              _selectedMemberIds.contains(member.id);

                          return CheckboxListTile(
                            value: selected,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity:
                                ListTileControlAffinity.leading,
                            title: Text(member.name),
                            subtitle: member.phone != null
                                ? Text(member.phone!)
                                : null,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedMemberIds.add(member.id);
                                } else {
                                  _selectedMemberIds.remove(member.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),

        FilledButton(
          onPressed: _selectedGroupId == null ||
                  !_availableGroups.any(
                    (group) => group.id == _selectedGroupId,
                  )
              ? null
              : () {
                  final group = _availableGroups.firstWhere(
                    (group) => group.id == _selectedGroupId,
                  );

                  final selectedMembers = group.members
                      .where(
                        (member) => _selectedMemberIds.contains(
                          member.id,
                        ),
                      )
                      .toList();

                  Navigator.pop(
                    context,
                    _GroupSelection(
                      group: group,
                      members: selectedMembers,
                    ),
                  );
                },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

// Lista de gastos recientes.
class ExpenseCollapsible extends StatefulWidget {
  const ExpenseCollapsible({
    super.key,
    required this.expenses,
  });

  final List<Expense> expenses;

  @override
  State<ExpenseCollapsible> createState() =>
      _ExpenseCollapsibleState();
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (totalItems > _itemLimit)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAll = !_showAll;
                  });
                },
                child: Text(
                  _showAll ? "Ver menos" : "Ver todo",
                  style: TextStyle(color: cs.primary),
                ),
              ),
          ],
        ),

        Expanded(
          child: totalItems == 0
              ? const Center(
                  child: Text("Aún no hay gastos"),
                )
              : ListView.builder(
                  itemCount: visibleItems,
                  itemBuilder: (context, index) {
                    return ExpenseItem(
                      expense: widget.expenses[index],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
