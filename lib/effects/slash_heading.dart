import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/custom_colors.dart';
import 'scroll_progress.dart';

/// Where a section title is on screen and how far its slice has progressed,
/// so the background katana can fly in and cut along it.
class SlashTarget {
  const SlashTarget(this.id, this.title, this.progress);

  /// Stable identity of the heading, for per-title effects such as sounds.
  final Object id;

  /// The title text's rectangle in global (screen) coordinates.
  final Rect title;

  /// The heading's scroll progress: 0 as it enters at the bottom of the
  /// screen, rising as it moves up. See [SlashTargets] for the phases.
  final double progress;

  /// The cut runs across the title from 62% height on the left to 38% on the
  /// right, overshooting the text by 30px each side.
  Offset get cutStart =>
      Offset(title.left - 30, title.top + title.height * 0.62);
  Offset get cutEnd =>
      Offset(title.right + 30, title.top + title.height * 0.38);
}

/// Every [SlashHeading] on the page, plus the shared timing of a slice, in
/// heading scroll progress:
/// * [approachEnd]: the katana has flown from its parked spot to the cut;
/// * [sweepEnd]: it has sliced along the cut, tip first;
/// * [exitEnd]: it is parked again on the right.
class SlashTargets {
  static const approachEnd = 0.12;
  static const sweepEnd = 0.26;
  static const exitEnd = 0.40;

  static final Set<_SlashHeadingState> _live = {};

  /// Headings currently on screen, measured now.
  static List<SlashTarget> visible(double viewport) {
    final out = <SlashTarget>[];
    for (final state in _live) {
      final box = state.context.findRenderObject() as RenderBox?;
      final titleBox =
          state._titleKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null ||
          titleBox == null ||
          !box.attached ||
          !titleBox.attached ||
          !box.hasSize ||
          !titleBox.hasSize) {
        continue;
      }
      final top = box.localToGlobal(Offset.zero).dy;
      final progress = (viewport - top) / (viewport + box.size.height);
      if (progress <= 0 || progress >= 1) continue;
      out.add(
        SlashTarget(
          state,
          titleBox.localToGlobal(Offset.zero) & titleBox.size,
          progress,
        ),
      );
    }
    return out;
  }
}

/// Section heading that the background katana slices as it scrolls in: the
/// title appears whole, the blade sweeps along a diagonal cut, the halves
/// split apart behind its tip with a glowing seam, then settle back together.
/// Everything is scroll-driven, so scrolling back up reverses it.
class SlashHeading extends StatefulWidget {
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
  State<SlashHeading> createState() => _SlashHeadingState();
}

class _SlashHeadingState extends State<SlashHeading> {
  final _titleKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Headings drawn off the page (e.g. for shader warm-up) are not targets.
    final offPage =
        context.dependOnInheritedWidgetOfExactType<ScrollProgressOverride>() !=
        null;
    offPage ? SlashTargets._live.remove(this) : SlashTargets._live.add(this);
  }

  @override
  void dispose() {
    SlashTargets._live.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final fontSize = width < 600 ? 40.0 : (width < 1000 ? 54.0 : 68.0);
    return ScrollProgress(
      builder: (context, p, _) {
        final appear = interval(
          p,
          0.02,
          SlashTargets.approachEnd,
          Curves.easeOut,
        );
        // How far the blade's tip has travelled along the cut.
        final sweep = interval(
          p,
          SlashTargets.approachEnd,
          SlashTargets.sweepEnd,
          Curves.easeInOut,
        );
        // The halves part as the blade passes and settle once it has gone.
        final split = math.sin(
          math.pi *
              interval(
                p,
                SlashTargets.approachEnd + 0.01,
                SlashTargets.exitEnd - 0.02,
              ),
        );
        final seam =
            1 - interval(p, SlashTargets.sweepEnd, SlashTargets.exitEnd);
        final style = TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: 1.05,
          letterSpacing: -1,
        );
        return Column(
          crossAxisAlignment: widget.alignment,
          children: [
            Opacity(
              opacity: appear,
              child: Transform.translate(
                offset: Offset(-30 * (1 - appear), 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28 * appear + 4,
                      height: 2,
                      color: CustomColors.secondary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.eyebrow.toUpperCase(),
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
            Opacity(
              opacity: appear,
              child: Transform.translate(
                offset: Offset(0, 24 * (1 - appear)),
                child: Stack(
                  key: _titleKey,
                  clipBehavior: Clip.none,
                  children: [
                    Transform.translate(
                      offset: Offset(-14 * split, -9 * split),
                      child: ClipPath(
                        clipper: const _HalfClipper(top: true),
                        child: Text(widget.title, style: style),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(14 * split, 9 * split),
                      child: ClipPath(
                        clipper: const _HalfClipper(top: false),
                        child: Text(
                          widget.title,
                          style: style.copyWith(color: const Color(0xffe9edf2)),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _CutFlashPainter(
                            sweep,
                            seam * (sweep > 0 ? 1 : 0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
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
  _CutFlashPainter(this.sweep, this.strength);

  /// 0..1: how far along the cut the blade's tip is.
  final double sweep;

  /// 0..1: seam brightness, fading once the blade has passed.
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    if (strength <= 0.01 || sweep <= 0) return;
    final a = Offset(-30, size.height * 0.62);
    final b = Offset(size.width + 30, size.height * 0.38);
    final tip = Offset.lerp(a, b, sweep)!;
    canvas.drawLine(
      a,
      tip,
      Paint()
        ..color = CustomColors.primary.withValues(alpha: 0.35 * strength)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      a,
      tip,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.95 * strength)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CutFlashPainter old) =>
      old.sweep != sweep || old.strength != strength;
}
