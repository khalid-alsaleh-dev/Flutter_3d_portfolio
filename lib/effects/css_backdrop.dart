import 'dart:ui';

import 'css_backdrop_stub.dart'
    if (dart.library.js_interop) 'css_backdrop_web.dart' as impl;

/// On web, the sky gradient and vignette are painted by the browser behind the
/// (transparent) Flutter canvas, see `web/index.html`. Full-screen gradients
/// are expensive to re-rasterize every frame in Flutter, but the browser
/// composites a CSS background for free.
class CssBackdrop {
  /// Whether the page background is handled by CSS.
  static bool get supported => impl.supported;

  static (int, int)? _last;

  /// Updates the CSS sky colors. Calls are cheap when nothing changed.
  static void setSky(Color top, Color bottom) {
    final key = (top.toARGB32(), bottom.toARGB32());
    if (key == _last) return;
    _last = key;
    impl.setSky(_css(top), _css(bottom));
  }

  static String _css(Color c) =>
      'rgb(${(c.r * 255).round()}, ${(c.g * 255).round()}, ${(c.b * 255).round()})';
}
