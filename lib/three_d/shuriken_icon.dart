import 'package:flutter/material.dart';

import 'mesh.dart';
import 'models.dart';

/// A small 3D shuriken rotated to [angle] radians, sized to its parent.
class ShurikenIcon extends StatelessWidget {
  const ShurikenIcon({super.key, required this.angle, this.tilt = 0.5});

  final double angle;
  final double tilt;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ShurikenPainter(angle, tilt), size: Size.infinite);
}

class _ShurikenPainter extends CustomPainter {
  _ShurikenPainter(this.angle, this.tilt);
  final double angle;
  final double tilt;

  static final _painter = MeshPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final model = Matrix4.identity()
      ..rotateX(tilt)
      ..rotateZ(angle);
    _painter.paint(canvas, Models.shuriken, model,
        center: size.center(Offset.zero), scale: size.shortestSide * 0.36);
  }

  @override
  bool shouldRepaint(covariant _ShurikenPainter old) =>
      old.angle != angle || old.tilt != tilt;
}
