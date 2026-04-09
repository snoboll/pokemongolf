import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/battle_models.dart';
import 'models/golf_course.dart';
import 'screens/auth_screen.dart';
import 'screens/battle_round_screen.dart';
import 'screens/battles_screen.dart';
import 'screens/collection_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/round_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/team_select_screen.dart';
import 'screens/trainers_screen.dart';
import 'services/battle_service.dart';
import 'services/supabase_service.dart';
import 'state/battle_store.dart';
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
          seedColor: const Color(0xFF00A651),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF57F287),
          onPrimary: const Color(0xFF003915),
          primaryContainer: const Color(0xFF00531F),
          onPrimaryContainer: const Color(0xFF7EFFA8),
          secondary: const Color(0xFFFFD700),
          onSecondary: const Color(0xFF3B2F00),
          surface: const Color(0xFF141F14),
          onSurface: const Color(0xFFDCEEDC),
          surfaceContainerHighest: const Color(0xFF263226),
          outline: const Color(0xFF4A5E4A),
          outlineVariant: const Color(0xFF2C3C2C),
        ),
        scaffoldBackgroundColor: const Color(0xFF0C150C),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF243024), width: 1),
          ),
          color: const Color(0xFF172417),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF0C150C),
          indicatorColor: const Color(0xFF57F287).withValues(alpha: 0.2),
          surfaceTintColor: Colors.transparent,
          height: 68,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF57F287));
            }
            return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
          }),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1C2C1C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2C3C2C), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2C3C2C), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF57F287), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
  bool _hasUpdate = false;
  String _currentVersion = '';

  static const String _versionUrl =
      'https://cuwcunjtervjelgomeil.supabase.co/storage/v1/object/public/app-distribution/version.json';
  static const String _installUrl =
      'https://luminous-dieffenbachia-a31fa5.netlify.app';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      _currentVersion = info.version;
      _checkForUpdate();
    });
  }

  Future<void> _checkForUpdate() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(_versionUrl));
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        final remote = data['version'] as String? ?? _currentVersion;
        if (remote != _currentVersion) {
          if (mounted) setState(() => _hasUpdate = true);
        }
      }
      client.close();
    } catch (_) {}
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

  void _openBattleMode(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const BattleFlow(),
      ),
    );
  }

  void _challengeLeader(BuildContext context, GolfCourse course) async {
    final store = PokemonGolfScope.of(context);
    final leader = store.leaderForCourse(course.id);

    if (store.caughtDexNumbers.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catch at least 3 Pokémon to challenge a leader')),
      );
      return;
    }

    final team = await Navigator.of(context).push<List<BattlePokemon>>(
      MaterialPageRoute(
        builder: (_) => TeamSelectScreen(
          caughtDexNumbers: Set<int>.from(store.caughtDexNumbers),
          title: 'Challenge ${leader.leaderName}',
        ),
      ),
    );
    if (team == null || !context.mounted) return;

    final pars = course.flatPars;
    final holeCount = pars.length > 18 ? 18 : pars.length;
    final selectedPars = pars.take(holeCount).toList();

    try {
      final battleStore = BattleStore(service: BattleService());
      final battle = await battleStore.createLeaderChallenge(
        courseId: course.id,
        courseName: course.name,
        holeCount: holeCount,
        coursePars: selectedPars,
        team: team,
        challengerName: store.trainerName ?? 'Trainer',
        leaderName: leader.leaderName,
        leaderTeam: leader.team,
        leaderHcp: leader.hcp,
        leaderUserId: leader.userId,
      );
      if (!context.mounted) return;

      battleStore.watchBattle(battle.id);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BattleScope(
          notifier: battleStore,
          child: BattleRoundScreen(battleId: battle.id),
        ),
      )).then((_) {
        battleStore.stopWatching();
        if (context.mounted) {
          PokemonGolfScope.of(context).refreshCourseLeaders();
        }
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const CollectionScreen(),
      const TrainersScreen(),
      HomeScreen(
        onPlay: () => setState(() => _selectedIndex = 3),
        onResumeRound: () => _resumeRound(context),
        onBattleMode: () => _openBattleMode(context),
        onGymChallenge: (course) => _challengeLeader(context, course),
      ),
      const CoursesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          if (_hasUpdate)
            GestureDetector(
              onTap: () => launchUrl(Uri.parse(_installUrl), mode: LaunchMode.externalApplication),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFFFD700),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: const SafeArea(
                  bottom: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.system_update, size: 16, color: Color(0xFF3B2F00)),
                      SizedBox(width: 8),
                      Text(
                        'Update available — tap to install',
                        style: TextStyle(
                          color: Color(0xFF3B2F00),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),
          ),
        ],
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
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
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
