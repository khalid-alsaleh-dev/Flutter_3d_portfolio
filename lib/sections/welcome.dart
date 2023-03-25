import 'package:flutter/material.dart';
import 'package:flutter_3d_portfolio/utils/breakpoints.dart';
import 'package:flutter_3d_portfolio/utils/constants.dart';
import 'package:flutter_3d_portfolio/utils/custom_colors.dart';
import 'package:flutter_3d_portfolio/widgets/desktop_pc.dart';
import 'package:flutter_3d_portfolio/widgets/hello_and_description.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        return Stack(
          children: [
            Positioned(
              top: 0.13*maxWidth,
              right: 0.36*maxWidth,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: CustomColors.primary,
                    borderRadius: BorderRadius.circular(30)),
              )),
               Positioned(
              top: 0.2*maxWidth,
              right: 0.26*maxWidth,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: CustomColors.purple,
                    borderRadius: BorderRadius.circular(30)),
              )),
          Positioned(
              top: 0.156*maxWidth,
              left: 0.41*maxWidth,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    color: CustomColors.secondary,
                    borderRadius: BorderRadius.circular(30)),
              )),
            Container(
              width: maxWidth,
              padding: EdgeInsets.only(
                top: maxWidth * 0.07,
              ),
              child: Column(
                children: [
                  Align(
                    alignment:maxWidth>=Breakpoints.md? Alignment.topLeft:Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:maxWidth>=Breakpoints.xxlg? maxWidth *
                            Constants.mediumAndAboveHorizontalPaddingRatio:maxWidth *
                            Constants.smallHorizontalPaddingRatio,
                      ),
                      child: SizedBox(
                          width:maxWidth>=Breakpoints.xlg?  maxWidth / 4:maxWidth*0.9, child: const HelloAndDescription()),
                    ),
                  ),
                  Align(
                    alignment: maxWidth>=Breakpoints.md?Alignment.bottomRight:Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:maxWidth>=Breakpoints.xxlg? maxWidth *
                            Constants.mediumAndAboveModelHorizontalPaddingRatio:maxWidth *
                            Constants.smallModelHorizontalPaddingRatio,
                      ),
                      child: const DesktopPc(),
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
