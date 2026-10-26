import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector3;

import '../audio/sound_fx.dart';
import '../three_d/mesh.dart';
import '../three_d/mesh_projection.dart';
import '../three_d/models.dart';
import '../utils/custom_colors.dart';
import 'css_backdrop.dart';

/// The fixed, full-screen layer behind the whole page.
///
/// Everything in it is driven by the page scroll offset (and a clock):
/// * a hero katana that floats, sweeps a slash across the first screen, then
///   parks at the right edge and spins on its axis as you keep scrolling;
/// * shurikens and kunai at different depths whose spin speeds up with
///   scroll velocity;
/// * a moon, drifting sakura petals, embers and speed lines.
class BladeBackground extends StatefulWidget {
  const BladeBackground({
    super.key,
    required this.controller,
    required this.pointer,
  });

  final ScrollController controller;
  final ValueNotifier<Offset?> pointer;

  @override
  State<BladeBackground> createState() => _BladeBackgroundState();
}

class _BladeBackgroundState extends State<BladeBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _frame = ValueNotifier<int>(0);
  final _scene = _SceneState();
  Duration _last = Duration.zero;
  double _sincePaint = 0;
  double _sinceInput = 0;
  Offset? _lastPointer;
  double _lastScreens = 0;

  /// When nothing is moving (no scroll, no pointer, no slash trail) the
  /// ambient petals and spinning blades only need 30 fps. Every frame on web
  /// re-rasterizes the whole screen, so this halves idle GPU work.
  static const _idleFrameTime = 1 / 30;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
    PaintingBinding.instance.systemFonts.addListener(_BladePainter.resetKanji);
  }

  void _tick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = elapsed;
    final c = widget.controller;
    final offset = c.hasClients ? c.offset : 0.0;
    final extent = c.hasClients && c.position.hasContentDimensions
        ? c.position.maxScrollExtent
        : 1.0;
    final scrolled = offset != _scene.offset;
    _scene.advance(dt, offset, extent);

    // The hero katana's slash swings through at ~0.2 screens of scroll.
    final viewport = c.hasClients && c.position.hasViewportDimension
        ? c.position.viewportDimension
        : 1.0;
    final screens = offset / viewport;
    if (_lastScreens < 0.2 && screens >= 0.2 && screens - _lastScreens < 0.5) {
      SoundFx.play(SoundFx.sword, volume: 0.7);
    }
    _lastScreens = screens;

    final pointer = widget.pointer.value;
    if (scrolled || pointer != _lastPointer || _scene.tipTrail.isNotEmpty) {
      _sinceInput = 0;
    } else {
      _sinceInput += dt;
    }
    _lastPointer = pointer;

    _sincePaint += dt;
    final busy = _sinceInput < 0.3;
    if (busy || _sincePaint >= _idleFrameTime - 0.004) {
      _sincePaint = 0;
      _frame.value++;
    }
  }

  @override
  void dispose() {
    PaintingBinding.instance.systemFonts.removeListener(
      _BladePainter.resetKanji,
    );
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _BladePainter(_scene, widget.pointer, _frame),
        size: Size.infinite,
      ),
    );
  }
}

/// Simulation state that survives between frames.
class _SceneState {
  double time = 0;
  double offset = 0;
  double extent = 1;
  double velocity = 0;
  double spin = 0;
  final List<_Trail> tipTrail = [];

  void advance(double dt, double newOffset, double newExtent) {
    if (dt > 0) {
      final v = (newOffset - offset) / dt;
      velocity = velocity * 0.85 + v * 0.15;
    }
    time += dt;
    offset = newOffset;
    extent = math.max(1, newExtent);
    spin += dt * (1.2 + (velocity.abs() / 220).clamp(0, 14));
    for (final t in tipTrail) {
      t.age += dt;
    }
    tipTrail.removeWhere((t) => t.age > 0.35);
  }
}

class _Trail {
  _Trail(this.point);
  final Offset point;
  double age = 0;
}

class _Flyer {
  const _Flyer(
    this.pageY,
    this.x,
    this.size,
    this.depth,
    this.speed,
    this.tilt,
    this.kunai,
  );
  final double pageY; // 0..1 along the whole page
  final double x; // 0..1 across the screen
  final double size;
  final double depth; // parallax factor
  final double speed;
  final double tilt;
  final bool kunai;
}

class _BladePainter extends CustomPainter {
  _BladePainter(this.scene, this.pointer, Listenable repaint)
    : super(repaint: repaint);

  final _SceneState scene;
  final ValueNotifier<Offset?> pointer;

  static final _steel = MeshPainter();
  static final _crimson = MeshPainter(rimColor: CustomColors.secondary);
  static final Vector3 _katanaTip = Models.katana.vertices.reduce(
    (a, b) => a.x > b.x ? a : b,
  );

  static const _flyers = [
    _Flyer(0.10, 0.035, 0.5, 0.55, 1.0, 1.0, false),
    _Flyer(0.18, 0.95, 0.35, 0.35, -1.4, 0.7, false),
    _Flyer(0.26, 0.03, 0.45, 0.8, 0.8, 0.4, true),
    _Flyer(0.36, 0.965, 0.5, 1.1, 1.2, 1.1, false),
    _Flyer(0.47, 0.03, 0.4, 0.5, -0.9, 0.9, false),
    _Flyer(0.55, 0.95, 0.45, 0.9, 1.0, 0.5, true),
    _Flyer(0.66, 0.04, 0.55, 1.2, 1.3, 0.8, false),
    _Flyer(0.76, 0.96, 0.4, 0.6, -1.1, 1.2, false),
    _Flyer(0.86, 0.035, 0.5, 0.9, 1.0, 0.6, true),
    _Flyer(0.95, 0.95, 0.5, 0.7, -1.2, 1.0, false),
  ];

  static final _petals = List.generate(70, (i) {
    final r = math.Random(i * 7919);
    return (
      x: r.nextDouble(),
      y: r.nextDouble(),
      speed: 0.3 + r.nextDouble(),
      size: 2.5 + r.nextDouble() * 5,
      depth: 0.2 + r.nextDouble() * 0.8,
      phase: r.nextDouble() * math.pi * 2,
      ember: i % 4 == 0,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final s = scene.offset;
    final page = s / scene.extent; // 0..1 through the whole page
    final compact = w < 900;

    _paintSky(canvas, size, page);
    _paintMoon(canvas, size, s, page);
    _paintKanji(canvas, size, s);
    _paintPetals(canvas, size, s);
    _paintFlyers(canvas, size, s, compact);
    _paintHeroKatana(canvas, size, s, compact);
    _paintSpeedLines(canvas, size);

    // Soft vignette keeps text readable on top of all of this. On web it is
    // part of the CSS backdrop instead (see [CssBackdrop]).
    if (CssBackdrop.supported) return;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(w / 2, h / 2),
          math.max(w, h) * 0.75,
          [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
          [0.55, 1],
        ),
    );
  }

  void _paintSky(Canvas canvas, Size size, double page) {
    // The sky slowly bleeds from midnight blue into a blood-red dusk around
    // the duel in the middle of the page, then into a green-tinted night.
    // Quantized so the CSS backdrop only changes in small steps.
    page = (page * 64).roundToDouble() / 64;
    final mid =
        (math.exp(-math.pow((page - 0.55) / 0.18, 2)) * 32).roundToDouble() /
        32;
    final top = Color.lerp(
      const Color(0xff070912),
      const Color(0xff1a0609),
      mid,
    )!;
    final bottom = Color.lerp(
      Color.lerp(const Color(0xff10141f), const Color(0xff0b1712), page)!,
      const Color(0xff2a0b10),
      mid,
    )!;
    if (CssBackdrop.supported) {
      CssBackdrop.setSky(top, bottom);
      return;
    }
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), [
          top,
          bottom,
        ]),
    );
  }

  void _paintMoon(Canvas canvas, Size size, double s, double page) {
    final w = size.width, h = size.height;
    final compact = w < 900;
    final r = math.min(w, h) * (compact ? 0.11 : 0.17);
    // The moon rises out of view as you leave the hero; the duel has its own.
    final center = compact
        ? Offset(w * 0.82, h * 0.11 - s * 0.3)
        : Offset(w * 0.74, h * 0.3 - s * 0.3);
    if (center.dy < -r * 3) return;
    final crimson = math.exp(-math.pow((page - 0.55) / 0.2, 2));
    final color = Color.lerp(
      const Color(0xfff3ecd8),
      const Color(0xffff4d5e),
      crimson,
    )!;
    canvas.drawCircle(
      center,
      r * 2.2,
      Paint()
        ..shader = ui.Gradient.radial(center, r * 2.2, [
          color.withValues(alpha: 0.22),
          color.withValues(alpha: 0.0),
        ]),
    );
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          center.translate(-r * 0.3, -r * 0.3),
          r * 1.3,
          [color, Color.lerp(color, Colors.black, 0.35)!],
        ),
    );
    // A few craters.
    final crater = Paint()..color = Colors.black.withValues(alpha: 0.08);
    canvas.drawCircle(center.translate(r * 0.3, r * 0.1), r * 0.18, crater);
    canvas.drawCircle(center.translate(-r * 0.35, r * 0.35), r * 0.12, crater);
    canvas.drawCircle(center.translate(-r * 0.1, -r * 0.4), r * 0.09, crater);
  }

  // Laying out a glyph this size is costly, so the painter is cached and
  // only rebuilt when the viewport height or the (quantized) fade changes.
  // On web the CJK fallback font arrives after the first frames, so the cache
  // is also dropped whenever fonts finish loading; otherwise the first
  // "missing glyph" layout would stick.
  static ui.Image? _kanji;
  static double? _kanjiHeight;
  static void resetKanji() => _kanjiHeight = null;
  static final Paint _kanjiPaint = Paint()..filterQuality = FilterQuality.low;

  void _paintKanji(Canvas canvas, Size size, double s) {
    final h = size.height;
    final fade = (1 - s / (h * 1.2)).clamp(0.0, 1.0);
    if (fade <= 0) return;
    if (_kanjiHeight != h || _kanji == null) {
      // A glyph this large is outside the text engine's glyph cache and gets
      // re-rasterized from its outline every frame; as an image it is a
      // single texture draw.
      _kanjiHeight = h;
      final tp = TextPainter(
        text: TextSpan(
          text: '忍',
          style: TextStyle(
            fontSize: h * 0.85,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final width = tp.width.ceil().clamp(1, 4096);
      final height = tp.height.ceil().clamp(1, 4096);
      final recorder = ui.PictureRecorder();
      tp.paint(Canvas(recorder), Offset.zero);
      tp.dispose();
      _kanji?.dispose();
      _kanji = recorder.endRecording().toImageSync(width, height);
    }
    _kanjiPaint.color = Colors.white.withValues(alpha: 0.035 * fade);
    canvas.drawImage(
      _kanji!,
      Offset(size.width * 0.04, h * 0.05 - s * 0.35),
      _kanjiPaint,
    );
  }

  // Petal and ember sprites, drawn once. Every particle is then a rotated,
  // scaled, tinted copy of one of them, all submitted in one drawRawAtlas
  // call. Separate drawOval/drawCircle calls cost ~280 JS-to-CanvasKit
  // round trips per frame.
  static ui.Image? _sprites;
  static const _petalRect = Rect.fromLTWH(0, 0, 64, 32);
  static const _emberRect = Rect.fromLTWH(64, 0, 64, 64);
  static final Float32List _rst = Float32List(_petals.length * 4);
  static final Float32List _rects = Float32List(_petals.length * 4);
  static final Int32List _tints = Int32List(_petals.length);
  static final Paint _spritePaint = Paint()..filterQuality = FilterQuality.low;

  static ui.Image _bakeSprites() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawOval(_petalRect.deflate(1), Paint()..color = Colors.white);
    final c = _emberRect.center;
    canvas.drawCircle(
      c,
      32,
      Paint()
        ..shader = ui.Gradient.radial(
          c,
          32,
          [
            Colors.white,
            Colors.white.withValues(alpha: 0.55),
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0),
          ],
          const [0, 0.3, 0.32, 1],
        ),
    );
    return recorder.endRecording().toImageSync(128, 64);
  }

  void _paintPetals(Canvas canvas, Size size, double s) {
    final w = size.width, h = size.height;
    final t = scene.time;
    final sprites = _sprites ??= _bakeSprites();
    // During a fling the page is already moving quickly. Halving the ambient
    // particles in that short window keeps the expensive full-screen painter
    // from competing with the scroll rasterization.
    final limit = scene.velocity.abs() > 1600 ? 35 : _petals.length;
    final span = h + 60;
    for (var i = 0; i < limit; i++) {
      final p = _petals[i];
      final y =
          ((p.y * span + t * p.speed * 40 - s * p.depth * 0.5) % span + span) %
              span -
          30;
      final x = p.x * w + math.sin(t * p.speed + p.phase) * 40 * p.depth;
      final double scale, angle, ax, ay;
      final Rect src;
      final Color tint;
      if (p.ember) {
        final glow = 0.5 + 0.5 * math.sin(t * 3 + p.phase);
        src = _emberRect;
        scale = p.size * 2.2 / 64;
        angle = 0;
        ax = ay = 32;
        tint = CustomColors.primary.withValues(alpha: 0.35 + 0.55 * glow);
      } else {
        src = _petalRect;
        scale = p.size * 2 / 64;
        angle = t * p.speed + p.phase;
        ax = 32;
        ay = 16;
        tint = const Color(0xffff9fb6).withValues(alpha: 0.35 + 0.4 * p.depth);
      }
      final scos = math.cos(angle) * scale, ssin = math.sin(angle) * scale;
      _rst
        ..[i * 4] = scos
        ..[i * 4 + 1] = ssin
        ..[i * 4 + 2] = x - scos * ax + ssin * ay
        ..[i * 4 + 3] = y - ssin * ax - scos * ay;
      _rects
        ..[i * 4] = src.left
        ..[i * 4 + 1] = src.top
        ..[i * 4 + 2] = src.right
        ..[i * 4 + 3] = src.bottom;
      _tints[i] = tint.toARGB32();
    }
    canvas.drawRawAtlas(
      sprites,
      Float32List.sublistView(_rst, 0, limit * 4),
      Float32List.sublistView(_rects, 0, limit * 4),
      Int32List.sublistView(_tints, 0, limit),
      BlendMode.modulate,
      null,
      _spritePaint,
    );
  }

  void _paintFlyers(Canvas canvas, Size size, double s, bool compact) {
    final w = size.width, h = size.height;
    final total = scene.extent + h;
    final unit = math.min(w, h) * (compact ? 0.06 : 0.075);
    for (var i = 0; i < _flyers.length; i++) {
      // The 3D mesh painter transforms, lights, sorts and allocates a vertex
      // buffer for every model. Keep the hero and alternating depth layers
      // during a fast fling, then restore the full composition when settled.
      if (scene.velocity.abs() > 1600 && i.isOdd) continue;
      final f = _flyers[i];
      final y = f.pageY * total * f.depth - s * f.depth + h * 0.5;
      if (y < -200 || y > h + 200) continue;
      final x = f.x * w + math.sin(scene.time * 0.4 + i) * 18;
      final spin = scene.spin * f.speed * (f.kunai ? 0.35 : 2.2);
      final model = Matrix4.identity()
        ..rotateX(f.tilt + 0.3 * math.sin(scene.time * 0.7 + i))
        ..rotateY(0.4 * math.sin(scene.time * 0.5 + i * 2));
      if (f.kunai) {
        model
          ..rotateZ(-math.pi / 2 + 0.4 * math.sin(scene.time + i))
          ..rotateX(spin);
      } else {
        model.rotateZ(spin);
      }
      final painter = i.isEven ? _steel : _crimson;
      painter.paint(
        canvas,
        f.kunai ? Models.kunai : Models.shuriken,
        model,
        center: Offset(x, y),
        scale: unit * f.size * (0.7 + f.depth * 0.6),
        focal: 6,
        opacity: compact ? 0.55 : 0.95,
      );
    }
  }

  void _paintHeroKatana(Canvas canvas, Size size, double s, bool compact) {
    final w = size.width, h = size.height;
    final t = scene.time;
    final vh = s / h;

    // 0..1 phases of the katana's choreography.
    final slash = Curves.easeInOutCubic.transform(
      ((vh - 0.05) / 0.6).clamp(0.0, 1.0),
    );
    final park = Curves.easeInOutCubic.transform(
      ((vh - 0.65) / 0.55).clamp(0.0, 1.0),
    );

    final pointerOffset = pointer.value;
    final tiltX = pointerOffset == null
        ? 0.0
        : (pointerOffset.dy / h - 0.5) * 0.6;
    final tiltY = pointerOffset == null
        ? 0.0
        : (pointerOffset.dx / w - 0.5) * 0.8;

    final heroCenter = compact
        ? Offset(w * 0.5, h * 0.72)
        : Offset(w * 0.68, h * 0.55);
    final slashEnd = Offset(w * 0.32, h * 0.42);
    final parkSpot = compact
        ? Offset(w - 26, h * 0.5)
        : Offset(w - 70, h * 0.52);

    final center = Offset.lerp(
      Offset.lerp(heroCenter, slashEnd, slash)!,
      parkSpot,
      park,
    )!.translate(0, math.sin(t * 1.3) * 10 * (1 - park));
    final baseUnit = math.min(w, h) * (compact ? 0.11 : 0.12);
    final unit = ui.lerpDouble(
      ui.lerpDouble(baseUnit, baseUnit * 1.35, math.sin(slash * math.pi))!,
      baseUnit * (compact ? 0.4 : 0.5),
      park,
    )!;

    final rz = ui.lerpDouble(
      ui.lerpDouble(0.55 + 0.06 * math.sin(t), -2.6, slash)!,
      math.pi / 2,
      park,
    )!;
    final ry = ui.lerpDouble(0.5 * math.sin(t * 0.45) + tiltY, 0, park)!;
    final rx = t * 0.6 * (1 - park) + s * 0.012 * park + tiltX;

    final model = Matrix4.identity()
      ..rotateZ(rz)
      ..rotateY(ry)
      ..rotateX(rx);

    // Slash trail from the tip of the blade.
    final tip = projectPoint(
      _katanaTip,
      model,
      center: center,
      scale: unit,
      focal: 9,
    );
    if (scene.tipTrail.isEmpty ||
        (scene.tipTrail.last.point - tip).distance > 2) {
      scene.tipTrail.add(_Trail(tip));
    }
    _paintTrail(canvas, scene.tipTrail);

    // Glow under the blade.
    canvas.drawCircle(
      center,
      unit * 2.2,
      Paint()
        ..shader = ui.Gradient.radial(center, unit * 2.2, [
          CustomColors.primary.withValues(alpha: 0.12 * (1 - park * 0.6)),
          Colors.transparent,
        ]),
    );
    _steel.paint(
      canvas,
      Models.katana,
      model,
      center: center,
      scale: unit,
      focal: 9,
      opacity: compact && park > 0.5 ? 0.6 : 1,
    );
  }

  void _paintTrail(Canvas canvas, List<_Trail> trail) {
    if (trail.length < 3) return;
    // A wide faint stroke under a bright core fakes the glow; a blur per
    // segment would cost one GPU pass per segment, every frame.
    final halo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final core = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i < trail.length; i++) {
      final a = trail[i - 1], b = trail[i];
      final life = (1 - b.age / 0.35).clamp(0.0, 1.0);
      final along = i / trail.length;
      halo
        ..strokeWidth = 4 + 16 * along * life
        ..color = CustomColors.primary.withValues(alpha: 0.18 * life);
      core
        ..strokeWidth = 1 + 6 * along * life
        ..color = Color.lerp(
          Colors.white,
          CustomColors.primary,
          1 - along,
        )!.withValues(alpha: 0.85 * life);
      canvas.drawLine(a.point, b.point, halo);
      canvas.drawLine(a.point, b.point, core);
    }
  }

  void _paintSpeedLines(Canvas canvas, Size size) {
    final v = scene.velocity.abs();
    if (v < 900) return;
    final strength = ((v - 900) / 3500).clamp(0.0, 1.0);
    final r = math.Random((scene.time * 20).floor());
    final dir = scene.velocity.sign;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.18 * strength);
    for (var i = 0; i < 14; i++) {
      final x = r.nextDouble() * size.width;
      final y = r.nextDouble() * size.height;
      final len = 80 + r.nextDouble() * 240 * strength;
      paint.strokeWidth = 0.6 + r.nextDouble() * 1.6;
      canvas.drawLine(Offset(x, y), Offset(x, y - len * dir), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BladePainter oldDelegate) => false;
}
