import 'package:flutter/material.dart';
import 'package:flutter_3d_portfolio/sections/contact.dart';
import 'package:flutter_3d_portfolio/sections/experience.dart';
import 'package:flutter_3d_portfolio/sections/overview.dart';
import 'package:flutter_3d_portfolio/sections/projects.dart';
import 'package:flutter_3d_portfolio/utils/breakpoints.dart';
import 'package:flutter_3d_portfolio/utils/custom_colors.dart';
import 'package:flutter_3d_portfolio/sections/welcome.dart';
import 'package:flutter_3d_portfolio/widgets/footer.dart';
import 'package:flutter_3d_portfolio/widgets/navbar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reactable/reactable.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ScrollController controller = ScrollController();
  Reactable<bool> showNavbarLineAndShowFloatingButton = false.asReactable;
  final GlobalKey homeKey = GlobalKey(debugLabel: 'homeKey');
  final GlobalKey overviewKey = GlobalKey(debugLabel: 'overviewKey');
  final GlobalKey experienceKey = GlobalKey(debugLabel: 'experienceKey');
  final GlobalKey projectsKey = GlobalKey(debugLabel: 'projectsKey');
  final GlobalKey contactKey = GlobalKey(debugLabel: 'contactKey');

  @override
  void initState() {
    controller.addListener(() {
      if (controller.offset.floor() >= Breakpoints.floatingButton) {
        showNavbarLineAndShowFloatingButton.value = true;
      } else {
        showNavbarLineAndShowFloatingButton.value = false;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double widthOfScreen = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: CustomColors.darkBackground,
      floatingActionButton: Scope(builder: (context) {
        return showNavbarLineAndShowFloatingButton.value
            ? FloatingActionButton(
                onPressed: () {
                  controller.animateTo(0.0,
                      duration: 2.seconds, curve: Curves.easeIn);
                },
                backgroundColor: CustomColors.primary,
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                ),
              ).animate().fadeIn().scale()
            : const SizedBox.shrink();
      }),
      body: Stack(
        children: [
          SingleChildScrollView(
              controller: controller,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  SizedBox(
                    width: widthOfScreen,
                    child: Welcome(
                      key: homeKey,
                    ),
                  ),
                  SizedBox(
                    width: widthOfScreen,
                    child: Overview(
                      key: overviewKey,
                    ),
                  ),
                  SizedBox(
                    width: widthOfScreen,
                    child: Experience(
                      key: experienceKey,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                      width: widthOfScreen,
                      child: Projects(
                        key: projectsKey,
                      )),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: widthOfScreen,
                    child: Contact(
                      key: contactKey,
                    ),
                  ),
                  const SizedBox(height: 100),
                  SizedBox(
                    width: widthOfScreen,
                    child:  Footer(
                      homeKey: homeKey,
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              )),
          SizedBox(
            width: widthOfScreen,
            child: Navbar(
              showNavbarLineAndShowFloatingButton:
                  showNavbarLineAndShowFloatingButton,
              homeKey: homeKey,
              overviewKey: overviewKey,
              experienceKey: experienceKey,
              projectsKey: projectsKey,
              contactKey: contactKey,
            ),
          ),
        ],
      ),
    );
  }
}
