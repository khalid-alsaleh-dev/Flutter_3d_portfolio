import 'package:flutter/material.dart';
import 'package:flutter_3d_portfolio/utils/custom_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelloAndDescription extends StatefulWidget {
  const HelloAndDescription({super.key});

  @override
  State<HelloAndDescription> createState() => _HelloAndDescriptionState();
}

class _HelloAndDescriptionState extends State<HelloAndDescription> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;
      return SizedBox(
        width: maxWidth,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 30,
              height: 200,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                        color: CustomColors.primary,
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                  ),
                  Container(
                    width: 3,
                    height: 200,
                    color: CustomColors.primary,
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                      text: const TextSpan(
                          text: "Hi, I'm ",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 40),
                          children: [
                        TextSpan(
                          text: 'Khalid',
                          style: TextStyle(
                              color: CustomColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 40),
                        )
                      ])),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    'I am developing mobile and frontend applications using flutter with a great experience.',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextButton(
                      onPressed: () async{
                        await launchUrl(Uri(path:  'https://mail.google.com/mail/u/0/?fs=1&to=khalid.alsaleh.dev@gmail.com&tf=cm'));
                      },
                      child: const Text("Let's chat",
                          style: TextStyle(
                              color: CustomColors.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              fontSize: 20)))
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
