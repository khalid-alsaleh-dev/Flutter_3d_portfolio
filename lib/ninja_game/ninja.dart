import 'dart:async';

import 'package:flame/components.dart';

import '../audio/sound_fx.dart';
import 'ninja_game.dart';

enum _Move { idle, run, jump, attack }

/// One animation strip plus the facts needed to draw it in place: source
/// frame size and where the body sits horizontally in the frame.
class _Strip {
  _Strip(this.animation, this.sourceSize, this.bodyX);
  final SpriteAnimation animation;
  final Vector2 sourceSize;
  final double bodyX;
}

/// The player ninja. [position] is the point between its feet.
class Ninja extends SpriteAnimationComponent
    with HasGameReference<NinjaGame> {
  Ninja() : super(priority: 1);

  static const _runSpeed = 420.0;
  static const _gravity = 2600.0;
  static const _jumpSpeed = 1050.0;
  static const _attackTime = 0.45;

  final Map<(_Move, bool), _Strip> _strips = {};
  bool facingRight = true;
  double _vx = 0, _vy = 0;
  double _attackLeft = 0;
  bool _slashed = false;
  int? dashTarget;
  _Strip? _current;

  bool get grounded => y >= game.groundY - 0.5 && _vy >= 0;

  @override
  FutureOr<void> onLoad() async {
    Future<SpriteAnimation> strip(String Function(int) name, double step,
        {bool loop = true}) async {
      final sprites = [for (var i = 0; i < 10; i++) await game.loadSprite(name(i))];
      return SpriteAnimation.spriteList(sprites, stepTime: step, loop: loop);
    }

    _strips[(_Move.idle, true)] =
        _Strip(await strip((i) => 'sprites/Idle$i.webp', 0.08), Vector2(232, 439), 0.5);
    _strips[(_Move.idle, false)] =
        _Strip(await strip((i) => 'sprites/IdleLeft$i.webp', 0.08), Vector2(232, 439), 0.5);
    _strips[(_Move.run, true)] = _Strip(
        await strip((i) => 'sprites/RunRight__00$i.webp', 0.06), Vector2(363, 434), 0.5);
    _strips[(_Move.run, false)] = _Strip(
        await strip((i) => 'sprites/RunLeft__00$i.webp', 0.06), Vector2(363, 434), 0.5);
    _strips[(_Move.jump, true)] = _Strip(
        await strip((i) => 'sprites/JumpRight$i.webp', 0.07, loop: false),
        Vector2(362, 464), 0.5);
    _strips[(_Move.jump, false)] = _Strip(
        await strip((i) => 'sprites/JumpLeft$i.webp', 0.07, loop: false),
        Vector2(362, 464), 0.5);
    _strips[(_Move.attack, true)] = _Strip(
        await strip((i) => 'sprites/Attack$i.webp', _attackTime / 10, loop: false),
        Vector2(536, 453), 0.24);
    _strips[(_Move.attack, false)] = _Strip(
        await strip((i) => 'sprites/AttackLeft$i.webp', _attackTime / 10, loop: false),
        Vector2(536, 453), 0.76);

    position = Vector2(game.size.x * 0.08, game.groundY);
    _show(_Move.idle);
  }

  void snapToGround() {
    y = game.groundY;
    x = x.clamp(0, game.size.x);
    if (_current != null) _resize(_current!);
  }

  void _resize(_Strip s) {
    final scale = game.size.y * 0.26 / 439;
    size = s.sourceSize * scale;
    anchor = Anchor(s.bodyX, 1);
  }

  void _show(_Move move) {
    final s = _strips[(move, facingRight)]!;
    if (identical(s, _current)) return;
    _current = s;
    animation = s.animation;
    animationTicker?.reset();
    _resize(s);
  }

  /// Horizontal input: -1, 0 or 1.
  void steer(int dir) {
    if (dashTarget != null) {
      final targetX = game.plateX(dashTarget!);
      final dx = targetX - x;
      if (dx.abs() < Ninja._dashStop) {
        facingRight = dx >= 0;
        dashTarget = null;
        _vx = 0;
        attack();
        return;
      }
      dir = dx > 0 ? 1 : -1;
    }
    if (_attackLeft > 0) {
      _vx = 0;
      return;
    }
    _vx = dir * _runSpeed * (dashTarget != null ? 1.6 : 1);
    if (dir != 0) facingRight = dir > 0;
  }

  static const _dashStop = 70.0;

  void jump() {
    if (!grounded || _attackLeft > 0) return;
    _vy = -_jumpSpeed;
    SoundFx.play(SoundFx.jump, volume: 0.5);
  }

  void attack() {
    if (_attackLeft > 0) return;
    // Turn toward an armed plate so the swing visibly hits it.
    final target = game.armed.value;
    if (target != null) facingRight = game.plateX(target) >= x;
    _attackLeft = _attackTime;
    _slashed = false;
    _show(_Move.attack);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_attackLeft > 0) {
      _attackLeft -= dt;
      if (!_slashed && _attackLeft < _attackTime * 0.5) {
        _slashed = true;
        game.onSlash();
      }
    }

    x = (x + _vx * dt).clamp(20, game.size.x - 20);
    _vy += _gravity * dt;
    y += _vy * dt;
    if (y >= game.groundY) {
      y = game.groundY;
      _vy = 0;
    }

    if (_attackLeft > 0) {
      _show(_Move.attack);
    } else if (!grounded) {
      _show(_Move.jump);
    } else if (_vx != 0) {
      _show(_Move.run);
    } else {
      _show(_Move.idle);
    }
  }
}
