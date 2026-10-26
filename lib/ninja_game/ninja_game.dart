import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/custom_colors.dart';
import '../audio/sound_fx.dart';
import 'ninja.dart';

/// The dojo mini-game: the ninja runs along the floor and slashes the chains
/// holding the metal plates that hide each project.
///
/// Plate positions are fractions of the game width, so the Flutter overlay
/// that draws the plates and this game always agree on where they are.
class NinjaGame extends FlameGame with KeyboardEvents {
  NinjaGame({required this.plateCount});

  final int plateCount;

  /// Which plates have been cut down.
  late final List<ValueNotifier<bool>> cut =
      List.generate(plateCount, (_) => ValueNotifier(false));

  /// The plate the ninja is close enough to slash, if any.
  final armed = ValueNotifier<int?>(null);

  /// Keyboard input is only captured while the dojo is on screen, so arrow
  /// keys keep scrolling the page everywhere else.
  bool active = false;

  late final Ninja ninja;
  final Set<LogicalKeyboardKey> _held = {};

  static const reach = 150.0;

  double plateX(int i) => size.x * (i + 1) / (plateCount + 1);
  double get groundY => size.y * 0.92;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  FutureOr<void> onLoad() async {
    ninja = Ninja();
    await add(ninja);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) ninja.snapToGround();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isLoaded) return;
    final left = _held.contains(LogicalKeyboardKey.arrowLeft) ||
        _held.contains(LogicalKeyboardKey.keyA);
    final right = _held.contains(LogicalKeyboardKey.arrowRight) ||
        _held.contains(LogicalKeyboardKey.keyD);
    if (left != right) ninja.dashTarget = null;
    ninja.steer(left == right ? 0 : (left ? -1 : 1));

    int? inRange;
    for (var i = 0; i < plateCount; i++) {
      if (!cut[i].value && (ninja.x - plateX(i)).abs() < reach) inRange = i;
    }
    armed.value = inRange;
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!active || !isLoaded) {
      _held.clear();
      return KeyEventResult.ignored;
    }
    _held
      ..clear()
      ..addAll(keysPressed);
    final key = event.logicalKey;
    final handled = {
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.space,
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.keyD,
      LogicalKeyboardKey.keyW,
      LogicalKeyboardKey.keyX,
      LogicalKeyboardKey.keyJ,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.controlRight,
      LogicalKeyboardKey.shiftLeft,
      LogicalKeyboardKey.shiftRight,
      LogicalKeyboardKey.enter,
    }.contains(key);

    if (event is KeyDownEvent) {
      if (key == LogicalKeyboardKey.space ||
          key == LogicalKeyboardKey.arrowUp ||
          key == LogicalKeyboardKey.keyW ||
          key == LogicalKeyboardKey.shiftLeft ||
          key == LogicalKeyboardKey.shiftRight) {
        ninja.jump();
      } else if (key == LogicalKeyboardKey.controlLeft ||
          key == LogicalKeyboardKey.controlRight ||
          key == LogicalKeyboardKey.keyX ||
          key == LogicalKeyboardKey.keyJ ||
          key == LogicalKeyboardKey.enter) {
        ninja.attack();
      }
    }
    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  /// Click/tap fallback: the ninja sprints to plate [i] and slashes it.
  void dashTo(int i) {
    if (!isLoaded || cut[i].value) return;
    ninja.dashTarget = i;
  }

  /// Called by the ninja at the moment the blade connects.
  void onSlash() {
    final i = armed.value;
    // The swing's whoosh already played on the key press; only a hit adds
    // the chain-cut sound, at the moment of impact.
    if (i == null || cut[i].value) return;
    cut[i].value = true;
    SoundFx.play(SoundFx.cut);
    _sparks(Vector2(plateX(i), ninja.y - ninja.size.y * 0.6));
  }

  void reset() {
    for (final c in cut) {
      c.value = false;
    }
  }

  void _sparks(Vector2 at) {
    final r = math.Random();
    add(ParticleSystemComponent(
      position: at,
      particle: Particle.generate(
        count: 46,
        lifespan: 0.8,
        generator: (i) {
          final angle = r.nextDouble() * math.pi * 2;
          final speed = 120 + r.nextDouble() * 380;
          return AcceleratedParticle(
            acceleration: Vector2(0, 900),
            speed: Vector2(math.cos(angle), math.sin(angle)) * speed,
            child: ComputedParticle(renderer: (canvas, particle) {
              final fade = 1 - particle.progress;
              canvas.drawCircle(
                Offset.zero,
                2.4 * fade + 0.6,
                Paint()
                  ..color = (i % 3 == 0
                          ? CustomColors.secondary
                          : const Color(0xffffe7a3))
                      .withValues(alpha: fade),
              );
            }),
          );
        },
      ),
    ));
  }

  @override
  void render(Canvas canvas) {
    // Dojo floor: a glowing line with a soft reflection.
    final y = groundY;
    canvas.drawRect(
      Rect.fromLTWH(0, y, size.x, size.y - y),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CustomColors.primary.withValues(alpha: 0.12),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, y, size.x, size.y - y)),
    );
    canvas.drawLine(
      Offset(0, y),
      Offset(size.x, y),
      Paint()
        ..color = CustomColors.primary.withValues(alpha: 0.6)
        ..strokeWidth = 1.5,
    );
    super.render(canvas);
  }

  @override
  void onRemove() {
    armed.dispose();
    for (final c in cut) {
      c.dispose();
    }
    super.onRemove();
  }
}
