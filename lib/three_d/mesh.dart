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

/// Lighting parameters for one [Material3d].
class _Finish {
  const _Finish(this.ambient, this.kd, this.ks, this.shininess, this.rim);
  final double ambient, kd, ks, shininess, rim;
}

const _finishes = {
  Material3d.steel: _Finish(0.28, 0.55, 1.0, 48, 0.3),
  Material3d.gold: _Finish(0.3, 0.7, 0.7, 24, 0.25),
  Material3d.cloth: _Finish(0.35, 0.65, 0.08, 6, 0.15),
  Material3d.wood: _Finish(0.3, 0.7, 0.2, 10, 0.1),
};

/// A mesh flattened into typed arrays, plus scratch buffers reused every
/// frame. Painting runs on every animation frame, so it must not allocate
/// per-vertex or per-face objects.
class _Compiled {
  _Compiled(Mesh mesh)
    : vertexCount = mesh.vertices.length,
      faceCount = mesh.faceCount,
      xyz = Float64List(mesh.vertices.length * 3),
      index = Int32List.fromList(mesh.indices),
      normal = Float64List(mesh.faceCount * 3),
      rgb = Float64List(mesh.faceCount * 3),
      alpha = Float64List(mesh.faceCount),
      finish = List.generate(
        mesh.faceCount,
        (f) => _finishes[mesh.faceMaterials[f]],
        growable: false,
      ),
      world = Float64List(mesh.vertices.length * 3),
      screen = Float64List(mesh.vertices.length * 2),
      depth = Float64List(mesh.faceCount),
      order = List<int>.generate(mesh.faceCount, (i) => i),
      shade = Int32List(mesh.faceCount),
      positions = Float32List(mesh.faceCount * 6),
      colors = Int32List(mesh.faceCount * 3) {
    for (var i = 0; i < vertexCount; i++) {
      final v = mesh.vertices[i];
      xyz
        ..[i * 3] = v.x
        ..[i * 3 + 1] = v.y
        ..[i * 3 + 2] = v.z;
    }
    for (var f = 0; f < faceCount; f++) {
      final c = mesh.faceColors[f];
      rgb
        ..[f * 3] = c.r
        ..[f * 3 + 1] = c.g
        ..[f * 3 + 2] = c.b;
      alpha[f] = c.a;
      // Model-space face normal; rotations are applied per frame.
      final a = index[f * 3] * 3,
          b = index[f * 3 + 1] * 3,
          cc = index[f * 3 + 2] * 3;
      final ux = xyz[b] - xyz[a],
          uy = xyz[b + 1] - xyz[a + 1],
          uz = xyz[b + 2] - xyz[a + 2];
      final vx = xyz[cc] - xyz[a],
          vy = xyz[cc + 1] - xyz[a + 1],
          vz = xyz[cc + 2] - xyz[a + 2];
      var nx = uy * vz - uz * vy,
          ny = uz * vx - ux * vz,
          nz = ux * vy - uy * vx;
      final len = math.sqrt(nx * nx + ny * ny + nz * nz);
      if (len > 0) {
        nx /= len;
        ny /= len;
        nz /= len;
      }
      normal
        ..[f * 3] = nx
        ..[f * 3 + 1] = ny
        ..[f * 3 + 2] = nz;
    }
  }

  final int vertexCount, faceCount;
  final Float64List xyz, normal, rgb, alpha;
  final Int32List index;
  final List<_Finish?> finish; // null = glow (unlit)
  final Float64List world, screen, depth;
  final List<int> order;
  final Int32List shade;
  final Float32List positions;
  final Int32List colors;
}

/// Paints [Mesh]es with a tiny software rasterizer: transform, light,
/// depth-sort, then hand all triangles to [Canvas.drawVertices] in one call.
/// Works on every Flutter web renderer and needs no WebGL setup.
class MeshPainter {
  MeshPainter({
    Vector3? lightDirection,
    this.rimColor = const Color(0xff6AE99F),
  }) : light = (lightDirection ?? Vector3(-0.45, -0.7, 0.9))..normalize() {
    // Half vector between the light and a viewer looking down -z.
    final hx = light.x, hy = light.y, hz = light.z + 1;
    final hl = math.sqrt(hx * hx + hy * hy + hz * hz);
    _half = Vector3(hx / hl, hy / hl, hz / hl);
  }

  final Vector3 light;
  late final Vector3 _half;
  final Color rimColor;

  static final Paint _paint = Paint()..isAntiAlias = true;
  static final Expando<_Compiled> _compiled = Expando('compiled mesh');

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
    final m = _compiled[mesh] ??= _Compiled(mesh);
    final s = model.storage; // column-major
    final cx = center.dx, cy = center.dy;

    // Transform and project every vertex.
    final xyz = m.xyz, world = m.world, screen = m.screen;
    for (var i = 0; i < m.vertexCount; i++) {
      final x = xyz[i * 3], y = xyz[i * 3 + 1], z = xyz[i * 3 + 2];
      final wx = s[0] * x + s[4] * y + s[8] * z + s[12];
      final wy = s[1] * x + s[5] * y + s[9] * z + s[13];
      final wz = s[2] * x + s[6] * y + s[10] * z + s[14];
      world
        ..[i * 3] = wx
        ..[i * 3 + 1] = wy
        ..[i * 3 + 2] = wz;
      final d = focal - wz;
      final p = focal / (d < 0.2 ? 0.2 : d);
      screen
        ..[i * 2] = cx + wx * scale * p
        ..[i * 2 + 1] = cy - wy * scale * p;
    }

    // Light each face and record its depth.
    final index = m.index, normal = m.normal, depth = m.depth, shade = m.shade;
    final lx = light.x, ly = light.y, lz = light.z;
    final hx = _half.x, hy = _half.y, hz = _half.z;
    final rr = rimColor.r, rg = rimColor.g, rb = rimColor.b;
    for (var f = 0; f < m.faceCount; f++) {
      final a = index[f * 3], b = index[f * 3 + 1], c = index[f * 3 + 2];
      depth[f] = (world[a * 3 + 2] + world[b * 3 + 2] + world[c * 3 + 2]) / 3;
      final alpha = (m.alpha[f] * opacity * 255).round().clamp(0, 255);
      final finish = m.finish[f];
      if (finish == null) {
        shade[f] =
            (alpha << 24) |
            ((m.rgb[f * 3] * 255).round() << 16) |
            ((m.rgb[f * 3 + 1] * 255).round() << 8) |
            (m.rgb[f * 3 + 2] * 255).round();
        continue;
      }
      // Rotate the model-space normal into the world (models use rotation
      // only, so the upper 3x3 of the matrix is enough).
      final ox = normal[f * 3], oy = normal[f * 3 + 1], oz = normal[f * 3 + 2];
      var nx = s[0] * ox + s[4] * oy + s[8] * oz;
      var ny = s[1] * ox + s[5] * oy + s[9] * oz;
      var nz = s[2] * ox + s[6] * oy + s[10] * oz;
      // Double sided: light whichever side faces the viewer, so thin blades
      // never go black.
      final ax = screen[a * 2], ay = screen[a * 2 + 1];
      final cross =
          (screen[b * 2] - ax) * (screen[c * 2 + 1] - ay) -
          (screen[b * 2 + 1] - ay) * (screen[c * 2] - ax);
      if (cross >= 0) {
        nx = -nx;
        ny = -ny;
        nz = -nz;
      }
      final diffuse = math.max(0.0, nx * lx + ny * ly + nz * lz);
      final specAngle = math.max(0.0, nx * hx + ny * hy + nz * hz);
      final facingViewer = 1 - math.max(0.0, nz);
      final rim = facingViewer * facingViewer * finish.rim;
      final spec = finish.ks * math.pow(specAngle, finish.shininess);
      final lit = finish.ambient + finish.kd * diffuse;
      int ch(double base, double rimC) =>
          ((base * lit + spec + rimC * rim).clamp(0.0, 1.0) * 255).round();
      shade[f] =
          (alpha << 24) |
          (ch(m.rgb[f * 3], rr) << 16) |
          (ch(m.rgb[f * 3 + 1], rg) << 8) |
          ch(m.rgb[f * 3 + 2], rb);
    }

    // Painter's algorithm: far faces first.
    m.order.sort((x, y) => depth[x].compareTo(depth[y]));

    final positions = m.positions, colors = m.colors;
    for (var i = 0; i < m.faceCount; i++) {
      final f = m.order[i];
      final a = index[f * 3], b = index[f * 3 + 1], c = index[f * 3 + 2];
      positions
        ..[i * 6] = screen[a * 2]
        ..[i * 6 + 1] = screen[a * 2 + 1]
        ..[i * 6 + 2] = screen[b * 2]
        ..[i * 6 + 3] = screen[b * 2 + 1]
        ..[i * 6 + 4] = screen[c * 2]
        ..[i * 6 + 5] = screen[c * 2 + 1];
      final argb = shade[f];
      colors
        ..[i * 3] = argb
        ..[i * 3 + 1] = argb
        ..[i * 3 + 2] = argb;
    }
    final vertices = Vertices.raw(
      VertexMode.triangles,
      positions,
      colors: colors,
    );
    canvas.drawVertices(vertices, BlendMode.dst, _paint);
    vertices.dispose();
  }
}
