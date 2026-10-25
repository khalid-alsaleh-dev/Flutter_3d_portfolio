import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../effects/scroll_progress.dart';
import '../utils/custom_colors.dart';
import '../utils/launch.dart';
import 'location_tag.dart';
import 'section_frame.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return SectionFrame(
      child: Padding(
        padding: const EdgeInsets.only(top: 60, bottom: 40),
        child: Column(
          children: [
            ScrollProgress(builder: (context, p, _) {
              final t = interval(p, 0.0, 0.4, Curves.easeOutCubic);
              return ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  colors: const [Colors.white, CustomColors.primary, Colors.white],
                  stops: [0, t, (t + 0.2).clamp(0, 1)],
                ).createShader(rect),
                child: Text(
                  "Let's build something legendary.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width < 600 ? 30 : 52,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => sendEmail(subject: 'Hello Khalid!'),
              child: const Text(
                Links.email,
                style: TextStyle(color: CustomColors.primary, fontSize: 18),
              ),
            ),
            const SizedBox(height: 6),
            const LocationTag(),
            const SizedBox(height: 48),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 24,
              runSpacing: 8,
              children: [
                Text(
                  '© ${DateTime.now().year} khalid-alsaleh-dev. All rights reserved.',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
                ),
                Text(
                  'Built with Flutter · Hand-rolled 3D · No ninjas were harmed',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
