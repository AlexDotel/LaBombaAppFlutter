import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'l10n/content_en.dart';

extension LocalizedContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const BombApp());
}

const ink = Color(0xFF11121A),
    panel = Color(0xFF1B1D28),
    cream = Color(0xFFF7F3E9),
    yellow = Color(0xFFFFCC4D),
    orange = Color(0xFFFF5A36),
    muted = Color(0xFFADB0BF);
const customCategoryCost = 10;
const customPromptCost = 5;
const maxCustomCategoryPrompts = 10;
const audio = MethodChannel('labomba/audio');

enum AddPromptResult { added, invalid, limitReached, notEnoughSparks }

enum AddCategoryResult { created, invalid, notEnoughSparks }

enum BombSkin {
  classic,
  mafioso,
  tattoo,
  cat,
  pirate,
  ninja,
  king,
  alien,
  punk,
  viking,
  panda,
  cyber,
  devil,
}

extension BombSkinMeta on BombSkin {
  int get sparkCost => switch (this) {
    BombSkin.classic => 0,
    BombSkin.mafioso => 120,
    BombSkin.tattoo => 120,
    BombSkin.cat => 100,
    BombSkin.pirate => 120,
    BombSkin.ninja => 130,
    BombSkin.king => 200,
    BombSkin.alien => 140,
    BombSkin.punk => 140,
    BombSkin.viking => 150,
    BombSkin.panda => 100,
    BombSkin.cyber => 160,
    BombSkin.devil => 150,
  };

  String get assetPath => switch (this) {
    BombSkin.classic => 'assets/branding/bomb-brand.png',
    _ => 'assets/skins/$name.png',
  };

  Color get glowColor => switch (this) {
    BombSkin.classic => orange,
    BombSkin.mafioso => yellow,
    BombSkin.tattoo => orange,
    BombSkin.cat => yellow,
    BombSkin.pirate => const Color(0xFFEF4444),
    BombSkin.ninja => const Color(0xFFEF4444),
    BombSkin.king => yellow,
    BombSkin.alien => const Color(0xFF22C55E),
    BombSkin.punk => orange,
    BombSkin.viking => orange,
    BombSkin.panda => yellow,
    BombSkin.cyber => const Color(0xFF22D3EE),
    BombSkin.devil => const Color(0xFFEF4444),
  };

  String localizedName(BuildContext context) => switch (this) {
    BombSkin.classic => context.l10n.skinClassic,
    BombSkin.mafioso => context.l10n.skinMafioso,
    BombSkin.tattoo => context.l10n.skinTattoo,
    BombSkin.cat => context.l10n.skinCat,
    BombSkin.pirate => context.l10n.skinPirate,
    BombSkin.ninja => context.l10n.skinNinja,
    BombSkin.king => context.l10n.skinKing,
    BombSkin.alien => context.l10n.skinAlien,
    BombSkin.punk => context.l10n.skinPunk,
    BombSkin.viking => context.l10n.skinViking,
    BombSkin.panda => context.l10n.skinPanda,
    BombSkin.cyber => context.l10n.skinCyber,
    BombSkin.devil => context.l10n.skinDevil,
  };
}

class Category {
  const Category(
    this.name,
    this.emoji,
    this.items, {
    this.custom = false,
    this.packId,
    this.sparkCost = 0,
  });
  final String name, emoji;
  final List<String> items;
  final bool custom;
  final String? packId;
  final int sparkCost;

  bool get isSpecialPack => packId != null;
}

final categories = <Category>[
  const Category('Al azar', '🎲', []),
  const Category('Animales', '🐾', [
    'Animales marinos',
    'Animales que vuelan',
    'Animales de granja',
    'Animales salvajes',
    'Animales con cuatro patas',
    'Animales domésticos',
    'Insectos y bichos',
    'Animales de África',
    'Animales pequeños',
    'Animales peligrosos',
  ]),
  const Category('Ciudades', '🏙️', [
    'Ciudades españolas',
    'Capitales europeas',
    'Ciudades con playa',
    'Ciudades de América',
    'Ciudades de Italia',
    'Ciudades muy turísticas',
    'Ciudades de Francia',
    'Capitales del mundo',
    'Ciudades con metro',
    'Ciudades donde irías de vacaciones',
  ]),
  const Category('Países', '🌍', [
    'Países de Europa',
    'Países de América',
    'Países con costa',
    'Países de Asia',
    'Países cálidos',
    'Países donde se habla español',
    'Países donde se habla inglés',
    'Países de África',
    'Países con nieve',
    'Países famosos por su comida',
  ]),
  const Category('Comida', '🍕', [
    'Frutas',
    'Postres',
    'Comidas con queso',
    'Platos fríos',
    'Comidas de otros países',
    'Verduras y hortalizas',
    'Desayunos',
    'Comida rápida',
    'Snacks y aperitivos',
    'Ingredientes de una pizza',
  ]),
  const Category('Objetos', '🎒', [
    'Objetos de cocina',
    'Objetos con ruedas',
    'Objetos de un colegio',
    'Objetos que caben en un bolsillo',
    'Objetos de metal',
    'Objetos de plástico',
    'Objetos que necesitan pilas o batería',
    'Objetos con botones',
    'Objetos de cristal',
    'Objetos que llevas en el bolso o mochila',
  ]),
  const Category('Películas', '🎬', [
    'Películas de animación',
    'Películas de terror',
    'Películas de superhéroes',
    'Sagas de cine',
    'Películas con animales',
    'Películas de comedia',
    'Películas de acción',
    'Películas de Disney o Pixar',
    'Películas románticas',
    'Películas de ciencia ficción',
  ]),
  const Category('Series', '📺', [
    'Series de comedia',
    'Series españolas',
    'Series de animación',
    'Series con detectives o crímenes',
    'Series de Netflix',
    'Series de ciencia ficción o fantasía',
    'Series de los años 90 o 2000',
    'Series de acción',
    'Series que todo el mundo conoce',
    'Personajes famosos de series',
  ]),
  const Category('Música', '🎵', [
    'Cantantes españoles',
    'Grupos musicales',
    'Instrumentos musicales',
    'Canciones de fiesta',
    'Géneros musicales',
    'Cantantes internacionales',
    'Canciones en español muy conocidas',
    'Artistas de reguetón o música urbana',
    'Artistas de pop',
    'Festivales o conciertos famosos',
  ]),
  const Category('Deportes', '🏆', [
    'Deportes con pelota',
    'Deportes de equipo',
    'Deportes acuáticos',
    'Deportes olímpicos',
    'Deportes individuales',
    'Deportes de invierno',
    'Deportes de raqueta o pala',
    'Deportes de motor',
    'Ejercicios de gimnasio',
    'Accesorios deportivos',
  ]),
  const Category('Profesiones', '💼', [
    'Profesiones sanitarias',
    'Trabajos al aire libre',
    'Profesiones con uniforme',
    'Profesiones creativas',
    'Trabajos con ordenador',
    'Profesiones de un restaurante',
    'Trabajos de oficina',
    'Profesiones relacionadas con el deporte',
    'Trabajos en un aeropuerto',
    'Oficios manuales',
  ]),
  const Category('Marcas', '🛍️', [
    'Marcas de coches',
    'Marcas de ropa',
    'Marcas de móviles o tecnología',
    'Marcas de comida o restaurantes',
    'Marcas deportivas',
    'Marcas de bebidas',
    'Supermercados y grandes tiendas',
    'Marcas de videojuegos',
    'Marcas de perfumes o cosmética',
    'Marcas de zapatillas',
  ]),
  const Category('Tecnología', '📱', [
    'Aplicaciones móviles',
    'Redes sociales',
    'Videojuegos',
    'Dispositivos electrónicos',
    'Cosas con pantalla',
    'Páginas web muy visitadas',
    'Accesorios de ordenador',
    'Plataformas de streaming',
    'Cosas que se conectan por Bluetooth',
    'Partes de un móvil o portátil',
  ]),
  const Category('Naturaleza', '🌿', [
    'Tipos de árboles',
    'Flores y plantas',
    'Fenómenos meteorológicos',
    'Cosas de un bosque',
    'Cosas del mar',
    'Paisajes naturales',
    'Montañas, ríos o mares famosos',
    'Cosas que ves en el cielo',
    'Piedras, minerales o metales',
    'Sonidos de la naturaleza',
  ]),
  const Category('Viajes', '✈️', [
    'Cosas de una maleta',
    'Medios de transporte',
    'Lugares turísticos famosos',
    'Cosas de un aeropuerto',
    'Cosas de un hotel',
    'Documentos o cosas para viajar',
    'Recuerdos o souvenirs',
    'Tipos de alojamiento',
    'Actividades de turista',
    'Destinos de playa',
  ]),
  const Category('Casa', '🏠', [
    'Cosas de un baño',
    'Muebles',
    'Electrodomésticos',
    'Cosas de un dormitorio',
    'Tareas domésticas',
    'Habitaciones o zonas de una casa',
    'Cosas de un salón',
    'Productos de limpieza',
    'Cosas que hay en una nevera',
    'Utensilios para cocinar',
  ]),
  const Category('Colegio', '🎓', [
    'Asignaturas',
    'Material escolar',
    'Cosas del recreo',
    'Lugares de un colegio',
    'Excusas para llegar tarde',
    'Juegos de patio',
    'Cosas dentro de un estuche',
    'Tipos de exámenes o trabajos',
    'Actividades extraescolares',
    'Cosas que hace un profesor',
  ]),
  const Category('Fiesta', '🪩', [
    'Bebidas de fiesta',
    'Canciones para bailar',
    'Motivos para celebrar',
    'Cosas que hay en una fiesta',
    'Juegos de mesa o de grupo',
    'Tipos de celebraciones',
    'Cosas de un cumpleaños',
    'Lugares donde salir de noche',
    'Comida de picoteo',
    'Disfraces típicos',
  ]),
  const Category('Famosos', '🌟', [
    'Actores de cine',
    'Deportistas famosos',
    'Cantantes famosos',
    'Personajes históricos',
    'Presentadores o creadores de contenido',
    'Actrices famosas',
    'Personajes de dibujos animados',
    'Superhéroes conocidos',
    'Científicos o inventores famosos',
    'Artistas o pintores famosos',
  ]),
  const Category('Palabras', '🔤', [
    'Palabras que empiezan por M',
    'Palabras de cinco letras',
    'Palabras que acaban en A',
    'Palabras que empiezan por C',
    'Palabras de verano',
    'Palabras que empiezan por P',
    'Palabras que acaban en O',
    'Palabras con tilde',
    'Palabras que empiezan por S',
    'Adjetivos para describir a una persona',
  ]),
  const Category('Cuerpo', '🫀', [
    'Partes del cuerpo',
    'Huesos del cuerpo',
    'Órganos internos',
    'Partes de la cara',
    'Cosas del cuerpo que tienes dos',
    'Articulaciones',
    'Músculos conocidos',
    'Partes de un brazo o mano',
    'Partes de una pierna o pie',
    'Acciones que hace tu cuerpo sin pensar',
  ]),
  const Category('Ropa', '👕', [
    'Prendas de invierno',
    'Tipos de calzado',
    'Accesorios de moda',
    'Ropa deportiva',
    'Prendas de verano',
    'Ropa elegante o de gala',
    'Cosas que se llevan en la cabeza',
    'Tejidos y materiales de ropa',
    'Ropa para estar por casa',
    'Colores de ropa habituales',
  ]),
  const Category('Vehículos', '🚗', [
    'Marcas de coche',
    'Vehículos de dos ruedas',
    'Transportes públicos',
    'Vehículos que vuelan',
    'Partes de un coche',
    'Vehículos que van por el agua',
    'Vehículos de emergencia o trabajo',
    'Cosas que ves en una carretera',
    'Señales o elementos de tráfico',
    'Cosas que llevas en el maletero',
  ]),
  const Category('Fantasía', '🐉', [
    'Seres mitológicos',
    'Superpoderes',
    'Personajes de cuentos',
    'Objetos mágicos',
    'Lugares imaginarios o de películas',
    'Monstruos famosos',
    'Dioses de la mitología',
    'Criaturas de ciencia ficción',
    'Sagas de fantasía',
    'Armas o herramientas de fantasía',
  ]),
  const Category('Verano', '☀️', [
    'Cosas de la playa',
    'Sabores de helado',
    'Planes de verano',
    'Cosas para protegerse del sol',
    'Bebidas frías',
    'Frutas de verano',
    'Actividades en la piscina',
    'Ropa de verano',
    'Cosas que molestan en verano',
    'Juegos de playa',
  ]),
  const Category('Navidad', '🎄', [
    'Adornos navideños',
    'Comidas y dulces de Navidad',
    'Regalos típicos',
    'Villancicos o canciones navideñas',
    'Cosas que haces en Navidad',
    'Personajes de Navidad',
    'Películas de Navidad',
    'Cosas de la cena de Nochevieja',
    'Propósitos de Año Nuevo',
    'Cosas típicas del invierno',
  ]),
];

final specialPacks = <Category>[
  const Category(
    'Fiesta +18',
    '🌶️',
    [
      'Excusas para no contestar un mensaje',
      'Mentiras piadosas típicas',
      'Cosas que nunca dirías en una primera cita',
      'Cócteles y combinados',
      'Señales de que la fiesta se ha ido de las manos',
      'Red flags en una cita',
      'Planes improvisados de madrugada',
      'Excusas para irte pronto de una fiesta',
      'Canciones que todo el mundo canta a gritos',
      'Cosas que pierdes cuando sales de fiesta',
    ],
    packId: 'fiesta',
    sparkCost: 80,
  ),
  const Category(
    'Gamers',
    '🎮',
    [
      'Sagas de videojuegos',
      'Personajes icónicos de videojuegos',
      'Consolas de la historia',
      'Juegos multijugador online',
      'Excusas de gamer cuando pierde',
      'Juegos de mundo abierto',
      'Armas o ítems famosos de videojuegos',
      'Juegos de Nintendo',
      'Juegos de móvil muy populares',
      'Cosas que hay en un setup gamer',
    ],
    packId: 'gamers',
    sparkCost: 80,
  ),
  const Category(
    'Cine Pro',
    '🎬',
    [
      'Directores de cine famosos',
      'Villanos de película',
      'Películas ganadoras de un Óscar',
      'Bandas sonoras inolvidables',
      'Clichés del cine de terror',
      'Películas con giros de guion',
      'Trilogías famosas',
      'Películas basadas en libros',
      'Películas de los años 80 o 90',
      'Frases míticas del cine',
    ],
    packId: 'cine',
    sparkCost: 100,
  ),
  const Category(
    'Fútbol',
    '⚽',
    [
      'Equipos de fútbol europeos',
      'Futbolistas legendarios',
      'Estadios famosos',
      'Selecciones campeonas del mundo',
      'Cosas que grita un entrenador',
      'Equipos de LaLiga',
      'Porteros famosos',
      'Entrenadores conocidos',
      'Posiciones o jugadas de fútbol',
      'Competiciones de fútbol',
    ],
    packId: 'futbol',
    sparkCost: 100,
  ),
];

const loserDares = <String>[
  'Imita a tu cantante favorito durante 10 segundos.',
  'Habla con acento extranjero hasta que termine la próxima ronda.',
  'Cuenta una anécdota graciosa en menos de 15 segundos.',
  'Haz 5 sentadillas antes de empezar la siguiente ronda.',
  'Di un trabalenguas rápido sin equivocarte.',
  'Elige a alguien del grupo para que invente la próxima categoría.',
  'Canta el estribillo de la última canción que escuchaste.',
  'Aplaude y anima a cada jugador en la siguiente ronda.',
  'Haz tu mejor cara de susto para una foto grupal imaginaria.',
  'Nombra 3 cosas buenas de la persona a tu derecha.',
];

class BombApp extends StatefulWidget {
  const BombApp({super.key});
  @override
  State<BombApp> createState() => _BombAppState();
}

class _BombAppState extends State<BombApp> {
  bool light = false;
  bool? tutorialSeen;
  String language = 'system';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        light = prefs.getBool('light_theme') ?? false;
        tutorialSeen = prefs.getBool('tutorial_seen') ?? false;
        language = prefs.getString('language') ?? 'system';
      });
    }
  }

  Future<void> completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_seen', true);
    if (mounted) setState(() => tutorialSeen = true);
  }

  Future<void> toggleTheme() async {
    setState(() => light = !light);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('light_theme', light);
  }

  Future<void> setLanguage(String value) async {
    setState(() => language = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) => context.l10n.appName,
    locale: switch (language) {
      'es' => const Locale('es'),
      'en' => const Locale('en'),
      _ => null,
    },
    supportedLocales: AppLocalizations.supportedLocales,
    localeResolutionCallback: (deviceLocale, supportedLocales) {
      if (deviceLocale?.languageCode == 'es') return const Locale('es');
      return const Locale('en');
    },
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    themeMode: light ? ThemeMode.light : ThemeMode.dark,
    darkTheme: ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: ink,
      colorScheme: const ColorScheme.dark(
        primary: yellow,
        onPrimary: ink,
        secondary: orange,
        surface: panel,
        onSurface: cream,
        onSurfaceVariant: muted,
        outline: Color(0xFF3A3D4B),
      ),
    ),
    theme: ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF6F1E6),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFE59E00),
        onPrimary: Color(0xFF17120A),
        secondary: Color(0xFFE84826),
        surface: Color(0xFFFFFBF3),
        onSurface: Color(0xFF191922),
        onSurfaceVariant: Color(0xFF64616B),
        outline: Color(0xFFD9D2C6),
      ),
    ),
    home: tutorialSeen == null
        ? const SizedBox.expand()
        : Game(
            light: light,
            onToggleTheme: toggleTheme,
            showTutorial: !tutorialSeen!,
            onTutorialDone: completeTutorial,
            language: language,
            onLanguageChanged: setLanguage,
          ),
  );
}

enum Screen {
  tutorial,
  home,
  countdown,
  playing,
  exploded,
  rewards,
  shop,
  settings,
  content,
}

enum CategoryFilter { all, favorites, mine }

class Game extends StatefulWidget {
  const Game({
    required this.light,
    required this.onToggleTheme,
    this.showTutorial = false,
    this.onTutorialDone,
    required this.language,
    required this.onLanguageChanged,
    super.key,
  });
  final bool light;
  final VoidCallback onToggleTheme;
  final bool showTutorial;
  final Future<void> Function()? onTutorialDone;
  final String language;
  final ValueChanged<String> onLanguageChanged;
  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> with WidgetsBindingObserver {
  final random = Random();
  final usedChallenges = <String>{};
  final customItems = <String, List<String>>{};
  final customCategories = <Category>[];
  final favoriteCategories = <String>{};
  final categoryUsage = <String, int>{};
  final permUnlockedPacks = <String>{};
  final tempUnlockedPacks = <String, int>{};
  final permUnlockedSkins = <String>{BombSkin.classic.name};
  final tempUnlockedSkins = <String, int>{};

  late final Future<void> historyReady;
  late Screen screen;
  Screen contentReturnScreen = Screen.home;

  Category? category;
  String challenge = '';
  String currentDare = loserDares.first;
  int minSeconds = 30, maxSeconds = 60;
  int freeSwapsRemaining = 2;
  bool paused = false;
  bool soundEnabled = true,
      vibrationEnabled = true,
      remindersEnabled = true,
      loserDareEnabled = true,
      dynamicTensionEnabled = true,
      reviewDone = false;
  int sparks = 20;
  BombSkin equippedSkin = BombSkin.classic;
  CategoryFilter categoryFilter = CategoryFilter.all;

  int completedRounds = 0, nextReviewRound = 1;
  int lastInterstitialAt = 0;
  Timer? timer;
  Timer? tensionTimer;
  Timer? tensionTimerFast;
  Timer? countdownTimer;
  int countdown = 3;
  bool hasPreviousLoser = false;
  Duration remaining = Duration.zero;
  DateTime? deadline;

  @override
  void initState() {
    super.initState();
    screen = widget.showTutorial ? Screen.tutorial : Screen.home;
    WidgetsBinding.instance.addObserver(this);
    historyReady = _loadHistory();
  }

  Future<void> finishTutorial() async {
    setState(() => screen = Screen.home);
    await widget.onTutorialDone?.call();
    await invoke('requestNotificationPermission');
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    soundEnabled = prefs.getBool('sound_enabled') ?? true;
    vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    loserDareEnabled = prefs.getBool('loser_dare_enabled') ?? true;
    dynamicTensionEnabled = prefs.getBool('dynamic_tension_enabled') ?? true;
    unawaited(_loadReminderSetting());
    reviewDone = prefs.getBool('review_done') ?? false;
    completedRounds = prefs.getInt('completed_rounds') ?? 0;
    nextReviewRound = prefs.getInt('next_review_round') ?? 1;
    lastInterstitialAt = prefs.getInt('last_interstitial_at') ?? 0;
    sparks = prefs.getInt('sparks') ?? 20;

    final savedSkin = prefs.getString('equipped_skin') ?? BombSkin.classic.name;
    equippedSkin = BombSkin.values.firstWhere(
      (s) => s.name == savedSkin,
      orElse: () => BombSkin.classic,
    );

    favoriteCategories.addAll(
      prefs.getStringList('favorite_categories') ?? const [],
    );
    final rawUsage = prefs.getString('category_usage');
    if (rawUsage != null) {
      final decoded = jsonDecode(rawUsage) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        categoryUsage[entry.key] = (entry.value as num).toInt();
      }
    }
    permUnlockedPacks.addAll(
      prefs.getStringList('unlocked_packs_perm') ?? const [],
    );
    permUnlockedSkins.addAll(
      prefs.getStringList('unlocked_skins_perm') ?? [BombSkin.classic.name],
    );

    final rawTempPacks = prefs.getString('unlocked_packs_temp');
    if (rawTempPacks != null) {
      final decoded = jsonDecode(rawTempPacks) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        tempUnlockedPacks[entry.key] = (entry.value as num).toInt();
      }
    }
    final rawTempSkins = prefs.getString('unlocked_skins_temp');
    if (rawTempSkins != null) {
      final decoded = jsonDecode(rawTempSkins) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        tempUnlockedSkins[entry.key] = (entry.value as num).toInt();
      }
    }

    if (!isSkinUnlocked(equippedSkin)) {
      equippedSkin = BombSkin.classic;
    }

    usedChallenges.addAll(prefs.getStringList('used_challenges') ?? const []);
    final storedItems = prefs.getString('custom_items');
    if (storedItems != null) {
      final decoded = jsonDecode(storedItems) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        customItems[entry.key] = List<String>.from(entry.value as List);
      }
    }
    final storedCategories = prefs.getString('custom_categories');
    if (storedCategories != null) {
      final decoded = jsonDecode(storedCategories) as List;
      customCategories.addAll(
        decoded.map((raw) {
          final item = raw as Map<String, dynamic>;
          return Category(
            item['name'] as String,
            item['emoji'] as String,
            List<String>.from(item['items'] as List),
            custom: true,
          );
        }),
      );
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadReminderSetting() async {
    try {
      final enabled =
          await audio.invokeMethod<bool>('areRemindersEnabled') ?? true;
      if (mounted) setState(() => remindersEnabled = enabled);
    } catch (_) {}
  }

  bool isPackUnlocked(String? packId) {
    if (packId == null) return true;
    if (permUnlockedPacks.contains(packId)) return true;
    final expiresAt = tempUnlockedPacks[packId];
    return expiresAt != null &&
        expiresAt > DateTime.now().millisecondsSinceEpoch;
  }

  bool isPackTempActive(String packId) {
    if (permUnlockedPacks.contains(packId)) return false;
    final expiresAt = tempUnlockedPacks[packId];
    return expiresAt != null &&
        expiresAt > DateTime.now().millisecondsSinceEpoch;
  }

  bool isSkinUnlocked(BombSkin skin) {
    if (skin == BombSkin.classic || permUnlockedSkins.contains(skin.name)) {
      return true;
    }
    final expiresAt = tempUnlockedSkins[skin.name];
    return expiresAt != null &&
        expiresAt > DateTime.now().millisecondsSinceEpoch;
  }

  List<Category> get availableCategories {
    final builtIn = categories.skip(1).map((base) {
      final expanded = <String>[...base.items, ...?customItems[base.name]];
      return Category(base.name, base.emoji, expanded);
    });
    final packs = specialPacks.map((pack) {
      final expanded = <String>[...pack.items, ...?customItems[pack.name]];
      return Category(
        pack.name,
        pack.emoji,
        expanded,
        packId: pack.packId,
        sparkCost: pack.sparkCost,
      );
    });
    return [categories.first, ...builtIn, ...packs, ...customCategories];
  }

  List<Category> get playableCategories => availableCategories
      .skip(1)
      .where((c) => isPackUnlocked(c.packId))
      .toList();

  Future<void> _saveRewardsState() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setInt('sparks', sparks),
      prefs.setString('equipped_skin', equippedSkin.name),
      prefs.setStringList('unlocked_packs_perm', permUnlockedPacks.toList()),
      prefs.setString('unlocked_packs_temp', jsonEncode(tempUnlockedPacks)),
      prefs.setStringList('unlocked_skins_perm', permUnlockedSkins.toList()),
      prefs.setString('unlocked_skins_temp', jsonEncode(tempUnlockedSkins)),
    ]);
  }

  Future<void> _saveCustomContent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_items', jsonEncode(customItems));
    await prefs.setString(
      'custom_categories',
      jsonEncode(
        customCategories
            .map(
              (item) => {
                'name': item.name,
                'emoji': item.emoji,
                'items': item.items,
              },
            )
            .toList(),
      ),
    );
  }

  Future<void> toggleFavorite(String categoryName) async {
    setState(() {
      if (favoriteCategories.contains(categoryName)) {
        favoriteCategories.remove(categoryName);
      } else {
        favoriteCategories.add(categoryName);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorite_categories',
      favoriteCategories.toList(),
    );
  }

  Future<AddPromptResult> addChallenge(
    String categoryName,
    String value,
  ) async {
    if (sparks < customPromptCost) return AddPromptResult.notEnoughSparks;
    final clean = value.trim();
    if (clean.isEmpty) return AddPromptResult.invalid;
    final customIndex = customCategories.indexWhere(
      (item) => item.name == categoryName,
    );
    if (customIndex >= 0) {
      final current = customCategories[customIndex];
      if (current.items.length >= maxCustomCategoryPrompts) {
        return AddPromptResult.limitReached;
      }
      if (current.items.any(
        (item) => item.toLowerCase() == clean.toLowerCase(),
      )) {
        return AddPromptResult.invalid;
      }
      customCategories[customIndex] = Category(current.name, current.emoji, [
        ...current.items,
        clean,
      ], custom: true);
    } else {
      final values = customItems.putIfAbsent(categoryName, () => []);
      if (values.any((item) => item.toLowerCase() == clean.toLowerCase())) {
        return AddPromptResult.invalid;
      }
      values.add(clean);
    }
    sparks -= customPromptCost;
    setState(() {});
    await Future.wait([_saveCustomContent(), _saveRewardsState()]);
    return AddPromptResult.added;
  }

  Future<AddCategoryResult> addCategory(
    String name,
    String emoji,
    String firstItem,
  ) async {
    if (sparks < customCategoryCost) {
      return AddCategoryResult.notEnoughSparks;
    }
    final cleanName = name.trim();
    final cleanItem = firstItem.trim();
    if (cleanName.isEmpty || cleanItem.isEmpty) {
      return AddCategoryResult.invalid;
    }
    if (availableCategories.any(
      (item) => item.name.toLowerCase() == cleanName.toLowerCase(),
    )) {
      return AddCategoryResult.invalid;
    }
    sparks -= customCategoryCost;
    customCategories.add(
      Category(cleanName, emoji.trim().isEmpty ? '🎯' : emoji.trim(), [
        cleanItem,
      ], custom: true),
    );
    setState(() {});
    await Future.wait([_saveCustomContent(), _saveRewardsState()]);
    return AddCategoryResult.created;
  }

  Future<void> removeCategory(String categoryName) async {
    customCategories.removeWhere((item) => item.name == categoryName);
    favoriteCategories.remove(categoryName);
    categoryUsage.remove(categoryName);
    usedChallenges.removeWhere((key) => key.startsWith('$categoryName::'));
    setState(() {});
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      _saveCustomContent(),
      _saveHistory(),
      prefs.setStringList('favorite_categories', favoriteCategories.toList()),
      prefs.setString('category_usage', jsonEncode(categoryUsage)),
    ]);
  }

  Future<bool> removeChallenge(String categoryName, String value) async {
    var categoryWasRemoved = false;
    final customIndex = customCategories.indexWhere(
      (item) => item.name == categoryName,
    );
    if (customIndex >= 0) {
      final current = customCategories[customIndex];
      final remainingItems = current.items
          .where((item) => item != value)
          .toList();
      if (remainingItems.isEmpty) {
        customCategories.removeAt(customIndex);
        categoryWasRemoved = true;
      } else {
        customCategories[customIndex] = Category(
          current.name,
          current.emoji,
          remainingItems,
          custom: true,
        );
      }
    } else {
      final values = customItems[categoryName];
      values?.remove(value);
      if (values?.isEmpty ?? false) customItems.remove(categoryName);
    }
    usedChallenges.remove(
      _historyKey(Category(categoryName, '', const []), value),
    );
    setState(() {});
    await Future.wait([_saveCustomContent(), _saveHistory()]);
    return categoryWasRemoved;
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('used_challenges', usedChallenges.toList());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s != AppLifecycleState.resumed) {
      if (screen == Screen.playing) pause();
      if (screen == Screen.countdown) leave(Screen.home);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    tensionTimer?.cancel();
    tensionTimerFast?.cancel();
    countdownTimer?.cancel();
    invoke('stopTicking');
    super.dispose();
  }

  Future<void> invoke(String method, [Object? arguments]) async {
    try {
      await audio.invokeMethod<void>(method, arguments);
    } catch (_) {}
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<bool> _showRewardedAd() async {
    try {
      final earned = await audio.invokeMethod<bool>('showRewarded') ?? false;
      if (!earned && mounted) {
        _showSnack(context.l10n.adNotReady);
      }
      return earned;
    } catch (_) {
      if (mounted) _showSnack(context.l10n.adNotReady);
      return false;
    }
  }

  Future<void> watchAdForSparks(int amount) async {
    final earned = await _showRewardedAd();
    if (!earned || !mounted) return;
    setState(() => sparks += amount);
    await _saveRewardsState();
    if (mounted) _showSnack(context.l10n.rewardEarnedSparks(amount));
  }

  Future<void> unlockPackWithAd(Category pack) async {
    final packId = pack.packId;
    if (packId == null) return;
    final earned = await _showRewardedAd();
    if (!earned || !mounted) return;
    final expiry = DateTime.now()
        .add(const Duration(hours: 24))
        .millisecondsSinceEpoch;
    setState(() => tempUnlockedPacks[packId] = expiry);
    await _saveRewardsState();
    if (mounted) {
      _showSnack(context.l10n.packUnlocked24h(localizedContent(context, pack.name)));
    }
  }

  Future<void> unlockPackWithSparks(Category pack) async {
    final packId = pack.packId;
    if (packId == null) return;
    if (sparks < pack.sparkCost) {
      _showSnack(context.l10n.notEnoughSparks);
      return;
    }
    setState(() {
      sparks -= pack.sparkCost;
      permUnlockedPacks.add(packId);
    });
    await _saveRewardsState();
    if (mounted) {
      _showSnack(
        context.l10n.packUnlockedForever(localizedContent(context, pack.name)),
      );
    }
  }

  Future<void> selectOrUnlockSkin(BombSkin skin, {bool withAd = false}) async {
    if (isSkinUnlocked(skin)) {
      setState(() => equippedSkin = skin);
      await _saveRewardsState();
      return;
    }
    if (withAd) {
      final earned = await _showRewardedAd();
      if (!earned || !mounted) return;
      final expiry = DateTime.now()
          .add(const Duration(hours: 24))
          .millisecondsSinceEpoch;
      setState(() {
        tempUnlockedSkins[skin.name] = expiry;
        equippedSkin = skin;
      });
      await _saveRewardsState();
      if (mounted) {
        _showSnack(context.l10n.skinUnlocked(skin.localizedName(context)));
      }
      return;
    }
    if (sparks < skin.sparkCost) {
      _showSnack(context.l10n.notEnoughSparks);
      return;
    }
    setState(() {
      sparks -= skin.sparkCost;
      permUnlockedSkins.add(skin.name);
      equippedSkin = skin;
    });
    await _saveRewardsState();
    if (mounted) {
      _showSnack(context.l10n.skinUnlocked(skin.localizedName(context)));
    }
  }

  Future<bool> _showInterstitialIfDue(SharedPreferences prefs) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    const minimumInterval = Duration(minutes: 2);
    if (lastInterstitialAt > 0 &&
        now - lastInterstitialAt < minimumInterval.inMilliseconds) {
      return false;
    }
    try {
      final shown = await audio.invokeMethod<bool>('showInterstitial') ?? false;
      if (!shown) return false;
      lastInterstitialAt = now;
      await prefs.setInt('last_interstitial_at', now);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleSound(bool value) async {
    if (!value) await invoke('stopTicking');
    setState(() => soundEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
  }

  Future<void> toggleVibration(bool value) async {
    setState(() => vibrationEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration_enabled', value);
  }

  Future<void> toggleLoserDare(bool value) async {
    setState(() => loserDareEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loser_dare_enabled', value);
  }

  Future<void> toggleDynamicTension(bool value) async {
    setState(() => dynamicTensionEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dynamic_tension_enabled', value);
  }

  Future<void> toggleReminders(bool value) async {
    setState(() => remindersEnabled = value);
    await invoke('setReminders', {'enabled': value});
  }

  Future<void> openPackage(String packageName) =>
      invoke('openAppOrStore', {'package': packageName});

  Future<void> openStore(String packageName) =>
      invoke('openStore', {'package': packageName});

  Future<void> _recordCategoryUsage(String categoryName) async {
    categoryUsage[categoryName] = (categoryUsage[categoryName] ?? 0) + 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('category_usage', jsonEncode(categoryUsage));
  }

  Future<void> chooseAndStart(Category c) async {
    await historyReady;
    if (!mounted) return;
    if (!isPackUnlocked(c.packId)) {
      setState(() => screen = Screen.rewards);
      return;
    }
    if (c.items.isEmpty) {
      final unlocked = playableCategories;
      final available = unlocked
          .where(
            (candidate) => candidate.items.any(
              (item) => !usedChallenges.contains(_historyKey(candidate, item)),
            ),
          )
          .toList();
      category = available.isEmpty
          ? unlocked[random.nextInt(unlocked.length)]
          : available[random.nextInt(available.length)];
    } else {
      category = c;
      unawaited(_recordCategoryUsage(c.name));
    }
    beginCountdown();
  }

  void pick() {
    var options = category!.items
        .where((item) => !usedChallenges.contains(_historyKey(category!, item)))
        .toList();
    if (options.isEmpty) {
      usedChallenges.removeWhere(
        (key) => key.startsWith('${category!.name}::'),
      );
      options = [...category!.items];
    }
    challenge = options[random.nextInt(options.length)];
    usedChallenges.add(_historyKey(category!, challenge));
    unawaited(_saveHistory());
  }

  void pickNewDare() {
    if (loserDares.length <= 1) return;
    String next;
    do {
      next = loserDares[random.nextInt(loserDares.length)];
    } while (next == currentDare);
    setState(() => currentDare = next);
  }

  String _historyKey(Category category, String item) =>
      '${category.name}::$item';

  void _scheduleTension(Duration total) {
    tensionTimer?.cancel();
    tensionTimerFast?.cancel();
    if (!dynamicTensionEnabled || !soundEnabled || total.inSeconds < 8) return;
    tensionTimer = Timer(
      Duration(milliseconds: (total.inMilliseconds * 0.55).round()),
      () {
        if (mounted && screen == Screen.playing && !paused && soundEnabled) {
          invoke('setTickingRate', {'rate': 1.35});
        }
      },
    );
    tensionTimerFast = Timer(
      Duration(milliseconds: (total.inMilliseconds * 0.80).round()),
      () {
        if (mounted && screen == Screen.playing && !paused && soundEnabled) {
          invoke('setTickingRate', {'rate': 1.75});
        }
      },
    );
  }

  void beginCountdown() {
    timer?.cancel();
    tensionTimer?.cancel();
    tensionTimerFast?.cancel();
    countdownTimer?.cancel();
    invoke('stopTicking');
    countdown = 3;
    setState(() => screen = Screen.countdown);
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (countdown > 1) {
        setState(() => countdown--);
      } else {
        t.cancel();
        startBomb();
      }
    });
  }

  void startBomb() {
    pick();
    final seconds = minSeconds + random.nextInt(maxSeconds - minSeconds + 1);
    remaining = Duration(seconds: seconds);
    deadline = DateTime.now().add(remaining);
    freeSwapsRemaining = 2;
    paused = false;
    timer?.cancel();
    timer = Timer(remaining, explode);
    _scheduleTension(remaining);
    if (soundEnabled) invoke('startTicking');
    setState(() => screen = Screen.playing);
  }

  Future<void> swapPromptInGame() async {
    if (paused) return;
    if (freeSwapsRemaining > 0) {
      setState(() {
        freeSwapsRemaining--;
        pick();
      });
      return;
    }
    pause();
    final earned = await _showRewardedAd();
    if (!mounted) return;
    if (earned) {
      setState(() {
        freeSwapsRemaining = 2;
        pick();
      });
      _showSnack(context.l10n.swapsRecharged);
    }
  }

  void pause() {
    if (paused || screen != Screen.playing) return;
    remaining =
        deadline?.difference(DateTime.now()) ?? const Duration(seconds: 2);
    if (remaining.isNegative) remaining = const Duration(seconds: 2);
    timer?.cancel();
    tensionTimer?.cancel();
    tensionTimerFast?.cancel();
    invoke('pauseTicking');
    setState(() => paused = true);
  }

  void resume() {
    deadline = DateTime.now().add(remaining);
    timer = Timer(remaining, explode);
    _scheduleTension(remaining);
    if (soundEnabled) invoke('resumeTicking');
    setState(() => paused = false);
  }

  void explode() {
    if (!mounted || screen != Screen.playing) return;
    timer?.cancel();
    tensionTimer?.cancel();
    tensionTimerFast?.cancel();
    invoke('stopTicking');
    if (soundEnabled) invoke('explode');
    if (vibrationEnabled) {
      HapticFeedback.heavyImpact();
      Future<void>.delayed(
        const Duration(milliseconds: 170),
        HapticFeedback.heavyImpact,
      );
      Future<void>.delayed(
        const Duration(milliseconds: 350),
        HapticFeedback.vibrate,
      );
    }
    hasPreviousLoser = true;
    currentDare = loserDares[random.nextInt(loserDares.length)];
    sparks += 10;
    setState(() => screen = Screen.exploded);
    unawaited(_saveRewardsState());
    unawaited(_completedRound());
  }

  Future<void> _completedRound() async {
    completedRounds++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('completed_rounds', completedRounds);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted || screen != Screen.exploded) return;
    if (await _showInterstitialIfDue(prefs)) return;
    if (!mounted || screen != Screen.exploded) return;
    if (reviewDone || completedRounds < nextReviewRound) return;
    final rateNow = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.star_rounded, color: yellow, size: 40),
        title: Text(context.l10n.ratePromptTitle),
        content: Text(context.l10n.ratePromptMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.later),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.rateNow),
          ),
        ],
      ),
    );
    if (rateNow == true) {
      reviewDone = true;
      await prefs.setBool('review_done', true);
      await openStore('nuviapps.co.labomba');
    } else {
      nextReviewRound = completedRounds + 3;
      await prefs.setInt('next_review_round', nextReviewRound);
    }
  }

  void leave(Screen target) {
    timer?.cancel();
    tensionTimer?.cancel();
    tensionTimerFast?.cancel();
    countdownTimer?.cancel();
    invoke('stopTicking');
    setState(() => screen = target);
  }

  @override
  Widget build(BuildContext c) => PopScope(
    canPop: screen == Screen.home || screen == Screen.tutorial,
    onPopInvokedWithResult: (did, _) {
      if (!did) {
        leave(switch (screen) {
          Screen.content => contentReturnScreen,
          Screen.shop => Screen.rewards,
          _ => Screen.home,
        });
      }
    },
    child: Scaffold(
      body: Stack(
        children: [
          const Background(),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: switch (screen) {
                Screen.tutorial => Tutorial(
                  key: const ValueKey('tutorial'),
                  finish: finishTutorial,
                ),
                Screen.home => Home(
                  key: const ValueKey('home'),
                  categories: availableCategories.skip(1).toList(),
                  favorites: favoriteCategories,
                  categoryUsage: categoryUsage,
                  filter: categoryFilter,
                  onFilterChanged: (f) => setState(() => categoryFilter = f),
                  isPackUnlocked: isPackUnlocked,
                  onToggleFavorite: toggleFavorite,
                  startRandom: () => chooseAndStart(categories.first),
                  chooseCategory: chooseAndStart,
                  minSeconds: minSeconds,
                  maxSeconds: maxSeconds,
                  setTime: (r) => setState(() {
                    minSeconds = r.$1;
                    maxSeconds = r.$2;
                  }),
                  light: widget.light,
                  toggleTheme: widget.onToggleTheme,
                  sparks: sparks,
                  skin: equippedSkin,
                  openRewards: () => setState(() => screen = Screen.rewards),
                  openSettings: () => setState(() => screen = Screen.settings),
                  openContent: () => setState(() {
                    contentReturnScreen = Screen.home;
                    screen = Screen.content;
                  }),
                ),
                Screen.countdown => StartCountdown(
                  key: ValueKey(countdown),
                  seconds: countdown,
                  previousLoserStarts: hasPreviousLoser,
                  skin: equippedSkin,
                  cancel: () => leave(Screen.home),
                ),
                Screen.playing => Playing(
                  key: const ValueKey('playing'),
                  category: category!,
                  challenge: challenge,
                  paused: paused,
                  skin: equippedSkin,
                  freeSwapsRemaining: freeSwapsRemaining,
                  change: swapPromptInGame,
                  pause: pause,
                  resume: resume,
                ),
                Screen.exploded => Exploded(
                  key: const ValueKey('exploded'),
                  category: category!,
                  challenge: challenge,
                  dare: loserDareEnabled ? currentDare : null,
                  rerollDare: pickNewDare,
                  again: beginCountdown,
                  changeCategory: () => setState(() => screen = Screen.home),
                  watchAdBonus: () => watchAdForSparks(30),
                ),
                Screen.rewards => RewardsScreen(
                  key: const ValueKey('rewards'),
                  sparks: sparks,
                  packs: specialPacks,
                  isPackUnlocked: isPackUnlocked,
                  isPackTempActive: isPackTempActive,
                  back: () => setState(() => screen = Screen.home),
                  openShop: () => setState(() => screen = Screen.shop),
                  watchAdSparks: () => watchAdForSparks(50),
                  unlockPackAd: unlockPackWithAd,
                  unlockPackSparks: unlockPackWithSparks,
                ),
                Screen.shop => BombShopScreen(
                  key: const ValueKey('shop'),
                  sparks: sparks,
                  equippedSkin: equippedSkin,
                  isSkinUnlocked: isSkinUnlocked,
                  back: () => setState(() => screen = Screen.rewards),
                  onSelectSkin: selectOrUnlockSkin,
                ),
                Screen.settings => Settings(
                  key: const ValueKey('settings'),
                  light: widget.light,
                  back: () => setState(() => screen = Screen.home),
                  toggleTheme: widget.onToggleTheme,
                  manageContent: () => setState(() {
                    contentReturnScreen = Screen.settings;
                    screen = Screen.content;
                  }),
                  language: widget.language,
                  onLanguageChanged: widget.onLanguageChanged,
                  soundEnabled: soundEnabled,
                  vibrationEnabled: vibrationEnabled,
                  remindersEnabled: remindersEnabled,
                  loserDareEnabled: loserDareEnabled,
                  dynamicTensionEnabled: dynamicTensionEnabled,
                  onSoundChanged: toggleSound,
                  onVibrationChanged: toggleVibration,
                  onRemindersChanged: toggleReminders,
                  onLoserDareChanged: toggleLoserDare,
                  onDynamicTensionChanged: toggleDynamicTension,
                  privacyOptions: () => invoke('showPrivacyOptions'),
                  rateApp: () => openStore('nuviapps.co.labomba'),
                  playTruthOrDare: () => openPackage('nuviapps.co.verdadoreto'),
                  playImpostor: () => openPackage('nuviapptest.co.impostor'),
                ),
                Screen.content => ContentManager(
                  key: const ValueKey('content'),
                  categories: availableCategories.skip(1).toList(),
                  sparks: sparks,
                  openRewards: () => setState(() => screen = Screen.rewards),
                  back: () => setState(() => screen = contentReturnScreen),
                  addChallenge: addChallenge,
                  addCategory: addCategory,
                  customItems: customItems,
                  customCategories: customCategories,
                  removeChallenge: removeChallenge,
                  removeCategory: removeCategory,
                ),
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class Background extends StatelessWidget {
  const Background({super.key});
  @override
  Widget build(BuildContext c) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(1.1, -1),
        radius: 1.5,
        colors: Theme.of(c).brightness == Brightness.dark
            ? const [Color(0xFF3A211B), ink, Color(0xFF0B0C11)]
            : const [Color(0xFFFFE7B0), Color(0xFFF8F2E7), Color(0xFFF2EBDD)],
      ),
    ),
    child: const SizedBox.expand(),
  );
}

class Tutorial extends StatelessWidget {
  const Tutorial({required this.finish, super.key});
  final VoidCallback finish;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const BombImage(size: 34),
            const SizedBox(width: 10),
            Text(
              context.l10n.howToPlay,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          context.l10n.tutorialTitle,
          style: const TextStyle(
            fontSize: 36,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 24),
        TutorialStep(
          number: '1',
          icon: Icons.center_focus_strong_rounded,
          title: context.l10n.phoneCenterTitle,
          text: context.l10n.phoneCenterText,
        ),
        const SizedBox(height: 10),
        TutorialStep(
          number: '2',
          icon: Icons.grid_view_rounded,
          title: context.l10n.chooseActivateTitle,
          text: context.l10n.chooseActivateText,
        ),
        const SizedBox(height: 10),
        TutorialStep(
          number: '3',
          icon: Icons.replay_rounded,
          title: context.l10n.whoStartsTitle,
          text: context.l10n.whoStartsText,
        ),
        const Spacer(),
        BigButton(
          label: context.l10n.tutorialDone,
          icon: Icons.arrow_forward_rounded,
          onTap: finish,
        ),
      ],
    ),
  );
}

class TutorialStep extends StatelessWidget {
  const TutorialStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.text,
    super.key,
  });
  final String number, title, text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: yellow,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: ink, size: 23),
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: orange,
                      child: Text(
                        number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    text,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12.5,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({
    required this.categories,
    required this.favorites,
    required this.categoryUsage,
    required this.filter,
    required this.onFilterChanged,
    required this.isPackUnlocked,
    required this.onToggleFavorite,
    required this.startRandom,
    required this.chooseCategory,
    required this.minSeconds,
    required this.maxSeconds,
    required this.setTime,
    required this.light,
    required this.toggleTheme,
    required this.sparks,
    required this.skin,
    required this.openRewards,
    required this.openSettings,
    required this.openContent,
    super.key,
  });

  final List<Category> categories;
  final Set<String> favorites;
  final Map<String, int> categoryUsage;
  final CategoryFilter filter;
  final ValueChanged<CategoryFilter> onFilterChanged;
  final bool Function(String? packId) isPackUnlocked;
  final ValueChanged<String> onToggleFavorite;
  final VoidCallback startRandom, toggleTheme, openRewards, openSettings, openContent;
  final ValueChanged<Category> chooseCategory;
  final int minSeconds, maxSeconds, sparks;
  final ValueChanged<(int, int)> setTime;
  final bool light;
  final BombSkin skin;

  List<Category> _sortByUsage(List<Category> list) {
    final indexed = list.indexed.toList();
    indexed.sort((a, b) {
      final ua = categoryUsage[a.$2.name] ?? 0;
      final ub = categoryUsage[b.$2.name] ?? 0;
      if (ub != ua) return ub.compareTo(ua);
      return a.$1.compareTo(b.$1);
    });
    return indexed.map((e) => e.$2).toList();
  }

  List<Category> _filteredCategories() {
    final base = switch (filter) {
      CategoryFilter.all => categories,
      CategoryFilter.favorites =>
        categories.where((c) => favorites.contains(c.name)).toList(),
      CategoryFilter.mine => categories.where((c) => c.custom).toList(),
    };
    if (filter == CategoryFilter.all) {
      final favs = _sortByUsage(
        base.where((c) => favorites.contains(c.name)).toList(),
      );
      final unlockedRest = _sortByUsage(
        base
            .where(
              (c) => !favorites.contains(c.name) && isPackUnlocked(c.packId),
            )
            .toList(),
      );
      final lockedRest = base
          .where(
            (c) => !favorites.contains(c.name) && !isPackUnlocked(c.packId),
          )
          .toList();
      return [...favs, ...unlockedRest, ...lockedRest];
    }
    return _sortByUsage(base);
  }

  @override
  Widget build(BuildContext c) {
    final colors = Theme.of(c).colorScheme;
    final isLight = Theme.of(c).brightness == Brightness.light;
    final visible = _filteredCategories();
    final hasMine = categories.any((item) => item.custom);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Row(
                  children: [
                    BombImage(size: 30, skin: skin),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        c.l10n.appName.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Material(
                      color: colors.surface,
                      shape: StadiumBorder(
                        side: BorderSide(color: yellow.withValues(alpha: 0.65)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: openRewards,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⚡', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 4),
                              Text(
                                '$sparks',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: isLight ? const Color(0xFF9A5A00) : yellow,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filledTonal(
                      onPressed: toggleTheme,
                      tooltip: light
                          ? c.l10n.darkModeTooltip
                          : c.l10n.lightModeTooltip,
                      icon: Icon(
                        light
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton.filled(
                      onPressed: openSettings,
                      tooltip: c.l10n.settingsTooltip,
                      style: IconButton.styleFrom(
                        backgroundColor: yellow,
                        foregroundColor: ink,
                      ),
                      icon: const Icon(Icons.settings_rounded, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Unified Hero Play Card (Bomb + Duration + 1-Tap Random Start)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: colors.outline),
                  ),
                  child: Column(
                    children: [
                      BombImage(size: 102, skin: skin),
                      const SizedBox(height: 12),
                      SegmentedButton<(int, int)>(
                        segments: [
                          ButtonSegment(
                            value: (15, 30),
                            label: Text(c.l10n.quick),
                          ),
                          ButtonSegment(
                            value: (30, 60),
                            label: Text(c.l10n.normal),
                          ),
                          ButtonSegment(
                            value: (60, 90),
                            label: Text(c.l10n.long),
                          ),
                        ],
                        selected: {(minSeconds, maxSeconds)},
                        onSelectionChanged: (v) => setTime(v.first),
                        showSelectedIcon: false,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        c.l10n.explosionRange(minSeconds, maxSeconds),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 14),
                      BigButton(
                        label: c.l10n.lightFuseRandom,
                        icon: Icons.local_fire_department_rounded,
                        onTap: startRandom,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        c.l10n.homeFooter,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Categories Header + Direct "+ Create mine"
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.l10n.orChooseCategory.toUpperCase(),
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: openContent,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(
                        c.l10n.createMine,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: isLight
                            ? const Color(0xFF9A5A00)
                            : yellow,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Quick Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: Text(c.l10n.filterAll),
                        selected: filter == CategoryFilter.all,
                        onSelected: (_) => onFilterChanged(CategoryFilter.all),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        avatar: const Icon(Icons.star_rounded, size: 16),
                        label: Text(c.l10n.filterFavorites),
                        selected: filter == CategoryFilter.favorites,
                        onSelected: (_) =>
                            onFilterChanged(CategoryFilter.favorites),
                      ),
                      if (hasMine) ...[
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(c.l10n.filterMine),
                          selected: filter == CategoryFilter.mine,
                          onSelected: (_) =>
                              onFilterChanged(CategoryFilter.mine),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (visible.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.outline),
                ),
                child: Text(
                  c.l10n.noFavoritesYet,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 76,
              ),
              delegate: SliverChildBuilderDelegate((_, i) {
                final item = visible[i];
                final unlocked = isPackUnlocked(item.packId);
                final isFav = favorites.contains(item.name);
                return Material(
                  color: isLight ? colors.surface : panel,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: unlocked
                          ? colors.outline
                          : yellow.withValues(alpha: 0.55),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => chooseCategory(item),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                      child: Row(
                        children: [
                          Text(item.emoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizedContent(c, item.name),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.onSurface,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  unlocked
                                      ? c.l10n.tapAndPlay
                                      : '🔒 ${c.l10n.unlockWithAd24h}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: unlocked
                                        ? colors.onSurfaceVariant
                                        : (isLight
                                              ? const Color(0xFF9A5A00)
                                              : yellow),
                                    fontSize: 10.5,
                                    fontWeight: unlocked
                                        ? FontWeight.w600
                                        : FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (unlocked)
                            IconButton(
                              onPressed: () => onToggleFavorite(item.name),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              icon: Icon(
                                isFav
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 19,
                                color: isFav
                                    ? yellow
                                    : colors.onSurfaceVariant.withValues(
                                        alpha: 0.45,
                                      ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }, childCount: visible.length),
            ),
          ),
      ],
    );
  }
}

class StartCountdown extends StatelessWidget {
  const StartCountdown({
    required this.seconds,
    required this.previousLoserStarts,
    required this.cancel,
    this.skin = BombSkin.classic,
    super.key,
  });
  final int seconds;
  final bool previousLoserStarts;
  final VoidCallback cancel;
  final BombSkin skin;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton.filledTonal(
            onPressed: cancel,
            tooltip: context.l10n.cancelCountdown,
            icon: const Icon(Icons.close_rounded),
          ),
        ),
        const Spacer(),
        BombImage(size: 126, skin: skin),
        const SizedBox(height: 24),
        Text(
          previousLoserStarts
              ? context.l10n.previousLoserStarts
              : context.l10n.chooseWhoStarts,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 17,
            height: 1.25,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            '$seconds',
            key: ValueKey(seconds),
            style: const TextStyle(
              color: orange,
              fontSize: 104,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -4,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          context.l10n.bombStartsAtZero,
          style: const TextStyle(color: muted, fontSize: 13),
        ),
        const Spacer(),
      ],
    ),
  );
}

class Playing extends StatefulWidget {
  const Playing({
    required this.category,
    required this.challenge,
    required this.paused,
    required this.skin,
    required this.freeSwapsRemaining,
    required this.change,
    required this.pause,
    required this.resume,
    super.key,
  });
  final Category category;
  final String challenge;
  final bool paused;
  final BombSkin skin;
  final int freeSwapsRemaining;
  final VoidCallback change, pause, resume;
  @override
  State<Playing> createState() => _PlayingState();
}

class _PlayingState extends State<Playing> with SingleTickerProviderStateMixin {
  late final AnimationController pulse;
  @override
  void initState() {
    super.initState();
    pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
      lowerBound: .95,
      upperBound: 1.04,
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant Playing old) {
    super.didUpdateWidget(old);
    widget.paused ? pulse.stop() : pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final colors = Theme.of(c).colorScheme;
    final isLight = Theme.of(c).brightness == Brightness.light;
    final pauseColor = isLight ? const Color(0xFFB43D22) : yellow;
    final pauseIconColor = isLight ? Colors.white : ink;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Chip(
                avatar: Text(widget.category.emoji),
                label: Text(
                  localizedContent(c, widget.category.name),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const Spacer(),
              IconButton.filledTonal(
                onPressed: widget.paused ? widget.resume : widget.pause,
                style: IconButton.styleFrom(
                  backgroundColor: pauseColor,
                  foregroundColor: pauseIconColor,
                ),
                icon: Icon(
                  widget.paused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                ),
              ),
            ],
          ),
          const Spacer(),
          ScaleTransition(
            scale: pulse,
            child: widget.paused
                ? Icon(
                    Icons.pause_circle_filled_rounded,
                    size: 112,
                    color: pauseColor,
                  )
                : Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.skin.glowColor.withValues(alpha: 0.25),
                          blurRadius: 36,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: BombImage(size: 146, skin: widget.skin),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.paused ? c.l10n.paused : c.l10n.tickTock,
            style: TextStyle(
              color: widget.paused ? pauseColor : orange,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 14),
          // High-contrast table-readable Prompt Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: yellow.withValues(alpha: isLight ? 0.65 : 0.45),
                width: 1.5,
              ),
            ),
            child: Text(
              localizedContent(c, widget.challenge),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                height: 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: widget.paused ? null : widget.change,
            icon: Icon(
              widget.freeSwapsRemaining > 0
                  ? Icons.shuffle_rounded
                  : Icons.play_circle_fill_rounded,
            ),
            label: Text(
              widget.freeSwapsRemaining > 0
                  ? c.l10n.swapsLeft(widget.freeSwapsRemaining)
                  : c.l10n.watchAdMoreSwaps,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const Spacer(),
          Text(
            widget.paused ? c.l10n.tapToContinue : c.l10n.keepAnswering,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class Exploded extends StatelessWidget {
  const Exploded({
    required this.category,
    required this.challenge,
    required this.dare,
    required this.rerollDare,
    required this.again,
    required this.changeCategory,
    required this.watchAdBonus,
    super.key,
  });
  final Category category;
  final String challenge;
  final String? dare;
  final VoidCallback rerollDare, again, changeCategory, watchAdBonus;

  @override
  Widget build(BuildContext c) {
    final colors = Theme.of(c).colorScheme;
    final isLight = Theme.of(c).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  orange.withValues(alpha: 0.42),
                  orange.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: const Text('💥', style: TextStyle(fontSize: 108)),
          ),
          Text(
            c.l10n.boom,
            style: const TextStyle(
              fontSize: 54,
              height: 1,
              fontWeight: FontWeight.w900,
              color: orange,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizedContent(c, challenge),
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: yellow.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              c.l10n.roundSparksBonus,
              style: TextStyle(
                color: isLight ? const Color(0xFF9A5A00) : yellow,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (dare != null) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: yellow.withValues(alpha: 0.45)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '🎲 ${c.l10n.loserDareTitle}',
                        style: TextStyle(
                          color: isLight ? const Color(0xFF9A5A00) : yellow,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: rerollDare,
                        child: Text(
                          c.l10n.anotherDare,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    localizedContent(c, dare!),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          BigButton(
            label: c.l10n.anotherFrom(localizedContent(c, category.name)),
            icon: Icons.replay_rounded,
            onTap: again,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: changeCategory,
            icon: const Icon(Icons.grid_view_rounded),
            label: Text(c.l10n.changeCategory),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: watchAdBonus,
            icon: const Icon(Icons.play_circle_outline_rounded, size: 19),
            label: Text(
              c.l10n.watchAdBonusSparks,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({
    required this.sparks,
    required this.packs,
    required this.isPackUnlocked,
    required this.isPackTempActive,
    required this.back,
    required this.openShop,
    required this.watchAdSparks,
    required this.unlockPackAd,
    required this.unlockPackSparks,
    super.key,
  });

  final int sparks;
  final List<Category> packs;
  final bool Function(String? packId) isPackUnlocked;
  final bool Function(String packId) isPackTempActive;
  final VoidCallback back, openShop, watchAdSparks;
  final ValueChanged<Category> unlockPackAd, unlockPackSparks;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 16, 6),
          child: Row(
            children: [
              IconButton(
                onPressed: back,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Text(
                  context.l10n.rewards,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: openShop,
                style: FilledButton.styleFrom(
                  backgroundColor: yellow,
                  foregroundColor: ink,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.storefront_rounded, size: 17),
                label: Text(
                  context.l10n.shop,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: yellow.withValues(alpha: 0.6)),
                ),
                child: Text(
                  '⚡ $sparks',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: isLight ? const Color(0xFF9A5A00) : yellow,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              // Hero Rewarded Ad Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      orange.withValues(alpha: isLight ? 0.16 : 0.24),
                      yellow.withValues(alpha: isLight ? 0.22 : 0.18),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: yellow.withValues(alpha: 0.65)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.earnSparksTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.earnSparksSubtitle,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    BigButton(
                      label: context.l10n.watchAdEarn,
                      icon: Icons.play_arrow_rounded,
                      onTap: watchAdSparks,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Special Packs
              Text(
                context.l10n.specialPacks,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              ...packs.map((pack) {
                final unlocked = isPackUnlocked(pack.packId);
                final temp = isPackTempActive(pack.packId!);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: colors.outline),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              pack.emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizedContent(context, pack.name),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    context.l10n.packPromptCount(
                                      pack.items.length,
                                    ),
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (unlocked)
                              Chip(
                                label: Text(
                                  temp
                                      ? context.l10n.active24h
                                      : context.l10n.unlocked,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (!unlocked) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () => unlockPackAd(pack),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: yellow,
                                    foregroundColor: ink,
                                  ),
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    context.l10n.unlockWithAd24h,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () => unlockPackSparks(pack),
                                child: Text(
                                  context.l10n.unlockWithSparks(pack.sparkCost),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class BombShopScreen extends StatelessWidget {
  const BombShopScreen({
    required this.sparks,
    required this.equippedSkin,
    required this.isSkinUnlocked,
    required this.back,
    required this.onSelectSkin,
    super.key,
  });

  final int sparks;
  final BombSkin equippedSkin;
  final bool Function(BombSkin skin) isSkinUnlocked;
  final VoidCallback back;
  final Future<void> Function(BombSkin skin, {bool withAd}) onSelectSkin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 20, 6),
          child: Row(
            children: [
              IconButton(
                onPressed: back,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Text(
                  context.l10n.bombShopTitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: yellow.withValues(alpha: 0.6)),
                ),
                child: Text(
                  '⚡ $sparks',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isLight ? const Color(0xFF9A5A00) : yellow,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            itemCount: BombSkin.values.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.84,
            ),
            itemBuilder: (_, index) {
              final skin = BombSkin.values[index];
              final unlocked = isSkinUnlocked(skin);
              final isEquipped = equippedSkin == skin;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isEquipped ? yellow : colors.outline,
                    width: isEquipped ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BombImage(size: 86, skin: skin),
                    Text(
                      skin.localizedName(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    if (isEquipped)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: yellow.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          context.l10n.equipped,
                          style: TextStyle(
                            color: isLight ? const Color(0xFF9A5A00) : yellow,
                            fontWeight: FontWeight.w900,
                            fontSize: 11.5,
                          ),
                        ),
                      )
                    else if (unlocked)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonal(
                          onPressed: () => onSelectSkin(skin),
                          child: Text(context.l10n.equip),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () => onSelectSkin(skin, withAd: true),
                              style: FilledButton.styleFrom(
                                backgroundColor: yellow,
                                foregroundColor: ink,
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                '▶ 24h',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => onSelectSkin(skin),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                '⚡${skin.sparkCost}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ContentManager extends StatefulWidget {
  const ContentManager({
    required this.categories,
    required this.sparks,
    required this.openRewards,
    required this.back,
    required this.addChallenge,
    required this.addCategory,
    required this.customItems,
    required this.customCategories,
    required this.removeChallenge,
    required this.removeCategory,
    super.key,
  });
  final List<Category> categories;
  final int sparks;
  final VoidCallback openRewards;
  final VoidCallback back;
  final Future<AddPromptResult> Function(String category, String value)
  addChallenge;
  final Future<AddCategoryResult> Function(
    String name,
    String emoji,
    String firstItem,
  )
  addCategory;
  final Map<String, List<String>> customItems;
  final List<Category> customCategories;
  final Future<bool> Function(String category, String value) removeChallenge;
  final Future<void> Function(String category) removeCategory;

  @override
  State<ContentManager> createState() => _ContentManagerState();
}

class _ContentManagerState extends State<ContentManager> {
  void message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<bool> confirm(String title, String body) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: Text(context.l10n.delete),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> deleteCategory(Category item) async {
    final accepted = await confirm(
      context.l10n.deleteCategoryTitle,
      context.l10n.deleteCategoryMessage(item.name),
    );
    if (!accepted || !mounted) return;
    await widget.removeCategory(item.name);
    if (mounted) message(context.l10n.categoryDeleted);
  }

  Future<void> deletePrompt(String category, String prompt) async {
    final accepted = await confirm(
      context.l10n.deletePromptTitle,
      context.l10n.deletePromptMessage(prompt),
    );
    if (!accepted || !mounted) return;
    final removedCategory = await widget.removeChallenge(category, prompt);
    if (!mounted) return;
    message(
      removedCategory
          ? context.l10n.lastPromptDeleted
          : context.l10n.promptDeleted,
    );
  }

  Future<void> addChallenge() async {
    final strings = context.l10n;
    if (widget.sparks < customPromptCost) {
      message(strings.needSparksForPrompt);
      return;
    }
    var selected = widget.categories.first.name;
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(strings.addPromptCost),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selected,
                isExpanded: true,
                decoration: InputDecoration(labelText: strings.category),
                items: widget.categories
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.name,
                        child: Text(
                          '${item.emoji}  ${localizedContent(context, item.name)}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => selected = value);
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: strings.prompt,
                  hintText: strings.promptHint,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(strings.save),
            ),
          ],
        ),
      ),
    );
    final value = controller.text;
    if (result != true || !mounted) return;
    final saved = await widget.addChallenge(selected, value);
    if (!mounted) return;
    message(switch (saved) {
      AddPromptResult.added => strings.promptAdded,
      AddPromptResult.limitReached => strings.maxPromptsReached,
      AddPromptResult.notEnoughSparks => strings.needSparksForPrompt,
      AddPromptResult.invalid => strings.newPromptRequired,
    });
  }

  Future<void> addCategory() async {
    final strings = context.l10n;
    if (widget.sparks < customCategoryCost) {
      message(strings.needSparksForCategory);
      return;
    }
    final name = TextEditingController();
    final emoji = TextEditingController(text: '🎯');
    final firstItem = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.createCategoryCost),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: strings.name),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: emoji,
                decoration: InputDecoration(
                  labelText: strings.icon,
                  helperText: strings.emojiHelp,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: firstItem,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: strings.firstPrompt),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.create),
          ),
        ],
      ),
    );
    final categoryName = name.text;
    final categoryEmoji = emoji.text;
    final categoryItem = firstItem.text;
    if (result != true || !mounted) return;
    final saved = await widget.addCategory(
      categoryName,
      categoryEmoji,
      categoryItem,
    );
    if (!mounted) return;
    message(switch (saved) {
      AddCategoryResult.created => strings.categoryCreated,
      AddCategoryResult.notEnoughSparks => strings.needSparksForCategory,
      AddCategoryResult.invalid => strings.categoryReview,
    });
  }

  @override
  Widget build(BuildContext context) {
    final addedPrompts = <({String category, String emoji, String prompt})>[
      for (final entry in widget.customItems.entries)
        for (final prompt in entry.value)
          (
            category: entry.key,
            emoji: widget.categories
                .firstWhere((item) => item.name == entry.key)
                .emoji,
            prompt: prompt,
          ),
      for (final category in widget.customCategories)
        for (final prompt in category.items)
          (category: category.name, emoji: category.emoji, prompt: prompt),
    ];
    final colors = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 20, 6),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.back,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Text(
                  context.l10n.yourContent,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Material(
                color: colors.surface,
                shape: StadiumBorder(
                  side: BorderSide(color: yellow.withValues(alpha: 0.65)),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: widget.openRewards,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    child: Text(
                      '⚡ ${widget.sparks}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: isLight ? const Color(0xFF9A5A00) : yellow,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                context.l10n.customizeGame,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.localOnly,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              BigButton(
                label: context.l10n.addPromptCost,
                icon: Icons.add_rounded,
                onTap: addChallenge,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: addCategory,
                icon: const Icon(Icons.create_new_folder_rounded),
                label: Text(context.l10n.createCategoryCost),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                context.l10n.ownCategories,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              ...widget.categories
                  .where((item) => item.custom)
                  .map(
                    (item) => Card(
                      child: ListTile(
                        leading: Text(
                          item.emoji,
                          style: const TextStyle(fontSize: 25),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          context.l10n.ownPromptCountMax(item.items.length),
                        ),
                        trailing: IconButton(
                          key: ValueKey('delete-category-${item.name}'),
                          onPressed: () => deleteCategory(item),
                          tooltip: context.l10n.delete,
                          color: Theme.of(context).colorScheme.error,
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ),
                    ),
                  ),
              if (!widget.categories.any((item) => item.custom))
                Text(
                  context.l10n.noOwnCategories,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 28),
              Text(
                context.l10n.ownPrompts,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              ...addedPrompts.map(
                (item) => Card(
                  child: ListTile(
                    leading: Text(
                      item.emoji,
                      style: const TextStyle(fontSize: 23),
                    ),
                    title: Text(
                      item.prompt,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(localizedContent(context, item.category)),
                    trailing: IconButton(
                      key: ValueKey(
                        'delete-prompt-${item.category}-${item.prompt}',
                      ),
                      onPressed: () => deletePrompt(item.category, item.prompt),
                      tooltip: context.l10n.delete,
                      color: Theme.of(context).colorScheme.error,
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ),
                ),
              ),
              if (addedPrompts.isEmpty)
                Text(
                  context.l10n.noOwnPrompts,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class Settings extends StatelessWidget {
  const Settings({
    required this.light,
    required this.back,
    required this.toggleTheme,
    required this.manageContent,
    required this.language,
    required this.onLanguageChanged,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.remindersEnabled,
    required this.loserDareEnabled,
    required this.dynamicTensionEnabled,
    required this.onSoundChanged,
    required this.onVibrationChanged,
    required this.onRemindersChanged,
    required this.onLoserDareChanged,
    required this.onDynamicTensionChanged,
    required this.privacyOptions,
    required this.rateApp,
    required this.playTruthOrDare,
    required this.playImpostor,
    super.key,
  });
  final bool light;
  final VoidCallback back, toggleTheme, manageContent;
  final String language;
  final ValueChanged<String> onLanguageChanged;
  final bool soundEnabled,
      vibrationEnabled,
      remindersEnabled,
      loserDareEnabled,
      dynamicTensionEnabled;
  final ValueChanged<bool> onSoundChanged,
      onVibrationChanged,
      onRemindersChanged,
      onLoserDareChanged,
      onDynamicTensionChanged;
  final VoidCallback rateApp, playTruthOrDare, playImpostor, privacyOptions;

  Widget _sectionLabel(BuildContext context, String label) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      label,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 11.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.3,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Header(title: context.l10n.settings, back: back),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _sectionLabel(context, context.l10n.sectionGameAudio),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  SwitchListTile(
                    value: soundEnabled,
                    onChanged: onSoundChanged,
                    secondary: Icon(
                      soundEnabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                    ),
                    title: Text(
                      context.l10n.bombSound,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      soundEnabled
                          ? context.l10n.soundEnabled
                          : context.l10n.soundDisabled,
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: vibrationEnabled,
                    onChanged: onVibrationChanged,
                    secondary: Icon(
                      vibrationEnabled
                          ? Icons.vibration_rounded
                          : Icons.phone_android_rounded,
                    ),
                    title: Text(
                      context.l10n.vibration,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      vibrationEnabled
                          ? context.l10n.vibrationEnabled
                          : context.l10n.vibrationDisabled,
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: loserDareEnabled,
                    onChanged: onLoserDareChanged,
                    secondary: const Icon(Icons.casino_rounded),
                    title: Text(
                      context.l10n.loserDareSetting,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      loserDareEnabled
                          ? context.l10n.loserDareEnabled
                          : context.l10n.loserDareDisabled,
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: dynamicTensionEnabled,
                    onChanged: onDynamicTensionChanged,
                    secondary: const Icon(Icons.speed_rounded),
                    title: Text(
                      context.l10n.dynamicTension,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      dynamicTensionEnabled
                          ? context.l10n.dynamicTensionEnabled
                          : context.l10n.dynamicTensionDisabled,
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: remindersEnabled,
                    onChanged: onRemindersChanged,
                    secondary: Icon(
                      remindersEnabled
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_rounded,
                    ),
                    title: Text(
                      context.l10n.gameReminders,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      remindersEnabled
                          ? context.l10n.remindersEnabled
                          : context.l10n.remindersDisabled,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _sectionLabel(context, context.l10n.sectionAppearance),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  SwitchListTile(
                    value: light,
                    onChanged: (_) => toggleTheme(),
                    secondary: Icon(
                      light
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      context.l10n.lightMode,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(context.l10n.darkDefault),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.language_rounded),
                          title: Text(
                            context.l10n.language,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(context.l10n.languageDescription),
                        ),
                        DropdownButtonFormField<String>(
                          initialValue: language,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'system',
                              child: Text(context.l10n.languageAutomatic),
                            ),
                            DropdownMenuItem(
                              value: 'es',
                              child: Text(context.l10n.languageSpanish),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Text(context.l10n.languageEnglish),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) onLanguageChanged(value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _sectionLabel(context, context.l10n.sectionContent),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    onTap: manageContent,
                    leading: const Icon(Icons.edit_note_rounded),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    title: Text(
                      context.l10n.categoriesAndPrompts,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(context.l10n.addLocalContent),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    onTap: privacyOptions,
                    leading: const Icon(Icons.privacy_tip_rounded),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    title: Text(
                      context.l10n.privacyOptions,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(context.l10n.privacyOptionsDescription),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    onTap: rateApp,
                    leading: const Icon(Icons.star_rounded),
                    trailing: const Icon(Icons.open_in_new_rounded),
                    title: Text(
                      context.l10n.rateApp,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(context.l10n.rateAppDescription),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            _sectionLabel(context, context.l10n.moreGames),
            OutlinedButton.icon(
              onPressed: playTruthOrDare,
              icon: const Text('🎭', style: TextStyle(fontSize: 22)),
              label: Text(context.l10n.playTruthOrDare),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: playImpostor,
              icon: const Text('🕵️', style: TextStyle(fontSize: 22)),
              label: Text(context.l10n.playImpostor),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class BombImage extends StatelessWidget {
  const BombImage({
    required this.size,
    this.skin = BombSkin.classic,
    super.key,
  });
  final double size;
  final BombSkin skin;

  @override
  Widget build(BuildContext context) {
    if (skin == BombSkin.classic) {
      return Image.asset(
        skin.assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ink,
        border: Border.all(
          color: skin.glowColor.withValues(alpha: 0.55),
          width: size > 60 ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: skin.glowColor.withValues(alpha: 0.28),
            blurRadius: size * 0.18,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        skin.assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({required this.title, required this.back, super.key});
  final String title;
  final VoidCallback back;
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 10, 20, 10),
    child: Row(
      children: [
        IconButton(onPressed: back, icon: const Icon(Icons.arrow_back_rounded)),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    ),
  );
}

class BigButton extends StatelessWidget {
  const BigButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.tall = false,
    super.key,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool tall;
  @override
  Widget build(BuildContext c) => SizedBox(
    width: double.infinity,
    height: tall ? 66 : 56,
    child: FilledButton.icon(
      onPressed: onTap,
      iconAlignment: IconAlignment.end,
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: yellow,
        foregroundColor: ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
  );
}
