
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';

import 'package:proyecto_entrega1/models/group.dart';
import 'package:proyecto_entrega1/models/group_member.dart';
import 'package:proyecto_entrega1/services/group_service.dart';

class ConfigGrupos extends StatefulWidget {
  const ConfigGrupos({super.key, required this.group});

  final Group group;

  @override
  State<ConfigGrupos> createState() => _ConfigGruposState();
}

class _ConfigGruposState extends State<ConfigGrupos> {
  final FlutterNativeContactPicker _contactPicker =
      FlutterNativeContactPicker();

  late List<GroupMember> miembros;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    miembros = List<GroupMember>.from(widget.group.members);
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  // Comprobar si el integrante es el administrador.
  bool _esAdministrador(GroupMember miembro) {
    return miembro.id == widget.group.createdBy ||
        miembro.userId == widget.group.createdBy;
  }

  // Formatear teléfonos mexicanos con el prefijo +52.
  String _formatearTelefono(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Sin teléfono';
    }

    String numero = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Quitar el código de país si ya existe.
    if (numero.startsWith('521') && numero.length == 13) {
      numero = numero.substring(3);
    } else if (numero.startsWith('52') && numero.length == 12) {
      numero = numero.substring(2);
    }

    return '+52 $numero';
  }

  // Abrir contactos y agregar un integrante.
  Future<void> _agregarMiembro() async {
    if (miembros.length >= 5) {
      _mostrarMensaje('Has llegado al límite de 5 miembros');
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      final contact = await _contactPicker.selectContact();

      if (!mounted) return;

      if (contact == null) return;

      final phone = contact.selectedPhoneNumber ??
          (contact.phoneNumbers?.isNotEmpty == true
              ? contact.phoneNumbers!.first
              : null);

      if (phone == null || phone.trim().isEmpty) {
        _mostrarMensaje(
          'El contacto no tiene un número telefónico',
        );
        return;
      }

      final name = contact.fullName?.trim().isNotEmpty == true
          ? contact.fullName!.trim()
          : 'Contacto';

      // Buscar si el contacto tiene cuenta de Check Me.
      final registeredUser =
          await GroupService.findUserByPhone(phone);

      if (!mounted) return;

      final member = registeredUser ??
          GroupMember(
            id: 'contact_${DateTime.now().microsecondsSinceEpoch}',
            name: name,
            phone: phone,
          );

      // Agregar a Firebase.
      await GroupService.addMember(widget.group.id, member);

      if (!mounted) return;

      setState(() {
        miembros.add(member);
      });

      _mostrarMensaje('$name fue agregado al grupo');
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  // Confirmar eliminación de un integrante.
  Future<void> _confirmarEliminar(GroupMember miembro) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar integrante'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${miembro.name} del grupo?',
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
      await GroupService.removeMember(
        widget.group.id,
        miembro.id,
      );

      if (!mounted) return;

      setState(() {
        miembros.removeWhere(
          (item) => item.id == miembro.id,
        );
      });

      _mostrarMensaje(
        '${miembro.name} fue eliminado del grupo',
      );
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(13, 20, 13, 24),
        children: [
          // Nombre del grupo.
          Text(
            widget.group.name,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),

          const SizedBox(height: 34),

          // Título de miembros.
          Text(
            'Miembros:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          // Barra decorativa.
          Container(
            width: 90,
            height: 7,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(6),
            ),
          ),

          const SizedBox(height: 4),

          // Contador de miembros.
          Text(
            '${miembros.length}/5 miembros',
            style: TextStyle(
              fontSize: 15,
              color: cs.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),

          // Botón para agregar miembros.
          Center(
            child: ElevatedButton.icon(
              onPressed: _cargando || miembros.length >= 5
                  ? null
                  : _agregarMiembro,
              icon: const Icon(
                Icons.person_add_alt_1,
                size: 18,
              ),
              label: Text(
                _cargando
                    ? 'Agregando...'
                    : 'Agregar miembros',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.onSurface,
                side: BorderSide(
                  color: cs.onSurface,
                  width: 2,
                ),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 8,
                ),
                minimumSize: const Size(0, 36),
              ),
            ),
          ),

          const SizedBox(height: 43),

          // Título de amigos.
          Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Text(
              'Mis amigos:',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Lista de integrantes.
          ...miembros.map((miembro) {
            final esAdmin = _esAdministrador(miembro);

            return Padding(
              padding: const EdgeInsets.only(
                left: 30,
                right: 27,
                bottom: 26,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Nombre y celular.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          miembro.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        if (!esAdmin) ...[
                          const SizedBox(height: 3),
                          Text(
                            _formatearTelefono(miembro.phone),
                            style: TextStyle(
                              fontSize: 14,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Administrador o botón de eliminar.
                  if (esAdmin)
                    Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(241, 196, 33, 1),
                      ),
                    )
                  else
                    OutlinedButton(
                      onPressed: () => _confirmarEliminar(miembro),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.onSurface,
                        side: BorderSide(
                          color: cs.outline,
                          width: 1,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        minimumSize: const Size(0, 25),
                      ),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
