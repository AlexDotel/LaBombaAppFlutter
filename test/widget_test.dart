import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labomba/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('no contiene jugadores ni turnos', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const BombApp());
    expect(
      find.text('SIN NOMBRES · SIN JUGADORES · SIN TURNOS'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('Elegir categoría'));
    await tester.pumpAndSettle();
    expect(find.text('Todo el grupo juega a la vez.'), findsOneWidget);
    await tester.tap(find.text('Animales'));
    await tester.pumpAndSettle();
    expect(find.text('NOMBRAD...'), findsOneWidget);
    expect(find.text('Encender la mecha'), findsOneWidget);
    await tester.tap(find.text('Encender la mecha'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Sumar respuesta'), findsNothing);
    expect(find.text('Seguid respondiendo hasta que explote'), findsOneWidget);
  });

  testWidgets('incluye categorías pares, azar y modo claro', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BombApp());
    await tester.pumpAndSettle();
    expect(categories.length, 26);
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Modo claro'), findsOneWidget);
  });

  testWidgets('no repite consignas antes de agotar la categoría', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BombApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elegir categoría'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Animales'));
    await tester.pumpAndSettle();

    final seen = <String>{};
    final animalPrompts = categories
        .firstWhere((item) => item.name == 'Animales')
        .items;
    for (var index = 0; index < animalPrompts.length; index++) {
      seen.add(
        animalPrompts.singleWhere(
          (prompt) => find.text(prompt).evaluate().isNotEmpty,
        ),
      );
      if (index < animalPrompts.length - 1) {
        await tester.tap(find.text('Otra consigna'));
        await tester.pumpAndSettle();
      }
    }
    expect(seen, hasLength(animalPrompts.length));
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getStringList('used_challenges'),
      hasLength(animalPrompts.length),
    );
  });
}
