import 'package:web/web.dart' as web;

bool _added = false;

/// Adds the `<model-viewer>` library to the page. Elements created before it
/// arrives upgrade once it has loaded.
void load() {
  if (_added) return;
  _added = true;
  web.document.head!.appendChild(
    web.HTMLScriptElement()
      ..type = 'module'
      ..src = 'assets/packages/model_viewer_plus/assets/model-viewer.min.js',
  );
}
