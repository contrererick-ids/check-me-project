
import 'package:flutter/material.dart';

import 'package:proyecto_entrega1/models/group.dart';
import 'package:proyecto_entrega1/services/group_service.dart';
import 'package:proyecto_entrega1/screens/configroups.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {

  // Mostrar el diálogo para crear un grupo.
  Future<void> _showGroupDialog() async {
    try {
      final name = await showDialog<String>(
        context: context,
        builder: (dialogContext) => const _NewGroupDialog(),
      );

      if (!mounted || name == null || name.isEmpty) return;

      await GroupService.createGroup(name);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grupo creado correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear el grupo: $e'),
        ),
      );
    }
  }

  // Abrir la configuración del grupo.
  void _editGroup(Group group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfigGrupos(group: group),
      ),
    );
  }

  // Confirmar y eliminar un grupo.
  Future<void> _confirmDelete(Group group) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar grupo'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el grupo "${group.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await GroupService.deleteGroup(group.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grupo eliminado correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al eliminar el grupo: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  String _plural(int n, String singular, String plural) {
    return '$n ${n == 1 ? singular : plural}';
  }

  // Construir tarjeta de grupo.
  Widget _groupCard(Group group) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: cs.surfaceContainer,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(
          group.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${_plural(group.members.length, 'integrante', 'integrantes')} • '
          '${_plural(group.tripIds.length, 'actividad', 'actividades')}',
        ),

        // Botones de editar y eliminar.
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Modificar grupo',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editGroup(group),
            ),
            IconButton(
              tooltip: 'Eliminar grupo',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(group),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grupos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Group>>(
                stream: GroupService.groupsStream(),
                builder: (context, snapshot) {

                  // Mientras carga Firebase.
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Si ocurre un error.
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error al cargar los grupos:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final groups = snapshot.data ?? [];

                  // Si no existen grupos.
                  if (groups.isEmpty) {
                    return const Center(
                      child: Text('Aún no tienes grupos'),
                    );
                  }

                  // Mostrar grupos de Firebase.
                  return ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      return _groupCard(groups[index]);
                    },
                  );
                },
              ),
            ),

            // Botón para crear grupo.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showGroupDialog,
                style: ElevatedButton.styleFrom(
                  foregroundColor: cs.onSurface,
                  side: BorderSide(color: cs.onSurface),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Crear Grupo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Diálogo independiente para crear grupos.
class _NewGroupDialog extends StatefulWidget {
  const _NewGroupDialog();

  @override
  State<_NewGroupDialog> createState() => _NewGroupDialogState();
}

class _NewGroupDialogState extends State<_NewGroupDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo grupo'),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'Nombre del grupo',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final value = _nameController.text.trim();

            if (value.isEmpty) return;

            Navigator.pop(context, value);
          },
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
