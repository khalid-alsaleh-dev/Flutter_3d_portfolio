import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../effects/scroll_progress.dart';
import '../effects/slash_heading.dart';
import '../effects/tilt_card.dart';
import '../three_d/mesh.dart';
import '../three_d/models.dart';
import '../utils/custom_colors.dart';
import '../widgets/emblem_view.dart';
import '../widgets/section_frame.dart';
import '../widgets/tech_chip.dart';

/// Work history on a timeline whose spine is a katana blade that draws itself
/// as you scroll. Each stop is a spinning 3D shuriken.
class Experience extends StatelessWidget {
  const Experience({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return SectionFrame(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 120),
        child: Column(
          crossAxisAlignment: wide
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            SlashHeading(
              eyebrow: 'What I have done so far',
              title: 'Work Experience.',
              alignment: wide
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
            ),
            const SizedBox(height: 72),
            ScrollProgress(
              builder: (context, p, _) {
                final drawn = interval(p, 0.12, 0.72);
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Align(
                        alignment: wide
                            ? Alignment.topCenter
                            : Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: wide ? 0 : 22),
                          child: SizedBox(
                            width: 18,
                            height: double.infinity,
                            child: CustomPaint(
                              painter: _BladeSpinePainter(drawn),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        for (var i = 0; i < PortfolioData.jobs.length; i++)
                          _JobRow(
                            job: PortfolioData.jobs[i],
                            index: i,
                            wide: wide,
                            spin: p,
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _JobRow extends StatelessWidget {
  const _JobRow({
    required this.job,
    required this.index,
    required this.wide,
    required this.spin,
  });

  final Job job;
  final int index;
  final bool wide;
  final double spin;

  @override
  Widget build(BuildContext context) {
    final fromLeft = wide && index.isEven;
    return Padding(
      padding: const EdgeInsets.only(bottom: 56),
      child: ScrollProgress(
        builder: (context, p, _) {
          final t = interval(p, 0.08, 0.34, Curves.easeOutCubic);
          final card = _swingIn(t, fromLeft, _JobCard(job: job, index: index));
          final time = Opacity(
            opacity: t,
            child: Text(
              job.time,
              textAlign: fromLeft ? TextAlign.left : TextAlign.right,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
          final node = SizedBox(
            width: 62,
            height: 62,
            child: CustomPaint(painter: _ShurikenNode(spin * 26 + index, t)),
          );
          if (!wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                node,
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 18, bottom: 12),
                        child: time,
                      ),
                      card,
                    ],
                  ),
                ),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: fromLeft
                    ? card
                    : Padding(
                        padding: const EdgeInsets.only(top: 20, right: 32),
                        child: time,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: node,
              ),
              Expanded(
                child: fromLeft
                    ? Padding(
                        padding: const EdgeInsets.only(top: 20, left: 32),
                        child: time,
                      )
                    : card,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _swingIn(double t, bool fromLeft, Widget child) {
    final dir = fromLeft ? -1.0 : 1.0;
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Transform(
        alignment: fromLeft ? Alignment.centerRight : Alignment.centerLeft,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..translateByDouble(dir * 140 * (1 - t), 0, 0, 1)
          ..rotateY(-dir * (1 - t) * 1.1),
        child: child,
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.index});
  final Job job;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TiltCard(
      maxTilt: 0.1,
      glowColor: index.isOdd ? CustomColors.secondary : CustomColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: EmblemView(job.emblem),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  job.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            job.summary,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          for (final point in job.highlights) _Highlight(text: point),
          if (job.stack.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final tech in job.stack) TechChip(label: tech)],
            ),
          ],
        ],
      ),
    );
  }
}

class _Highlight extends StatelessWidget {
  const _Highlight({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 9, right: 12),
            child: Container(
              width: 12,
              height: 2,
              color: CustomColors.secondary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 14.5,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A vertical katana: steel blade with a glowing edge, drawn down to
/// [progress] of the available height, ending in a sharp tip.
class _BladeSpinePainter extends CustomPainter {
  _BladeSpinePainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final cx = size.width / 2;
    final length = size.height * progress;
    final half = 3.5;
    final tip = 22.0;
    final path = Path()
      ..moveTo(cx - half, 0)
      ..lineTo(cx + half, 0)
      ..lineTo(cx + half, math.max(0, length - tip))
      ..lineTo(cx, length)
      ..lineTo(cx - half, math.max(0, length - tip))
      ..close();
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, length),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, 0),
          [
            Colors.transparent,
            CustomColors.primary.withValues(alpha: 0.35),
            Colors.transparent,
          ],
          const [0, 0.5, 1],
        ),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx - half, 0),
          Offset(cx + half, 0),
          const [Color(0xff6f7a84), Color(0xfff4f8fb), Color(0xff9aa5af)],
          const [0, 0.45, 1],
        ),
    );
    // The glint that rides down the blade with the scroll.
    final glintY = length - tip - 40;
    if (glintY > 0) {
      canvas.drawCircle(
        Offset(cx, glintY),
        14,
        Paint()
          ..shader = ui.Gradient.radial(Offset(cx, glintY), 14, [
            Colors.white,
            Colors.white.withValues(alpha: 0),
          ]),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BladeSpinePainter old) =>
      old.progress != progress;
}

class _ShurikenNode extends CustomPainter {
  _ShurikenNode(this.angle, this.reveal);
  final double angle;
  final double reveal;

  static final _painter = MeshPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawCircle(
      c,
      size.width / 2,
      Paint()..color = CustomColors.darkBackground,
    );
    canvas.drawCircle(
      c,
      size.width / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = CustomColors.primary.withValues(alpha: 0.3 + 0.5 * reveal),
    );
    final model = Matrix4.identity()
      ..rotateX(0.5)
      ..rotateZ(angle);
    _painter.paint(
      canvas,
      Models.shuriken,
      model,
      center: c,
      scale: size.width * 0.36 * (0.4 + 0.6 * reveal),
    );
  }

  @override
  bool shouldRepaint(covariant _ShurikenNode old) =>
      old.angle != angle || old.reveal != reveal;
}
