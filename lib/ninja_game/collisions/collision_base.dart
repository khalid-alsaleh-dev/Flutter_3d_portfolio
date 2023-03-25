import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_portfolio/ninja_game/classes/ninja_game.dart';


class CollisionBase extends RectangleComponent
    with HasGameRef<NinjaGame>, CollisionCallbacks {
  CollisionBase({required this.baseWidth,required this.baseHeight,required this.baseX,required this.baseY,});
  final double baseWidth;
  final double baseHeight;
  final double baseX;
  final double baseY;
  late ShapeHitbox _hitbox;
  @override
  FutureOr<void> onLoad() async{
    size=Vector2(baseWidth, baseHeight);
    position = Vector2(baseX, baseY);
    _hitbox = RectangleHitbox();
    final defaultPaint = Paint()
      ..color = const Color(0xff424346)
      ..style = PaintingStyle.fill;
    paint = defaultPaint;
    await add(_hitbox);
    return super.onLoad();
  }
}
