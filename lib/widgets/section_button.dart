import 'package:flutter/material.dart';
import 'package:flutter_3d_portfolio/utils/custom_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reactable/reactable.dart';

class SectionButton extends StatelessWidget {
  const SectionButton(
      {super.key,
      required this.text,
      required this.onPressed,
      required this.isHover, required this.lineWidth});

  final String text;
  final VoidCallback onPressed;
  final Reactable<bool> isHover;
  final double lineWidth;
  @override
  Widget build(BuildContext context) {
    return Scope(
      builder: (context) {
        return InkWell(
          onTap: onPressed,
          onHover: (newIsHover) =>isHover.value=newIsHover,
          child: Column(
            children: [
              Text(
                text,
                style: TextStyle(
                    color: isHover.value ? CustomColors.primary : Colors.white),
              ),
              const SizedBox(height: 3),
              Container(width: lineWidth, height: 1.5, color: CustomColors.primary)
                  .animate(target: isHover.value?1:0)
                  .scaleX()
            ],
          ),
        );
      }
    );
  }
}
