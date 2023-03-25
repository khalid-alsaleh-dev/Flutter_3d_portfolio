import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_portfolio/ninja_game/classes/ninja_game.dart';
import 'package:flutter_3d_portfolio/ninja_game/core/project_state_variables.dart';
import 'package:flutter_3d_portfolio/ninja_game/utils/game_audio.dart';
import 'package:flutter_3d_portfolio/ninja_game/widgets/project_animated_foreground.dart';
import 'package:flutter_3d_portfolio/utils/image_assets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}


class _GameState extends State<Game> {
  
  bool audioPlayed = false;

  @override
  void dispose() {
    GameAudio.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('game'),
      onVisibilityChanged: (visibilityInfo) async{
        double visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage > 80 && !audioPlayed) {
          await GameAudio.playNinjaSoundTrack();
          audioPlayed = true;
        } else if(visiblePercentage <40) {
          if (audioPlayed) {
           await GameAudio.stopNinjaSoundTrack();
            audioPlayed = false;
          }
        }
      },
      child: GameWidget(
        game: NinjaGame(),
        overlayBuilderMap: {
          'FirstProjectOverlay': (ctx, NinjaGame myGame) {
            return Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 200, left: 400),
                  child: ProjectAnimatedForeground(
                    title: 'Flutter Brain Game',
                    description:
                        'A brain game built using only pure flutter animations(with no engines like flutter flame engine).',
                    githubOnPressed: () {},
                    image: ImageAssets.flutterBrainGame,
                    openOnPressed: () {},
                    removeForeground:
                        ProjectStateVariables.removeFirstProjectForeground,
                    enableToRemoveForeground: ProjectStateVariables
                        .enableToRemoveFirstProjectForeground,
                        delay: 0.1.seconds,
                  ),
                ));
          },
          'SecondProjectOverlay': (ctx, NinjaGame myGame) {
            return Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 200),
                  child: ProjectAnimatedForeground(
                      title: 'Ethkrypto',
                      description:
                          'A web3.0 blockchain application to make ethereum transactions built using react typescript on the frontend and solidity for developing smart contracts.',
                      githubOnPressed: () {},
                      image: ImageAssets.ethkrypto,
                      openOnPressed: () {},
                      removeForeground:
                          ProjectStateVariables.removeSecondProjectForeground,
                      enableToRemoveForeground: ProjectStateVariables
                          .enableToRemoveSecondProjectForeground,
                          delay: 0.2.seconds,
                          ),
                ));
          },
          'ThirdProjectOverlay': (ctx, NinjaGame myGame) {
            return Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 200, right: 400),
                  child: ProjectAnimatedForeground(
                    title: 'Al-labeeb YEP',
                    description:
                        'A flutter project built for deaf people to fill a document using the sign language.',
                    githubOnPressed: () {},
                    image: ImageAssets.allabeebYep,
                    openOnPressed: () {},
                    removeForeground:
                        ProjectStateVariables.removeThirdProjectForeground,
                    enableToRemoveForeground: ProjectStateVariables
                        .enableToRemoveThirdProjectForeground,
                        delay: 0.3.seconds,
                  ),
                ));
          },
        },
      ),
    );
  }
}