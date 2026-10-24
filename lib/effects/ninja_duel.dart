import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../audio/sound_fx.dart';
import '../utils/custom_colors.dart';
import 'scroll_progress.dart';

/// Sprite sheet info for one ninja animation: file name pattern, source size
/// and where the body sits horizontally (0..1) so wide attack frames line up.
class _Anim {
  const _Anim(this.pattern, this.width, this.height, this.anchor);
  final String Function(int frame) pattern;
  final double width;
  final double height;
  final double anchor;

  String frame(int i) => 'assets/images/sprites/${pattern(i.clamp(0, 9))}';
}

class NinjaSprites {
  static final idleRight = _Anim((i) => 'Idle$i.webp', 232, 439, 0.5);
  static final idleLeft = _Anim((i) => 'IdleLeft$i.webp', 232, 439, 0.5);
  static final runRight = _Anim((i) => 'RunRight__00$i.webp', 363, 434, 0.5);
  static final runLeft = _Anim((i) => 'RunLeft__00$i.webp', 363, 434, 0.5);
  static final jumpRight = _Anim((i) => 'JumpRight$i.webp', 362, 464, 0.5);
  static final jumpLeft = _Anim((i) => 'JumpLeft$i.webp', 362, 464, 0.5);
  static final attackRight = _Anim((i) => 'Attack$i.webp', 536, 453, 0.24);
  static final attackLeft = _Anim((i) => 'AttackLeft$i.webp', 536, 453, 0.76);

  static final all = [
    idleRight,
    idleLeft,
    runRight,
    runLeft,
    jumpRight,
    jumpLeft,
    attackRight,
    attackLeft,
  ];

  /// Decodes every frame up front so scrubbing never flickers.
  static Future<void> precache(BuildContext context) async {
    await Future.wait([
      for (final anim in all)
        for (var i = 0; i < 10; i++)
          precacheImage(AssetImage(anim.frame(i)), context),
    ]);
  }
}

/// A pose for one fighter at one instant of the duel.
class _Pose {
  const _Pose(
    this.anim,
    this.frame,
    this.x,
    this.lift, {
    this.opacity = 1,
    this.split = 0,
  });
  final _Anim anim;
  final int frame;
  final double x; // body centre, 0..1 of stage width
  final double lift; // height above ground, 0..1 of stage height
  final double opacity;
  final double split; // 0..1: the defeated fighter falling apart
}

/// A tall section whose stage stays pinned while you scroll through it. The
/// whole fight is a pure function of scroll position.
class NinjaDuel extends StatefulWidget {
  const NinjaDuel({super.key});

  @override
  State<NinjaDuel> createState() => _NinjaDuelState();
}

class _NinjaDuelState extends State<NinjaDuel> {
  static const double _scrollScreens = 3.2;

  /// Sound cues: (moment in the fight, sound, volume). Each fires when the
  /// scroll moves forward past its moment.
  static const _cues = [
    (0.22, SoundFx.jump, 0.6), // both fighters leap
    (0.31, SoundFx.sword, 1.0), // mid-air clash
    (0.405, SoundFx.sword, 0.8), // strike exchange
    (0.505, SoundFx.sword, 0.8),
    (0.605, SoundFx.sword, 0.8),
    (0.70, SoundFx.sword, 1.0), // the dash cut
    (0.82, SoundFx.cut, 0.9), // the rival falls apart
  ];

  double _lastQ = 0;

  void _cue(double q) {
    final from = _lastQ;
    _lastQ = q;
    // Only forward motion plays sounds, and a big jump (a nav click flying
    // past the whole fight) stays silent rather than firing every cue at once.
    if (q <= from || q - from > 0.12) return;
    for (final (at, sound, volume) in _cues) {
      if (from < at && at <= q) SoundFx.play(sound, volume: volume);
    }
  }

  /// How far through the pinned fight we are, from the section's progress.
  static double _fight(double p, double vh, double total) {
    final top = vh - p * (vh + total);
    final pinned = (-top).clamp(0.0, total - vh);
    return (pinned / (total - vh)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final vh = MediaQuery.sizeOf(context).height;
    final total = vh * _scrollScreens;
    return SizedBox(
      height: total,
      child: ScrollProgress(
        onProgress: (p) => _cue(_fight(p, vh, total)),
        builder: (context, p, _) {
          // Where the section's top is relative to the viewport top.
          final top = vh - p * (vh + total);
          final pinned = (-top).clamp(0.0, total - vh);
          final q = _fight(p, vh, total);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: pinned,
                left: 0,
                right: 0,
                height: vh,
                child: _DuelStage(q: q),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DuelStage extends StatelessWidget {
  const _DuelStage({required this.q});
  final double q;

  // Choreography windows (fractions of the pinned scroll).
  static const _runEnd = 0.22;
  static const _jumpEnd = 0.32;
  static const _clash1 = 0.31;
  static const _strikes = [
    (0.36, 0.45, true),
    (0.46, 0.55, false),
    (0.56, 0.64, true),
  ];
  static const _dashStart = 0.67, _dashEnd = 0.76;
  static const _splitStart = 0.8;

  (_Pose hero, _Pose rival) _poses() {
    // Phase 1: both sprint in.
    if (q < _runEnd) {
      final t = interval(q, 0, _runEnd);
      final hx = -0.1 + t * 0.42;
      final rx = 1.1 - t * 0.42;
      final frame = (t * 34).floor() % 10;
      return (
        _Pose(NinjaSprites.runRight, frame, hx, 0),
        _Pose(NinjaSprites.runLeft, frame, rx, 0),
      );
    }
    // Phase 2: both leap and meet in the air.
    if (q < _jumpEnd + 0.02) {
      final t = interval(q, _runEnd, _jumpEnd + 0.02);
      final arc = math.sin(t * math.pi) * 0.28;
      final frame = (t * 9.99).floor();
      return (
        _Pose(NinjaSprites.jumpRight, frame, 0.32 + t * 0.1, arc),
        _Pose(NinjaSprites.jumpLeft, frame, 0.68 - t * 0.1, arc),
      );
    }
    // Phase 3: three exchanges of strikes.
    for (final (start, end, heroStrikes) in _strikes) {
      if (q < end) {
        final t = interval(q, start, end);
        final frame = (t * 9.99).floor();
        final lunge = math.sin(t * math.pi) * 0.04;
        if (q < start) {
          return (
            _Pose(NinjaSprites.idleRight, (q * 120).floor() % 10, 0.4, 0),
            _Pose(NinjaSprites.idleLeft, (q * 120).floor() % 10, 0.6, 0),
          );
        }
        return heroStrikes
            ? (
                _Pose(NinjaSprites.attackRight, frame, 0.4 + lunge, 0),
                _Pose(NinjaSprites.idleLeft, frame, 0.6 + lunge * 0.6, 0),
              )
            : (
                _Pose(NinjaSprites.idleRight, frame, 0.4 - lunge * 0.6, 0),
                _Pose(NinjaSprites.attackLeft, frame, 0.6 - lunge, 0),
              );
      }
    }
    // Phase 4: the hero dashes straight through the rival.
    if (q < _dashEnd) {
      final t = interval(q, _dashStart, _dashEnd, Curves.easeInExpo);
      if (q < _dashStart) {
        return (
          _Pose(NinjaSprites.idleRight, (q * 120).floor() % 10, 0.4, 0),
          _Pose(NinjaSprites.idleLeft, (q * 120).floor() % 10, 0.6, 0),
        );
      }
      return (
        _Pose(NinjaSprites.attackRight, (t * 9.99).floor(), 0.4 + t * 0.42, 0),
        _Pose(NinjaSprites.idleLeft, 0, 0.6, 0),
      );
    }
    // Phase 5: a beat of silence, then the rival falls apart.
    final split = interval(q, _splitStart, 0.95, Curves.easeInCubic);
    return (
      _Pose(NinjaSprites.idleLeft, (q * 140).floor() % 10, 0.82, 0),
      _Pose(
        NinjaSprites.idleLeft,
        0,
        0.6,
        0,
        split: split,
        opacity: 1 - interval(q, 0.9, 1),
      ),
    );
  }

  /// Every moment where steel meets steel: (scroll position, x of impact).
  static const _impacts = [
    (_clash1, 0.5, 0.28),
    (0.405, 0.53, 0.0),
    (0.505, 0.47, 0.0),
    (0.605, 0.53, 0.0),
    (0.72, 0.6, 0.0),
  ];

  String _caption() {
    if (q < 0.12) return 'A rival approaches.';
    if (q < _jumpEnd + 0.02) return 'Steel meets steel.';
    if (q < _dashStart) return 'Bugs. Deadlines. Legacy code.';
    if (q < _splitStart) return 'One clean cut.';
    return 'Shipped.';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth, h = c.maxHeight;
        final ninjaHeight = math.min(h * 0.34, w * 0.36);
        final ground = h * 0.78;
        final (hero, rival) = _poses();

        final impactFlash = _impacts
            .map((i) => math.max(0.0, 1 - (q - i.$1).abs() / 0.018))
            .fold(0.0, math.max);
        final slashLine = interval(q, _dashStart + 0.03, _dashEnd + 0.02);
        final kanji = interval(q, _splitStart + 0.04, 0.96, Curves.easeOutBack);

        final moonRadius = math.min(w, h) * 0.24;
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // A blood moon rising behind the fighters, cut off by the horizon.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: ground,
              child: ClipRect(
                child: Stack(
                  children: [
                    // Halo: a gradient is one cheap draw; a 120px blur is not.
                    Positioned(
                      left: w / 2 - moonRadius * 2.2,
                      top: ground - moonRadius * 2.75 + 80 * (1 - q),
                      width: moonRadius * 4.4,
                      height: moonRadius * 4.4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              CustomColors.secondary.withValues(alpha: 0.4),
                              CustomColors.secondary.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: w / 2 - moonRadius,
                      top: ground - moonRadius * 1.55 + 80 * (1 - q),
                      width: moonRadius * 2,
                      height: moonRadius * 2,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: Alignment(-0.3, -0.3),
                            colors: [Color(0xffff7a6b), Color(0xff9b1c2c)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Stage floor: a lit dojo line with reflections.
            Positioned(
              left: 0,
              right: 0,
              top: ground,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      CustomColors.primary.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                  border: Border(
                    top: BorderSide(
                      color: CustomColors.primary.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            // Giant kanji for "cut" once the fight is decided.
            if (kanji > 0)
              Positioned.fill(
                child: Align(
                  alignment: const Alignment(0, -0.35),
                  child: Opacity(
                    opacity: kanji.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.6 + 0.4 * kanji,
                      child: Text(
                        '斬',
                        style: TextStyle(
                          fontSize: h * 0.42,
                          fontWeight: FontWeight.w900,
                          color: CustomColors.secondary.withValues(alpha: 0.85),
                          shadows: [
                            Shadow(
                              color: CustomColors.secondary,
                              blurRadius: 16 * kanji,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            _fighter(rival, w, ground, ninjaHeight, rival: true),
            _fighter(hero, w, ground, ninjaHeight, rival: false),
            // Sparks, flash and the final slash line.
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _DuelFxPainter(
                    q: q,
                    impacts: _impacts,
                    ground: ground,
                    ninjaHeight: ninjaHeight,
                    slash: slashLine,
                  ),
                ),
              ),
            ),
            if (impactFlash > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    color: Colors.white.withValues(alpha: 0.18 * impactFlash),
                  ),
                ),
              ),
            // Caption and progress.
            Positioned(
              left: 0,
              right: 0,
              top: h * 0.12,
              child: Column(
                children: [
                  Text(
                    'THE DUEL',
                    style: TextStyle(
                      color: CustomColors.secondary.withValues(alpha: 0.9),
                      letterSpacing: 8,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.4),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: Text(
                      _caption(),
                      key: ValueKey(_caption()),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: w < 600 ? 28 : 44,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: w * 0.2,
              right: w * 0.2,
              bottom: h * 0.08,
              child: _DuelProgress(q: q),
            ),
          ],
        );
      },
    );
  }

  Widget _fighter(
    _Pose pose,
    double w,
    double ground,
    double ninjaHeight, {
    required bool rival,
  }) {
    final scale = ninjaHeight / 439;
    final iw = pose.anim.width * scale, ih = pose.anim.height * scale;
    final left = pose.x * w - pose.anim.anchor * iw;
    final top = ground - ih - pose.lift * ninjaHeight * 2.2;
    Widget sprite = Image.asset(
      pose.anim.frame(pose.frame),
      width: iw,
      height: ih,
      fit: BoxFit.fill,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
    );
    if (rival) {
      sprite = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          1.1, 0.2, 0.2, 0, 30, //
          0.1, 0.25, 0.1, 0, 0,
          0.1, 0.1, 0.25, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: sprite,
      );
    }
    if (pose.split > 0) {
      final s = pose.split;
      sprite = Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: Offset(-40 * s, -60 * s + 180 * s * s),
            child: Transform.rotate(
              angle: -0.6 * s,
              child: ClipPath(
                clipper: const _BodyCut(top: true),
                child: sprite,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(30 * s, 40 * s * s),
            child: Transform.rotate(
              angle: 0.25 * s,
              child: ClipPath(
                clipper: const _BodyCut(top: false),
                child: sprite,
              ),
            ),
          ),
        ],
      );
    }
    return Positioned(
      left: left,
      top: top,
      width: iw,
      height: ih,
      child: Opacity(opacity: pose.opacity.clamp(0.0, 1.0), child: sprite),
    );
  }
}

class _BodyCut extends CustomClipper<Path> {
  const _BodyCut({required this.top});
  final bool top;

  @override
  Path getClip(Size s) {
    final l = s.height * 0.38, r = s.height * 0.55;
    final p = Path();
    if (top) {
      p
        ..moveTo(0, 0)
        ..lineTo(s.width, 0)
        ..lineTo(s.width, r)
        ..lineTo(0, l);
    } else {
      p
        ..moveTo(0, l)
        ..lineTo(s.width, r)
        ..lineTo(s.width, s.height)
        ..lineTo(0, s.height);
    }
    return p..close();
  }

  @override
  bool shouldReclip(covariant _BodyCut old) => old.top != top;
}

class _DuelFxPainter extends CustomPainter {
  _DuelFxPainter({
    required this.q,
    required this.impacts,
    required this.ground,
    required this.ninjaHeight,
    required this.slash,
  });

  final double q;
  final List<(double, double, double)> impacts;
  final double ground;
  final double ninjaHeight;
  final double slash;

  @override
  void paint(Canvas canvas, Size size) {
    for (var k = 0; k < impacts.length; k++) {
      final (at, x, lift) = impacts[k];
      final t = (q - at) / 0.05; // spark lifetime in scroll units
      if (t < 0 || t > 1) continue;
      final center = Offset(
        x * size.width,
        ground - ninjaHeight * 0.55 - lift * ninjaHeight * 2.2,
      );
      _sparks(canvas, center, t, k);
    }
    if (slash > 0 && slash < 1) {
      // The dash leaves a single long cut across the stage.
      final a = Offset(size.width * 0.15, ground - ninjaHeight * 0.75);
      final b = Offset(size.width * 0.95, ground - ninjaHeight * 0.35);
      final end = Offset.lerp(a, b, Curves.easeOut.transform(slash))!;
      final fade = 1 - interval(slash, 0.6, 1);
      canvas.drawLine(
        a,
        end,
        Paint()
          ..color = CustomColors.primary.withValues(alpha: 0.7 * fade)
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawLine(
        a,
        end,
        Paint()
          ..color = Colors.white.withValues(alpha: fade)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _sparks(Canvas canvas, Offset center, double t, int seed) {
    final r = math.Random(seed * 31 + 7);
    final fade = 1 - t;
    canvas.drawCircle(
      center,
      60 + 120 * t,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.8 * fade),
            const Color(0xffffd36b).withValues(alpha: 0.4 * fade),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 60 + 120 * t)),
    );
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (var i = 0; i < 26; i++) {
      final angle = r.nextDouble() * math.pi * 2;
      final speed = 80 + r.nextDouble() * 260;
      final dir = Offset(math.cos(angle), math.sin(angle));
      final head = center + dir * speed * t + Offset(0, 160 * t * t);
      final tail = center + dir * speed * math.max(0, t - 0.15);
      paint
        ..strokeWidth = 1 + r.nextDouble() * 2.5 * fade
        ..color =
            (i % 4 == 0 ? CustomColors.secondary : const Color(0xffffe7a3))
                .withValues(alpha: fade);
      canvas.drawLine(tail, head, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DuelFxPainter old) =>
      old.q != q || old.slash != slash;
}

class _DuelProgress extends StatelessWidget {
  const _DuelProgress({required this.q});
  final double q;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(height: 2, color: Colors.white.withValues(alpha: 0.12)),
            FractionallySizedBox(
              widthFactor: q.clamp(0.0, 1.0),
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: CustomColors.secondary,
                  boxShadow: [
                    BoxShadow(
                      color: CustomColors.secondary.withValues(alpha: 0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          q < 0.98 ? 'KEEP SCROLLING TO FIGHT' : 'VICTORY',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}
