import 'dart:async';

import 'package:flame/components.dart';

class NinjaAnimation {
 static late final SpriteAnimation idleLeft;
 static late final SpriteAnimation idleRight;
 static late final SpriteAnimation runLeft;
 static late final SpriteAnimation runRight;
 static late final SpriteAnimation jumpLeft;
 static late final SpriteAnimation jumpRight;
 static late final SpriteAnimation attackLeft;
 static late final SpriteAnimation attackRight;
 static const double animationSpeed=0.15;


 static FutureOr<void> load() async {
    
    final idleLeftSprites =
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map((i) => Sprite.load('IdleLeft$i.png'));
    idleLeft = SpriteAnimation.spriteList(
      await Future.wait(idleLeftSprites),
      stepTime: 0.1,
    );
    final idleRightSprites =
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map((i) => Sprite.load('Idle$i.png'));
    idleRight = SpriteAnimation.spriteList(
      await Future.wait(idleRightSprites),
      stepTime: 0.1,
    );

    final runLeftSprites =
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map((i) => Sprite.load('RunLeft__00$i.png'));
    runLeft = SpriteAnimation.spriteList(
      await Future.wait(runLeftSprites),
      stepTime: 0.1,
    );

    final runRightSprites =
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map((i) => Sprite.load('RunRight__00$i.png'));
    runRight = SpriteAnimation.spriteList(
      await Future.wait(runRightSprites),
      stepTime: 0.1,
    );

     final jumpLeftSprites =
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map((i) => Sprite.load('JumpLeft$i.png'));
    jumpLeft = SpriteAnimation.spriteList(
      await Future.wait(jumpLeftSprites),
      stepTime: 0.1,
    );
     final jumpRightSprites =
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map((i) => Sprite.load('JumpRight$i.png'));
    jumpRight = SpriteAnimation.spriteList(
      await Future.wait(jumpRightSprites),
      stepTime: 0.1,
    );

     final attackLeftSprites =
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map((i) => Sprite.load('AttackLeft$i.png'));
    attackLeft = SpriteAnimation.spriteList(
      await Future.wait(attackLeftSprites),
      stepTime: 0.05,
    );
     final attackRightSprites =
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map((i) => Sprite.load('Attack$i.png'));
    attackRight = SpriteAnimation.spriteList(
      await Future.wait(attackRightSprites),
      stepTime: 0.05,
    );
  }
}
