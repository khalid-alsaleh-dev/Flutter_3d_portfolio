import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';

/// Stylized artwork for a project: a phone, tilted in 3D, showing a sketch of
/// the app's main screen. Client apps can't show real screenshots, so this
/// conveys the kind of product without exposing anyone's data.
class AppMockup extends StatelessWidget {
  const AppMockup({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final accent = project.accent;
    return LayoutBuilder(
      builder: (context, c) {
        final phoneHeight = c.maxHeight * 0.8;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.35, -0.2),
              radius: 1.1,
              colors: [accent.withValues(alpha: 0.35), const Color(0xff10131b)],
            ),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: -c.maxHeight * 0.12,
                bottom: -c.maxHeight * 0.18,
                child: Icon(
                  project.icon,
                  size: c.maxHeight * 0.75,
                  color: accent.withValues(alpha: 0.12),
                ),
              ),
              Align(
                alignment: const Alignment(0.45, 0.1),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0016)
                    ..rotateY(-0.5)
                    ..rotateX(0.18)
                    ..rotateZ(0.05),
                  child: SizedBox(
                    height: phoneHeight,
                    width: phoneHeight * 0.5,
                    child: CustomPaint(
                      painter: _PhonePainter(
                        project.layout,
                        accent,
                        project.icon,
                      ),
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

class _PhonePainter extends CustomPainter {
  _PhonePainter(this.layout, this.accent, this.icon);

  final MockLayout layout;
  final Color accent;
  final IconData icon;

  static const _ink = Color(0xff1b2030);
  static const _line = Color(0xff2a3042);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Body, bezel and screen.
    final body = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(w * 0.15),
    );
    canvas.drawShadow(Path()..addRRect(body), Colors.black, 18, false);
    canvas.drawRRect(body, Paint()..color = const Color(0xff07080c));
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xff5b6470),
    );
    final screen = Rect.fromLTWH(w * 0.05, w * 0.05, w * 0.9, h - w * 0.1);
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(screen, Radius.circular(w * 0.11)),
    );
    canvas.drawRect(screen, Paint()..color = const Color(0xff11141c));
    canvas.translate(screen.left, screen.top);
    _paintScreen(canvas, screen.size);
    canvas.restore();
    // Dynamic-island style notch.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w / 2, w * 0.12),
          width: w * 0.28,
          height: w * 0.065,
        ),
        Radius.circular(w),
      ),
      Paint()..color = Colors.black,
    );
  }

  void _paintScreen(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final pad = w * 0.07;
    // App bar.
    final barH = h * 0.17;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, barH),
      Paint()
        ..shader = LinearGradient(
          colors: [accent, Color.lerp(accent, Colors.black, 0.35)!],
        ).createShader(Rect.fromLTWH(0, 0, w, barH)),
    );
    _bar(
      canvas,
      Rect.fromLTWH(pad, barH * 0.5, w * 0.45, barH * 0.12),
      Colors.white,
    );
    _bar(
      canvas,
      Rect.fromLTWH(pad, barH * 0.72, w * 0.3, barH * 0.08),
      Colors.white.withValues(alpha: 0.6),
    );
    _icon(
      canvas,
      Offset(w - pad - barH * 0.2, barH * 0.6),
      barH * 0.36,
      Colors.white,
    );

    final top = barH + pad;
    switch (layout) {
      case MockLayout.dashboard:
        _dashboard(canvas, s, top, pad);
      case MockLayout.live:
        _live(canvas, s, top, pad);
      case MockLayout.deals:
        _deals(canvas, s, top, pad);
      case MockLayout.shop:
        _shop(canvas, s, top, pad);
      case MockLayout.course:
        _course(canvas, s, top, pad);
    }
  }

  void _course(Canvas canvas, Size s, double top, double pad) {
    final w = s.width;
    // Video player with a play button and a watched-progress bar.
    final player = Rect.fromLTWH(pad, top, w - pad * 2, (w - pad * 2) * 0.58);
    canvas.drawRRect(
      RRect.fromRectAndRadius(player, Radius.circular(w * 0.05)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.55), _ink],
        ).createShader(player),
    );
    final c = player.center;
    final r = player.height * 0.17;
    canvas.drawCircle(
      c,
      r,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - r * 0.3, c.dy - r * 0.45)
        ..lineTo(c.dx + r * 0.5, c.dy)
        ..lineTo(c.dx - r * 0.3, c.dy + r * 0.45)
        ..close(),
      Paint()..color = accent,
    );
    final track = Rect.fromLTWH(
      player.left + pad * 0.6,
      player.bottom - pad * 0.9,
      player.width - pad * 1.2,
      w * 0.018,
    );
    _bar(canvas, track, Colors.white.withValues(alpha: 0.25));
    _bar(
      canvas,
      Rect.fromLTWH(track.left, track.top, track.width * 0.62, track.height),
      accent,
    );

    // Lessons, each with its own progress.
    final rowH = w * 0.2;
    var y = player.bottom + pad;
    for (var i = 0; i < 5 && y + rowH <= s.height; i++, y += rowH + pad * 0.5) {
      final row = Rect.fromLTWH(pad, y, w - pad * 2, rowH);
      _card(canvas, row);
      final thumb = Rect.fromLTWH(
        row.left + rowH * 0.15,
        row.top + rowH * 0.15,
        rowH * 0.9,
        rowH * 0.7,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(thumb, Radius.circular(w * 0.02)),
        Paint()..color = accent.withValues(alpha: 0.2 + 0.1 * (i % 3)),
      );
      _bar(
        canvas,
        Rect.fromLTWH(
          thumb.right + pad * 0.5,
          row.top + rowH * 0.25,
          row.width * 0.45,
          rowH * 0.13,
        ),
        Colors.white.withValues(alpha: 0.75),
      );
      final prog = Rect.fromLTWH(
        thumb.right + pad * 0.5,
        row.top + rowH * 0.6,
        row.width * 0.5,
        rowH * 0.09,
      );
      _bar(canvas, prog, Colors.white.withValues(alpha: 0.15));
      _bar(
        canvas,
        Rect.fromLTWH(
          prog.left,
          prog.top,
          prog.width * [1.0, 0.8, 0.45, 0.2, 0.05][i],
          prog.height,
        ),
        accent,
      );
    }
  }

  void _dashboard(Canvas canvas, Size s, double top, double pad) {
    final w = s.width;
    final tile = (w - pad * 3) / 2;
    for (var i = 0; i < 4; i++) {
      final r = Rect.fromLTWH(
        pad + (i % 2) * (tile + pad),
        top + (i ~/ 2) * (tile * 0.62 + pad),
        tile,
        tile * 0.62,
      );
      _card(canvas, r);
      _bar(
        canvas,
        Rect.fromLTWH(
          r.left + r.width * 0.12,
          r.top + r.height * 0.25,
          r.width * 0.5,
          r.height * 0.12,
        ),
        Colors.white.withValues(alpha: 0.5),
      );
      _bar(
        canvas,
        Rect.fromLTWH(
          r.left + r.width * 0.12,
          r.top + r.height * 0.55,
          r.width * 0.3,
          r.height * 0.2,
        ),
        i == 0 ? accent : Colors.white.withValues(alpha: 0.85),
      );
    }
    _rows(canvas, s, top + 2 * (tile * 0.62 + pad), pad, 4);
  }

  void _live(Canvas canvas, Size s, double top, double pad) {
    final w = s.width;
    final chart = Rect.fromLTWH(pad, top, w - pad * 2, w * 0.62);
    _card(canvas, chart);
    final path = Path();
    for (var i = 0; i <= 12; i++) {
      final x = chart.left + chart.width * (0.06 + 0.88 * i / 12);
      final y =
          chart.top +
          chart.height *
              (0.7 -
                  0.4 * (0.5 + 0.5 * math.sin(i * 0.9) * math.cos(i * 0.35)));
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.018
        ..strokeJoin = StrokeJoin.round
        ..color = accent,
    );
    _rows(canvas, s, chart.bottom + pad, pad, 5, status: true);
  }

  void _deals(Canvas canvas, Size s, double top, double pad) {
    final w = s.width;
    final cardH = w * 0.48;
    for (var i = 0; i < 3; i++) {
      final r = Rect.fromLTWH(pad, top + i * (cardH + pad), w - pad * 2, cardH);
      _card(canvas, r);
      final img = Rect.fromLTWH(
        r.left + pad * 0.6,
        r.top + pad * 0.6,
        r.height - pad * 1.2,
        r.height - pad * 1.2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(img, Radius.circular(w * 0.04)),
        Paint()..color = accent.withValues(alpha: 0.25 + 0.2 * i),
      );
      _bar(
        canvas,
        Rect.fromLTWH(
          img.right + pad * 0.6,
          img.top + img.height * 0.1,
          r.width * 0.38,
          img.height * 0.14,
        ),
        Colors.white.withValues(alpha: 0.85),
      );
      _bar(
        canvas,
        Rect.fromLTWH(
          img.right + pad * 0.6,
          img.top + img.height * 0.42,
          r.width * 0.26,
          img.height * 0.12,
        ),
        Colors.white.withValues(alpha: 0.4),
      );
      // Discount badge.
      final badge = Rect.fromLTWH(
        img.right + pad * 0.6,
        img.bottom - img.height * 0.3,
        r.width * 0.2,
        img.height * 0.3,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(badge, Radius.circular(w)),
        Paint()..color = accent,
      );
    }
  }

  void _shop(Canvas canvas, Size s, double top, double pad) {
    final w = s.width, h = s.height;
    final tile = (w - pad * 3) / 2;
    for (var i = 0; i < 4; i++) {
      final r = Rect.fromLTWH(
        pad + (i % 2) * (tile + pad),
        top + (i ~/ 2) * (tile * 1.3 + pad),
        tile,
        tile * 1.3,
      );
      _card(canvas, r);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            r.left + tile * 0.08,
            r.top + tile * 0.08,
            tile * 0.84,
            tile * 0.75,
          ),
          Radius.circular(w * 0.03),
        ),
        Paint()..color = accent.withValues(alpha: 0.2 + 0.12 * i),
      );
      _bar(
        canvas,
        Rect.fromLTWH(
          r.left + tile * 0.1,
          r.top + tile * 0.93,
          tile * 0.6,
          tile * 0.08,
        ),
        Colors.white.withValues(alpha: 0.7),
      );
      _bar(
        canvas,
        Rect.fromLTWH(
          r.left + tile * 0.1,
          r.top + tile * 1.08,
          tile * 0.35,
          tile * 0.09,
        ),
        accent,
      );
    }
    // Bottom navigation.
    final nav = Rect.fromLTWH(0, h - w * 0.2, w, w * 0.2);
    canvas.drawRect(nav, Paint()..color = _ink);
    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(w * (0.15 + 0.233 * i), nav.center.dy),
        w * 0.03,
        Paint()..color = i == 0 ? accent : Colors.white.withValues(alpha: 0.35),
      );
    }
  }

  void _rows(
    Canvas canvas,
    Size s,
    double top,
    double pad,
    int count, {
    bool status = false,
  }) {
    final w = s.width;
    final rowH = w * 0.2;
    for (var i = 0; i < count; i++) {
      final y = top + i * (rowH + pad * 0.5);
      if (y + rowH > s.height) break;
      final r = Rect.fromLTWH(pad, y, w - pad * 2, rowH);
      _card(canvas, r);
      canvas.drawCircle(
        Offset(r.left + rowH * 0.5, r.center.dy),
        rowH * 0.26,
        Paint()..color = Colors.white.withValues(alpha: 0.18),
      );
      _bar(
        canvas,
        Rect.fromLTWH(
          r.left + rowH,
          r.top + rowH * 0.28,
          r.width * 0.45,
          rowH * 0.14,
        ),
        Colors.white.withValues(alpha: 0.75),
      );
      _bar(
        canvas,
        Rect.fromLTWH(
          r.left + rowH,
          r.top + rowH * 0.56,
          r.width * 0.3,
          rowH * 0.11,
        ),
        Colors.white.withValues(alpha: 0.35),
      );
      if (status) {
        canvas.drawCircle(
          Offset(r.right - rowH * 0.4, r.center.dy),
          rowH * 0.11,
          Paint()
            ..color = i == 2
                ? const Color(0xffDF504A)
                : const Color(0xff6AE99F),
        );
      }
    }
  }

  void _card(Canvas canvas, Rect r) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, Radius.circular(r.shortestSide * 0.16)),
      Paint()..color = _ink,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, Radius.circular(r.shortestSide * 0.16)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = _line,
    );
  }

  void _bar(Canvas canvas, Rect r, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, Radius.circular(r.height)),
      Paint()..color = color,
    );
  }

  void _icon(Canvas canvas, Offset center, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _PhonePainter old) =>
      old.layout != layout || old.accent != accent || old.icon != icon;
}
