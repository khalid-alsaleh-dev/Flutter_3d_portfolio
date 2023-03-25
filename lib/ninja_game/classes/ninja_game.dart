import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_3d_portfolio/ninja_game/classes/ninja.dart';
import 'package:flutter_3d_portfolio/ninja_game/collisions/collision_base.dart';
import 'package:flutter_3d_portfolio/ninja_game/collisions/collision_first_project.dart';
import 'package:flutter_3d_portfolio/ninja_game/collisions/collision_second_project.dart';
import 'package:flutter_3d_portfolio/ninja_game/collisions/collision_third_project.dart';
import 'package:flutter_3d_portfolio/ninja_game/core/collision_box_size_variables.dart';
import 'package:flutter_3d_portfolio/ninja_game/core/ninja_animation.dart';
import 'package:flutter_3d_portfolio/ninja_game/core/ninja_state.dart';
import 'package:flutter_3d_portfolio/ninja_game/core/project_state_variables.dart';
import 'package:flutter_3d_portfolio/ninja_game/utils/game_audio.dart';

class NinjaGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  double velocity = 0.0;
  double gravity = 500.0;
  double jumpHeight = 200;
  double ninjaPositionBeforeJump = 0.0;
  int lastNinjaStateDirection = 0;
  bool isJump = false;
  bool isLeftWallCollision = false;
  bool isRightWallCollision = false;
  bool isBaseCollision = true;
  bool shiftEnabled = true;
  int maxTimeSpacingInMilliSecondsForHit = 1200;
  int lastTimeHitPressed = 0;

  //projects variables
  bool firstProjectLeftCollision = false;
  bool firstProjectRightCollision = false;
  static const firstProjectOverlay = 'FirstProjectOverlay';

  bool secondProjectLeftCollision = false;
  bool secondProjectRightCollision = false;
  static const secondProjectOverlay = 'SecondProjectOverlay';

  bool thirdProjectLeftCollision = false;
  bool thirdProjectRightCollision = false;
  static const thirdProjectOverlay = 'ThirdProjectOverlay';

  @override
  Color backgroundColor() {
    return const Color(0xff2D2F33);
  }

  final Ninja ninja = Ninja();

  @override
  FutureOr<void> onLoad() async {
    await add(ScreenHitbox());
    await add(ninja);

    //collision bases
    // await add(
    //     CollisionBase(baseHeight: 10, baseWidth: 1950, baseX: 0, baseY: 850));
    await add(
        CollisionBase(baseHeight: 10, baseWidth: 1950, baseX: 0, baseY: 500));

    // collision projects
    await add(CollisionFirstProject(
        baseHeight: CollisionBoxSizeVariables.firstProjectHeight,
        baseWidth: CollisionBoxSizeVariables.firstProjectWidth,
        baseX: CollisionBoxSizeVariables.firstProjectTopLeftX,
        baseY: CollisionBoxSizeVariables.firstProjectTopLeftY));

    await add(CollisionSecondProject(
        baseHeight: CollisionBoxSizeVariables.secondProjectHeight,
        baseWidth: CollisionBoxSizeVariables.secondProjectWidth,
        baseX: CollisionBoxSizeVariables.secondProjectTopLeftX,
        baseY: CollisionBoxSizeVariables.secondProjectTopLeftY));

    await add(CollisionThirdProject(
        baseHeight: CollisionBoxSizeVariables.thirdProjectHeight,
        baseWidth: CollisionBoxSizeVariables.thirdProjectWidth,
        baseX: CollisionBoxSizeVariables.thirdProjectTopLeftX,
        baseY: CollisionBoxSizeVariables.thirdProjectTopLeftY));

    // project overlays
    overlays.add(firstProjectOverlay);
    overlays.add(secondProjectOverlay);
    overlays.add(thirdProjectOverlay);
  }

  @override
  void update(double dt) {
    ninja.setNinjaState(dt);
    super.update(dt);
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRight = keysPressed.contains(LogicalKeyboardKey.arrowRight);
    final isControl = keysPressed.contains(LogicalKeyboardKey.controlLeft);
    final isShift = keysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
        keysPressed.contains(LogicalKeyboardKey.shiftRight);

    if (isRight) {
      velocity = 400;
      ninja.ninjaState = NinjaState.runRight;
      lastNinjaStateDirection = 0;
    } else if (isLeft) {
      velocity = -400;
      ninja.ninjaState = NinjaState.runLeft;
      lastNinjaStateDirection = 1;
    } else if (isControl) {
      if (DateTime.now().millisecondsSinceEpoch - lastTimeHitPressed >=
          maxTimeSpacingInMilliSecondsForHit) {
        lastTimeHitPressed = DateTime.now().millisecondsSinceEpoch;
        if (lastNinjaStateDirection == 0) {
          ninja.ninjaState = NinjaState.attackRight;
        } else {
          ninja.ninjaState = NinjaState.attackLeft;
        }
        if (firstProjectLeftCollision &&
            ninja.ninjaState == NinjaState.attackRight) {
          //cut the rope
          if (!ProjectStateVariables.removeFirstProjectForeground.value) {
            GameAudio.playCutTheChain();
          }
          ninja.x = CollisionBoxSizeVariables.firstProjectTopLeftX - 150;
          ProjectStateVariables.removeFirstProjectForeground.value = true;
          ProjectStateVariables.enableToRemoveFirstProjectForeground.value =
              false;
        }
        if (firstProjectRightCollision &&
            ninja.ninjaState == NinjaState.attackLeft) {
          //cut the rope
          if (!ProjectStateVariables.removeFirstProjectForeground.value) {
            GameAudio.playCutTheChain();
          }
          ninja.x = CollisionBoxSizeVariables.firstProjectTopLeftX +
              CollisionBoxSizeVariables.firstProjectWidth -
              150;
          ProjectStateVariables.removeFirstProjectForeground.value = true;
          ProjectStateVariables.enableToRemoveFirstProjectForeground.value =
              false;
        }
        if (secondProjectLeftCollision &&
            ninja.ninjaState == NinjaState.attackRight) {
          //cut the rope
          if (!ProjectStateVariables.removeSecondProjectForeground.value) {
            GameAudio.playCutTheChain();
          }
          ninja.x = CollisionBoxSizeVariables.secondProjectTopLeftX - 150;
          ProjectStateVariables.removeSecondProjectForeground.value = true;
          ProjectStateVariables.enableToRemoveSecondProjectForeground.value =
              false;
        }
        if (secondProjectRightCollision &&
            ninja.ninjaState == NinjaState.attackLeft) {
          //cut the rope
          if (!ProjectStateVariables.removeSecondProjectForeground.value) {
            GameAudio.playCutTheChain();
          }
          ninja.x = CollisionBoxSizeVariables.secondProjectTopLeftX +
              CollisionBoxSizeVariables.secondProjectWidth -
              150;
          ProjectStateVariables.removeSecondProjectForeground.value = true;
          ProjectStateVariables.enableToRemoveSecondProjectForeground.value =
              false;
          print('cut the rope from right');
        }
        if (thirdProjectLeftCollision &&
            ninja.ninjaState == NinjaState.attackRight) {
          //cut the rope
          if (!ProjectStateVariables.removeThirdProjectForeground.value) {
            GameAudio.playCutTheChain();
          }
          ninja.x = CollisionBoxSizeVariables.thirdProjectTopLeftX - 150;
          ProjectStateVariables.removeThirdProjectForeground.value = true;
          ProjectStateVariables.enableToRemoveThirdProjectForeground.value =
              false;
          print('cut the rope from left');
        }
        if (thirdProjectRightCollision &&
            ninja.ninjaState == NinjaState.attackLeft) {
          //cut the rope
          if (!ProjectStateVariables.removeThirdProjectForeground.value) {
            GameAudio.playCutTheChain();
          }
          ninja.x = CollisionBoxSizeVariables.thirdProjectTopLeftX +
              CollisionBoxSizeVariables.thirdProjectWidth -
              150;
          ProjectStateVariables.removeThirdProjectForeground.value = true;
          ProjectStateVariables.enableToRemoveThirdProjectForeground.value =
              false;
          print('cut the rope from right');
        } else {
          GameAudio.playSword();
        }
      } else {
        if (lastNinjaStateDirection == 0) {
          ninja.ninjaState = NinjaState.idleRight;
        } else {
          ninja.ninjaState = NinjaState.idleLeft;
        }
      }
    } else if (isShift) {
      if (!shiftEnabled) {
        shiftEnabled = true;
        isJump = true;
        GameAudio.playJump();
        if (lastNinjaStateDirection == 0) {
          ninja.ninjaState = NinjaState.jumpRight;
        } else {
          ninja.ninjaState = NinjaState.jumpLeft;
        }
      }
    } else if (isShift && isRight) {
      velocity = 400;
      ninja.ninjaState = NinjaState.runRight;
      lastNinjaStateDirection = 0;
      if (lastNinjaStateDirection == 0) {
        ninja.ninjaState = NinjaState.jumpRight;
      } else {
        ninja.ninjaState = NinjaState.jumpLeft;
      }
    } else {
      velocity = 0;
      isJump = false;
      if (lastNinjaStateDirection == 0) {
        ninja.ninjaState = NinjaState.idleRight;
      } else {
        ninja.ninjaState = NinjaState.idleLeft;
      }
    }
    return KeyEventResult.ignored;
  }
}
