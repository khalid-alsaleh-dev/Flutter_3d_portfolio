import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../effects/scroll_progress.dart';
import '../effects/slash_heading.dart';
import '../effects/tilt_card.dart';
import '../utils/custom_colors.dart';
import '../widgets/section_frame.dart';
import '../widgets/tech_chip.dart';

/// Skill groups as tilt cards that unsheathe (slide up and unfold) in a
/// staggered wave as the section scrolls into view.
class Skills extends StatelessWidget {
  const Skills({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionFrame(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SlashHeading(eyebrow: 'What I wield', title: 'Arsenal.'),
            const SizedBox(height: 48),
            LayoutBuilder(builder: (context, c) {
              final cols = c.maxWidth >= 960 ? 3 : (c.maxWidth >= 600 ? 2 : 1);
              const gap = 22.0;
              final cardWidth = (c.maxWidth - gap * (cols - 1)) / cols;
              return ScrollProgress(builder: (context, p, _) {
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (var i = 0; i < PortfolioData.skills.length; i++)
                      _unfold(
                        interval(p, 0.08 + i * 0.04, 0.3 + i * 0.04,
                            Curves.easeOutCubic),
                        SizedBox(
                          width: cardWidth,
                          child: _SkillCard(
                              group: PortfolioData.skills[i], index: i),
                        ),
                      ),
                  ],
                );
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _unfold(double t, Widget child) {
    return Opacity(
      opacity: t,
      child: Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..translateByDouble(0, 60 * (1 - t), 0, 1)
          ..rotateX((1 - t) * math.pi / 2.5),
        child: child,
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({required this.group, required this.index});
  final SkillGroup group;
  final int index;

  @override
  Widget build(BuildContext context) {
    final color = index.isEven ? CustomColors.primary : CustomColors.secondary;
    return TiltCard(
      glowColor: color,
      maxTilt: 0.14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 18, height: 2, color: color),
              const SizedBox(width: 10),
              Text(
                group.title.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  letterSpacing: 3.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final skill in group.skills)
                TechChip(label: skill, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}
