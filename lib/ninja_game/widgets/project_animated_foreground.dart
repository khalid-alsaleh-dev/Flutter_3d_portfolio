import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reactable/reactable.dart';

class ProjectAnimatedForeground extends StatelessWidget {
  const ProjectAnimatedForeground(
      {super.key,
      required this.title,
      required this.description,
      required this.openOnPressed,
      required this.githubOnPressed,
      required this.image,
      required this.removeForeground,
      required this.enableToRemoveForeground, required this.delay});
  final String title;
  final String description;
  final VoidCallback openOnPressed;
  final VoidCallback githubOnPressed;
  final String image;
  final Reactable<bool> removeForeground;
  final Reactable<bool> enableToRemoveForeground;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 900,
      child: Stack(
        children: [
          SizedBox(
            width: 300,
            height: 900,
            child: Stack(
              children: [
                Stack(
                  children: [
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Image.asset('assets/images/cuttedchain.png'),
                        ),
                        Scope(builder: (context) {
                          return Opacity(
                            opacity: 0.2,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Image.asset(
                                'assets/images/cuttedchain.png',
                                color: Colors.red,
                              ),
                            )
                                .animate(
                                    target:
                                        enableToRemoveForeground.value ? 1 : 0)
                                .fadeIn()
                                .animate(
                                    target:
                                        enableToRemoveForeground.value ? 0 : 1)
                                .fadeOut(),
                          );
                        }),
                      ],
                    )
                        .animate(onPlay: (controller) => controller.repeat(),delay: delay)
                        .rotate(
                          alignment: Alignment.topCenter,
                          begin: 0,
                          end: -0.001,
                        )
                        .then()
                        .rotate(
                          alignment: Alignment.topCenter,
                          begin: -0.001,
                          end: 0,
                        )
                        .then()
                        .rotate(
                          alignment: Alignment.topCenter,
                          begin: 0,
                          end: 0.001,
                        )
                        .then()
                        .rotate(
                          alignment: Alignment.topCenter,
                          begin: 0.001,
                          end: 0,
                        ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Container(
                          width: 300,
                          height: 440,
                          decoration: const BoxDecoration(
                              color: Color(0xff424346),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 4),
                                    color: Colors.black,
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    blurStyle: BlurStyle.inner)
                              ]),
                          child: Column(
                            children: [
                              Container(
                                width: 300,
                                height: 180,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        topLeft: Radius.circular(10)),
                                    image: DecorationImage(
                                        image: ExactAssetImage(image),
                                        fit: BoxFit.fill)),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Text(description,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        )),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                            onPressed: openOnPressed,
                                            style: const ButtonStyle(
                                                backgroundColor:
                                                    MaterialStatePropertyAll(
                                                        Color(0xff424346)),
                                                side: MaterialStatePropertyAll(
                                                    BorderSide(
                                                        color: Color(
                                                            0xff65F8AE)))),
                                            child: const Padding(
                                              padding: EdgeInsets.all(5.0),
                                              child: Text('Open',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15)),
                                            )),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        ElevatedButton(
                                            onPressed: githubOnPressed,
                                            style: const ButtonStyle(
                                                backgroundColor:
                                                    MaterialStatePropertyAll(
                                                        Color(0xff424346)),
                                                side: MaterialStatePropertyAll(
                                                    BorderSide(
                                                        color: Color(
                                                            0xff65F8AE)))),
                                            child: const Padding(
                                              padding: EdgeInsets.all(5.0),
                                              child: Text('Github',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15)),
                                            ))
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          color: const Color(0xff424346),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50)),
                          border: Border.all(color: const Color(0xff6AE99F))),
                    )),
              ],
            ),
          ),
          //animated section
          //----------------------------------------------------------------------------------------------------------
          Scope(builder: (context) {
            return Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100.0),
                    child: Image.asset(
                        'assets/images/cuttedChainWithContainer.png'),
                  ),
                ),
                Scope(builder: (context) {
                  return Opacity(
                    opacity: 0.2,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100.0),
                        child: Image.asset(
                          'assets/images/cuttedChainWithContainer.png',
                          color: Colors.red,
                        ),
                      ),
                    )
                        .animate(target: enableToRemoveForeground.value ? 1 : 0)
                        .fadeIn()
                        .animate(target: enableToRemoveForeground.value ? 0 : 1)
                        .fadeOut(),
                  );
                }),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Container(
                      width: 300,
                      height: 450,
                      decoration: BoxDecoration(
                          color: const Color(0xff424346),
                          border: Border.all(color: const Color(0xff6AE99F))),
                      child: Center(
                          child: Text(title,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 30))),
                    ),
                  ),
                ),
              ],
            )
                .animate(onPlay: (controller) => controller.repeat(),delay: delay)
                .rotate(
                  alignment: Alignment.topCenter,
                  begin: 0,
                  end: -0.001,
                )
                .then()
                .rotate(
                  alignment: Alignment.topCenter,
                  begin: -0.001,
                  end: 0,
                )
                .then()
                .rotate(
                  alignment: Alignment.topCenter,
                  begin: 0,
                  end: 0.001,
                )
                .then()
                .rotate(
                  alignment: Alignment.topCenter,
                  begin: 0.001,
                  end: 0,
                )
                .animate(target: removeForeground.value ? 1 : 0)
                .moveY(end: 1500, curve: Curves.easeIn, duration: 3.seconds)
                .then()
                .fadeOut();
          })
        ],
      ),
    );
  }
}
