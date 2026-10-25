import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../utils/custom_colors.dart';

/// "Based in Dubai, UAE" with a pulsing locator dot.
class LocationTag extends StatelessWidget {
  const LocationTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.place_rounded, color: CustomColors.secondary, size: 18),
        const SizedBox(width: 6),
        Text(
          'Based in ${PortfolioData.location}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
