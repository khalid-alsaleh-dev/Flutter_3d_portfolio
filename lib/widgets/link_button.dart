import 'package:flutter/material.dart';
import 'package:flutter_3d_portfolio/utils/custom_colors.dart';


class LinkButton extends StatelessWidget {
  const LinkButton(
      {super.key,
      required this.onPressed,
      required this.icon,
      required this.text});

  final VoidCallback onPressed;
  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        style: const ButtonStyle(
            elevation: MaterialStatePropertyAll<double>(0.0),
            backgroundColor:
                MaterialStatePropertyAll<Color>(CustomColors.darkBackground)),
        onPressed: onPressed,
        icon: Image.asset(icon),
        label:  Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ));
  }
}
