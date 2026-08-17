import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
const audio = MethodChannel('labomba/audio');

class Category {
  const Category(this.name, this.emoji, this.items);
  final String name, emoji;
  final List<String> items;
}

const categories = <Category>[
  Category('Al azar', '🎲', []),
  Category('Animales', '🐾', [
    'Animales marinos',
    'Animales que vuelan',
    'Animales de granja',
    'Animales salvajes',
    'Animales con cuatro patas',
  ]),
  Category('Ciudades', '🏙️', [
    'Ciudades españolas',
    'Capitales europeas',
    'Ciudades con playa',
    'Ciudades de América',
    'Ciudades que empiezan por M',
  ]),
  Category('Países', '🌍', [
    'Países de Europa',
    'Países de América',
    'Países con costa',
    'Países que empiezan por C',
    'Países cálidos',
  ]),
  Category('Comida', '🍕', [
    'Frutas',
    'Postres',
    'Comidas con queso',
    'Platos fríos',
    'Comidas de otros países',
  ]),
  Category('Objetos', '🎒', [
    'Objetos de cocina',
    'Objetos con ruedas',
    'Objetos de un colegio',
    'Objetos que caben en un bolsillo',
    'Objetos rojos',
  ]),
  Category('Películas', '🎬', [
    'Películas de animación',
    'Películas de terror',
    'Películas de superhéroes',
    'Sagas de cine',
    'Películas con animales',
  ]),
  Category('Series', '📺', [
    'Series de comedia',
    'Series españolas',
    'Series de animación',
    'Series con detectives',
    'Series de Netflix',
  ]),
  Category('Música', '🎵', [
    'Cantantes españoles',
    'Grupos musicales',
    'Instrumentos',
    'Canciones de fiesta',
    'Géneros musicales',
  ]),
  Category('Deportes', '🏆', [
    'Deportes con pelota',
    'Deportes de equipo',
    'Deportes acuáticos',
    'Deportes olímpicos',
    'Deportes con casco',
  ]),
  Category('Profesiones', '💼', [
    'Profesiones sanitarias',
    'Trabajos al aire libre',
    'Profesiones con uniforme',
    'Profesiones creativas',
    'Trabajos con ordenador',
  ]),
  Category('Marcas', '🛍️', [
    'Marcas de coches',
    'Marcas de ropa',
    'Marcas de móviles',
    'Marcas de comida',
    'Marcas deportivas',
  ]),
  Category('Tecnología', '📱', [
    'Aplicaciones móviles',
    'Redes sociales',
    'Videojuegos',
    'Dispositivos electrónicos',
    'Cosas con pantalla',
  ]),
  Category('Naturaleza', '🌿', [
    'Tipos de árboles',
    'Flores',
    'Fenómenos meteorológicos',
    'Cosas de un bosque',
    'Cosas del mar',
  ]),
  Category('Viajes', '✈️', [
    'Cosas de una maleta',
    'Medios de transporte',
    'Lugares turísticos',
    'Cosas de un aeropuerto',
    'Motivos para viajar',
  ]),
  Category('Casa', '🏠', [
    'Cosas de un baño',
    'Muebles',
    'Electrodomésticos',
    'Cosas de un dormitorio',
    'Tareas domésticas',
  ]),
  Category('Colegio', '🎓', [
    'Asignaturas',
    'Material escolar',
    'Cosas del recreo',
    'Lugares de un colegio',
    'Excusas para llegar tarde',
  ]),
  Category('Fiesta', '🪩', [
    'Bebidas',
    'Canciones para bailar',
    'Motivos para celebrar',
    'Cosas de una fiesta',
    'Cosas que pueden salir mal',
  ]),
  Category('Famosos', '🌟', [
    'Actores',
    'Deportistas famosos',
    'Cantantes',
    'Personajes históricos',
    'Presentadores',
  ]),
  Category('Palabras', '🔤', [
    'Palabras que empiezan por M',
    'Palabras de cinco letras',
    'Palabras que acaban en A',
    'Palabras con doble letra',
    'Palabras de verano',
  ]),
  Category('Cuerpo', '🫀', [
    'Partes del cuerpo',
    'Huesos',
    'Órganos',
    'Cosas que puedes mover',
    'Cosas que tienes dos',
  ]),
  Category('Ropa', '👕', [
    'Prendas de invierno',
    'Tipos de calzado',
    'Accesorios',
    'Ropa deportiva',
    'Prendas negras',
  ]),
  Category('Vehículos', '🚗', [
    'Marcas de coche',
    'Vehículos de dos ruedas',
    'Transportes públicos',
    'Vehículos que vuelan',
    'Partes de un coche',
  ]),
  Category('Fantasía', '🐉', [
    'Seres mitológicos',
    'Superpoderes',
    'Personajes de cuentos',
    'Objetos mágicos',
    'Lugares imaginarios',
  ]),
  Category('Verano', '☀️', [
    'Cosas de la playa',
    'Sabores de helado',
    'Planes de verano',
    'Protección solar',
    'Bebidas frías',
  ]),
  Category('Navidad', '🎄', [
    'Adornos navideños',
    'Comidas de Navidad',
    'Regalos',
    'Canciones navideñas',
    'Cosas que haces en Navidad',
  ]),
];

class BombApp extends StatefulWidget {
  const BombApp({super.key});
  @override
  State<BombApp> createState() => _BombAppState();
}

class _BombAppState extends State<BombApp> {
  bool light = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => light = prefs.getBool('light_theme') ?? false);
  }

  Future<void> toggleTheme() async {
    setState(() => light = !light);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('light_theme', light);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'La Bomba',
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
    home: Game(light: light, onToggleTheme: toggleTheme),
  );
}

enum Screen { home, categories, ready, playing, exploded, settings }

class Game extends StatefulWidget {
  const Game({required this.light, required this.onToggleTheme, super.key});
  final bool light;
  final VoidCallback onToggleTheme;
  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> with WidgetsBindingObserver {
  final random = Random();
  final usedChallenges = <String>{};
  late final Future<void> historyReady;
  Screen screen = Screen.home;
  Category? category;
  String challenge = '';
  int minSeconds = 30, maxSeconds = 60;
  bool paused = false;
  Timer? timer;
  Duration remaining = Duration.zero;
  DateTime? deadline;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    historyReady = _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    usedChallenges.addAll(prefs.getStringList('used_challenges') ?? const []);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('used_challenges', usedChallenges.toList());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s != AppLifecycleState.resumed && screen == Screen.playing) pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    invoke('stopTicking');
    super.dispose();
  }

  Future<void> invoke(String method) async {
    try {
      await audio.invokeMethod<void>(method);
    } catch (_) {}
  }

  Future<void> choose(Category c) async {
    await historyReady;
    if (!mounted) return;
    if (c.items.isEmpty) {
      final available = categories
          .skip(1)
          .where(
            (candidate) => candidate.items.any(
              (item) => !usedChallenges.contains(_historyKey(candidate, item)),
            ),
          )
          .toList();
      category = available.isEmpty
          ? categories[1 + random.nextInt(categories.length - 1)]
          : available[random.nextInt(available.length)];
    } else {
      category = c;
    }
    pick();
    setState(() => screen = Screen.ready);
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

  String _historyKey(Category category, String item) =>
      '${category.name}::$item';

  void start() {
    final seconds = minSeconds + random.nextInt(maxSeconds - minSeconds + 1);
    remaining = Duration(seconds: seconds);
    deadline = DateTime.now().add(remaining);
    paused = false;
    timer?.cancel();
    timer = Timer(remaining, explode);
    invoke('startTicking');
    setState(() => screen = Screen.playing);
  }

  void pause() {
    if (paused || screen != Screen.playing) return;
    remaining =
        deadline?.difference(DateTime.now()) ?? const Duration(seconds: 2);
    if (remaining.isNegative) remaining = const Duration(seconds: 2);
    timer?.cancel();
    invoke('pauseTicking');
    setState(() => paused = true);
  }

  void resume() {
    deadline = DateTime.now().add(remaining);
    timer = Timer(remaining, explode);
    invoke('resumeTicking');
    setState(() => paused = false);
  }

  void explode() {
    if (!mounted || screen != Screen.playing) return;
    timer?.cancel();
    invoke('stopTicking');
    invoke('explode');
    HapticFeedback.heavyImpact();
    Future<void>.delayed(
      const Duration(milliseconds: 170),
      HapticFeedback.heavyImpact,
    );
    Future<void>.delayed(
      const Duration(milliseconds: 350),
      HapticFeedback.vibrate,
    );
    setState(() => screen = Screen.exploded);
  }

  void leave(Screen target) {
    timer?.cancel();
    invoke('stopTicking');
    setState(() => screen = target);
  }

  @override
  Widget build(BuildContext c) => PopScope(
    canPop: screen == Screen.home,
    onPopInvokedWithResult: (did, _) {
      if (!did) {
        leave(screen == Screen.categories ? Screen.home : Screen.categories);
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
                Screen.home => Home(
                  key: const ValueKey('home'),
                  start: () => setState(() => screen = Screen.categories),
                  light: widget.light,
                  toggleTheme: widget.onToggleTheme,
                  settings: () => setState(() => screen = Screen.settings),
                ),
                Screen.categories => CategoryPicker(
                  key: const ValueKey('categories'),
                  back: () => setState(() => screen = Screen.home),
                  choose: choose,
                ),
                Screen.ready => Ready(
                  key: ValueKey(challenge),
                  category: category!,
                  challenge: challenge,
                  minSeconds: minSeconds,
                  maxSeconds: maxSeconds,
                  back: () => setState(() => screen = Screen.categories),
                  change: () => setState(pick),
                  setTime: (r) => setState(() {
                    minSeconds = r.$1;
                    maxSeconds = r.$2;
                  }),
                  start: start,
                ),
                Screen.playing => Playing(
                  key: const ValueKey('playing'),
                  category: category!,
                  challenge: challenge,
                  paused: paused,
                  change: () {
                    if (!paused) setState(pick);
                  },
                  pause: pause,
                  resume: resume,
                ),
                Screen.exploded => Exploded(
                  key: const ValueKey('exploded'),
                  category: category!,
                  challenge: challenge,
                  again: () {
                    pick();
                    start();
                  },
                  changeCategory: () =>
                      setState(() => screen = Screen.categories),
                ),
                Screen.settings => Settings(
                  key: const ValueKey('settings'),
                  light: widget.light,
                  back: () => setState(() => screen = Screen.home),
                  toggleTheme: widget.onToggleTheme,
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
        center: Alignment(1.1, -1),
        radius: 1.5,
        colors: Theme.of(c).brightness == Brightness.dark
            ? const [Color(0xFF3A211B), ink, Color(0xFF0B0C11)]
            : const [Color(0xFFFFE7B0), Color(0xFFF8F2E7), Color(0xFFF2EBDD)],
      ),
    ),
    child: const SizedBox.expand(),
  );
}

class Home extends StatelessWidget {
  const Home({
    required this.start,
    required this.light,
    required this.toggleTheme,
    required this.settings,
    super.key,
  });
  final VoidCallback start, toggleTheme, settings;
  final bool light;
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const BombImage(size: 32),
            const SizedBox(width: 9),
            const Text(
              'LA BOMBA',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
            const Spacer(),
            IconButton.filledTonal(
              onPressed: settings,
              tooltip: 'Configuración',
              icon: const Icon(Icons.settings_rounded),
            ),
            const SizedBox(width: 6),
            IconButton.filledTonal(
              onPressed: toggleTheme,
              tooltip: light ? 'Modo oscuro' : 'Modo claro',
              icon: Icon(
                light ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              ),
            ),
          ],
        ),
        const Spacer(),
        const Center(child: BombImage(size: 156)),
        const SizedBox(height: 28),
        const Text(
          'Nombra cosas.\nQue no te pille.',
          style: TextStyle(
            fontSize: 45,
            height: .98,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.8,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Elegid una categoría y decid respuestas sin repetir hasta que la bomba explote.',
          style: TextStyle(
            color: Theme.of(c).colorScheme.onSurfaceVariant,
            fontSize: 17,
            height: 1.4,
          ),
        ),
        const Spacer(),
        BigButton(
          label: 'Elegir categoría',
          icon: Icons.grid_view_rounded,
          onTap: start,
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'SIN NOMBRES · SIN JUGADORES · SIN TURNOS',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class CategoryPicker extends StatelessWidget {
  const CategoryPicker({required this.back, required this.choose, super.key});
  final VoidCallback back;
  final ValueChanged<Category> choose;
  @override
  Widget build(BuildContext c) => Column(
    children: [
      Header(title: 'Elige una categoría', back: back),
      const Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Todo el grupo juega a la vez.',
            style: TextStyle(color: muted),
          ),
        ),
      ),
      Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemBuilder: (_, i) {
            final item = categories[i];
            return Material(
              color: panel,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => choose(item),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.emoji, style: const TextStyle(fontSize: 30)),
                      const Spacer(),
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${item.items.length} consignas',
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

class Ready extends StatelessWidget {
  const Ready({
    required this.category,
    required this.challenge,
    required this.minSeconds,
    required this.maxSeconds,
    required this.back,
    required this.change,
    required this.setTime,
    required this.start,
    super.key,
  });
  final Category category;
  final String challenge;
  final int minSeconds, maxSeconds;
  final VoidCallback back, change, start;
  final ValueChanged<(int, int)> setTime;
  @override
  Widget build(BuildContext c) => Column(
    children: [
      Header(title: category.name, back: back),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Text(category.emoji, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 18),
              const Text(
                'NOMBRAD...',
                style: TextStyle(
                  color: yellow,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  challenge,
                  key: ValueKey(challenge),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 35,
                    height: 1.06,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: change,
                icon: const Icon(Icons.shuffle_rounded),
                label: const Text('Otra consigna'),
              ),
              const Spacer(),
              SegmentedButton<(int, int)>(
                segments: const [
                  ButtonSegment(value: (15, 30), label: Text('Rápida')),
                  ButtonSegment(value: (30, 60), label: Text('Normal')),
                  ButtonSegment(value: (60, 90), label: Text('Larga')),
                ],
                selected: {(minSeconds, maxSeconds)},
                onSelectionChanged: (v) => setTime(v.first),
                showSelectedIcon: false,
              ),
              const SizedBox(height: 12),
              Text(
                'La explosión ocurrirá entre $minSeconds y $maxSeconds segundos.',
                style: const TextStyle(color: muted, fontSize: 12),
              ),
              const SizedBox(height: 24),
              BigButton(
                label: 'Encender la mecha',
                icon: Icons.local_fire_department_rounded,
                onTap: start,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class Playing extends StatefulWidget {
  const Playing({
    required this.category,
    required this.challenge,
    required this.paused,
    required this.change,
    required this.pause,
    required this.resume,
    super.key,
  });
  final Category category;
  final String challenge;
  final bool paused;
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
      duration: const Duration(milliseconds: 850),
      lowerBound: .96,
      upperBound: 1,
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
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        Row(
          children: [
            Chip(
              avatar: Text(widget.category.emoji),
              label: Text(widget.category.name),
            ),
            const Spacer(),
            IconButton.filledTonal(
              onPressed: widget.paused ? widget.resume : widget.pause,
              icon: Icon(
                widget.paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              ),
            ),
          ],
        ),
        const Spacer(),
        ScaleTransition(
          scale: pulse,
          child: widget.paused
              ? const Icon(
                  Icons.pause_circle_filled_rounded,
                  size: 112,
                  color: yellow,
                )
              : const BombImage(size: 156),
        ),
        const SizedBox(height: 18),
        Text(
          widget.paused ? 'EN PAUSA' : 'TIC · TAC · TIC · TAC',
          style: TextStyle(
            color: widget.paused ? yellow : orange,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            widget.challenge,
            key: ValueKey(widget.challenge),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              height: 1.08,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: widget.paused ? null : widget.change,
          icon: const Icon(Icons.shuffle_rounded),
          label: const Text('Cambiar consigna'),
        ),
        const Spacer(),
        Text(
          widget.paused
              ? 'Pulsa ▶ para continuar'
              : 'Seguid respondiendo hasta que explote',
          style: const TextStyle(color: muted, fontSize: 14),
        ),
        const SizedBox(height: 28),
      ],
    ),
  );
}

class Exploded extends StatelessWidget {
  const Exploded({
    required this.category,
    required this.challenge,
    required this.again,
    required this.changeCategory,
    super.key,
  });
  final Category category;
  final String challenge;
  final VoidCallback again, changeCategory;
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        const Spacer(),
        const Text('💥', style: TextStyle(fontSize: 124)),
        const Text(
          '¡BOOM!',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w900,
            color: orange,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          challenge,
          style: const TextStyle(color: muted),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        BigButton(
          label: 'Otra de ${category.name}',
          icon: Icons.replay_rounded,
          onTap: again,
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: changeCategory,
          icon: const Icon(Icons.grid_view_rounded),
          label: const Text('Cambiar categoría'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
        ),
      ],
    ),
  );
}

class Settings extends StatelessWidget {
  const Settings({
    required this.light,
    required this.back,
    required this.toggleTheme,
    super.key,
  });
  final bool light;
  final VoidCallback back, toggleTheme;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Header(title: 'Configuración', back: back),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              child: SwitchListTile(
                value: light,
                onChanged: (_) => toggleTheme(),
                secondary: Icon(
                  light ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'Modo claro',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text(
                  'El modo oscuro seguirá siendo el predeterminado',
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                leading: Icon(Icons.volume_up_rounded),
                title: Text(
                  'Sonido de la bomba',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('Tic-tac continuo y explosión activados'),
              ),
            ),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                leading: Icon(Icons.vibration_rounded),
                title: Text(
                  'Vibración',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('Impacto háptico al explotar'),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class BombImage extends StatelessWidget {
  const BombImage({required this.size, super.key});
  final double size;
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/branding/bomb-brand.png',
    width: size,
    height: size,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.high,
  );
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
    height: tall ? 68 : 58,
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
