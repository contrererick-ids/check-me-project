import 'package:flutter/material.dart';

// colores "positivos" (verde) que Material no incluye en el ColorScheme.
//
// se derivan de una semilla verde con el mismo algoritmo de Material 3 que usa el resto del tema, asi cada par cumple contraste AA (>= 4.5:1) en claro y oscuro:
//   color       -> texto/iconos sobre una superficie neutra (tono 40 claro / 80 oscuro)
//   container   -> fondo suave, para avatares o chips
//   onContainer -> texto/icono que va sobre `container`
class SuccessColors {
  const SuccessColors({
    required this.color,
    required this.container,
    required this.onContainer,
  });

  final Color color;
  final Color container;
  final Color onContainer;

  static const Color _seed = Color(0xFF4CAF50);

  // se guarda uno por brillo
  static final Map<Brightness, ColorScheme> _cache = {};

  static SuccessColors of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = _cache.putIfAbsent(
      brightness,
      () => ColorScheme.fromSeed(seedColor: _seed, brightness: brightness),
    );

    return SuccessColors(
      color: scheme.primary,
      container: scheme.primaryContainer,
      onContainer: scheme.onPrimaryContainer,
    );
  }
}
