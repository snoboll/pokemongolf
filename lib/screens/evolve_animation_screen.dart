import 'package:flutter/material.dart';

import '../models/bogeybeast_species.dart';

/// Full-screen ~5-second evolution animation.
/// Caller pushes this route; it auto-pops when the animation finishes.
/// [onEvolve] is called mid-animation (at the flash peak) so the DB write
/// happens in the background while the reveal plays.
class EvolveAnimationScreen extends StatefulWidget {
  const EvolveAnimationScreen({
    super.key,
    required this.from,
    required this.into,
    required this.onEvolve,
  });

  final BogeybeastSpecies from;
  final BogeybeastSpecies into;
  final Future<void> Function() onEvolve;

  @override
  State<EvolveAnimationScreen> createState() => _EvolveAnimationScreenState();
}

class _EvolveAnimationScreenState extends State<EvolveAnimationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _evolved = false;

  // ── interval animations (all driven by _ctrl 0→1 over 5 s) ───────────────

  // Background fades to near-black
  late final Animation<double> _bgDark;
  // Glow ring around the beast pulses in
  late final Animation<double> _glow;
  // Beast silhouette: overlay whitens the sprite
  late final Animation<double> _whiten;
  // Pulsing scale on the beast (two pulses before flash)
  late final Animation<double> _scale;
  // Full-screen white flash (in then out)
  late final Animation<double> _flashIn;
  late final Animation<double> _flashOut;
  // New beast / name reveal
  late final Animation<double> _reveal;

  static const _purple = Color(0xFF7C4DFF);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    Animation<double> interval(double begin, double end, [Curve curve = Curves.easeInOut]) =>
        CurvedAnimation(parent: _ctrl, curve: Interval(begin, end, curve: curve));

    _bgDark  = interval(0.0,  0.25, Curves.easeIn);
    _glow    = interval(0.10, 0.45, Curves.easeInOut);
    _whiten  = interval(0.30, 0.52, Curves.easeIn);
    _flashIn = interval(0.46, 0.54, Curves.easeIn);
    _flashOut= interval(0.54, 0.72, Curves.easeOut);
    _reveal  = interval(0.68, 0.90, Curves.easeOut);

    // Two-pulse scale sequence over the pre-flash window
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0),  weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.24),  weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.24, end: 1.0),  weight: 1),
    ]).animate(interval(0.05, 0.50));

    _ctrl.addListener(() {
      // Trigger the DB write at the flash peak and auto-pop when done
      if (!_evolved && _ctrl.value >= 0.54) {
        _evolved = true;
        widget.onEvolve();
      }
    });

    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        Navigator.of(context).pop();
      }
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final progress = _ctrl.value;
        final pastFlash = progress >= 0.54;

        // Combined flash opacity: rises then falls
        final flashOpacity = pastFlash ? (1.0 - _flashOut.value) : _flashIn.value;

        // Which sprite to show (swap at flash peak)
        final species = pastFlash ? widget.into : widget.from;

        return Scaffold(
          backgroundColor: Color.lerp(scaffoldBg, Colors.black87, _bgDark.value),
          body: Stack(
            children: [
              // ── Radial glow behind beast ───────────────────────────────
              if (_glow.value > 0)
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _purple.withValues(alpha: _glow.value * 0.55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Beast sprite ───────────────────────────────────────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: progress < 0.50 ? _scale.value : 1.0,
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              species.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.pets, size: 80, color: _purple),
                            ),
                            // White whiten overlay on sprite before flash
                            if (!pastFlash && _whiten.value > 0)
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: _whiten.value),
                                    borderRadius: BorderRadius.circular(80),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Evolution text reveal ────────────────────────────
                    Opacity(
                      opacity: _reveal.value,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - _reveal.value)),
                        child: Column(
                          children: [
                            Text(
                              widget.into.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'evolved!',
                              style: TextStyle(
                                color: _purple.withValues(alpha: 0.9),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Full-screen white flash ────────────────────────────────
              if (flashOpacity > 0)
                Opacity(
                  opacity: flashOpacity,
                  child: const ColoredBox(
                    color: Colors.white,
                    child: SizedBox.expand(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
