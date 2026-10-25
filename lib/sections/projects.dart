import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../effects/scroll_progress.dart';
import '../effects/slash_heading.dart';
import '../ninja_game/dojo.dart';
import '../utils/custom_colors.dart';
import '../widgets/project_card.dart';
import '../widgets/section_frame.dart';

class Projects extends StatefulWidget {
  const Projects({super.key});

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  bool _listView = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final canPlay = width >= 1100;
    final playing = canPlay && !_listView;
    return SectionFrame(
      maxWidth: 1400,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SlashHeading(eyebrow: 'My work', title: 'Projects.'),
            const SizedBox(height: 20),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              children: [
                Text(
                  playing
                      ? 'Each project is sealed behind a metal plate. Walk the ninja up to a plate and cut its chains.'
                      : 'A few things I have built.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 17,
                  ),
                ),
                if (canPlay)
                  TextButton(
                    onPressed: () => setState(() => _listView = !_listView),
                    child: Text(
                      _listView ? 'Play the dojo instead' : 'Just show me the list',
                      style: const TextStyle(
                        color: CustomColors.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: CustomColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 36),
            if (playing) const Dojo() else const _ProjectGrid(),
          ],
        ),
      ),
    );
  }
}

class _ProjectGrid extends StatelessWidget {
  const _ProjectGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 1200 ? 4 : (c.maxWidth >= 640 ? 2 : 1);
      const gap = 24.0;
      final cardWidth = (c.maxWidth - gap * (cols - 1)) / cols;
      return ScrollProgress(builder: (context, p, _) {
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < PortfolioData.projects.length; i++)
              _throwIn(
                interval(p, 0.05 + i * 0.05, 0.3 + i * 0.05, Curves.easeOutCubic),
                i,
                SizedBox(
                  width: cardWidth,
                  child: ProjectCard(project: PortfolioData.projects[i]),
                ),
              ),
          ],
        );
      });
    });
  }

  /// Cards arrive like thrown shuriken: spinning in from below.
  Widget _throwIn(double t, int i, Widget child) {
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..translateByDouble(0, 160 * (1 - t), 0, 1)
          ..rotateZ((1 - t) * (i.isEven ? -0.3 : 0.3))
          ..rotateX((1 - t) * math.pi / 3),
        child: child,
      ),
    );
  }
}
