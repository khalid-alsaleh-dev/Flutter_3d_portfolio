import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../effects/scroll_progress.dart';
import '../effects/slash_heading.dart';
import '../effects/tilt_card.dart';
import '../utils/custom_colors.dart';
import '../widgets/emblem_view.dart';
import '../widgets/profile_portrait.dart';
import '../widgets/section_frame.dart';

class Overview extends StatelessWidget {
  const Overview({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionFrame(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SlashHeading(eyebrow: 'Introduction', title: 'Overview.'),
            const SizedBox(height: 36),
            LayoutBuilder(
              builder: (context, c) {
                final lines = ScrollProgress(
                  builder: (context, p, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < PortfolioData.overview.length; i++)
                          _Line(
                            text: PortfolioData.overview[i],
                            t: interval(
                              p,
                              0.08 + i * 0.05,
                              0.25 + i * 0.05,
                              Curves.easeOutCubic,
                            ),
                          ),
                      ],
                    );
                  },
                );
                // Portrait beside the introduction on wide screens, above it
                // on narrow ones.
                if (c.maxWidth < 900) {
                  return Column(
                    children: [
                      const ProfilePortrait(size: 200),
                      const SizedBox(height: 32),
                      lines,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: lines),
                    const SizedBox(width: 48),
                    const ProfilePortrait(size: 280),
                  ],
                );
              },
            ),
            const SizedBox(height: 64),
            const _RoleGrid(),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.text, required this.t});
  final String text;
  final double t;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, 40 * (1 - t)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 9, right: 16),
                child: Transform.rotate(
                  angle: math.pi / 4 + t * math.pi,
                  child: Container(
                    width: 9,
                    height: 9,
                    color: CustomColors.secondary,
                  ),
                ),
              ),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: width < 600 ? 16 : 19,
                      height: 1.55,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleGrid extends StatelessWidget {
  const _RoleGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 960 ? 4 : 2;
        const gap = 24.0;
        final cardWidth = (c.maxWidth - gap * (cols - 1)) / cols;
        return ScrollProgress(
          builder: (context, p, _) {
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < PortfolioData.roles.length; i++)
                  _flipIn(
                    interval(
                      p,
                      0.1 + i * 0.06,
                      0.32 + i * 0.06,
                      Curves.easeOutBack,
                    ),
                    SizedBox(
                      width: cardWidth,
                      height: cardWidth * (cols == 4 ? 1.15 : 1.0),
                      child: _RoleCard(role: PortfolioData.roles[i], index: i),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  /// Cards spin in on the Y axis like thrown blades.
  Widget _flipIn(double t, Widget child) {
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..translateByDouble(0, 80 * (1 - t), 0, 1)
          ..rotateY((1 - t) * math.pi * 0.9),
        child: child,
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role, required this.index});
  final Role role;
  final int index;

  @override
  Widget build(BuildContext context) {
    final glow = index.isEven ? CustomColors.primary : CustomColors.secondary;
    return TiltCard(
      glowColor: glow,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [glow.withValues(alpha: 0.22), Colors.transparent],
                ),
              ),
              child: EmblemView(role.emblem, color: glow),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            role.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(width: 30, height: 2, color: glow),
        ],
      ),
    );
  }
}
