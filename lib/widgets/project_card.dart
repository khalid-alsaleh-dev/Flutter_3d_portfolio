import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard(
      {super.key,
      required this.image,
      required this.title,
      required this.description,
      required this.githubOnPressed,
      required this.openOnPressed});
  final String image;
  final String title;
  final String description;
  final VoidCallback githubOnPressed;
  final VoidCallback openOnPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context,constraints) {
        double maxWidth=constraints.maxWidth;
        return Container(
            decoration: const BoxDecoration(
                color: Color(0xff424346),
                borderRadius: BorderRadius.all(Radius.circular(10)),
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
                  width: maxWidth,
                  height: maxWidth*0.7,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10)),
                      image: DecorationImage(
                          image: ExactAssetImage(image), fit: BoxFit.fill)),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                                  backgroundColor: MaterialStatePropertyAll(
                                      Color(0xff424346)),
                                  side: MaterialStatePropertyAll(
                                      BorderSide(color: Color(0xff65F8AE)))),
                              child: const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text('Open',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15)),
                              )),
                          const SizedBox(
                            width: 15,
                          ),
                          ElevatedButton(
                              onPressed: githubOnPressed,
                              style: const ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      Color(0xff424346)),
                                  side: MaterialStatePropertyAll(
                                      BorderSide(color: Color(0xff65F8AE)))),
                              child: const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text('Github',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15)),
                              ))
                        ],
                      )
                    ],
                  ),
                )
              ],
            ));
      }
    );
  }
}
