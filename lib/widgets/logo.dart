import 'package:flutter/material.dart';
import 'package:flutter_3d_portfolio/utils/image_assets.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Logo extends StatelessWidget {
  const Logo({super.key, required this.homeKey});
  final GlobalKey homeKey;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Scrollable.ensureVisible(homeKey.currentContext!,duration: 1.5.seconds,curve: Curves.easeIn);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(ImageAssets.logo),
          const SizedBox(
            width: 10,
          ),
          const Text('Khalid',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(
            width: 8,
          ),
          const Text('Al-Saleh',
              style: TextStyle(fontSize: 25, color: Colors.white))
        ],
      ),
    );
  }
}
