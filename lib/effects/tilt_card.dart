import 'package:flutter/material.dart';

import '../utils/custom_colors.dart';

/// Glass card that tilts in 3D toward the cursor, with a moving glare and a
/// glowing edge on hover.
class TiltCard extends StatefulWidget {
  const TiltCard({
    super.key,
    required this.child,
    this.glowColor = CustomColors.primary,
    this.maxTilt = 0.22,
    this.borderRadius = 22,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final Color glowColor;
  final double maxTilt;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  Offset _tilt = Offset.zero; // -1..1 on both axes
  bool _hover = false;

  void _update(PointerEvent e, Size size) {
    setState(() {
      _hover = true;
      _tilt = Offset(
        (e.localPosition.dx / size.width) * 2 - 1,
        (e.localPosition.dy / size.height) * 2 - 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (e) => _update(
            e,
            constraints.biggest.isFinite
                ? constraints.biggest
                : (context.size ?? const Size(1, 1)),
          ),
          onExit: (_) => setState(() {
            _hover = false;
            _tilt = Offset.zero;
          }),
          child: TweenAnimationBuilder<Offset>(
            tween: Tween(end: _tilt),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            builder: (context, tilt, child) {
              final transform = Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateX(-tilt.dy * widget.maxTilt)
                ..rotateY(tilt.dx * widget.maxTilt);
              if (_hover) transform.scaleByDouble(1.025, 1.025, 1.025, 1);
              return Transform(
                alignment: Alignment.center,
                transform: transform,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: CustomColors.glass,
                    borderRadius: radius,
                    border: Border.all(
                      color: _hover
                          ? widget.glowColor.withValues(alpha: 0.75)
                          : CustomColors.glassBorder,
                      width: 1.2,
                    ),
                    // Blurred shadows are re-rasterized every frame on web, so
                    // they only exist while the card is hovered.
                    boxShadow: _hover
                        ? [
                            BoxShadow(
                              color: widget.glowColor.withValues(alpha: 0.35),
                              blurRadius: 28,
                              spreadRadius: -4,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 20,
                              offset: Offset(-tilt.dx * 14, 14 - tilt.dy * 8),
                            ),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: radius,
                    child: Stack(
                      children: [
                        Padding(padding: widget.padding, child: child),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment(tilt.dx, tilt.dy),
                                  radius: 1.1,
                                  colors: [
                                    Colors.white.withValues(
                                      alpha: _hover ? 0.12 : 0.03,
                                    ),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: widget.child,
          ),
        );
      },
    );
  }
}
