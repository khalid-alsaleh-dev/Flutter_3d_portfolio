import 'dart:math' as math;
import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import 'mesh.dart';

typedef _FaceStyle = (Color, Material3d) Function(int segment, int side);

/// Procedurally built low-poly ninja weapons. Each model is generated once and
/// cached, then posed every frame with a [Matrix4].
class Models {
  static final Mesh katana = _buildKatana();
  static final Mesh shuriken = _buildShuriken();
  static final Mesh kunai = _buildKunai();

  static const _edgeSteel = Color(0xffeef3f6);
  static const _flatSteel = Color(0xffa3adb6);
  static const _spineSteel = Color(0xff79838c);
  static const _gold = Color(0xffc9962e);
  static const _darkGold = Color(0xff6e5520);
  static const _wrapBlack = Color(0xff16161b);
  static const _wrapRed = Color(0xff8e1d2c);

  /// Connects consecutive rings of points with quads.
  static void _tube(Mesh mesh, List<List<Vector3>> rings, _FaceStyle style,
      {bool closed = true}) {
    final ids = [
      for (final ring in rings)
        [for (final p in ring) mesh.addVertex(p.x, p.y, p.z)]
    ];
    for (var s = 0; s < ids.length - 1; s++) {
      final a = ids[s], b = ids[s + 1];
      final sides = closed ? a.length : a.length - 1;
      for (var k = 0; k < sides; k++) {
        final k2 = (k + 1) % a.length;
        final (color, material) = style(s, k);
        mesh.addQuad(a[k], a[k2], b[k2], b[k], color, material);
      }
    }
  }

  /// Fans a ring of points to a single apex (tips, caps).
  static void _fan(Mesh mesh, List<Vector3> ring, Vector3 apex, Color color,
      Material3d material) {
    final c = mesh.addVertex(apex.x, apex.y, apex.z);
    final ids = [for (final p in ring) mesh.addVertex(p.x, p.y, p.z)];
    for (var k = 0; k < ids.length; k++) {
      mesh.addTri(c, ids[k], ids[(k + 1) % ids.length], color, material);
    }
  }

  static List<Vector3> _ellipse(
      double x, double ry, double rz, int segments, {double y0 = 0}) {
    return [
      for (var k = 0; k < segments; k++)
        Vector3(x, y0 + ry * math.cos(2 * math.pi * k / segments),
            rz * math.sin(2 * math.pi * k / segments))
    ];
  }

  static Mesh _buildKatana() {
    final mesh = Mesh();
    const bladeLength = 4.2;
    const width = 0.3;
    const thickness = 0.07;
    const segments = 14;

    // Blade: five-point cross-section (edge, ridge, spine) swept along a
    // gentle curve, then pinched into the kissaki (tip).
    final rings = <List<Vector3>>[];
    for (var s = 0; s <= segments; s++) {
      final t = s / segments;
      final x = 0.18 + t * (bladeLength - 0.35);
      final curve = 0.22 * t * t;
      final w = width * (1 - 0.18 * t);
      final th = thickness * (1 - 0.35 * t);
      rings.add([
        Vector3(x, curve - w / 2, 0), // cutting edge
        Vector3(x, curve + w * 0.12, th), // shinogi ridge, front
        Vector3(x, curve + w / 2, th * 0.55), // spine, front
        Vector3(x, curve + w / 2, -th * 0.55), // spine, back
        Vector3(x, curve + w * 0.12, -th), // shinogi ridge, back
      ]);
    }
    _tube(mesh, rings, (s, side) {
      return switch (side) {
        0 || 4 => (_edgeSteel, Material3d.steel),
        2 => (_spineSteel, Material3d.steel),
        _ => (_flatSteel, Material3d.steel),
      };
    });
    _fan(mesh, rings.last, Vector3(bladeLength + 0.05, 0.22 + 0.05, 0),
        _edgeSteel, Material3d.steel);

    // Habaki (blade collar).
    _tube(mesh, [
      _ellipse(0.0, 0.19, 0.06, 8),
      _ellipse(0.2, 0.18, 0.055, 8),
    ], (_, _) => (_gold, Material3d.gold));

    // Tsuba (guard): a thick disc.
    final front = _ellipse(-0.03, 0.42, 0.42, 20);
    final back = _ellipse(-0.1, 0.42, 0.42, 20);
    _tube(mesh, [front, back], (_, _) => (_darkGold, Material3d.gold));
    _fan(mesh, front, Vector3(-0.03, 0, 0), _gold, Material3d.gold);
    _fan(mesh, back, Vector3(-0.1, 0, 0), _gold, Material3d.gold);

    // Tsuka (handle) with a checkered wrap that reads as the diamond ito.
    const handleSegments = 10;
    final handle = <List<Vector3>>[];
    for (var s = 0; s <= handleSegments; s++) {
      final t = s / handleSegments;
      final bulge = 1 + 0.06 * math.sin(t * math.pi);
      handle.add(_ellipse(-0.1 - t * 1.35, 0.15 * bulge, 0.11 * bulge, 6,
          y0: -0.03 * t));
    }
    _tube(mesh, handle, (s, side) {
      return (s + side).isEven
          ? (_wrapBlack, Material3d.cloth)
          : (_wrapRed, Material3d.cloth);
    });
    // Kashira (pommel cap).
    final cap = _ellipse(-1.52, 0.16, 0.12, 6, y0: -0.03);
    _tube(mesh, [handle.last, cap], (_, _) => (_gold, Material3d.gold));
    _fan(mesh, cap, Vector3(-1.56, -0.03, 0), _darkGold, Material3d.gold);

    _recenter(mesh);
    return mesh;
  }

  static Mesh _buildShuriken() {
    final mesh = Mesh();
    const points = 4;
    const outer = 1.0;
    const inner = 0.3;
    const edge = 0.025;
    const bevel = 0.14;
    final ring = <Vector3>[];
    for (var k = 0; k < points * 2; k++) {
      final a = math.pi * k / points;
      final r = k.isEven ? outer : inner;
      ring.add(Vector3(r * math.cos(a), r * math.sin(a), 0));
    }
    final front = [for (final p in ring) Vector3(p.x, p.y, edge)];
    final back = [for (final p in ring) Vector3(p.x, p.y, -edge)];
    _tube(mesh, [front, back], (_, _) => (Models._edgeSteel, Material3d.steel));

    // Bevelled faces: each blade alternates bright and dark planes, which
    // gives the spinning star its flicker.
    final cf = mesh.addVertex(0, 0, bevel);
    final cb = mesh.addVertex(0, 0, -bevel);
    final fIds = [for (final p in front) mesh.addVertex(p.x, p.y, p.z)];
    final bIds = [for (final p in back) mesh.addVertex(p.x, p.y, p.z)];
    for (var k = 0; k < fIds.length; k++) {
      final k2 = (k + 1) % fIds.length;
      final color = k.isEven ? const Color(0xffb7c0c8) : const Color(0xff4a525a);
      mesh.addTri(cf, fIds[k], fIds[k2], color, Material3d.steel);
      mesh.addTri(cb, bIds[k2], bIds[k], color, Material3d.steel);
    }
    // Centre ring.
    _tube(mesh, [
      _ellipse(0, 0.12, 0.12, 10).map((p) => Vector3(p.y, p.z, bevel + 0.01)).toList(),
      _ellipse(0, 0.12, 0.12, 10).map((p) => Vector3(p.y, p.z, -bevel - 0.01)).toList(),
    ], (_, _) => (const Color(0xff2a2e33), Material3d.steel));
    return mesh;
  }

  static Mesh _buildKunai() {
    final mesh = Mesh();
    // Leaf blade: diamond section that widens then narrows to the tip.
    final rings = <List<Vector3>>[];
    const steps = 6;
    for (var s = 0; s <= steps; s++) {
      final t = s / steps;
      final x = t * 1.5;
      final w = 0.32 * math.sin(math.pi * (0.25 + 0.75 * t)) + 0.04;
      const th = 0.05;
      rings.add([
        Vector3(x, -w, 0),
        Vector3(x, 0, th),
        Vector3(x, w, 0),
        Vector3(x, 0, -th),
      ]);
    }
    _tube(mesh, rings, (s, side) => side.isEven
        ? (_flatSteel, Material3d.steel)
        : (_edgeSteel, Material3d.steel));
    _fan(mesh, rings.last, Vector3(1.75, 0, 0), _edgeSteel, Material3d.steel);
    // Wrapped grip and ring pommel.
    final grip = <List<Vector3>>[];
    for (var s = 0; s <= 4; s++) {
      grip.add(_ellipse(-s * 0.22, 0.07, 0.07, 6));
    }
    _tube(mesh, grip, (s, side) => (s + side).isEven
        ? (_wrapBlack, Material3d.cloth)
        : (_wrapRed, Material3d.cloth));
    final loop = <List<Vector3>>[];
    for (var k = 0; k <= 12; k++) {
      final a = 2 * math.pi * k / 12;
      final cx = -1.05 + 0.16 * math.cos(a);
      final cy = 0.16 * math.sin(a);
      loop.add(_ellipse(0, 0.035, 0.035, 5)
          .map((p) => Vector3(cx + p.y * math.cos(a), cy + p.y * math.sin(a), p.z))
          .toList());
    }
    _tube(mesh, loop, (_, _) => (_darkGold, Material3d.gold));
    _recenter(mesh);
    return mesh;
  }

  static void _recenter(Mesh mesh) {
    var minX = double.infinity, maxX = -double.infinity;
    for (final v in mesh.vertices) {
      minX = math.min(minX, v.x);
      maxX = math.max(maxX, v.x);
    }
    final cx = (minX + maxX) / 2;
    for (final v in mesh.vertices) {
      v.x -= cx;
    }
  }
}
