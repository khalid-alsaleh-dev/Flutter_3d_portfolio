import 'package:flutter/material.dart';
import 'package:flutter_3d_portfolio/utils/breakpoints.dart';
import 'package:flutter_3d_portfolio/utils/constants.dart';
import 'package:flutter_3d_portfolio/utils/custom_colors.dart';
import 'package:flutter_3d_portfolio/utils/image_assets.dart';
import 'package:flutter_3d_portfolio/widgets/overview_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:reactable/reactable.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  final Reactable<bool> playAnimation = false.asReactable;

  @override
  Widget build(BuildContext context) {
      int crossAxisCount = 4;
    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;
      if (maxWidth >= Breakpoints.lg) {
        crossAxisCount = 4;
      } else if (maxWidth < Breakpoints.lg) {
        crossAxisCount = 2;
      } else {
        crossAxisCount = 1;
      }
      return Stack(
        children: [
          Positioned(
              top: 0.03 * maxWidth,
              right: 0.156 * maxWidth,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: CustomColors.secondary,
                    borderRadius: BorderRadius.circular(30)),
              )),
          Positioned(
              top: 0.07 * maxWidth,
              right: 0.26 * maxWidth,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    color: CustomColors.purple,
                    borderRadius: BorderRadius.circular(30)),
              )),
          SizedBox(
            width: maxWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: maxWidth >= Breakpoints.xxlg
                    ? maxWidth * Constants.mediumAndAboveHorizontalPaddingRatio
                    : maxWidth * Constants.smallHorizontalPaddingRatio,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VisibilityDetector(
                    key: const Key('overview'),
                    onVisibilityChanged: (visibilityInfo) {
                      var visiblePercentage =
                          visibilityInfo.visibleFraction * 100;
                      if (visiblePercentage > 80 && !playAnimation.value) {
                        playAnimation.value = true;
                      }
                    },
                    child: Scope(builder: (context) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Introduction',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 25),
                            child: Text(
                              'Overview.',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 40),
                            ),
                          ),
                          Text(
                            '⚫ I seek challenging opportunities where I can fully use my skills for the success.',
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 15.0),
                            child: Text(
                              '⚫ I’m studying informatics engineering at the University Of Aleppo.',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                          ),
                          Text(
                            '⚫ The Only thing that makes me feel happy is coding.',
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 15.0),
                            child: Text(
                              '⚫ I always try to discover the new and the best technologies and use them to make my client feel comfortable and satisfied.',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                          ),
                        ],
                      )
                          .animate(
                            target: playAnimation.value ? 1 : 0,
                          )
                          .moveY(begin: 70, duration: 1.seconds)
                          .fadeIn(duration: 2.seconds);
                    }),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Scope(builder: (context) {
                    return StaggeredGrid.count(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 25,
                      crossAxisSpacing: 25,
                      children: [
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1,
                          child: const OverviewCard(
                            text: 'Flutter Developer',
                            image: ImageAssets.greenFlutter,
                          )
                              .animate(target: playAnimation.value ? 1 : 0)
                              .moveX(delay: 1.seconds, begin: -5)
                              .fadeIn(delay: 1.seconds),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1,
                          child: const OverviewCard(
                            text: 'Backend Developer',
                            image: ImageAssets.backend,
                          )
                              .animate(
                                target: playAnimation.value ? 1 : 0,
                              )
                              .moveX(delay: 2.seconds, begin: -5)
                              .fadeIn(delay: 2.seconds),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1,
                          child: const OverviewCard(
                            text: 'Content Creator',
                            image: ImageAssets.contentCreator,
                          )
                              .animate(target: playAnimation.value ? 1 : 0)
                              .moveX(delay: 3.seconds, begin: -5)
                              .fadeIn(delay: 3.seconds),
                        ),
                          StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1,
                          child: const OverviewCard(
                            text: 'Figma Designer',
                            image: ImageAssets.figma,
                          )
                              .animate(target: playAnimation.value ? 1 : 0)
                              .moveX(delay: 4.seconds, begin: -5)
                              .fadeIn(delay: 4.seconds),
                        ),
                      ],
                    );
                  })
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
