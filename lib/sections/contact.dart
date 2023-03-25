import 'package:flutter/material.dart';
import 'package:flutter_3d_portfolio/utils/breakpoints.dart';
import 'package:flutter_3d_portfolio/utils/constants.dart';
import 'package:flutter_3d_portfolio/utils/custom_colors.dart';
import 'package:flutter_3d_portfolio/widgets/planet.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reactable/reactable.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  final Reactable<bool> playAnimation = false.asReactable;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;
      return VisibilityDetector(
        key: const Key('contact'),
        onVisibilityChanged: (visibilityInfo) {
          double visiblePercentage = visibilityInfo.visibleFraction * 100;
          if (visiblePercentage > 60 && !playAnimation.value) {
            playAnimation.value = true;
          }
        },
        child: Scope(builder: (context) {
          return Stack(
            children: [
              Positioned(
                  top: 100,
                  right: 430,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                        color: CustomColors.purple,
                        borderRadius: BorderRadius.circular(30)),
                  )),
              Positioned(
                  bottom: 50,
                  right: 630,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                        color: CustomColors.secondary,
                        borderRadius: BorderRadius.circular(30)),
                  )),
              Positioned(
                  bottom: 200,
                  right: 900,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                        color: CustomColors.primary,
                        borderRadius: BorderRadius.circular(30)),
                  )),
              SizedBox(
                width: maxWidth,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                       horizontal: maxWidth >= Breakpoints.xxlg
                    ? (maxWidth * Constants.mediumAndAboveHorizontalPaddingRatio)-0.05*maxWidth
                    : (maxWidth * Constants.smallHorizontalPaddingRatio)-0.05*maxWidth
                      ),
                  child: maxWidth >= Breakpoints.xxlg
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: 0.26*maxWidth,
                              decoration: BoxDecoration(
                                  color: CustomColors.brightBackground,
                                  border: Border.all(
                                      color: CustomColors.primary, width: 2),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20)),
                                  boxShadow: const [
                                    BoxShadow(
                                        spreadRadius: 0,
                                        blurRadius: 8,
                                        color: CustomColors.primary)
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Get In Touch',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      'Contact.',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    SizedBox(
                                      width: 450,
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                            fillColor: CustomColors.textForm,
                                            filled: true,
                                            hintText: 'Email',
                                            border: InputBorder.none,
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)))),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    SizedBox(
                                      width: 450,
                                      child: TextFormField(
                                        maxLines: 15,
                                        decoration: const InputDecoration(
                                            fillColor: CustomColors.textForm,
                                            filled: true,
                                            hintText: 'Message',
                                            border: InputBorder.none,
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)))),
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: const ButtonStyle(
                                        side: MaterialStatePropertyAll(
                                            BorderSide(
                                                color: CustomColors.primary)),
                                        backgroundColor:
                                            MaterialStatePropertyAll<Color>(
                                                CustomColors.brightBackground),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(15.0),
                                        child: Text(
                                          'Send',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                                .animate(target: playAnimation.value ? 1 : 0)
                                .moveX(
                                  begin:100 ,
                                    end: 0,
                                    curve: Curves.elasticOut,
                                    duration: 1.seconds)
                                .fadeIn(duration: 2.seconds),
                                // SizedBox(width: 50,),
                            SizedBox(
                              width: 0.26*maxWidth,
                              height: 0.26*maxWidth,
                              child: const Planet()
                                  .animate(target: playAnimation.value ? 1 : 0)
                                  .moveX(
                                     begin: -100,
                                      end: 0,
                                      curve: Curves.elasticOut,
                                      duration: 1.seconds)
                                  .fadeIn(duration: 2.seconds),
                            ),
                          ],
                        )
                      : Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width:maxWidth<=Breakpoints.sm? 0.8*maxWidth:0.6*maxWidth,
                                height:maxWidth<=Breakpoints.sm? 0.8*maxWidth:0.6*maxWidth,
                              child: const Planet()
                                  .animate(target: playAnimation.value ? 1 : 0)
                                  .moveX(
                                      begin: 100,
                                      end: 0,
                                      curve: Curves.elasticOut,
                                      duration: 1.seconds)
                                  .fadeIn(duration: 2.seconds),
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            Container(
                               width:maxWidth<=Breakpoints.sm? 0.8*maxWidth:0.6*maxWidth,
                              decoration: BoxDecoration(
                                  color: CustomColors.brightBackground,
                                  border: Border.all(
                                      color: CustomColors.primary, width: 2),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20)),
                                  boxShadow: const [
                                    BoxShadow(
                                        spreadRadius: 0,
                                        blurRadius: 8,
                                        color: CustomColors.primary)
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Get In Touch',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      'Contact.',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    SizedBox(
                                      width: 450,
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                            fillColor: CustomColors.textForm,
                                            filled: true,
                                            hintText: 'Email',
                                            border: InputBorder.none,
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)))),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    SizedBox(
                                      width: 450,
                                      child: TextFormField(
                                        maxLines: 15,
                                        decoration: const InputDecoration(
                                            fillColor: CustomColors.textForm,
                                            filled: true,
                                            hintText: 'Message',
                                            border: InputBorder.none,
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)))),
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: const ButtonStyle(
                                        side: MaterialStatePropertyAll(
                                            BorderSide(
                                                color: CustomColors.primary)),
                                        backgroundColor:
                                            MaterialStatePropertyAll<Color>(
                                                CustomColors.brightBackground),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(15.0),
                                        child: Text(
                                          'Send',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                                .animate(target: playAnimation.value ? 1 : 0)
                                .moveX(
                                    begin: -100,
                                    end: 0,
                                    curve: Curves.elasticOut,
                                    duration: 1.seconds)
                                .fadeIn(duration: 2.seconds),
                          ],
                        ),
                ),
              ),
            ],
          );
        }),
      );
    });
  }
}
