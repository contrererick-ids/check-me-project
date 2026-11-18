import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_entrega1/screens/login.dart';
import 'package:proyecto_entrega1/services/profile_service.dart';
import 'package:proyecto_entrega1/utils/snackbar_utils.dart';

enum _OpcionFoto { camara, galeria, eliminar }

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _perfil = ProfileService.instance;
  final _nombreController = TextEditingController();
  final _celularController = TextEditingController();
  bool _guardando = false;
  bool _cambiandoFoto = false;

  @override
  void initState() {
    super.initState();
    if (_perfil.cargado) {
      _rellenar();
    } else {
      _perfil.cargar().then((_) {
        if (mounted) _rellenar();
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _celularController.dispose();
    super.dispose();
  }

  void _rellenar() {
    _nombreController.text = _perfil.nombreParaEditar;
    _celularController.text = _perfil.celular;
  }

  Future<void> _elegirFoto() async {
    if (_guardando || _cambiandoFoto) return;

    final opcion = await showModalBottomSheet<_OpcionFoto>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(sheetContext, _OpcionFoto.camara),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(sheetContext, _OpcionFoto.galeria),
            ),
            if (_perfil.tieneFotoLocal)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Eliminar foto'),
                onTap: () => Navigator.pop(sheetContext, _OpcionFoto.eliminar),
              ),
          ],
        ),
      ),
    );

    if (opcion == null || !mounted) return;

    setState(() => _cambiandoFoto = true);
    try {
      if (opcion == _OpcionFoto.eliminar) {
        await _perfil.eliminarFoto();
        if (!mounted) return;
        final tieneGoogle = FirebaseAuth.instance.currentUser?.photoURL != null;
        showSnackbarMessage(
          context,
          tieneGoogle
              ? 'Foto eliminada. Se mostrará tu foto de Google.'
              : 'Foto eliminada.',
        );
      } else {
        final cambio = await _perfil.cambiarFoto(
          opcion == _OpcionFoto.camara
              ? ImageSource.camera
              : ImageSource.gallery,
        );
        if (!mounted) return;
        if (cambio) showSnackbarMessage(context, 'Foto actualizada.');
      }
    } catch (_) {
      if (!mounted) return;
      showSnackbarMessage(
        context,
        'No se pudo actualizar la foto. Intenta de nuevo.',
      );
    } finally {
      if (mounted) setState(() => _cambiandoFoto = false);
    }
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    final nombre = _nombreController.text.trim();
    final celular = _celularController.text.trim();

    if (nombre.length <= 3) {
      showSnackbarMessage(context, 'El nombre debe tener más de 3 caracteres.');
      return;
    }
    if (celular.isNotEmpty && !RegExp(r'^\d{9,11}$').hasMatch(celular)) {
      showSnackbarMessage(
        context,
        'El celular debe tener solo números, de 9 a 11 dígitos.',
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      await _perfil.guardarDatos(nombre: nombre, celular: celular);
      if (!mounted) return;
      showSnackbarMessage(context, 'Perfil actualizado correctamente.');
    } catch (_) {
      if (!mounted) return;
      showSnackbarMessage(
        context,
        'No se pudo guardar el perfil. Revisa tu conexión e intenta de nuevo.',
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    // confirmacion antes de cerrar sesion
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesion'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cerrar sesion',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();
      _perfil.limpiar();

      if (!context.mounted) return;
      // quita todas las pantallas anteriores y regresa al login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!context.mounted) return;
      showSnackbarMessage(context, 'No se pudo cerrar sesion. Intenta de nuevo.');
    }
  }

  InputDecoration _decoracion(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color.fromARGB(255, 151, 150, 150)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar Mi Perfil',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 43, vertical: 20),
        children: [
          const SizedBox(height: 20),

          // Foto de perfil
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ListenableBuilder(
                  listenable: _perfil,
                  builder: (context, _) => CircleAvatar(
                    radius: 87.5,
                    backgroundColor: const Color(0xFFD9D9D9),
                    backgroundImage: _perfil.foto,
                    child: _cambiandoFoto
                        ? const CircularProgressIndicator(color: Colors.white)
                        : null,
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _elegirFoto,
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // Nombre
          const Text(
            'Nombre',
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nombreController,
            enabled: !_guardando,
            textCapitalization: TextCapitalization.words,
            decoration: _decoracion('Nombre'),
          ),

          const SizedBox(height: 15),

          // Celular
          const Text(
            'Celular',
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _celularController,
            enabled: !_guardando,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            decoration: _decoracion('Celular'),
          ),

          const SizedBox(height: 35),

          // Guardar cambios
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: (_guardando || _cambiandoFoto) ? null : _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF808080),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: _guardando
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Guardar cambios',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          // Cerrar sesion
          ElevatedButton(
            onPressed: _guardando ? null : () => _signOut(context),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: const StadiumBorder(),
            ),
            child: const Text('Cerrar sesión', style: TextStyle(fontSize: 18)),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
