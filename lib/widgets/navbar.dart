import 'package:flutter/material.dart';
import 'package:flutter_3d_portfolio/utils/breakpoints.dart';
import 'package:flutter_3d_portfolio/utils/custom_colors.dart';
import 'package:flutter_3d_portfolio/utils/image_assets.dart';
import 'package:flutter_3d_portfolio/widgets/link_button.dart';
import 'package:flutter_3d_portfolio/widgets/logo.dart';
import 'package:flutter_3d_portfolio/widgets/section_button.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reactable/reactable.dart';
import 'package:url_launcher/url_launcher.dart';



class Navbar extends StatefulWidget {
  const Navbar({super.key, required this.showNavbarLineAndShowFloatingButton, required this.homeKey, required this.overviewKey, required this.experienceKey, required this.projectsKey, required this.contactKey});

  final Reactable<bool> showNavbarLineAndShowFloatingButton;
  final GlobalKey homeKey;
  final GlobalKey overviewKey;
  final GlobalKey experienceKey;
  final GlobalKey projectsKey;
  final GlobalKey contactKey;

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  final Reactable<bool> homeIsHover = false.asReactable;
  final Reactable<bool> overviewIsHover = false.asReactable;
  final Reactable<bool> experienceIsHover = false.asReactable;
  final Reactable<bool> projectsIsHover = false.asReactable;
  final Reactable<bool> contactIsHover = false.asReactable;
  final Reactable<bool> showDropdownNavbar = false.asReactable;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;
      if (maxWidth >= Breakpoints.xxlg) {
        return NavbarOnXLGOrLarger(maxWidth: maxWidth, homeIsHover: homeIsHover, overviewIsHover: overviewIsHover, experienceIsHover: experienceIsHover, projectsIsHover: projectsIsHover, contactIsHover: contactIsHover, showNavbarLineAndShowFloatingButton: widget.showNavbarLineAndShowFloatingButton, homeKey: widget.homeKey, overviewKey: widget.overviewKey, experienceKey: widget.experienceKey, projectsKey: widget.projectsKey, contactKey: widget.contactKey);
      } else {
        return NavbarOnLessThanXLG(maxWidth: maxWidth, showDropdownNavbar: showDropdownNavbar, homeKey: widget.homeKey, overviewKey: widget.overviewKey, experienceKey: widget.experienceKey, projectsKey: widget.projectsKey, contactKey: widget.contactKey);
      }
    });
  }
}

class NavbarOnXLGOrLarger extends StatelessWidget {
  const NavbarOnXLGOrLarger({
    super.key,
    required this.maxWidth,
    required this.homeIsHover,
    required this.overviewIsHover,
    required this.experienceIsHover,
    required this.projectsIsHover,
    required this.contactIsHover, required this.showNavbarLineAndShowFloatingButton, required this.homeKey, required this.overviewKey, required this.experienceKey, required this.projectsKey, required this.contactKey,
  });

  final double maxWidth;
  final Reactable<bool> homeIsHover;
  final Reactable<bool> overviewIsHover;
  final Reactable<bool> experienceIsHover;
  final Reactable<bool> projectsIsHover;
  final Reactable<bool> contactIsHover;
  final Reactable<bool> showNavbarLineAndShowFloatingButton;
  final GlobalKey homeKey;
  final GlobalKey overviewKey;
  final GlobalKey experienceKey;
  final GlobalKey projectsKey;
  final GlobalKey contactKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: maxWidth,
            height: 130,
            color: CustomColors.darkBackground,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 100.0, vertical: 50),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Logo(homeKey: homeKey,),
                      Row(
                        children: [
                          LinkButton(
                            icon: ImageAssets.facebook,
                            text: 'Facebook',
                            onPressed: () async{
                         await launchUrl(Uri.parse('https://www.facebook.com/khalid.alsaleh.52090/'));
                       },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: LinkButton(
                              icon: ImageAssets.github,
                              text: 'Github',
                              onPressed: () async{
                                 await launchUrl(Uri.parse('https://github.com/khalid-alsaleh-dev'));
                              },
                            ),
                          ),
                          LinkButton(
                            icon: ImageAssets.linkedin,
                            text: 'LinedIn',
                            onPressed: () async{
                               await launchUrl(Uri(path:'https://www.linkedin.com/in/khalid-al-saleh-3561881a8/'));
                            },
                          )
                        ],
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SectionButton(
                        text: 'Home',
                        onPressed: () {
                          Scrollable.ensureVisible(homeKey.currentContext!,duration: 0.5.seconds,curve: Curves.easeIn);
                        },
                        isHover: homeIsHover,
                        lineWidth: 35,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: SectionButton(
                          text: 'Overview',
                          onPressed: () {
                            Scrollable.ensureVisible(overviewKey.currentContext!,duration: 1.seconds,curve: Curves.easeIn);
                          },
                          isHover: overviewIsHover,
                          lineWidth: 55,
                        ),
                      ),
                      SectionButton(
                        text: 'Experience',
                        onPressed: () {
                          Scrollable.ensureVisible(experienceKey.currentContext!,duration: 1.5.seconds,curve: Curves.easeIn);
                        },
                        isHover: experienceIsHover,
                        lineWidth: 70,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: SectionButton(
                          text: 'Projects',
                          onPressed: () {
                            Scrollable.ensureVisible(projectsKey.currentContext!,duration: 2.seconds,curve: Curves.easeIn);
                          },
                          isHover: projectsIsHover,
                          lineWidth: 50,
                        ),
                      ),
                      SectionButton(
                        text: 'Contact',
                        onPressed: () {
                          Scrollable.ensureVisible(contactKey.currentContext!,duration: 2.5.seconds,curve: Curves.easeIn);
                        },
                        isHover: contactIsHover,
                        lineWidth: 50,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
               Scope(builder: (context) {
                    return showNavbarLineAndShowFloatingButton.value
                        ? Container(
                            width: maxWidth,
                            height: 2,
                            decoration: const BoxDecoration(
                                color: CustomColors.primary,
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 0,
                                      blurRadius: 8,
                                      color: CustomColors.primary)
                                ]),
                          ).animate().scaleX()
                        : const SizedBox.shrink();
                  })
        
        ],
      ),
    );
  }
}

class NavbarOnLessThanXLG extends StatelessWidget {
  const NavbarOnLessThanXLG({
    super.key,
    required this.maxWidth,
    required this.showDropdownNavbar, required this.homeKey, required this.overviewKey, required this.experienceKey, required this.projectsKey, required this.contactKey,
  });

  final double maxWidth;
  final Reactable<bool> showDropdownNavbar;
   final GlobalKey homeKey;
  final GlobalKey overviewKey;
  final GlobalKey experienceKey;
  final GlobalKey projectsKey;
  final GlobalKey contactKey;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 120.0),
            child: Scope(builder: (context) {
              return SizedBox(
                width: maxWidth,
                height: maxWidth / 4,
                child: ListView(
                  children: [
                    InkWell(
                       onTap: () {
                        showDropdownNavbar.value=false;
                        Scrollable.ensureVisible(homeKey.currentContext!,duration: 0.5.seconds,curve: Curves.easeIn);
                       },
                      child: Container(
                        color: CustomColors.brightBackground,
                        child: const Padding(
                          padding:  EdgeInsets.all(20.0),
                          child:  Text(
                            'Home',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                   InkWell(
                       onTap: () {
                        showDropdownNavbar.value=false;
                        Scrollable.ensureVisible(overviewKey.currentContext!,duration: 1.seconds,curve: Curves.easeIn);
                       },
                      child: Container(
                        color: CustomColors.brightBackground,
                        child: const Padding(
                          padding:  EdgeInsets.all(20.0),
                          child:  Text(
                            'Overview',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                   InkWell(
                       onTap: () {
                        showDropdownNavbar.value=false;
                        Scrollable.ensureVisible(experienceKey.currentContext!,duration: 1.5.seconds,curve: Curves.easeIn);
                       },
                      child: Container(
                        color: CustomColors.brightBackground,
                        child: const Padding(
                          padding:  EdgeInsets.all(20.0),
                          child:  Text(
                            'Experience',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                   InkWell(
                       onTap: () {
                        showDropdownNavbar.value=false;
                        Scrollable.ensureVisible(projectsKey.currentContext!,duration: 1.5.seconds,curve: Curves.easeIn);
                       },
                      child: Container(
                        color: CustomColors.brightBackground,
                        child: const Padding(
                          padding:  EdgeInsets.all(20.0),
                          child:  Text(
                            'Projects',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                InkWell(
                       onTap: () {
                        showDropdownNavbar.value=false;
                        Scrollable.ensureVisible(contactKey.currentContext!,duration: 1.5.seconds,curve: Curves.easeIn);
                       },
                      child: Container(
                        color: CustomColors.brightBackground,
                        child: const Padding(
                          padding:  EdgeInsets.all(20.0),
                          child:  Text(
                            'Contact',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                 InkWell(
                       onTap: () async{
                         await launchUrl(Uri.parse('https://github.com/khalid-alsaleh-dev'));
                       },
                      child: Container(
                        color: CustomColors.brightBackground,
                        child:  Padding(
                          padding:  const EdgeInsets.all(20.0),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children:  [
                             const Text(
                                'Github',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Image.asset(ImageAssets.github)
                            ],
                          ),
                        ),
                      ),
                    ),
                        InkWell(
                       onTap: () async{
                         await launchUrl(Uri.parse(  'https://www.facebook.com/khalid.alsaleh.52090/'));
                       },
                      child: Container(
                        color: CustomColors.brightBackground,
                        child:  Padding(
                          padding:  const EdgeInsets.all(20.0),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children:  [
                             const Text(
                                'Facebook',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Image.asset(ImageAssets.facebook)
                            ],
                          ),
                        ),
                      ),
                    ),
                      InkWell(
                       onTap: () async{
                          await launchUrl(Uri.parse(  'https://www.linkedin.com/in/khalid-al-saleh-3561881a8/'));
                       },
                      child: Container(
                        color: CustomColors.brightBackground,
                        child:  Padding(
                          padding:  const EdgeInsets.all(20.0),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children:  [
                             const Text(
                                'LinkedIn',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Image.asset(ImageAssets.linkedin)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate(target: showDropdownNavbar.value ? 1 : 0)
                  .scaleY(alignment: Alignment.topCenter);
            }),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: ElevatedButton(
              onPressed: () {
                showDropdownNavbar.value = !showDropdownNavbar.value;
              },
              style: const ButtonStyle(
                  shape: MaterialStatePropertyAll(CircleBorder()),
                  backgroundColor: MaterialStatePropertyAll(
                      CustomColors.brightBackground),
                  elevation: MaterialStatePropertyAll(5)),
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Icon(
                  Icons.list,
                  size: 25,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


  void scrollToWidgetByKey(GlobalKey key,ScrollController scrollController) {
    RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero); //this is global position
    double y = position.dy;
    scrollController.animateTo(y,
        duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
  }