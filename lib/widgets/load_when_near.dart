import 'package:flutter/material.dart';

/// Builds [child] only once it scrolls within [margin] screen heights of the
/// viewport, and keeps it from then on. Until then it shows [placeholder],
/// which should take the same space so the page layout does not shift.
///
/// For widgets that download something big (a 3D model, a full-page
/// screenshot) far down the page, so that the first visit does not fetch them.
class LoadWhenNear extends StatefulWidget {
  const LoadWhenNear({
    super.key,
    required this.child,
    this.placeholder = const SizedBox.expand(),
    this.margin = 1.5,
  });

  final Widget child;
  final Widget placeholder;
  final double margin;

  @override
  State<LoadWhenNear> createState() => _LoadWhenNearState();
}

class _LoadWhenNearState extends State<LoadWhenNear> {
  ScrollPosition? _position;
  bool _near = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_near) return;
    final position = Scrollable.maybeOf(context)?.position;
    if (position == _position) return;
    _position?.removeListener(_check);
    _position = position?..addListener(_check);
    // Not inside a scroll view (or already in view): decide after layout.
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_near || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;
    final view = MediaQuery.sizeOf(context).height;
    final top = box.localToGlobal(Offset.zero).dy;
    final reach = view * widget.margin;
    if (top < view + reach && top + box.size.height > -reach) {
      _position?.removeListener(_check);
      setState(() => _near = true);
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _near ? widget.child : widget.placeholder;
}
