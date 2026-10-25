import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../utils/custom_colors.dart';

/// A full-length website screenshot playing inside a browser window: it
/// scrolls slowly down and back up like a screen recording. Hovering pauses
/// the loop and lets the mouse scrub through the page; leaving resumes it.
/// The loop only runs while the preview is on screen.
class SitePreview extends StatefulWidget {
  const SitePreview({
    super.key,
    required this.asset,
    required this.aspect,
    required this.url,
    required this.accent,
  });

  /// Bundled screenshot, full page height.
  final String asset;

  /// Screenshot height divided by width.
  final double aspect;
  final String url;
  final Color accent;

  @override
  State<SitePreview> createState() => _SitePreviewState();
}

class _SitePreviewState extends State<SitePreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scroll = AnimationController(
    vsync: this,
    // Roughly 2.2 seconds per screenful, so long pages don't race.
    duration: Duration(milliseconds: (widget.aspect * 2200).round()),
  );
  bool _visible = false;
  bool _hovering = false;

  void _play() {
    if (!_visible || _hovering) return;
    _scroll.repeat(reverse: true);
  }

  void _onVisibility(VisibilityInfo info) {
    if (!mounted) return;
    _visible = info.visibleFraction > 0.05;
    _visible ? _play() : _scroll.stop();
  }

  void _scrub(Offset local, double height) {
    final target = (local.dy / height).clamp(0.0, 1.0);
    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parsedHost = Uri.tryParse(widget.url)?.host ?? '';
    final host = parsedHost.isEmpty ? widget.url : parsedHost;
    return VisibilityDetector(
      key: ValueKey('preview-${widget.asset}'),
      onVisibilityChanged: _onVisibility,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.6),
            radius: 1.2,
            colors: [
              widget.accent.withValues(alpha: 0.35),
              const Color(0xff10131b),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Column(
              children: [
                _chrome(host),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final imageHeight = c.maxWidth * widget.aspect;
                      final travel = (imageHeight - c.maxHeight).clamp(
                        0.0,
                        double.infinity,
                      );
                      return MouseRegion(
                        onEnter: (_) {
                          _hovering = true;
                          _scroll.stop();
                          setState(() {});
                        },
                        onHover: (e) => _scrub(e.localPosition, c.maxHeight),
                        onExit: (_) {
                          _hovering = false;
                          setState(() {});
                          _play();
                        },
                        child: Stack(
                          children: [
                            AnimatedBuilder(
                              animation: _scroll,
                              builder: (context, child) => Transform.translate(
                                offset: Offset(
                                  0,
                                  -travel *
                                      Curves.easeInOutSine.transform(
                                        _scroll.value,
                                      ),
                                ),
                                child: child,
                              ),
                              child: OverflowBox(
                                alignment: Alignment.topCenter,
                                maxHeight: imageHeight,
                                child: Image.asset(
                                  widget.asset,
                                  width: c.maxWidth,
                                  height: imageHeight,
                                  fit: BoxFit.fill,
                                  filterQuality: FilterQuality.medium,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: _Badge(
                                hovering: _hovering,
                                accent: widget.accent,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chrome(String host) {
    return Container(
      height: 26,
      color: const Color(0xff1b1f2a),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          for (final color in const [
            Color(0xffff5f57),
            Color(0xfffebc2e),
            Color(0xff28c840),
          ])
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 16,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 9,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    host,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.hovering, required this.accent});
  final bool hovering;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: hovering ? CustomColors.steel : accent,
                  shape: BoxShape.circle,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeOut(duration: 700.ms),
          const SizedBox(width: 6),
          Text(
            hovering ? 'Move to explore' : 'Live preview',
            style: const TextStyle(color: Colors.white, fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}
