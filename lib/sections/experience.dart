import 'package:flutter/material.dart';
import 'package:flutter_3d_portfolio/utils/breakpoints.dart';
import 'package:flutter_3d_portfolio/utils/constants.dart';
import 'package:flutter_3d_portfolio/utils/custom_colors.dart';
import 'package:flutter_3d_portfolio/utils/image_assets.dart';
import 'package:flutter_3d_portfolio/widgets/experience_block.dart';
import 'package:reactable/reactable.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Experience extends StatefulWidget {
  const Experience({super.key});

  @override
  State<Experience> createState() => _ExperienceState();
}

class _ExperienceState extends State<Experience> {
  final Reactable<bool> showAndroidExperience = false.asReactable;
  final Reactable<bool> showFlutterExperience = false.asReactable;
  final Reactable<bool> showNestjsExperience = false.asReactable;
  final Reactable<double> heightOfAndroid = 10.0.asReactable;
  final Reactable<double> heightOfFlutter = 10.0.asReactable;
  final Reactable<double> heightOfNest = 10.0.asReactable;
  final GlobalKey androidKey = GlobalKey();
  final GlobalKey flutterKey = GlobalKey();
  final GlobalKey nestKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;
      return Stack(
        children: [
          Positioned(
              top: 300,
              right: 400,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: CustomColors.purple,
                    borderRadius: BorderRadius.circular(30)),
              )),
          Positioned(
              top: 140,
              right: 650,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: CustomColors.primary,
                    borderRadius: BorderRadius.circular(30)),
              )),
          Positioned(
              top: 140,
              left: 400,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: CustomColors.secondary,
                    borderRadius: BorderRadius.circular(30)),
              )),
          Positioned(
              top: 700,
              left: 430,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: CustomColors.primary,
                    borderRadius: BorderRadius.circular(30)),
              )),
          Positioned(
              top: 1000,
              right: 430,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: CustomColors.secondary,
                    borderRadius: BorderRadius.circular(30)),
              )),
          SizedBox(
            width: maxWidth,
            child: Padding(
              padding: EdgeInsets.only(
                top: maxWidth * 0.04,
                left: maxWidth >= Breakpoints.xxlg
                    ? 0
                    : maxWidth * Constants.smallHorizontalPaddingRatio,
                right:  maxWidth >= Breakpoints.xxlg
                    ? 0
                    : maxWidth * Constants.smallHorizontalPaddingRatio,    
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
            Align(
                    alignment:maxWidth>=Breakpoints.lg?Alignment.center:Alignment.centerLeft ,
                    child: const Text('What i have done so far',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment:maxWidth>=Breakpoints.lg?Alignment.center:Alignment.centerLeft ,
                    child: const Text('Work Experience.',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    width: maxWidth,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: maxWidth >= Breakpoints.xxlg
                    ? (maxWidth * Constants.mediumAndAboveHorizontalPaddingRatio)-0.05*maxWidth
                    : (maxWidth * Constants.smallHorizontalPaddingRatio)-0.05*maxWidth,
                      ),
                      child: Stack(
                        alignment:maxWidth>=Breakpoints.lg? Alignment.topCenter:Alignment.topLeft,
                        children: [
                          Scope(builder: (context) {
                            return Padding(
                              padding:  EdgeInsets.only(left:maxWidth<Breakpoints.lg?20:0 ),
                              child: Container(
                                width: 3,
                                height: heightOfAndroid.value +
                                    heightOfFlutter.value +
                                    heightOfNest.value+200,
                                color: Colors.white,
                              ),
                            );
                          }),
                          VisibilityDetector(
                            key: const Key('android'),
                            onVisibilityChanged: (_) {
                              heightOfAndroid.value =
                                  androidKey.currentContext?.size?.height ??
                                      0.0;
                            },
                            child: Padding(
                       padding: const EdgeInsets.only(top: 50),
                              child: ExperienceBlock(
                                key: androidKey,
                                image: ImageAssets.android,
                                title: 'Android Developer',
                                description: 'I started my programming journey in android native development. I have had a very good experience in building native android applications. I used in my journey many amazing libraires like retrofit, firebase, SQLite and so many of them.',
                                time: 'Jan 2019 - Feb 2020',
                                multidirection: maxWidth>=Breakpoints.lg,
                                topPadding: 50,
                                playAnimation: showAndroidExperience,
                                cardAlignment:maxWidth>=Breakpoints.lg? Alignment.topLeft:Alignment.topLeft,
                                timeTextPadding: const EdgeInsets.only(left: 250),
                              ),
                            ),
                          ),
                          VisibilityDetector(
                            key: const Key('flutter'),
                            onVisibilityChanged: (_) {
                              heightOfFlutter.value =
                                  flutterKey.currentContext?.size?.height ??
                                      0.0;
                            },
                            child: Scope(builder: (context) {
                              return Padding(
                                padding: 
                                 EdgeInsets.only(top:heightOfAndroid.value + 110,),
                                child: ExperienceBlock(
                                  key: flutterKey,
                                  image: ImageAssets.flutter,
                                  title: 'Flutter Developer',
                                  description:
                                      '''Experience in development of Android/iOS applications and have deployed them on Google Play/App Store. 4+ years knowledge in mobile app development. In depth understanding of front end languages like HTML, CSS3 and JavaScript. Knowledge of Dart programming language, Rest APIs and integration of various APIs from third parties. Comfortable using test cases for debugging code, enhancing performance and reliability. Great experience in state management solutions like bloc library and getx light fremework.
                                              ''',
                                  time: 'May 2019 - Present',
                                  multidirection: maxWidth>=Breakpoints.lg,
                                  topPadding: heightOfAndroid.value + 110,
                                  playAnimation: showFlutterExperience,
                                  cardAlignment:maxWidth>=Breakpoints.lg? Alignment.topRight:Alignment.topLeft,
                                  timeTextPadding:
                                      const EdgeInsets.only(right: 250),
                                ),
                              );
                            }),
                          ),
                          VisibilityDetector(
                            key: const Key('nest'),
                            onVisibilityChanged: (_) {
                              heightOfNest.value =
                                  nestKey.currentContext?.size?.height ?? 0.0;
                            },
                            child: Scope(builder: (context) {
                              return Padding(
                                padding:  EdgeInsets.only(top:heightOfAndroid.value+ heightOfFlutter.value + 150),
                                child: ExperienceBlock(
                                  key: nestKey,
                                  image: ImageAssets.nestjs,
                                  title: 'Nestjs Developer',
                                  description: 'I have a very good experience in nestjs basics and techniques like typeorm, redis, queue, middlewares, interceptors, graphql and so many of them.',
                                  time: 'Jan 2022 - Present',
                                  multidirection: maxWidth>=Breakpoints.lg,
                                  topPadding: heightOfFlutter.value + 150,
                                  playAnimation: showNestjsExperience,
                                  cardAlignment:maxWidth>=Breakpoints.lg? Alignment.topLeft:Alignment.topLeft,
                                  timeTextPadding:
                                      const EdgeInsets.only(left: 250),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
