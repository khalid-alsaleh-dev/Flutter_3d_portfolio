import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../utils/custom_colors.dart';

/// Draws an [Emblem]: the logo image, or the icon scaled to fill the space.
class EmblemView extends StatelessWidget {
  const EmblemView(this.emblem, {super.key, this.color = CustomColors.primary});

  final Emblem emblem;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final asset = emblem.asset;
    if (asset != null) return Image.asset(asset, fit: BoxFit.contain);
    return LayoutBuilder(
      builder: (context, c) =>
          Icon(emblem.icon, color: color, size: c.biggest.shortestSide),
    );
  }
}
