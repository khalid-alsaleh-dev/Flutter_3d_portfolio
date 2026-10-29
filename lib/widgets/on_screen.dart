import 'package:flutter/material.dart';

/// Tells [onChanged] whenever [child] scrolls on or off the screen.
///
/// Worked out from the page's scroll position and the child's box, so it is
/// exact and costs one rect check per scroll update. (`VisibilityDetector`
/// infers visibility from the compositing layers, which the web renderer can
/// reuse between frames without it noticing, and then reports a widget that
/// is in plain view as hidden.)
class OnScreen extends StatefulWidget {
  const OnScreen({super.key, required this.onChanged, required this.child});

  final ValueChanged<bool> onChanged;
  final Widget child;

  @override
  State<OnScreen> createState() => _OnScreenState();
}

class _OnScreenState extends State<OnScreen> {
  ScrollPosition? _position;
  bool? _visible;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _position) {
      _position?.removeListener(_check);
      _position = position?..addListener(_check);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;
    final screen = Offset.zero & MediaQuery.sizeOf(context);
    final visible = screen.overlaps(box.localToGlobal(Offset.zero) & box.size);
    if (visible == _visible) return;
    _visible = visible;
    widget.onChanged(visible);
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
