import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import 'load_when_near.dart';
import 'model_viewer_script_stub.dart'
    if (dart.library.js_interop) 'model_viewer_script_web.dart'
    as model_viewer_script;

/// The 3D planet beside the contact form. It sits at the very bottom of the
/// page, so neither the model nor the `<model-viewer>` library (~260 KB) is
/// fetched until the visitor scrolls near it.
class Planet extends StatelessWidget {
  const Planet({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadWhenNear(child: _PlanetView());
  }
}

class _PlanetView extends StatefulWidget {
  const _PlanetView();

  @override
  State<_PlanetView> createState() => _PlanetViewState();
}

class _PlanetViewState extends State<_PlanetView> {
  // On web the <model-viewer> element fetches `src` relative to the page, and
  // Flutter serves bundled assets under an extra `assets/` folder.
  static const _model = 'assets/three_d_models/planet/scene.gltf';

  @override
  void initState() {
    super.initState();
    model_viewer_script.load();
  }

  @override
  Widget build(BuildContext context) {
    return const ModelViewer(
      src: kIsWeb ? 'assets/$_model' : _model,
      alt: 'A 3D model of a planet',
      loading: Loading.eager,
      autoRotate: true,
      autoRotateDelay: 0,
      rotationPerSecond: '25deg',
      cameraControls: true,
      disableZoom: true,
      disablePan: true,
      disableTap: true,
      interactionPrompt: InteractionPrompt.none,
      autoPlay: true,
      debugLogging: false,
    );
  }
}
