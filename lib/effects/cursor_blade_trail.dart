import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../audio/sound_fx.dart';
import '../utils/custom_colors.dart';

/// Tracks the mouse over [child] and draws a glowing katana-slash trail
/// behind it. Clicking leaves a short burst of sparks. The pointer position is
/// also published to [pointer] so the 3D scene can lean toward the cursor.
class CursorBladeTrail extends StatefulWidget {
  const CursorBladeTrail({
    super.key,
    required this.child,
    required this.pointer,
  });

  final Widget child;
  final ValueNotifier<Offset?> pointer;

  @override
  State<CursorBladeTrail> createState() => _CursorBladeTrailState();
}

class _CursorBladeTrailState extends State<CursorBladeTrail>
    with SingleTickerProviderStateMixin {
  static const _life = 0.28;
  final List<_Point> _points = [];
  final List<_Spark> _sparks = [];
  final _repaint = ValueNotifier<int>(0);
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    for (final p in _points) {
      p.age += dt;
    }
    _points.removeWhere((p) => p.age > _life);
    for (final s in _sparks) {
      s.age += dt;
      s.position += s.velocity * dt;
      s.velocity = s.velocity * 0.9 + const Offset(0, 900) * dt;
    }
    _sparks.removeWhere((s) => s.age > 0.6);
    _repaint.value++;
    if (_points.isEmpty && _sparks.isEmpty) {
      _ticker.stop();
      _last = Duration.zero;
    }
  }

  void _wake() {
    if (!_ticker.isActive) _ticker.start();
  }

  void _move(Offset position) {
    // Pointer events can arrive much faster than a frame. Keeping every
    // event makes the trail needlessly expensive to repaint and eventually
    // creates a large list during a fast mouse sweep.
    if (_points.isNotEmpty && (_points.last.position - position).distance < 4) {
      widget.pointer.value = position;
      return;
    }
    widget.pointer.value = position;
    _points.add(_Point(position));
    if (_points.length > 32) _points.removeAt(0);
    _wake();
  }

  void _burst(Offset position) {
    for (var i = 0; i < 14; i++) {
      final angle = i / 14 * 6.283 + (i.isEven ? 0.2 : 0);
      final speed = 180.0 + (i % 5) * 70;
      _sparks.add(
        _Spark(position, Offset.fromDirection(angle, speed), i % 3 == 0),
      );
    }
    _wake();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerHover: (e) => _move(e.position),
      onPointerMove: (e) => _move(e.position),
      onPointerDown: (e) {
        // Any click or tap is the user gesture browsers require for audio.
        SoundFx.unlock();
        _burst(e.position);
      },
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _TrailPainter(_points, _sparks, _life, _repaint),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Point {
  _Point(this.position);
  final Offset position;
  double age = 0;
}

class _Spark {
  _Spark(this.position, this.velocity, this.red);
  Offset position;
  Offset velocity;
  final bool red;
  double age = 0;
}

class _TrailPainter extends CustomPainter {
  _TrailPainter(this.points, this.sparks, this.life, Listenable repaint)
    : super(repaint: repaint);

  final List<_Point> points;
  final List<_Spark> sparks;
  final double life;

  @override
  void paint(Canvas canvas, Size size) {
    // Wide translucent underlay instead of a blur: blurs cost a GPU pass each.
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final core = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i < points.length; i++) {
      final a = points[i - 1], b = points[i];
      final fade = (1 - b.age / life).clamp(0.0, 1.0);
      final along = i / points.length;
      glow
        ..strokeWidth = 12 * along * fade
        ..color = CustomColors.primary.withValues(alpha: 0.25 * fade);
      core
        ..strokeWidth = 2.6 * along * fade
        ..color = Colors.white.withValues(alpha: 0.9 * fade);
      canvas.drawLine(a.position, b.position, glow);
      canvas.drawLine(a.position, b.position, core);
    }
    final spark = Paint()..strokeCap = StrokeCap.round;
    for (final s in sparks) {
      final fade = (1 - s.age / 0.6).clamp(0.0, 1.0);
      spark
        ..strokeWidth = 2.2 * fade + 0.4
        ..color = (s.red ? CustomColors.secondary : const Color(0xfffff2b0))
            .withValues(alpha: fade);
      canvas.drawLine(s.position, s.position - s.velocity * 0.03, spark);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
