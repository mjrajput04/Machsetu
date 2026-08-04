import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Slow-drifting colour blooms behind everything else.
class AuroraPainter extends CustomPainter {
  AuroraPainter(this.t);

  /// Ambient clock, 0..1, repeating.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final angle = t * 2 * math.pi;

    void bloom(Offset centre, double radius, Color color) {
      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: centre, radius: radius)),
      );
    }

    bloom(
      Offset(
        size.width * (0.28 + 0.10 * math.sin(angle)),
        size.height * (0.24 + 0.05 * math.cos(angle)),
      ),
      size.width * 0.62,
      AppColors.accent.withValues(alpha: 0.16),
    );
    bloom(
      Offset(
        size.width * (0.78 + 0.08 * math.cos(angle * 0.8)),
        size.height * (0.68 + 0.06 * math.sin(angle * 1.2)),
      ),
      size.width * 0.70,
      AppColors.brandBlue.withValues(alpha: 0.22),
    );
    bloom(
      Offset(
        size.width * (0.5 + 0.14 * math.sin(angle * 0.6)),
        size.height * 0.92,
      ),
      size.width * 0.55,
      AppColors.accentGlow.withValues(alpha: 0.10),
    );
  }

  @override
  bool shouldRepaint(covariant AuroraPainter oldDelegate) =>
      oldDelegate.t != t;
}

/// Technical grid that drifts upward and fades toward the horizon.
class DriftGridPainter extends CustomPainter {
  DriftGridPainter(this.t, {this.opacity = 1});

  final double t;
  final double opacity;

  static const double step = 46;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05 * opacity)
      ..strokeWidth = 1;

    final offset = (t * step) % step;

    for (var x = -step; x < size.width + step; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = -step + offset; y < size.height + step; y += step) {
      // Lines dim as they approach the vertical centre, giving depth.
      final depth = 1 - (y / size.height - 0.5).abs() * 1.4;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = Colors.white.withValues(
            alpha: 0.06 * opacity * depth.clamp(0.15, 1),
          )
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DriftGridPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.opacity != opacity;
}

/// The badge behind the logo: a hexagon and rings that draw themselves in,
/// then keep breathing and rotating.
class MarkPainter extends CustomPainter {
  MarkPainter({
    required this.draw,
    required this.spin,
    required this.pulse,
  });

  /// 0..1 stroke-drawing progress for the intro.
  final double draw;

  /// 0..1 ambient rotation clock.
  final double spin;

  /// 0..1 breathing clock.
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = size.height / 2;

    // Soft halo that breathes with the pulse.
    canvas.drawCircle(
      centre,
      radius * (0.92 + pulse * 0.08),
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.16 * draw),
            AppColors.accent.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: centre, radius: radius)),
    );

    _drawPath(canvas, _hexagon(centre, radius * 0.94), draw, 1.4,
        AppColors.steelLight.withValues(alpha: 0.55));
    _drawPath(canvas, _hexagon(centre, radius * 0.72), draw, 1,
        Colors.white.withValues(alpha: 0.10));
    _drawPath(
      canvas,
      Path()..addOval(Rect.fromCircle(center: centre, radius: radius * 0.60)),
      draw,
      1,
      Colors.white.withValues(alpha: 0.12),
    );

    // Rotating dashed arc — the "scanning" ring.
    final sweepRect = Rect.fromCircle(center: centre, radius: radius * 0.99);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4
      ..color = AppColors.accent.withValues(alpha: 0.85 * draw);

    for (var i = 0; i < 3; i++) {
      final start = spin * 2 * math.pi + i * (2 * math.pi / 3);
      canvas.drawArc(sweepRect, start, 0.42 * draw, false, arcPaint);
    }

    // Tick marks around the rim.
    final tick = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.22 * draw);
    for (var i = 0; i < 24; i++) {
      final angle = (math.pi / 12) * i;
      final long = i % 6 == 0;
      final outer = radius * 1.06;
      final inner = outer - (long ? 10 : 5);
      canvas.drawLine(
        centre + Offset(math.cos(angle), math.sin(angle)) * inner,
        centre + Offset(math.cos(angle), math.sin(angle)) * outer,
        tick,
      );
    }
  }

  Path _hexagon(Offset centre, double radius) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final point = centre + Offset(math.cos(angle), math.sin(angle)) * radius;
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  /// Traces [path] from 0 to [progress] of its length.
  void _drawPath(
    Canvas canvas,
    Path path,
    double progress,
    double width,
    Color color,
  ) {
    if (progress <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..color = color;

    for (final metric in path.computeMetrics()) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * progress),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MarkPainter oldDelegate) =>
      oldDelegate.draw != draw ||
      oldDelegate.spin != spin ||
      oldDelegate.pulse != pulse;
}
