import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

/// Surface finish of a face, used by the renderer to pick a lighting model.
enum Material3d { steel, gold, cloth, wood, glow }

/// A flat-shaded triangle mesh. Every face carries its own base color and
/// material so procedural models can mix steel, gold and cloth.
class Mesh {
  Mesh();

  final List<Vector3> vertices = [];
  final List<int> indices = [];
  final List<Color> faceColors = [];
  final List<Material3d> faceMaterials = [];

  int addVertex(double x, double y, double z) {
    vertices.add(Vector3(x, y, z));
    return vertices.length - 1;
  }

  void addTri(int a, int b, int c, Color color, Material3d material) {
    indices
      ..add(a)
      ..add(b)
      ..add(c);
    faceColors.add(color);
    faceMaterials.add(material);
  }

  void addQuad(int a, int b, int c, int d, Color color, Material3d material) {
    addTri(a, b, c, color, material);
    addTri(a, c, d, color, material);
  }

  int get faceCount => faceColors.length;
}

/// Paints [Mesh]es with a tiny software rasterizer: transform, cull, light,
/// depth-sort, then hand all triangles to [Canvas.drawVertices] in one call.
/// Works on every Flutter web renderer and needs no WebGL setup.
class MeshPainter {
  MeshPainter({Vector3? lightDirection, this.rimColor = const Color(0xff6AE99F)})
      : light = (lightDirection ?? Vector3(-0.45, -0.7, 0.9))..normalize();

  final Vector3 light;
  final Color rimColor;

  static final Paint _paint = Paint()..isAntiAlias = true;

  /// Draws [mesh] transformed by [model] around [center] on the canvas.
  /// [scale] converts model units into logical pixels and [focal] controls how
  /// strong the perspective is (bigger = flatter).
  void paint(
    Canvas canvas,
    Mesh mesh,
    Matrix4 model, {
    required Offset center,
    required double scale,
    double focal = 6,
    double opacity = 1,
  }) {
    if (opacity <= 0.01) return;
    final n = mesh.vertices.length;
    final world = List<Vector3>.generate(
        n, (i) => model.transformed3(mesh.vertices[i]),
        growable: false);
    final projected = List<Offset>.generate(n, (i) {
      final v = world[i];
      final p = focal / (focal - v.z).clamp(0.2, double.infinity);
      return Offset(center.dx + v.x * scale * p, center.dy - v.y * scale * p);
    }, growable: false);

    final faces = <_Face>[];
    final view = Vector3(0, 0, 1);
    for (var f = 0; f < mesh.faceCount; f++) {
      final ia = mesh.indices[f * 3];
      final ib = mesh.indices[f * 3 + 1];
      final ic = mesh.indices[f * 3 + 2];
      final a = projected[ia], b = projected[ib], c = projected[ic];
      // Screen-space winding: y is flipped, so front faces are clockwise.
      final cross =
          (b.dx - a.dx) * (c.dy - a.dy) - (b.dy - a.dy) * (c.dx - a.dx);
      final wa = world[ia], wb = world[ib], wc = world[ic];
      final normal = (wb - wa).cross(wc - wa);
      if (normal.length2 == 0) continue;
      normal.normalize();
      final facing = cross < 0;
      // Thin blades are rendered double sided so edges never vanish.
      if (!facing) normal.negate();
      final depth = (wa.z + wb.z + wc.z) / 3;
      faces.add(_Face(a, b, c, depth,
          _shade(mesh.faceColors[f], mesh.faceMaterials[f], normal, view)));
    }
    faces.sort((x, y) => x.depth.compareTo(y.depth));

    final positions = Float32List(faces.length * 6);
    final colors = Int32List(faces.length * 3);
    for (var i = 0; i < faces.length; i++) {
      final face = faces[i];
      positions
        ..[i * 6] = face.a.dx
        ..[i * 6 + 1] = face.a.dy
        ..[i * 6 + 2] = face.b.dx
        ..[i * 6 + 3] = face.b.dy
        ..[i * 6 + 4] = face.c.dx
        ..[i * 6 + 5] = face.c.dy;
      final argb = face.color.withValues(alpha: face.color.a * opacity).toARGB32();
      colors
        ..[i * 3] = argb
        ..[i * 3 + 1] = argb
        ..[i * 3 + 2] = argb;
    }
    final vertices =
        Vertices.raw(VertexMode.triangles, positions, colors: colors);
    canvas.drawVertices(vertices, BlendMode.dst, _paint);
    vertices.dispose();
  }

  Color _shade(Color base, Material3d material, Vector3 normal, Vector3 view) {
    final diffuse = math.max(0.0, normal.dot(light));
    final half = (light + view)..normalize();
    final specAngle = math.max(0.0, normal.dot(half));
    final rim = math.pow(1 - math.max(0.0, normal.dot(view)), 2).toDouble();

    double ambient, kd, ks, shininess, rimStrength;
    switch (material) {
      case Material3d.steel:
        ambient = 0.28;
        kd = 0.55;
        ks = 1.0;
        shininess = 48;
        rimStrength = 0.3;
      case Material3d.gold:
        ambient = 0.3;
        kd = 0.7;
        ks = 0.7;
        shininess = 24;
        rimStrength = 0.25;
      case Material3d.cloth:
        ambient = 0.35;
        kd = 0.65;
        ks = 0.08;
        shininess = 6;
        rimStrength = 0.15;
      case Material3d.wood:
        ambient = 0.3;
        kd = 0.7;
        ks = 0.2;
        shininess = 10;
        rimStrength = 0.1;
      case Material3d.glow:
        return base;
    }
    final spec = ks * math.pow(specAngle, shininess).toDouble();
    final lit = ambient + kd * diffuse;
    double ch(double c, double rimC) =>
        (c * lit + spec + rimC * rim * rimStrength).clamp(0.0, 1.0);
    return Color.from(
      alpha: base.a,
      red: ch(base.r, rimColor.r),
      green: ch(base.g, rimColor.g),
      blue: ch(base.b, rimColor.b),
    );
  }
}

class _Face {
  _Face(this.a, this.b, this.c, this.depth, this.color);
  final Offset a, b, c;
  final double depth;
  final Color color;
}
