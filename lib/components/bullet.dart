import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Bullet extends SpriteAnimationComponent with HasGameRef<PixelAdventure>, CollisionCallbacks{
  final int attackDirection;
  final String bulletId;
  Bullet({
    this.bulletId = "1",
    this.attackDirection = 1,
    position,
    size,
  }) : super(
     
    position: position,
    size: size
  );
  CusotmHitbox hitbox = CusotmHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 8,
    height: 8
  );
  @override
  FutureOr<void> onLoad() {
    
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache("Enemies/Plant/Bullet.png"),
      SpriteAnimationData.sequenced(
        amount: 1, 
        stepTime:1, 
        textureSize: Vector2.all(16)
    ));
    
    return super.onLoad();
  }
  @override
  void update(double dt) {

    position.x += attackDirection * dt * 250;
    _checkCollisions();
    
    super.update(dt);
  }



  void _checkCollisions() async{
    for(final block in game.player.collisionBlocks){
      if(checkCollision(this, block)){
        removeFromParent();
      }
    }
    if(checkPlayerCollision(this, game.player)){
       removeFromParent();
       game.player.respawn();
    }
  }
}