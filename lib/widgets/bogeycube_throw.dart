import 'dart:math';

import 'package:flutter/material.dart';

import 'bogeybeast_art.dart';

/// A stylized Bogeycube — the game's catching device, drawn as a gray-green
/// isometric cube.
class Bogeycube extends StatelessWidget {
  const Bogeycube({super.key, this.size = 64, this.openAmount = 0});

  final double size;

  /// 0 = closed, 1 = lid fully lifted off.
  final double openAmount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BogeycubePainter(openAmount: openAmount.clamp(0.0, 1.0)),
      ),
    );
  }
}

class _BogeycubePainter extends CustomPainter {
  _BogeycubePainter({required this.openAmount});

  final double openAmount;

  static const Color _top = Color(0xFFAEB9A1);
  static const Color _left = Color(0xFF7E8B72);
  static const Color _right = Color(0xFF5B6651);
  static const Color _ink = Color(0xFF2C322A);

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final double lift = openAmount * s * 0.5;
    Offset p(double x, double y) => Offset(x * s, y * s);

    // Cube corners.
    final Offset r = p(0.94, 0.30);
    final Offset bc = p(0.5, 0.54);
    final Offset l = p(0.06, 0.30);
    final Offset b = p(0.5, 0.94);
    final Offset bl = p(0.06, 0.70);
    final Offset br = p(0.94, 0.70);

    // The top face acts as a lid that lifts straight up when opening.
    final Offset tLid = p(0.5, 0.06).translate(0, -lift);
    final Offset rLid = r.translate(0, -lift);
    final Offset bcLid = bc.translate(0, -lift);
    final Offset lLid = l.translate(0, -lift);

    Paint fill(Color c) => Paint()..color = c;
    Paint stroke(double alpha) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.05
      ..strokeJoin = StrokeJoin.round
      ..color = _ink.withValues(alpha: alpha);

    // Left face.
    final Path leftFace = Path()..addPolygon(<Offset>[l, bc, b, bl], true);
    canvas.drawPath(leftFace, fill(_left));
    canvas.drawPath(leftFace, stroke(1));

    // Right face.
    final Path rightFace = Path()..addPolygon(<Offset>[bc, r, br, b], true);
    canvas.drawPath(rightFace, fill(_right));
    canvas.drawPath(rightFace, stroke(1));

    // Top face / lid.
    final double lidAlpha = (1 - openAmount * 0.55).clamp(0.0, 1.0);
    final Path topFace = Path()
      ..addPolygon(<Offset>[tLid, rLid, bcLid, lLid], true);
    canvas.drawPath(topFace, fill(_top.withValues(alpha: lidAlpha)));
    canvas.drawPath(topFace, stroke(lidAlpha));
  }

  @override
  bool shouldRepaint(_BogeycubePainter old) => old.openAmount != openAmount;
}

/// Full-screen "throw a Bogeycube" sequence: the cube is hurled in from the
/// bottom, the beast is drawn in, the cube wobbles three times, then either
/// snaps shut (caught) or bursts open and lets the beast pop back out.
class BogeycubeThrowOverlay extends StatefulWidget {
  const BogeycubeThrowOverlay({
    super.key,
    required this.caught,
    required this.beastAssetPath,
    required this.beastName,
    required this.onComplete,
  });

  final bool caught;
  final String beastAssetPath;
  final String beastName;
  final VoidCallback onComplete;

  @override
  State<BogeycubeThrowOverlay> createState() => _BogeycubeThrowOverlayState();
}

class _BogeycubeThrowOverlayState extends State<BogeycubeThrowOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _c.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) widget.onComplete();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _seg(double v, double a, double b) =>
      ((v - a) / (b - a)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _c,
      builder: (BuildContext context, _) {
        final double v = _c.value;

        final double throwT = _seg(v, 0.0, 0.24);
        final double absorbT = _seg(v, 0.24, 0.36);
        final double wobbleT = _seg(v, 0.36, 0.80);
        final double resultT = _seg(v, 0.80, 1.0);

        // The cube is hurled up from the bottom-left toward the beast.
        final double throwEase = Curves.easeOutCubic.transform(throwT);
        final double cubeY = (1 - throwEase) * 460;
        final double cubeX = (1 - throwEase) * -120;

        // Spins twice mid-flight, then settles upright.
        double cubeRot = (1 - throwEase) * 4 * pi;
        // Three decaying wobbles once the beast is inside.
        if (wobbleT > 0 && wobbleT < 1) {
          cubeRot = sin(wobbleT * pi * 6) * 0.34 * (1 - wobbleT * 0.6);
        } else if (wobbleT >= 1) {
          cubeRot = 0;
        }

        // Beast shrinks into the cube, then pops back out on a break-free.
        double beastScale = 1.0 - absorbT;
        double beastOpacity = 1.0 - absorbT;
        if (!widget.caught && resultT > 0) {
          beastScale = Curves.easeOutBack.transform(resultT);
          beastOpacity = resultT;
        }

        double cubeScale = 0.6 + 0.4 * throwEase;
        double openAmount = 0;
        double cubeOpacity = throwT;
        if (widget.caught) {
          if (resultT > 0) cubeScale = 1 + sin(resultT * pi) * 0.14;
        } else if (resultT > 0) {
          openAmount = Curves.easeOut.transform(_seg(resultT, 0.0, 0.5));
          cubeOpacity = 1 - _seg(resultT, 0.35, 1.0);
        }

        final double flash = (absorbT > 0 && absorbT < 1)
            ? sin(absorbT * pi)
            : 0.0;

        return SizedBox.expand(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Transform.scale(
                scale: beastScale.clamp(0.0, 1.2),
                child: Opacity(
                  opacity: beastOpacity.clamp(0.0, 1.0),
                  child: BogeybeastArt(
                    assetPath: widget.beastAssetPath,
                    height: 210,
                  ),
                ),
              ),
              if (flash > 0)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.white.withValues(alpha: flash * 0.7),
                  ),
                ),
              if (widget.caught && resultT > 0)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SparklePainter(progress: resultT),
                  ),
                ),
              Transform.translate(
                offset: Offset(cubeX, cubeY),
                child: Transform.rotate(
                  angle: cubeRot,
                  child: Transform.scale(
                    scale: cubeScale,
                    child: Opacity(
                      opacity: cubeOpacity.clamp(0.0, 1.0),
                      child: Bogeycube(size: 104, openAmount: openAmount),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final double opacity = (1 - progress).clamp(0.0, 1.0);
    if (opacity <= 0) return;

    final Offset c = size.center(Offset.zero);
    final double p = Curves.easeOut.transform(progress);
    final double maxR = size.shortestSide * 0.34;
    final Paint paint = Paint()
      ..color = const Color(0xFFFFE066).withValues(alpha: opacity);

    const int count = 8;
    for (int i = 0; i < count; i++) {
      final double a = (i / count) * 2 * pi;
      final Offset pos = c + Offset(cos(a), sin(a)) * (p * maxR);
      final double starS = (5 + (i % 3) * 3) * (1 - progress * 0.5);
      _drawStar(canvas, pos, starS, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset c, double s, Paint paint) {
    final Path star = Path()
      ..moveTo(c.dx, c.dy - s)
      ..lineTo(c.dx + s * 0.3, c.dy)
      ..lineTo(c.dx, c.dy + s)
      ..lineTo(c.dx - s * 0.3, c.dy)
      ..close()
      ..moveTo(c.dx - s, c.dy)
      ..lineTo(c.dx, c.dy + s * 0.3)
      ..lineTo(c.dx + s, c.dy)
      ..lineTo(c.dx, c.dy - s * 0.3)
      ..close();
    canvas.drawPath(star, paint);
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.progress != progress;
}
