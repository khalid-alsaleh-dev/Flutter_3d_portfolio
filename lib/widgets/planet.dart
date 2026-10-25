import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Planet extends StatelessWidget {
  const Planet({super.key});

  // On web the <model-viewer> element fetches `src` relative to the page, and
  // Flutter serves bundled assets under an extra `assets/` folder.
  static const _model = 'assets/three_d_models/planet/scene.gltf';

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
