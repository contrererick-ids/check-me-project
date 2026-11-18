import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Este valor se puede cambiar para probar otros temas
  static const FlexScheme _scheme = FlexScheme.deepOrangeM3;

  static const FlexSubThemesData _subThemes = FlexSubThemesData(
    defaultRadius: 16,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    inputDecoratorRadius: 30,
    interactionEffects: true,
  );

  static ThemeData get light => FlexThemeData.light(
    scheme: _scheme,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 7,
    subThemesData: _subThemes,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
  );

  static ThemeData get dark => FlexThemeData.dark(
    scheme: _scheme,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 13,
    subThemesData: _subThemes,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
  );
}