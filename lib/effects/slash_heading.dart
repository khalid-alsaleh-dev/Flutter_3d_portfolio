import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/custom_colors.dart';
import 'scroll_progress.dart';

/// Section heading that starts sliced in two along a diagonal sword cut. As
/// it scrolls into view the halves slide back together and a blade flash runs
/// along the cut. Scrolling back up reverses it.
class SlashHeading extends StatelessWidget {
  const SlashHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.alignment = CrossAxisAlignment.start,
  });

  final String eyebrow;
  final String title;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final fontSize = width < 600 ? 40.0 : (width < 1000 ? 54.0 : 68.0);
    return ScrollProgress(builder: (context, p, _) {
      final join = interval(p, 0.06, 0.3, Curves.easeOutCubic);
      final flash = math.sin(interval(p, 0.24, 0.36) * math.pi);
      final eyebrowIn = interval(p, 0.04, 0.2);
      final apart = 1 - join;
      final style = TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        height: 1.05,
        letterSpacing: -1,
      );
      return Column(
        crossAxisAlignment: alignment,
        children: [
          Opacity(
            opacity: eyebrowIn,
            child: Transform.translate(
              offset: Offset(-30 * (1 - eyebrowIn), 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28 * eyebrowIn + 4,
                    height: 2,
                    color: CustomColors.secondary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    eyebrow.toUpperCase(),
                    style: const TextStyle(
                      color: CustomColors.primary,
                      fontSize: 14,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Opacity(
                opacity: join.clamp(0.0, 1.0) * 0.8 + 0.2,
                child: Transform.translate(
                  offset: Offset(-70 * apart, -18 * apart),
                  child: ClipPath(
                    clipper: const _HalfClipper(top: true),
                    child: Text(title, style: style),
                  ),
                ),
              ),
              Opacity(
                opacity: join.clamp(0.0, 1.0) * 0.8 + 0.2,
                child: Transform.translate(
                  offset: Offset(70 * apart, 18 * apart),
                  child: ClipPath(
                    clipper: const _HalfClipper(top: false),
                    child: Text(title,
                        style: style.copyWith(color: const Color(0xffe9edf2))),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _CutFlashPainter(flash, apart)),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

/// The cut runs from 62% height on the left to 38% on the right.
Path _cutPath(Size size, bool top) {
  final path = Path();
  final left = size.height * 0.62, right = size.height * 0.38;
  if (top) {
    path
      ..moveTo(-40, -40)
      ..lineTo(size.width + 40, -40)
      ..lineTo(size.width + 40, right)
      ..lineTo(-40, left);
  } else {
    path
      ..moveTo(-40, left)
      ..lineTo(size.width + 40, right)
      ..lineTo(size.width + 40, size.height + 40)
      ..lineTo(-40, size.height + 40);
  }
  return path..close();
}

class _HalfClipper extends CustomClipper<Path> {
  const _HalfClipper({required this.top});
  final bool top;

  @override
  Path getClip(Size size) => _cutPath(size, top);

  @override
  bool shouldReclip(covariant _HalfClipper oldClipper) => oldClipper.top != top;
}

class _CutFlashPainter extends CustomPainter {
  _CutFlashPainter(this.flash, this.apart);
  final double flash;
  final double apart;

  @override
  void paint(Canvas canvas, Size size) {
    final a = Offset(-30, size.height * 0.62);
    final b = Offset(size.width + 30, size.height * 0.38);
    if (apart > 0.02) {
      // A faint red seam while the heading is still cut.
      canvas.drawLine(
          a,
          b,
          Paint()
            ..color = CustomColors.secondary.withValues(alpha: 0.6 * apart)
            ..strokeWidth = 1.5);
    }
    if (flash <= 0.01) return;
    final along = Offset.lerp(a, b, flash)!;
    canvas.drawLine(
        a,
        along,
        Paint()
          ..color = CustomColors.primary.withValues(alpha: 0.8 * flash)
          ..strokeWidth = 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawLine(
        a,
        along,
        Paint()
          ..color = Colors.white.withValues(alpha: flash)
          ..strokeWidth = 1.6);
  }

  @override
  bool shouldRepaint(covariant _CutFlashPainter old) =>
      old.flash != flash || old.apart != apart;
}
