import 'package:flutter/material.dart';

import 'effects/css_backdrop.dart';
import 'screens/home.dart';
import 'utils/custom_colors.dart';

void main() {
  runApp(const Flutter3dPortfolio());
}

class Flutter3dPortfolio extends StatelessWidget {
  const Flutter3dPortfolio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khalid Al-Saleh · Shinobi of Code',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Ebrima',
        scaffoldBackgroundColor: CssBackdrop.supported
            ? Colors.transparent
            : CustomColors.darkBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomColors.primary,
          brightness: Brightness.dark,
        ),
      ),
      home: const Home(),
    );
  }
}
