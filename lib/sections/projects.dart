import 'package:flutter/material.dart';
import 'package:flutter_3d_portfolio/utils/breakpoints.dart';
import 'package:flutter_3d_portfolio/utils/constants.dart';
import 'package:flutter_3d_portfolio/utils/image_assets.dart';
import 'package:flutter_3d_portfolio/widgets/game.dart';
import 'package:flutter_3d_portfolio/widgets/project_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Projects extends StatelessWidget {
  const Projects({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;
      int crossAxisCount = 2;
      if (maxWidth >= Breakpoints.xlg) {
        crossAxisCount = 3;
      } else if (maxWidth >= Breakpoints.lg) {
        crossAxisCount = 2;
      } else {
        crossAxisCount = 1;
      }
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: maxWidth >= Breakpoints.xxlg
              ? 0
              : maxWidth * Constants.smallHorizontalPaddingRatio,
        ),
        child: Column(
          crossAxisAlignment: maxWidth >= Breakpoints.xxlg
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            const Text(
              '.Use the Ninja to discover my projects.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              '.Each project is hidden behind a metal plate.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              '.Use the arrow buttons (left ⬅ and right ➡) to get colse to the chains, when you see they got red, use the control button to cut them🎇.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Some Of My Projects.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            ),
         maxWidth < Breakpoints.xxlg? const SizedBox(height: 15,):const SizedBox.shrink(),
            maxWidth >= Breakpoints.xxlg
                ? const SizedBox(
                    width: double.infinity, height: 1000, child: Game())
                : StaggeredGrid.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 25,
                    crossAxisSpacing: 25,
                    children: [
                      StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount:crossAxisCount>=2? 1.3:1.2,
                          child: ProjectCard(
                            title: 'Flutter Brain Game',
                            image: ImageAssets.flutterBrainGame,
                            description:
                                'A brain game built using only pure flutter animations(with no engines like flutter flame engine.',
                            githubOnPressed: () {},
                            openOnPressed: () {},
                          )),
                      StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                         mainAxisCellCount:crossAxisCount>=2? 1.3:1.2,
                          child: ProjectCard(
                            title: 'Ethkrypto',
                            image: ImageAssets.ethkrypto,
                            description:
                                'A web3.0 blockchain application to make ethereum transactions built using react typescript on the frontend and solidity for developing smart contracts.',
                            githubOnPressed: () {},
                            openOnPressed: () {},
                          )),
                      StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount:crossAxisCount>=2? 1.3:1.2,
                          child: ProjectCard(
                            title: 'Al-labeeb YEP',
                            image: ImageAssets.allabeebYep,
                            description:
                                'A flutter project built for deaf people to fill a document using the sign language.',
                            githubOnPressed: () {},
                            openOnPressed: () {},
                          )),
                    ],
                  ),
          ],
        ),
      );
    });
  }
}
