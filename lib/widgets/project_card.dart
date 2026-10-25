import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../effects/tilt_card.dart';
import '../utils/custom_colors.dart';
import '../utils/launch.dart';
import 'app_mockup.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, this.tilt = true});

  final Project project;
  final bool tilt;

  @override
  Widget build(BuildContext context) {
    return TiltCard(
      maxTilt: tilt ? 0.16 : 0,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: AppMockup(project: project),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  project.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 14.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in project.tags)
                      Text(
                        '#$tag',
                        style: TextStyle(
                          color: CustomColors.primary.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (project.github == null && project.url == null)
                  const _PrivateNote()
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (project.github case final github?)
                        _LinkChip(
                          icon: Icons.code_rounded,
                          label: 'GitHub',
                          onTap: () => openUrl(github),
                        ),
                      if (project.url case final url?)
                        _LinkChip(
                          icon: Icons.open_in_new_rounded,
                          label: 'Open',
                          onTap: () => openUrl(url),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivateNote extends StatelessWidget {
  const _PrivateNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 16,
          color: Colors.white.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 6),
        Text(
          'Private client project',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: CustomColors.primary.withValues(alpha: 0.7)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
