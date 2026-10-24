import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

/// Projects a model-space point the same way [MeshPainter.paint] does, so
/// effects (trails, sparks) can be attached to a point on a 3D model.
Offset projectPoint(Vector3 point, Matrix4 model,
    {required Offset center, required double scale, double focal = 6}) {
  final v = model.transformed3(point);
  final p = focal / (focal - v.z).clamp(0.2, double.infinity);
  return Offset(center.dx + v.x * scale * p, center.dy - v.y * scale * p);
}
