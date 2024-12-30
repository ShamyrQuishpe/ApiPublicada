import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_api/main.dart'; // Importa tu archivo `main.dart` correctamente

void main() {
  testWidgets('Carga de la aplicación', (WidgetTester tester) async {
    // Construye el widget principal.
    await tester.pumpWidget(MyApp());

    // Verifica que el título de la app esté presente.
    expect(find.text('Pokémon & Dog Finder'), findsOneWidget);
  });
}
