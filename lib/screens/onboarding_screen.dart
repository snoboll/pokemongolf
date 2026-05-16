import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/golf_course.dart';
import '../models/golfer_team.dart';
import '../state/bogeybeasts_golf_store.dart';
import '../widgets/white_bg_image.dart';

const _hickory = 'assets/golfers/starter_hickory.png';

const _sprites = <({String asset, String label})>[
  (asset: 'assets/golfers/male/transparent_bg/ace.png', label: 'Ace ♂'),
  (asset: 'assets/golfers/female/transparent_bg/ace.png', label: 'Ace ♀'),
  (asset: 'assets/golfers/male/transparent_bg/chipper.png', label: 'Chipper ♂'),
  (
    asset: 'assets/golfers/female/transparent_bg/chipper.png',
    label: 'Chipper ♀',
  ),
  (asset: 'assets/golfers/male/transparent_bg/drawer.png', label: 'Drawer ♂'),
  (asset: 'assets/golfers/female/transparent_bg/drawer.png', label: 'Drawer ♀'),
  (asset: 'assets/golfers/male/transparent_bg/slicer.png', label: 'Slicer ♂'),
  (asset: 'assets/golfers/female/transparent_bg/slicer.png', label: 'Slicer ♀'),
  (asset: 'assets/golfers/male/transparent_bg/hooker.png', label: 'Hooker ♂'),
  (asset: 'assets/golfers/female/transparent_bg/hooker.png', label: 'Hooker ♀'),
  (asset: 'assets/golfers/male/transparent_bg/flyer.png', label: 'Flyer ♂'),
  (asset: 'assets/golfers/female/transparent_bg/flyer.png', label: 'Flyer ♀'),
  (asset: 'assets/golfers/male/transparent_bg/fisher.png', label: 'Fisher ♂'),
  (asset: 'assets/golfers/female/transparent_bg/fisher.png', label: 'Fisher ♀'),
  (
    asset: 'assets/golfers/male/transparent_bg/longdriver.png',
    label: 'Longdriver ♂',
  ),
  (
    asset: 'assets/golfers/female/transparent_bg/longdriver.png',
    label: 'Longdriver ♀',
  ),
  (asset: 'assets/golfers/male/transparent_bg/hotshot.png', label: 'Hotshot ♂'),
  (
    asset: 'assets/golfers/female/transparent_bg/hotshot.png',
    label: 'Hotshot ♀',
  ),
  (
    asset: 'assets/golfers/male/transparent_bg/roughrunner.png',
    label: 'Roughrunner ♂',
  ),
  (
    asset: 'assets/golfers/female/transparent_bg/roughrunner.png',
    label: 'Roughrunner ♀',
  ),
  (
    asset: 'assets/golfers/male/transparent_bg/bunkerdigger.png',
    label: 'Bunkerboy ♂',
  ),
  (
    asset: 'assets/golfers/female/transparent_bg/bunkerdigger.png',
    label: 'Bunkerboy ♀',
  ),
  (
    asset: 'assets/golfers/male/transparent_bg/greenkeeper.png',
    label: 'Greenkeeper ♂',
  ),
  (
    asset: 'assets/golfers/female/transparent_bg/greenkeeper.png',
    label: 'Greenkeeper ♀',
  ),
  (asset: 'assets/golfers/male/transparent_bg/psycher.png', label: 'Psych ♂'),
  (asset: 'assets/golfers/female/transparent_bg/psycher.png', label: 'Psych ♀'),
  (asset: 'assets/golfers/male/transparent_bg/manager.png', label: 'Manager ♂'),
  (
    asset: 'assets/golfers/female/transparent_bg/manager.png',
    label: 'Manager ♀',
  ),
];

// ── Onboarding entry point ────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.store,
    required this.onComplete,
  });

  final BogeybeastGolfStore store;
  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _page = 0;

  // setup state — pre-filled for returning users replaying the tutorial
  late String? _selectedSprite = widget.store.golferSprite;
  late GolferTeam? _selectedTeam = widget.store.golferTeam != null
      ? GolferTeam.fromDb(widget.store.golferTeam!)
      : null;
  late String? _selectedHomeCourseId = widget.store.homeCourseId;
  final _hcpController = TextEditingController();

  @override
  void dispose() {
    _hcpController.dispose();
    super.dispose();
  }

  void _next() => setState(() => _page = math.min(_page + 1, 3));

  void _skipToSetup() => setState(() => _page = 3);

  void _finish() {
    if (_selectedSprite == null) return;

    widget.store.setGolferSprite(_selectedSprite);
    if (_selectedTeam != null) {
      widget.store.setGolferTeam(_selectedTeam!.dbValue);
    }
    if (_selectedHomeCourseId != null) {
      widget.store.setHomeCourseId(_selectedHomeCourseId!);
    }

    final hcp = double.tryParse(_hcpController.text.replaceAll(',', '.'));
    if (hcp != null && hcp >= 0 && hcp <= 54) {
      widget.store.setHcpOverride((hcp * 10).round() / 10.0);
    }

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final canFinish = _selectedSprite != null;
    final tutorialStep =
        _tutorialSteps[math.min(_page, _tutorialSteps.length - 1)];

    return Scaffold(
      body: _page < 3
          ? _SlidePage(
              page: _page,
              title: tutorialStep.title,
              body: tutorialStep.body,
              warning: tutorialStep.warning,
              onNext: _next,
              onSkip: _skipToSetup,
              nextLabel: _page == _tutorialSteps.length - 1
                  ? 'Set up profile'
                  : 'Next',
            )
          : _SetupPage(
              selectedSprite: _selectedSprite,
              selectedTeam: _selectedTeam,
              selectedHomeCourseId: _selectedHomeCourseId,
              courses: widget.store.catalogCourses,
              hcpController: _hcpController,
              canFinish: canFinish,
              onSpriteChanged: (s) => setState(() => _selectedSprite = s),
              onTeamChanged: (t) => setState(() => _selectedTeam = t),
              onHomeCourseChanged: (id) =>
                  setState(() => _selectedHomeCourseId = id),
              onFinish: _finish,
            ),
    );
  }
}

const _tutorialSteps = <({String title, String body, String? warning})>[
  (
    title: 'Well, hello there, rookie!',
    body:
        "I'm Starter Hickory — I've been sending golfers off the first tee on every course in this land for forty years. And I've never seen anything quite like what's out there on those fairways...",
    warning: null,
  ),
  (
    title: 'Bogeybeasts roam the courses',
    body:
        "Play a round and you'll encounter wild Bogeybeasts lurking in the rough, hiding in bunkers, soaring over the fairways. Catch them for your Bogeydex and use them to challenge friends or Course Leaders. Beat a Course Leader and you'll take their place, sending three Bogeybeasts to protect your position.",
    warning: null,
  ),
  (
    title: 'One more thing...',
    body:
        "You can join a team — Hazard, Socket, or Green — to compete with other golfers and conquer courses on the map together. It's optional, but the courses won't beat themselves.",
    warning: 'Once you pick a team, you\'re locked in for 30 days.',
  ),
];

// ── Slide page ────────────────────────────────────────────────────────────────

class _SlidePage extends StatelessWidget {
  const _SlidePage({
    required this.page,
    required this.title,
    required this.body,
    required this.onNext,
    required this.onSkip,
    this.warning,
    this.nextLabel = 'Next',
  });

  final int page;
  final String title;
  final String body;
  final String? warning;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final safeTop = MediaQuery.of(context).padding.top;

    return Column(
      children: [
        // Skip button
        SizedBox(
          height: safeTop + 48,
          child: Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),

        // Hickory portrait
        Expanded(
          flex: 5,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final portraitHeight = math.min(
                constraints.maxHeight * 0.96,
                360.0,
              );
              final glowSize = math.min(portraitHeight * 0.9, 300.0);

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Subtle glow behind character
                  Container(
                    width: glowSize,
                    height: glowSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primary.withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Image.asset(
                    _hickory,
                    height: portraitHeight,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.sports_golf_rounded,
                      size: math.min(portraitHeight * 0.45, 140.0),
                      color: primary.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // Dialogue card
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: primary.withValues(alpha: 0.2), width: 1),
            ),
          ),
          padding: EdgeInsets.fromLTRB(24, 24, 24, 16 + safeBottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hickory name badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_rounded, size: 13, color: primary),
                    const SizedBox(width: 5),
                    Text(
                      'Starter Hickory',
                      style: TextStyle(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              // Body
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                  height: 1.5,
                ),
              ),

              // Warning chip
              if (warning != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.secondary.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          warning!,
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Dots + Next
              Row(
                children: [
                  // Page dots
                  Row(
                    children: List.generate(3, (i) {
                      final active = i == page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 6),
                        width: active ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? primary
                              : primary.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: onNext,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(nextLabel),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Setup page ────────────────────────────────────────────────────────────────

class _SetupPage extends StatefulWidget {
  const _SetupPage({
    required this.selectedSprite,
    required this.selectedTeam,
    required this.selectedHomeCourseId,
    required this.courses,
    required this.hcpController,
    required this.canFinish,
    required this.onSpriteChanged,
    required this.onTeamChanged,
    required this.onHomeCourseChanged,
    required this.onFinish,
  });

  final String? selectedSprite;
  final GolferTeam? selectedTeam;
  final String? selectedHomeCourseId;
  final List<GolfCourse> courses;
  final TextEditingController hcpController;
  final bool canFinish;
  final ValueChanged<String> onSpriteChanged;
  final ValueChanged<GolferTeam> onTeamChanged;
  final ValueChanged<String> onHomeCourseChanged;
  final VoidCallback onFinish;

  @override
  State<_SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<_SetupPage> {
  // male sprites are at even indices, female at odd indices
  bool _male = true;

  @override
  void initState() {
    super.initState();
    // initialise toggle from already-selected sprite if any
    final idx = _sprites.indexWhere((s) => s.asset == widget.selectedSprite);
    if (idx != -1) _male = idx.isEven;
  }

  void _toggleGender(bool toMale) {
    if (_male == toMale) return;
    setState(() => _male = toMale);
    // auto-switch to same archetype in the new gender
    final idx = _sprites.indexWhere((s) => s.asset == widget.selectedSprite);
    if (idx == -1) return;
    final paired = toMale
        ? (idx.isOdd ? idx - 1 : idx)
        : (idx.isEven ? idx + 1 : idx);
    if (paired >= 0 && paired < _sprites.length) {
      widget.onSpriteChanged(_sprites[paired].asset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final safeTop = MediaQuery.of(context).padding.top;
    final visibleSprites = _sprites
        .asMap()
        .entries
        .where((e) => _male ? e.key.isEven : e.key.isOdd)
        .map((e) => e.value)
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, safeTop + 16, 20, safeBottom + 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with small Hickory
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_rounded, size: 13, color: primary),
                          const SizedBox(width: 5),
                          Text(
                            'Starter Hickory',
                            style: TextStyle(
                              color: primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Right then — let's get you sorted.",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Pick your look, set your handicap, and optionally join a team.",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                _hickory,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(width: 60),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Avatar ──────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _SectionLabel(label: 'Your look', required: true),
              ),
              _GenderToggle(male: _male, onChanged: _toggleGender),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
            itemCount: visibleSprites.length,
            itemBuilder: (_, i) {
              final entry = visibleSprites[i];
              final selected = widget.selectedSprite == entry.asset;
              final label = entry.label
                  .replaceAll(' ♂', '')
                  .replaceAll(' ♀', '');
              return GestureDetector(
                onTap: () => widget.onSpriteChanged(entry.asset),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? primary.withValues(alpha: 0.12)
                            : theme.colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: selected
                              ? primary
                              : theme.colorScheme.outlineVariant,
                          width: selected ? 2.5 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: WhiteBgImage(
                        asset: entry.asset,
                        width: 62,
                        height: 62,
                        placeholder: const Icon(Icons.sports_golf_rounded),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: selected
                            ? primary
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                        fontWeight: selected ? FontWeight.w700 : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // ── HCP ─────────────────────────────────────────────────────────
          _SectionLabel(label: 'Handicap', required: false),
          const SizedBox(height: 6),
          Text(
            "Leave blank and we'll calculate it from your rounds.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: widget.hcpController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'e.g. 18',
              suffixText: 'HCP',
            ),
          ),

          const SizedBox(height: 28),

          // ── Home course ──────────────────────────────────────────────────
          _SectionLabel(label: 'Home course', required: false),
          const SizedBox(height: 4),
          Text(
            "Your local club. We'll keep it pinned at the top of your courses.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 10),
          _CourseSearchField(
            courses: widget.courses,
            selectedId: widget.selectedHomeCourseId,
            onSelected: widget.onHomeCourseChanged,
          ),

          const SizedBox(height: 28),

          // ── Team ─────────────────────────────────────────────────────────
          _SectionLabel(label: 'Your team', required: false),
          const SizedBox(height: 4),
          Text(
            'Join a team to conquer courses on the map. You can skip this and join later.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: GolferTeam.values.map((team) {
              final selected = team == widget.selectedTeam;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: team != GolferTeam.values.last ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => widget.onTeamChanged(team),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: selected
                            ? team.color.withValues(alpha: 0.15)
                            : theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? team.color
                              : const Color(0xFF243024),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: team.color.withValues(
                                alpha: selected ? 0.3 : 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: team == GolferTeam.socket
                                  ? Text(
                                      'S',
                                      style: TextStyle(
                                        color: team.color,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        height: 1,
                                      ),
                                    )
                                  : Icon(
                                      team.icon,
                                      size: 24,
                                      color: team.color,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            team.label,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: selected
                                  ? team.color
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // 30-day warning
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.colorScheme.secondary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 15,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "You won't be able to switch teams for 30 days after joining.",
                    style: TextStyle(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Tee off button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.canFinish ? widget.onFinish : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sports_golf_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Tee Off!',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.required});
  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'required',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _GenderToggle extends StatelessWidget {
  const _GenderToggle({required this.male, required this.onChanged});
  final bool male;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GenderOption(
            icon: Icons.male_rounded,
            selected: male,
            onTap: () => onChanged(true),
            primary: primary,
          ),
          _GenderOption(
            icon: Icons.female_rounded,
            selected: !male,
            onTap: () => onChanged(false),
            primary: primary,
          ),
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.primary,
  });
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 48,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          border: selected
              ? Border.all(color: primary.withValues(alpha: 0.5), width: 1.5)
              : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: selected
              ? primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

class _CourseSearchField extends StatefulWidget {
  const _CourseSearchField({
    required this.courses,
    required this.selectedId,
    required this.onSelected,
  });

  final List<GolfCourse> courses;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  State<_CourseSearchField> createState() => _CourseSearchFieldState();
}

class _CourseSearchFieldState extends State<_CourseSearchField> {
  final _controller = TextEditingController();
  List<GolfCourse> _filtered = [];
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedId != null) {
      final match = widget.courses
          .where((c) => c.id == widget.selectedId)
          .firstOrNull;
      if (match != null) _controller.text = match.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      _showResults = q.isNotEmpty;
      _filtered = q.isEmpty
          ? []
          : widget.courses
                .where((c) => c.name.toLowerCase().contains(q))
                .take(6)
                .toList();
    });
  }

  void _select(GolfCourse course) {
    _controller.text = course.name;
    setState(() {
      _showResults = false;
      _filtered = [];
    });
    FocusScope.of(context).unfocus();
    widget.onSelected(course.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      children: [
        TextField(
          controller: _controller,
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: 'Search courses…',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _controller.clear();
                      _onChanged('');
                    },
                  )
                : null,
          ),
        ),
        if (_showResults && _filtered.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              children: _filtered.map((course) {
                final selected = course.id == widget.selectedId;
                return InkWell(
                  onTap: () => _select(course),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.golf_course_rounded,
                          size: 16,
                          color: selected
                              ? primary
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            course.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: selected ? FontWeight.w700 : null,
                              color: selected ? primary : null,
                            ),
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_rounded, size: 16, color: primary),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ] else if (_showResults && _filtered.isEmpty) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'No courses found',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
