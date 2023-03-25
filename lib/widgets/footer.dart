import 'package:flutter/material.dart';
import 'package:flutter_3d_portfolio/utils/breakpoints.dart';
import 'package:flutter_3d_portfolio/utils/custom_colors.dart';
import 'package:flutter_3d_portfolio/widgets/logo.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key, required this.homeKey}) : super(key: key);
  final GlobalKey homeKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;
      return Container(
          color: CustomColors.darkBackground,
          padding: const EdgeInsets.symmetric(vertical: 20),
          width: maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               Logo(homeKey: homeKey,),
              const SizedBox(height: 22),
              maxWidth > Breakpoints.md
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text('Copyright © 2023 khalid-alsaleh-dev',
                            style: TextStyle(
                                color: CustomColors.gray, fontSize: 14)),
                        Text('All rights reserved',
                            style: TextStyle(
                                color: CustomColors.gray, fontSize: 14)),
                        Text('khalid.alsaleh.dev@gmail.com',
                            style: TextStyle(
                                color: CustomColors.gray, fontSize: 14)),
                      ],
                    )
                  : Column(
                      children: const [
                        Text('Copyright © 2023 khalid-alsaleh-dev',
                            style: TextStyle(
                                color: CustomColors.gray, fontSize: 14)),
                        Text('All rights reserved',
                            style: TextStyle(
                                color: CustomColors.gray, fontSize: 14)),
                        Text('khalid.alsaleh.dev@gmail.com',
                            style: TextStyle(
                                color: CustomColors.gray, fontSize: 14)),
                      ],
                    ),
            ],
          ));
    });
  }
}
