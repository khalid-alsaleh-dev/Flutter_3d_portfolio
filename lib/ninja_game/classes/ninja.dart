import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_3d_portfolio/ninja_game/classes/ninja_game.dart';
import 'package:flutter_3d_portfolio/ninja_game/collisions/collision_base.dart';
import 'package:flutter_3d_portfolio/ninja_game/collisions/collision_first_project.dart';
import 'package:flutter_3d_portfolio/ninja_game/collisions/collision_second_project.dart';
import 'package:flutter_3d_portfolio/ninja_game/collisions/collision_third_project.dart';
import 'package:flutter_3d_portfolio/ninja_game/core/collision_box_size_variables.dart';
import 'package:flutter_3d_portfolio/ninja_game/core/collision_project_wrapper.dart';
import 'package:flutter_3d_portfolio/ninja_game/core/ninja_animation.dart';
import 'package:flutter_3d_portfolio/ninja_game/core/ninja_state.dart';
import 'package:flutter_3d_portfolio/ninja_game/core/project_state_variables.dart';


class Ninja extends SpriteAnimationComponent
    with HasGameRef<NinjaGame>, CollisionCallbacks {
  Ninja() : super(position: Vector2(100, 250));

  late NinjaState ninjaState;
  late ShapeHitbox ninjaHitbox;

  @override
  FutureOr<void> onLoad() async {
    // final defaultPaint = Paint()
    //   ..color = Colors.red
    //   ..style = PaintingStyle.stroke;
    ninjaHitbox = RectangleHitbox();
    // ..paint = defaultPaint
    // ..renderShape = true;
    priority = 1;
    await add(ninjaHitbox);
    ninjaState = NinjaState.idleRight;
    setIdleRightAnimation();
  }

  @override
  void onCollision(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    //wall collistion
    if (other is ScreenHitbox) {
      if (intersectionPoints.first[0] <= 0) {
        game.isLeftWallCollision = true;
      } else if (intersectionPoints.first[0] > 0 &&
          intersectionPoints.elementAt(0)[0] ==
              intersectionPoints.elementAt(1)[0]) {
        game.isRightWallCollision = true;
      }
    } //base collistion
    else if (other is CollisionBase) {
      if ((intersectionPoints.last[1].floor() - (y.floor() + 250)).abs() <=
          10) {
        game.shiftEnabled = false;
        game.isBaseCollision = true;
        game.ninjaPositionBeforeJump = y;
      }
    } else if (other is CollisionFirstProject) {
      if (!ProjectStateVariables.removeFirstProjectForeground.value) {
        ProjectStateVariables.enableToRemoveFirstProjectForeground.value = true;
      }
      //collision from left
      if (intersectionPoints.first[0] ==
              CollisionBoxSizeVariables.firstProjectTopLeftX &&
          intersectionPoints.last[0] <=
              (CollisionBoxSizeVariables.firstProjectTopLeftX +
                  CollisionBoxSizeVariables.collisionBoxWidth / 2)) {
                    print('collision from left in check collision');
        game.firstProjectLeftCollision = true;
        game.firstProjectRightCollision = false;
      }
      //collision from right
      if (intersectionPoints.last[0] ==
              CollisionBoxSizeVariables.firstProjectTopLeftX +
                  CollisionBoxSizeVariables.collisionBoxWidth &&
          intersectionPoints.first[0] >=
              (CollisionBoxSizeVariables.firstProjectTopLeftX +
                  CollisionBoxSizeVariables.collisionBoxWidth / 2)) {
        print('collision from right in check collision');
        game.firstProjectLeftCollision = false;
        game.firstProjectRightCollision = true;
      }
    } else if (other is CollisionSecondProject) {
      if (!ProjectStateVariables.removeSecondProjectForeground.value) {
        ProjectStateVariables.enableToRemoveSecondProjectForeground.value =
            true;
      }
      if (intersectionPoints.first[0] ==
              CollisionBoxSizeVariables.secondProjectTopLeftX &&
          intersectionPoints.last[0] <=
              (CollisionBoxSizeVariables.secondProjectTopLeftX +
                  CollisionBoxSizeVariables.collisionBoxWidth / 2)) {
        game.secondProjectLeftCollision = true;
        game.secondProjectRightCollision = false;
      }
      if (intersectionPoints.last[0] ==
              CollisionBoxSizeVariables.secondProjectTopLeftX +
                  CollisionBoxSizeVariables.collisionBoxWidth &&
          intersectionPoints.first[0] >=
              (CollisionBoxSizeVariables.secondProjectTopLeftX +
                  CollisionBoxSizeVariables.collisionBoxWidth / 2)) {
        game.secondProjectLeftCollision = false;
        game.secondProjectRightCollision = true;
      }
    } else if (other is CollisionThirdProject) {
      if (!ProjectStateVariables.removeThirdProjectForeground.value) {
        ProjectStateVariables.enableToRemoveThirdProjectForeground.value = true;
      }
      if (intersectionPoints.first[0] ==
              CollisionBoxSizeVariables.thirdProjectTopLeftX &&
          intersectionPoints.last[0] <=
              (CollisionBoxSizeVariables.thirdProjectTopLeftX +
                  CollisionBoxSizeVariables.collisionBoxWidth / 2)) {
        game.thirdProjectLeftCollision = true;
        game.thirdProjectRightCollision = false;
      }
      if (intersectionPoints.last[0] ==
              CollisionBoxSizeVariables.thirdProjectTopLeftX +
                  CollisionBoxSizeVariables.collisionBoxWidth &&
          intersectionPoints.first[0] >=
              (CollisionBoxSizeVariables.thirdProjectTopLeftX +
                  CollisionBoxSizeVariables.collisionBoxWidth / 2)) {
        game.thirdProjectLeftCollision = false;
        game.thirdProjectRightCollision = true;
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is ScreenHitbox) {
      game.isLeftWallCollision = false;
      game.isRightWallCollision = false;
    } else if (other is CollisionBase) {
      game.isBaseCollision = false;
    } else if (other is CollisionProjectWrapper) {
      game.firstProjectLeftCollision = false;
      game.firstProjectRightCollision = false;
      game.secondProjectLeftCollision = false;
      game.secondProjectRightCollision = false;
      game.thirdProjectLeftCollision = false;
      game.thirdProjectRightCollision = false;
      ProjectStateVariables.enableToRemoveFirstProjectForeground.value = false;
      ProjectStateVariables.enableToRemoveSecondProjectForeground.value = false;
      ProjectStateVariables.enableToRemoveThirdProjectForeground.value = false;
    }
  }

  void setNinjaState(double delta) {
    moveDown(delta);
    switch (ninjaState) {
      case NinjaState.jumpRight:
        jumpRight(delta);
        break;
      case NinjaState.jumpLeft:
        jumpLeft(delta);
        break;
      case NinjaState.runLeft:
        runLeft(delta);
        break;
      case NinjaState.runRight:
        runRight(delta);
        break;
      case NinjaState.idleLeft:
        idleLeft();
        break;
      case NinjaState.idleRight:
        idleRight();
        break;
      case NinjaState.attackLeft:
        attackLeft();
        break;
      case NinjaState.attackRight:
        attackRight();
        break;
    }
  }

  void runLeft(double delta) {
    if (!game.isLeftWallCollision) {
      setRunLeftAnimation();
      position.add(Vector2(delta * game.velocity, 0));
    }
  }

  void runRight(double delta) {
    if (!game.isRightWallCollision) {
      setRunRightAnimation();
      position.add(Vector2(delta * game.velocity, 0));
    }
  }

  void jumpLeft(double delta) {
    if (y <= game.ninjaPositionBeforeJump - game.jumpHeight) {
      game.isJump = false;
    } else {
      setJumpLeftAnimation();
      position.add(Vector2(0, -1.3 * delta * game.gravity));
    }
  }

  void jumpRight(double delta) {
    if (y <= game.ninjaPositionBeforeJump - game.jumpHeight) {
      game.isJump = false;
    } else {
      setJumpRightAnimation();
      position.add(Vector2(0, -1.3 * delta * game.gravity));
    }
  }

  void moveDown(double delta) {
    if (!game.isJump && !game.isBaseCollision) {
      setIdleRightAnimation();
      position.add(Vector2(0, delta * game.gravity));
    }
  }

  void idleLeft() {
    setIdleLeftAnimation();
  }

  void idleRight() {
    setIdleRightAnimation();
  }

  void attackLeft() {
    setAttackLeftAnimation();
  }

  void attackRight() {
    setAttackRightAnimation();
  }

  void setIdleRightAnimation() {
    _setAnimation(130, 250, NinjaAnimation.idleRight);
  }

  void setIdleLeftAnimation() {
    _setAnimation(130, 250, NinjaAnimation.idleLeft);
  }

  void setRunLeftAnimation() {
    _setAnimation(180, 250, NinjaAnimation.runLeft);
  }

  void setRunRightAnimation() {
    _setAnimation(180, 250, NinjaAnimation.runRight);
  }

  void setJumpLeftAnimation() {
    _setAnimation(180, 250, NinjaAnimation.jumpLeft);
  }

  void setJumpRightAnimation() {
    _setAnimation(180, 250, NinjaAnimation.jumpRight);
  }

  void setAttackLeftAnimation() {
    _setAnimation(300, 250, NinjaAnimation.attackLeft);
  }

  void setAttackRightAnimation() {
    _setAnimation(300, 250, NinjaAnimation.attackRight);
  }

  void _setAnimation(double width, double height, SpriteAnimation animation) {
    size = Vector2(width, height);
    this.animation = animation;
  }
}
