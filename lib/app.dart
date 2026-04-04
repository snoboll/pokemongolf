import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth_screen.dart';
import 'screens/collection_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/round_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/trainers_screen.dart';
import 'services/supabase_service.dart';
import 'state/pokemon_golf_store.dart';

class PokemonGolfApp extends StatefulWidget {
  const PokemonGolfApp({super.key});

  @override
  State<PokemonGolfApp> createState() => _PokemonGolfAppState();
}

class _PokemonGolfAppState extends State<PokemonGolfApp> {
  PokemonGolfStore? _store;
  late final StreamSubscription<AuthState> _authSub;
  bool _isAuthenticated = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _isAuthenticated = true;
      _initStore();
    } else {
      _loading = false;
    }

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (AuthState state) {
        final bool wasAuthenticated = _isAuthenticated;
        final bool nowAuthenticated = state.session != null;

        if (!wasAuthenticated && nowAuthenticated) {
          setState(() {
            _isAuthenticated = true;
            _loading = true;
          });
          _initStore();
        } else if (wasAuthenticated && !nowAuthenticated) {
          _store?.dispose();
          setState(() {
            _store = null;
            _isAuthenticated = false;
            _loading = false;
          });
        }
      },
    );
  }

  Future<void> _initStore() async {
    final store = PokemonGolfStore(
      supabaseService: SupabaseService(),
    );
    await store.loadUserData();
    if (mounted) {
      setState(() {
        _store = store;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    _store?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      builder: (BuildContext context, Widget? child) {
        if (_store != null) {
          return PokemonGolfScope(
            notifier: _store!,
            child: child!,
          );
        }
        return child!;
      },
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAuthenticated || _store == null) {
      return const AuthScreen();
    }

    return const PokemonGolfShell();
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
  int _selectedIndex = 2;

  void _startRound(BuildContext context, int holeCount, {List<int>? holePars, String? courseName, List<({double lat, double lng})>? greenCoords}) {
    final store = PokemonGolfScope.of(context);
    store.startRound(holeCount, holePars: holePars, courseName: courseName, greenCoords: greenCoords);

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
      const TrainersScreen(),
      HomeScreen(
        onStartRound: ({required int holeCount, List<int>? holePars, String? courseName, List<({double lat, double lng})>? greenCoords}) =>
            _startRound(context, holeCount, holePars: holePars, courseName: courseName, greenCoords: greenCoords),
        onResumeRound: () => _resumeRound(context),
      ),
      const CoursesScreen(),
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
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Trainers',
          ),
          NavigationDestination(
            icon: Icon(Icons.golf_course_outlined),
            selectedIcon: Icon(Icons.golf_course),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Courses',
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
