import 'package:flutter/material.dart';

/// Rebuilds [builder] with how far this widget has travelled through the
/// viewport: 0 when its top edge enters from the bottom, 1 when its bottom
/// edge leaves at the top. 0.5 is roughly "centered on screen".
///
/// This is what makes every scroll-scrubbed animation on the page reversible:
/// scroll back up and the animation plays backwards.
class ScrollProgress extends StatefulWidget {
  const ScrollProgress({
    super.key,
    required this.builder,
    this.child,
    this.onProgress,
  });

  final Widget Function(BuildContext context, double progress, Widget? child)
  builder;
  final Widget? child;

  /// Called whenever the progress changes, for side effects such as sounds.
  final ValueChanged<double>? onProgress;

  @override
  State<ScrollProgress> createState() => _ScrollProgressState();
}

class _ScrollProgressState extends State<ScrollProgress> {
  ScrollPosition? _position;
  double _progress = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _position) {
      _position?.removeListener(_update);
      _position = position?..addListener(_update);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void dispose() {
    _position?.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) return;
    final viewport = MediaQuery.sizeOf(context).height;
    final top = box.localToGlobal(Offset.zero).dy;
    final travel = viewport + box.size.height;
    final p = ((viewport - top) / travel).clamp(0.0, 1.0);
    // A sub-pixel progress update has no visible effect, but it still causes
    // the whole animated section to rebuild while the page is scrolling.
    if ((p - _progress).abs() > 0.002) {
      setState(() => _progress = p);
      widget.onProgress?.call(p);
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _progress, widget.child);
}

/// Remaps [t] from the [start]..[end] window into 0..1, clamped.
double interval(
  double t,
  double start,
  double end, [
  Curve curve = Curves.linear,
]) {
  if (end <= start) return t >= end ? 1 : 0;
  return curve.transform(((t - start) / (end - start)).clamp(0.0, 1.0));
}
