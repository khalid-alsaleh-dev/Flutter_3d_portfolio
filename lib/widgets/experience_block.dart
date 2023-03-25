import 'package:flutter/material.dart';
import 'package:flutter_3d_portfolio/utils/custom_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reactable/reactable.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ExperienceBlock extends StatelessWidget {
  const ExperienceBlock(
      {super.key,
      required this.image,
      required this.title,
      required this.description,
      required this.time,
      required this.topPadding,
      required this.playAnimation,
      required this.cardAlignment,
      required this.timeTextPadding,
      required this.multidirection});
  final String image;
  final String title;
  final String description;
  final String time;
  final double topPadding;
  final Reactable<bool> playAnimation;
  final Alignment cardAlignment;
  final EdgeInsetsGeometry timeTextPadding;
  final bool multidirection;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;
      return SizedBox(
        child: VisibilityDetector(
          key: Key(image),
          onVisibilityChanged: (visibilityInfo) {
            double visiblePercentage = visibilityInfo.visibleFraction * 100;
            if (visiblePercentage > 80 && !playAnimation.value) {
              playAnimation.value = true;
            }
          },
          child: Scope(builder: (context) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                Align(
                  alignment:
                      multidirection ? Alignment.topCenter : Alignment.topLeft,
                  child: Container(
                          width: 40,
                          height: 40,
                          decoration:
                              const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  color: Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(image),
                          ))
                      .animate(target: playAnimation.value ? 1 : 0)
                      .scale(
                          curve: Curves.easeIn,
                          begin: const Offset(1, 1),
                          end: const Offset(1.5, 1.5))
                      .fadeIn()
                      .then()
                      .scale(
                          curve: Curves.easeIn,
                          begin: const Offset(1.5, 1.5),
                          end: const Offset(1, 1)),
                ),
                Align(
                  alignment: cardAlignment,
                  child: Column(
                    children: [
                      Container(
                        width:multidirection? maxWidth * 0.3:maxWidth*0.7,
                        color: CustomColors.brightBackground,
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(description,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ))
                            ],
                          ),
                        ),
                      ),
                      Container(
                     width:multidirection? maxWidth * 0.3:maxWidth*0.7,
                        height: 5,
                        color: Colors.white,
                      )
                    ],
                  ),
                )
                    .animate(target: playAnimation.value ? 1 : 0)
                    .moveX(
                        end: cardAlignment == Alignment.topLeft ? 100 : -100,
                        duration: 1.seconds,
                        curve: Curves.elasticOut)
                    .fadeIn(duration: 1.seconds, curve: Curves.elasticOut),
                multidirection
                    ? Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: timeTextPadding,
                          child: Column(
                            children: [
                              Text(
                                time,
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      )
                        .animate(target: playAnimation.value ? 1 : 0)
                        .moveX(
                            end: cardAlignment == Alignment.topLeft ? 70 : -70,
                            duration: 1.seconds,
                            curve: Curves.elasticOut)
                        .fadeIn()
                    : const SizedBox.shrink()
              ],
            );
          }),
        ),
      );
    });
  }
}
