import 'package:flutter/material.dart';

import '../sections/experience.dart';
import '../sections/overview.dart';
import '../sections/skills.dart';
import '../widgets/footer.dart';
import 'ninja_duel.dart';
import 'scroll_progress.dart';

/// Compiles the page's GPU shaders before the visitor scrolls to them.
///
/// The first time a visual effect is drawn, the browser compiles a GPU program
/// for it; with the JavaScript renderer that blocks the frame, so each section
/// used to hitch the first time it scrolled into view. Shortly after the hero
/// appears, this draws the real sections, mid-reveal, one per frame, at a few
/// percent of their size and 1% opacity under the navbar, where nobody can
/// see them. Once each has been drawn its shaders are cached for the session.
///
/// Sections that load heavy assets or embed platform views (projects with the
/// game and live previews, contact with the 3D planet) are left out.
class ShaderPrimer extends StatefulWidget {
  const ShaderPrimer({super.key});

  @override
  State<ShaderPrimer> createState() => _ShaderPrimerState();
}

class _ShaderPrimerState extends State<ShaderPrimer> {
  static final _sections = <Widget Function()>[
    () => const Overview(),
    () => const Experience(),
    () => const Skills(),
    () => const NinjaDuel(),
    () => const Footer(),
  ];

  /// Index into [_sections] currently being drawn, or null when idle/done.
  int? _current;

  @override
  void initState() {
    super.initState();
    // Wait for the hero's entrance animation to settle first.
    Future<void>.delayed(const Duration(milliseconds: 1800), _next);
  }

  void _next() {
    if (!mounted) return;
    final next = (_current ?? -1) + 1;
    setState(() => _current = next < _sections.length ? next : null);
    if (_current == null) return;
    // Two frames per section: one to build and lay out, one to draw.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => WidgetsBinding.instance.addPostFrameCallback((_) => _next()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;
    if (current == null) return const SizedBox.shrink();
    final size = MediaQuery.sizeOf(context);
    return IgnorePointer(
      child: ExcludeSemantics(
        // Not clipped: a clipped-away draw is skipped without compiling
        // anything, so the whole section must actually be drawn (tiny and
        // nearly transparent).
        child: Opacity(
          opacity: 0.01,
          child: SizedBox.shrink(
            child: OverflowBox(
              alignment: Alignment.topLeft,
              minWidth: size.width,
              maxWidth: size.width,
              minHeight: 0,
              maxHeight: double.infinity,
              child: Transform.scale(
                scale: 0.03,
                alignment: Alignment.topLeft,
                child: ScrollProgressOverride(
                  progress: 0.45,
                  child: KeyedSubtree(
                    key: ValueKey(current),
                    child: _sections[current](),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
