import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../effects/scroll_progress.dart';
import '../three_d/shuriken_icon.dart';
import '../utils/custom_colors.dart';
import '../utils/image_assets.dart';

/// Circular portrait with a glowing blade ring. As the section scrolls in,
/// the photo unveils and a 3D shuriken travels around the ring; scrolling back
/// reverses it.
class ProfilePortrait extends StatelessWidget {
  const ProfilePortrait({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ScrollProgress(
      builder: (context, p, _) {
        final reveal = interval(p, 0.05, 0.3, Curves.easeOutBack);
        final orbit = interval(p, 0.05, 0.9) * math.pi * 3 - math.pi / 2;
        final shuriken = size * 0.2;
        final ringRadius = size / 2;
        return SizedBox(
          width: size + shuriken,
          height: size + shuriken,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Soft glow behind the portrait.
              Container(
                width: size * 1.25,
                height: size * 1.25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      CustomColors.primary.withValues(
                        alpha: 0.22 * reveal.clamp(0, 1),
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // The blade ring sweeps open with the scroll.
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: _RingPainter(reveal.clamp(0.0, 1.0)),
                ),
              ),
              Opacity(
                opacity: reveal.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.85 + 0.15 * reveal,
                  child: Container(
                    width: size - 14,
                    height: size - 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CustomColors.darkBackground,
                        width: 4,
                      ),
                      image: const DecorationImage(
                        image: AssetImage(ImageAssets.profile),
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                ),
              ),
              // A shuriken riding the ring.
              Transform.translate(
                offset: Offset(math.cos(orbit), math.sin(orbit)) * ringRadius,
                child: SizedBox(
                  width: shuriken,
                  height: shuriken,
                  child: ShurikenIcon(angle: orbit * 4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sweep = math.pi * 2 * progress;
    canvas.drawArc(
      rect.deflate(1),
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: const [
            CustomColors.primary,
            CustomColors.steel,
            CustomColors.secondary,
            CustomColors.primary,
          ],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
