import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Trampoline extends SpriteAnimationComponent with HasGameRef<PixelAdventure>, CollisionCallbacks{
  final double offJump;

  Trampoline({
    this.offJump = 0,
    position,
    size,
  }) : super(
    position:  Vector2(position.x, position.y + 4),
    size: size,
  );

  double range = 0;
  final double _jumpForce = 260;
  bool state = false;


  @override
  FutureOr<void> onLoad() {

   
    add(RectangleHitbox(
      size: Vector2(24, 10),
      position: Vector2(1, 18),
      
    ));
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache("Traps/Trampoline/Idle.png"), 
        SpriteAnimationData.sequenced(
            amount: 1, 
            stepTime: 1,
            textureSize: Vector2.all(32)
      ));
    return super.onLoad();
  }
  @override
  void update(double dt) {
    if(state){

      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache("Traps/Trampoline/Jump (28x28).png"), 
          SpriteAnimationData.sequenced(
              amount: 8, 
              stepTime: 0.06, 
              textureSize: Vector2.all(28),
              loop: false
        ));
      
      game.player.velocity.y = -_jumpForce;
      game.player.position.y -= offJump * 16 - 30;
      game.player.isOnGround = false;
      game.player.hasJumped = false;
      
      state = false;

    }
    super.update(dt);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(other is Player){
      state = true;
    }
    if(other is Player ){
      if(game.playAudio){
        FlameAudio.play("bounce.wav", volume: game.audioVolume);

    }

    super.onCollisionStart(intersectionPoints, other);
  }

  }
}