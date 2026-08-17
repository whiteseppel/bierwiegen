import 'package:flutter/material.dart';

/// A tapered beer glass filled from the bottom to [fillFraction] (0–1), with a
/// foam cap on the beer. Changes to [fillFraction] animate over [duration];
/// pass [Duration.zero] when the caller already animates the value.
class BeerGlass extends StatelessWidget {
  const BeerGlass({
    super.key,
    required this.fillFraction,
    this.duration = Duration.zero,
  });

  final double fillFraction;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (duration == Duration.zero) {
      return CustomPaint(painter: _BeerGlassPainter(fill: fillFraction));
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(end: fillFraction),
      duration: duration,
      curve: Curves.easeOut,
      builder:
          (context, fill, _) =>
              CustomPaint(painter: _BeerGlassPainter(fill: fill)),
    );
  }
}

class _BeerGlassPainter extends CustomPainter {
  const _BeerGlassPainter({required this.fill});

  final double fill;

  static const _rimHeight = 12.0;
  static const _bodyTop = 7.0;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bodyHeight = h - _bodyTop;
    final body = _bodyPath(w, h);

    canvas.save();
    canvas.clipPath(body);

    final bodyRect = Rect.fromLTRB(0, _bodyTop, w, h);
    canvas.drawRect(
      bodyRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFEDEDE7),
            Color(0xFFFAFAF7),
            Color(0xFFF1F1EC),
            Color(0xFFE7E7E1),
          ],
          stops: [0, .32, .70, 1],
        ).createShader(bodyRect),
    );

    if (fill > 0) {
      final fillTop = _bodyTop + bodyHeight * (1 - fill);
      final fillRect = Rect.fromLTRB(0, fillTop, w, h);
      canvas.drawRect(
        fillRect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFC44C), Color(0xFFF0A020), Color(0xFFD9880F)],
            stops: [0, .55, 1],
          ).createShader(fillRect),
      );
      _bubbles(canvas, fillRect, const [
        (.26, .24, 2.5, Color(0x80FFFFFF)),
        (.63, .46, 2.0, Color(0x6BFFFFFF)),
        (.38, .70, 1.5, Color(0x61FFFFFF)),
        (.74, .82, 2.0, Color(0x52FFFFFF)),
      ]);

      final foamRect = Rect.fromLTRB(-3, fillTop - 11, w + 3, fillTop + 11);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          foamRect,
          topLeft: Radius.elliptical(
            foamRect.width * .60,
            foamRect.height * .74,
          ),
          topRight: Radius.elliptical(
            foamRect.width * .52,
            foamRect.height * .70,
          ),
          bottomRight: Radius.elliptical(
            foamRect.width * .46,
            foamRect.height * .30,
          ),
          bottomLeft: Radius.elliptical(
            foamRect.width * .50,
            foamRect.height * .26,
          ),
        ).scaleRadii(),
        Paint()..color = const Color(0xFFFFFCF4),
      );
      _bubbles(canvas, Rect.fromLTWH(0, fillTop - 8, w - 4, 10), const [
        (.16, .62, 3.5, Color(0xFFFFFEFA)),
        (.44, .26, 5.0, Color(0xFFFFFFFF)),
        (.70, .66, 3.0, Color(0xFFFFF8EA)),
        (.88, .34, 4.0, Color(0xFFFFFDF7)),
      ]);
    }

    canvas.drawRect(
      bodyRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xB3FFFFFF),
            Color(0xB3FFFFFF),
            Color(0x2EFFFFFF),
            Color(0x2EFFFFFF),
            Color(0x00FFFFFF),
            Color(0x00FFFFFF),
            Color(0x73FFFFFF),
            Color(0x73FFFFFF),
            Color(0x00FFFFFF),
            Color(0x00FFFFFF),
            Color(0x4DFFFFFF),
            Color(0x4DFFFFFF),
          ],
          stops: [0, .04, .04, .11, .11, .70, .70, .79, .79, .92, .92, 1],
        ).createShader(bodyRect),
    );
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x14000000),
    );

    canvas.restore();

    final rimRect = Rect.fromLTWH(w * .03, 1, w * .94, _rimHeight);
    canvas.drawOval(rimRect, Paint()..color = const Color(0x99FFFFFF));
    canvas.drawOval(
      rimRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x21000000),
    );
  }

  /// Trapezoid from 3–97% wide at the rim to 10–90% at the base, with lightly
  /// rounded top and rounder bottom corners.
  Path _bodyPath(double w, double h) {
    final tl = Offset(w * .03, _bodyTop);
    final tr = Offset(w * .97, _bodyTop);
    final br = Offset(w * .90, h);
    final bl = Offset(w * .10, h);
    return Path()
      ..moveTo(tl.dx + 2, tl.dy)
      ..lineTo(tr.dx - 2, tr.dy)
      ..quadraticBezierTo(tr.dx, tr.dy, _along(tr, br, 2).dx, _along(tr, br, 2).dy)
      ..lineTo(_along(br, tr, 12).dx, _along(br, tr, 12).dy)
      ..quadraticBezierTo(br.dx, br.dy, br.dx - 12, br.dy)
      ..lineTo(bl.dx + 12, bl.dy)
      ..quadraticBezierTo(bl.dx, bl.dy, _along(bl, tl, 12).dx, _along(bl, tl, 12).dy)
      ..lineTo(_along(tl, bl, 2).dx, _along(tl, bl, 2).dy)
      ..quadraticBezierTo(tl.dx, tl.dy, tl.dx + 2, tl.dy)
      ..close();
  }

  static Offset _along(Offset from, Offset to, double distance) {
    return from + (to - from) / (to - from).distance * distance;
  }

  void _bubbles(
    Canvas canvas,
    Rect area,
    List<(double, double, double, Color)> specs,
  ) {
    for (final (x, y, radius, color) in specs) {
      canvas.drawCircle(
        Offset(area.left + area.width * x, area.top + area.height * y),
        radius,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_BeerGlassPainter old) => old.fill != fill;
}
