import 'package:flutter/material.dart';

import '../utils/custom_colors.dart';

/// Pill button whose fill sweeps in like a blade on hover.
class BladeButton extends StatefulWidget {
  const BladeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = false,
    this.color = CustomColors.primary,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool filled;
  final Color color;

  @override
  State<BladeButton> createState() => _BladeButtonState();
}

class _BladeButtonState extends State<BladeButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = _hover || widget.filled;
    final fg = active ? const Color(0xff07130c) : Colors.white;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: widget.color, width: 1.4),
            gradient: LinearGradient(
              colors: [widget.color, widget.color, Colors.transparent],
              stops: active ? const [0, 1, 1] : const [0, 0, 0],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: active ? 0.45 : 0),
                blurRadius: 24,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: fg,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: 10),
                AnimatedSlide(
                  duration: const Duration(milliseconds: 220),
                  offset: Offset(_hover ? 0.25 : 0, 0),
                  child: Icon(widget.icon, color: fg, size: 18),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
