import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labomba/main.dart';
import 'package:labomba/l10n/app_localizations.dart';
import 'package:labomba/l10n/content_en.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('inicio unificado arranca en 1 toque sin jugadores ni turnos', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'tutorial_seen': true,
      'language': 'es',
    });
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const BombApp());
    await tester.pumpAndSettle();

    expect(
      find.text('SIN NOMBRES · SIN JUGADORES · SIN TURNOS'),
      findsOneWidget,
    );
    expect(find.text('Encender mecha (Al azar)'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text('Animales'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('3'), findsOneWidget);
    expect(find.text('ELEGID QUIÉN EMPIEZA'), findsOneWidget);
    expect(find.text('TIC · TAC · TIC · TAC'), findsNothing);

    await tester.pump(const Duration(seconds: 3));
    final animalPrompts = expandedPrompts('Animales');
    expect(
      animalPrompts.any((prompt) => find.text(prompt).evaluate().isNotEmpty),
      isTrue,
    );
    expect(find.text('Seguid respondiendo hasta que explote'), findsOneWidget);
    expect(find.text('Cambiar consigna (2)'), findsOneWidget);
  });

  testWidgets('incluye categorías, packs especiales, recompensas y ajustes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'tutorial_seen': true,
      'language': 'es',
    });
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const BombApp());
    await tester.pumpAndSettle();

    expect(categories.length, 26);
    expect(specialPacks.length, 4);
    expect(categories.skip(1).every((item) => item.items.length >= 10), isTrue);
    expect(specialPacks.every((item) => item.items.length >= 10), isTrue);

    // Open Rewards from top sparks pill
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();
    expect(find.text('Recompensas'), findsOneWidget);
    expect(find.text('Gana +50 Chispas gratis'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // Open Settings and check grouped sections
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Reto del perdedor'), findsOneWidget);
    expect(find.text('Tensión dinámica'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(find.text('Modo claro'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(find.text('Opciones de privacidad'), findsOneWidget);
  });

  testWidgets('permite cambiar consigna 2 veces gratis y luego pide anuncio', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'tutorial_seen': true,
      'language': 'es',
    });
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const BombApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Animales'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.text('Cambiar consigna (2)'), findsOneWidget);
    await tester.tap(find.text('Cambiar consigna (2)'));
    await tester.pump();
    expect(find.text('Cambiar consigna (1)'), findsOneWidget);
    await tester.tap(find.text('Cambiar consigna (1)'));
    await tester.pump();
    expect(find.text('Ver anuncio (+3 cambios)'), findsOneWidget);
  });

  testWidgets('la siguiente ronda la comienza quien perdió', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('es'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: Scaffold(
          body: StartCountdown(
            seconds: 3,
            previousLoserStarts: true,
            cancel: _noop,
          ),
        ),
      ),
    );
    expect(
      find.text('EMPIEZA QUIEN PERDIÓ\nLA RONDA ANTERIOR'),
      findsOneWidget,
    );
  });

  testWidgets('muestra el tutorial solo en la primera apertura', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'language': 'es'});
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const BombApp());
    await tester.pumpAndSettle();
    expect(find.text('Móvil en el centro'), findsOneWidget);
    expect(find.text('Elegid y activad una categoría'), findsOneWidget);
    expect(find.text('Quién empieza'), findsOneWidget);
    await tester.tap(find.text('Entendido, vamos a jugar'));
    await tester.pumpAndSettle();
    expect(find.text('Encender mecha (Al azar)'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('tutorial_seen'), isTrue);
  });

  testWidgets('traduce la interfaz y el contenido al inglés', (tester) async {
    SharedPreferences.setMockInitialValues({
      'tutorial_seen': true,
      'language': 'en',
    });
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const BombApp());
    await tester.pumpAndSettle();
    expect(find.text('Light the fuse (Random)'), findsOneWidget);
    expect(find.text('Animals'), findsOneWidget);
    expect(find.text('Animales'), findsNothing);
  });

  test('todas las categorías, packs y retos incluidos tienen traducción', () {
    for (final category in [...categories, ...specialPacks]) {
      expect(englishContent(category.name), isNot(category.name));
      for (final prompt in category.items) {
        expect(englishContent(prompt), isNot(prompt), reason: prompt);
      }
    }
    for (final dare in loserDares) {
      expect(englishContent(dare), isNot(dare), reason: dare);
    }
  });

  testWidgets('permite cambiar el idioma desde configuración', (tester) async {
    SharedPreferences.setMockInitialValues({
      'tutorial_seen': true,
      'language': 'es',
    });
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const BombApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inglés').last);
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('language'), 'en');
  });

  testWidgets('crea consignas y categorías directamente desde inicio', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'tutorial_seen': true,
      'language': 'es',
    });
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const BombApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crear mía'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Añadir consigna'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Animales nocturnos');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Consigna añadida'), findsOneWidget);

    await tester.tap(find.text('Crear categoría'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Espacio');
    await tester.enterText(fields.at(1), '🚀');
    await tester.enterText(fields.at(2), 'Planetas');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Espacio'), findsWidgets);

    final prefs = await SharedPreferences.getInstance();
    final custom = jsonDecode(prefs.getString('custom_categories')!) as List;
    expect(custom, hasLength(1));

    final promptDelete = find.byKey(
      const ValueKey('delete-prompt-Animales-Animales nocturnos'),
    );
    await tester.ensureVisible(promptDelete);
    await tester.tap(promptDelete);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();
    final customItems =
        jsonDecode(prefs.getString('custom_items')!) as Map<String, dynamic>;
    expect(customItems['Animales'], isNull);

    final categoryDelete = find.byKey(
      const ValueKey('delete-category-Espacio'),
    );
    await tester.ensureVisible(categoryDelete);
    await tester.tap(categoryDelete);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();
    final remainingCategories =
        jsonDecode(prefs.getString('custom_categories')!) as List;
    expect(remainingCategories, isEmpty);
    expect(tester.takeException(), isNull);
  });
}

List<String> expandedPrompts(String categoryName) {
  return categories.firstWhere((item) => item.name == categoryName).items;
}

void _noop() {}
