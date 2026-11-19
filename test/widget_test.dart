// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_entrega1/main.dart';
import 'package:proyecto_entrega1/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('La aplicación se construye correctamente', (
    WidgetTester tester,
  ) async {
    final themeProvider = ThemeProvider();
    await themeProvider.load();

    await tester.pumpWidget(
      MyApp(themeProvider: themeProvider),
    );

    await tester.pump();

    expect(find.byType(MyApp), findsOneWidget);
  });
}
