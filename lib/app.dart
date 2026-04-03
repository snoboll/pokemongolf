import 'package:flutter/material.dart';

import 'screens/collection_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/round_screen.dart';
import 'state/pokemon_golf_store.dart';

class PokemonGolfApp extends StatefulWidget {
  const PokemonGolfApp({super.key});

  @override
  State<PokemonGolfApp> createState() => _PokemonGolfAppState();
}

class _PokemonGolfAppState extends State<PokemonGolfApp> {
  final PokemonGolfStore _store = PokemonGolfStore();

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PokemonGolfScope(
      notifier: _store,
      child: MaterialApp(
        title: 'Pokemon Golf',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0F1A0F),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: const Color(0xFF1A2E1A),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: const Color(0xFF0F1A0F),
            indicatorColor: const Color(0xFF2E7D32).withValues(alpha: 0.3),
            height: 68,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        home: const PokemonGolfShell(),
      ),
    );
  }
}

class PokemonGolfScope extends InheritedNotifier<PokemonGolfStore> {
  const PokemonGolfScope({
    super.key,
    required PokemonGolfStore notifier,
    required super.child,
  }) : super(notifier: notifier);

  static PokemonGolfStore of(BuildContext context) {
    final PokemonGolfScope? scope =
        context.dependOnInheritedWidgetOfExactType<PokemonGolfScope>();
    assert(scope != null, 'PokemonGolfScope not found in widget tree.');
    return scope!.notifier!;
  }
}

class PokemonGolfShell extends StatefulWidget {
  const PokemonGolfShell({super.key});

  @override
  State<PokemonGolfShell> createState() => _PokemonGolfShellState();
}

class _PokemonGolfShellState extends State<PokemonGolfShell> {
  int _selectedIndex = 1;

  void _startRound(BuildContext context, int holeCount) {
    final store = PokemonGolfScope.of(context);
    store.startRound(holeCount);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const RoundScreen(),
      ),
    );
  }

  void _resumeRound(BuildContext context) {
    final store = PokemonGolfScope.of(context);
    if (store.activeRound == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const RoundScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const CollectionScreen(),
      HomeScreen(
        onStartRound: (int holeCount) => _startRound(context, holeCount),
        onResumeRound: () => _resumeRound(context),
      ),
      const HistoryScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.catching_pokemon_outlined),
            selectedIcon: Icon(Icons.catching_pokemon),
            label: 'Pokedex',
          ),
          NavigationDestination(
            icon: Icon(Icons.golf_course_outlined),
            selectedIcon: Icon(Icons.golf_course),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.scoreboard_outlined),
            selectedIcon: Icon(Icons.scoreboard),
            label: 'Scorecards',
          ),
        ],
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
