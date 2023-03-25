import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Planet extends StatelessWidget {
  const Planet({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:(context,constraints){
        return ModelViewer(
        loading: Loading.eager,
        src: 'assets/three_d_models/planet/scene.gltf',
        alt: "A 3D model of a planet",
        disableZoom: true,
        cameraControls: true,
        disableTap: true,
        autoPlay: true,);
      }
    );
  }
}