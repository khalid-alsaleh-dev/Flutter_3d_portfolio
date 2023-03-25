import 'package:flutter/material.dart';
import 'package:flutter_3d_portfolio/ninja_game/core/ninja_animation.dart';
import 'package:flutter_3d_portfolio/ninja_game/utils/game_audio.dart';
import 'package:flutter_3d_portfolio/screens/home.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NinjaAnimation.load();
  await GameAudio.preload();
  runApp(const Flutter3dPortfolio());
}

class Flutter3dPortfolio extends StatelessWidget {
  const Flutter3dPortfolio({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Ebrima'
      ),
      home: const Home(),
    ).animate().fadeIn(duration: 500.milliseconds);
  }
}