import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class DesktopPc extends StatelessWidget {
  const DesktopPc({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:(context,constraints){
        double maxWidth=constraints.maxWidth;
        return SizedBox(
          width: maxWidth*0.8,
          height:maxWidth* 0.45,
          child: ModelViewer(
          loading: Loading.eager,
          src: 'assets/three_d_models/desktop_pc/scene.gltf',
          alt: "A 3D model of a gaming desktop",
          cameraOrbit: '90deg 75deg 1cm',minCameraOrbit: '',
          disableZoom: true,
          cameraControls: true,
          disableTap: true,
          autoPlay: true,),
        );
      }
    );
  }
}