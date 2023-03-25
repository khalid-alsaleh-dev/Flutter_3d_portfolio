import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter_3d_portfolio/ninja_game/classes/ninja_game.dart';

class CollisionProjectWrapper extends RectangleComponent
    with HasGameRef<NinjaGame>, CollisionCallbacks {
  CollisionProjectWrapper({
    required this.baseWidth,
    required this.baseHeight,
    required this.baseX,
    required this.baseY,
  });
  final double baseWidth;
  final double baseHeight;
  final double baseX;
  final double baseY;
  late ShapeHitbox _hitbox;
  @override
  FutureOr<void> onLoad() {
    size = Vector2(baseWidth, baseHeight);
    position = Vector2(baseX, baseY);
    _hitbox = RectangleHitbox();
    renderShape=false;
    add(_hitbox);
    return super.onLoad();
  }
}
