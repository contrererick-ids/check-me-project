import 'package:flutter/material.dart';
import 'package:proyecto_entrega1/data/dummy_data.dart';
import 'package:proyecto_entrega1/models/group.dart';
import 'package:proyecto_entrega1/screens/configroups.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  Future<void> _showGroupDialog({Group? group}) async {
    final nameController = TextEditingController(text: group?.name ?? '');
    final selected = <String>{...?group?.memberNames};

    final friends = amigosGrupoDummy
        .map((a) => a['nombre'] ?? '')
        .where((n) => n.isNotEmpty);
    final options = {...friends, ...?group?.memberNames}.toList();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(group == null ? "Nuevo grupo" : "Editar grupo"),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: "Nombre del grupo",
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Integrantes",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: options
                        .map(
                          (name) => CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(name),
                            value: selected.contains(name),
                            onChanged: (checked) => setDialogState(() {
                              checked == true
                                  ? selected.add(name)
                                  : selected.remove(name);
                            }),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(group == null ? "Crear" : "Guardar"),
            ),
          ],
        ),
      ),
    );

    final name = nameController.text.trim();
    if (saved != true || name.isEmpty) return;

    setState(() {
      if (group == null) {
        groups.add(
          Group(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            memberNames: selected.toList(),
            tripIds: [],
          ),
        );
      } else {
        group.name = name;
        group.memberNames = selected.toList();
      }
    });
  }

  Future<void> _confirmDelete(Group group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar grupo"),
        content: Text(
          "¿Seguro que quieres eliminar \"${group.name}\"? "
          "Las actividades del grupo no se borrarán.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => groups.remove(group));
  }

  String _plural(int n, String singular, String plural) =>
      "$n ${n == 1 ? singular : plural}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Grupos",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: groups.isEmpty
                  ? const Center(child: Text("Aún no tienes grupos"))
                  : ListView.builder(
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 219, 215, 211),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.only(
                              left: 16,
                              right: 4,
                              top: 8,
                              bottom: 8,
                            ),
                            title: Text(
                              group.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${_plural(group.memberNames.length, 'integrante', 'integrantes')} • "
                              "${_plural(group.tripIds.length, 'actividad', 'actividades')}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: "Editar",
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ConfigGrupos(group: group),
                                      ),
                                    );
                                    setState(() {});
                                  },
                                ),
                                IconButton(
                                  tooltip: "Eliminar",
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _confirmDelete(group),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showGroupDialog(),
<<<<<<< HEAD
                style: ElevatedButton.styleFrom(
=======
                style: OutlinedButton.styleFrom(
>>>>>>> 26ef33d3ee7a84cb5473b99516402fa8c8aa7019
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: const StadiumBorder(),
                ),
                child: const Text("Crear Grupo"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
