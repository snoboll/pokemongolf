import 'package:flutter/material.dart';

import '../models/golf_score.dart';

const List<GolfScore> selectableScores = <GolfScore>[
  GolfScore.eagle,
  GolfScore.birdie,
  GolfScore.par,
  GolfScore.bogey,
  GolfScore.doubleBogey,
  GolfScore.tripleOrWorse,
];

class ScorePicker extends StatelessWidget {
  const ScorePicker({
    super.key,
    required this.par,
    required this.selected,
    required this.onChanged,
  });

  final int par;
  final GolfScore selected;
  final ValueChanged<GolfScore> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: selectableScores
          .map(
            (score) => Expanded(
              child: GestureDetector(
                onTap: () => onChanged(score),
                child: _ScoreButton(
                  score: score,
                  par: par,
                  isSelected: selected == score,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

String _pickerLabel(GolfScore score) {
  return switch (score) {
    GolfScore.eagle => 'Eagle',
    GolfScore.birdie => 'Birdie',
    GolfScore.par => 'Par',
    GolfScore.bogey => 'Bogey',
    GolfScore.doubleBogey => 'Double',
    GolfScore.tripleOrWorse => 'Trpl+',
    GolfScore.albatross => 'Albt',
  };
}

class _ScoreButton extends StatelessWidget {
  const _ScoreButton({
    required this.score,
    required this.par,
    required this.isSelected,
  });

  final GolfScore score;
  final int par;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool underPar = score.relativeToPar < 0;
    final bool overPar = score.relativeToPar > 0;
    final Color activeColor = isSelected
        ? (underPar
            ? const Color(0xFF4CAF50)
            : overPar
                ? const Color(0xFFE57373)
                : theme.colorScheme.primary)
        : theme.colorScheme.onSurface.withValues(alpha: 0.4);

    final int strokes = par + score.relativeToPar;
    final String strokesLabel =
        score == GolfScore.tripleOrWorse ? '$strokes+' : '$strokes';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? activeColor.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? activeColor.withValues(alpha: 0.4) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 44,
            height: 44,
            child: CustomPaint(
              painter: _ScoreNotationPainter(
                score: score,
                strokesLabel: strokesLabel,
                color: activeColor,
                isSelected: isSelected,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _pickerLabel(score),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: activeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreNotationPainter extends CustomPainter {
  _ScoreNotationPainter({
    required this.score,
    required this.strokesLabel,
    required this.color,
    required this.isSelected,
  });

  final GolfScore score;
  final String strokesLabel;
  final Color color;
  final bool isSelected;

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double strokeWidth = isSelected ? 2.0 : 1.5;

    final Paint borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final int rel = score.relativeToPar;

    if (rel < 0) {
      final int circleCount = rel.abs().clamp(1, 2);
      // inner radius=12 (diam 24), outer radius=16 (diam 32) → 6px margin in 44px box
      const double baseRadius = 12;
      const double radiusStep = 4;
      for (int i = 0; i < circleCount; i++) {
        canvas.drawCircle(
          Offset(cx, cy),
          baseRadius + (i * radiusStep),
          borderPaint,
        );
      }
    } else if (rel > 0) {
      final int squareCount = rel.clamp(1, 2);
      // inner half=11 (22px), outer half=15 (30px) → 7px margin in 44px box
      const double baseHalf = 11;
      const double halfStep = 4;
      for (int i = 0; i < squareCount; i++) {
        final double half = baseHalf + (i * halfStep);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx, cy),
              width: half * 2,
              height: half * 2,
            ),
            const Radius.circular(3),
          ),
          borderPaint,
        );
      }
    }

    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: strokesLabel,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_ScoreNotationPainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.strokesLabel != strokesLabel ||
        oldDelegate.color != color ||
        oldDelegate.isSelected != isSelected;
  }
}
