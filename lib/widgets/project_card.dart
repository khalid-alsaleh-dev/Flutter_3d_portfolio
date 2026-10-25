import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../effects/tilt_card.dart';
import '../utils/custom_colors.dart';
import '../utils/launch.dart';
import 'app_mockup.dart';
import 'site_preview.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    this.tilt = true,
    this.compact = false,
  });

  final Project project;
  final bool tilt;

  /// For the narrow cards hanging in the dojo: a three-line description with
  /// "Read more" opening the full card, and icon-only links.
  final bool compact;

  void _showDetails(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            child: ProjectCard(project: project, tilt: false),
          ),
        ),
      ),
    );
  }

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
            child: switch ((
              project.preview,
              project.url ?? project.previewHost,
            )) {
              (final preview?, final url?) => SitePreview(
                asset: preview,
                aspect: project.previewAspect,
                url: url,
                accent: project.accent,
              ),
              _ => AppMockup(project: project),
            },
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
                  // Compact cards hang in the dojo above the ninja, so they
                  // show a preview of the text and open the rest on demand.
                  maxLines: compact ? 3 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: compact ? 13.5 : 14.5,
                    height: 1.5,
                  ),
                ),
                if (compact)
                  TextButton(
                    onPressed: () => _showDetails(context),
                    style: TextButton.styleFrom(
                      foregroundColor: CustomColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Read more →'),
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
                if (!project.hasLinks)
                  _Note(text: project.note)
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (project.appStore case final link?)
                        _LinkChip(
                          compact: compact,
                          icon: Icons.apple_rounded,
                          label: 'App Store',
                          onTap: () => openUrl(link),
                        ),
                      if (project.playStore case final link?)
                        _LinkChip(
                          compact: compact,
                          icon: Icons.shop_rounded,
                          label: 'Google Play',
                          onTap: () => openUrl(link),
                        ),
                      if (project.url case final link?)
                        _LinkChip(
                          compact: compact,
                          icon: Icons.language_rounded,
                          label: 'Website',
                          onTap: () => openUrl(link),
                        ),
                      if (project.github case final link?)
                        _LinkChip(
                          compact: compact,
                          icon: Icons.code_rounded,
                          label: 'GitHub',
                          onTap: () => openUrl(link),
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

class _Note extends StatelessWidget {
  const _Note({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            text.startsWith('Private')
                ? Icons.lock_outline_rounded
                : Icons.language_rounded,
            size: 16,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: 6),
        // Flexible so long notes wrap on narrow cards (the dojo's are ~200px).
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
              letterSpacing: 0.5,
            ),
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
    this.compact = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(color: CustomColors.primary.withValues(alpha: 0.7));
    if (compact) {
      return Tooltip(
        message: label,
        child: IconButton(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          color: Colors.white,
          style: IconButton.styleFrom(side: side),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: side,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
