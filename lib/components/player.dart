import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import "package:flutter/services.dart";
import 'package:pixel_adventure/components/bullet.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/score.dart';

import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';


enum PlayerState{
  idle, 
  running,
  jumping,
  falling,
  hit,
  appearing,
  disappearing
  }


class Player extends SpriteAnimationGroupComponent with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks{

  String character;
  Player({position, this.character = "Ninja Frog"}): super(position: position);


  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  static bool hasBorder = true;
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;
  late bool offJump;

  final double _gravity = 9.8;
  final double _jumpForce = 260;
  final double _terminalVelocity = 300;
  final double stepTime = 0.05;
  double horizontalMovement = 0;
  double moveSpeed = 100;
  double accumulatedTime = 0;
  double fixedDeltaTime = 1 / 60;


  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  CusotmHitbox hitbox = CusotmHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28
  );
 

  @override
  FutureOr<void> onLoad() {

    startingPosition = Vector2.zero();
    _loadAllAnimations();
    
    
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height)
    ));
    Future.delayed(const Duration(seconds: 5), (){
      startingPosition = Vector2(position.x, position.y);
      });
    

    return super.onLoad();
  }

 @override
 void update(double dt) {
    
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
           if(!hasBorder){
      updateCameraPosition();
    }
      if (!gotHit && !reachedCheckpoint) {
    _updatePlayerMovement(fixedDeltaTime);
    _updatePlayerState();
   
    _checkHorizontalCollisions();
    _applyGravity(fixedDeltaTime);
    _verticalCollisions();

  }
  accumulatedTime -= fixedDeltaTime;
  }
    super.update(dt);

}
 void updateCameraPosition() {

    final double t = 0.1;
    final newPosition = interpolate(gameRef.cam.viewfinder.position, position, t);
    gameRef.cam.viewfinder.position = newPosition;
 }

 Vector2 interpolate(Vector2 a, Vector2 b, double t) {

    return a * (1 - t) + b * t;
 }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Fruit) other.collidedWithPlayer();
      if (other is Saw) respawn();

      if (other is Checkpoint) _reachedCheckpoint();
      if(other is Bullet) respawn();



    }
    super.onCollisionStart(intersectionPoints, other);
  }


  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation("Idle", 11);
    runningAnimation = _spriteAnimation("Run", 12);
    jumpingAnimation = _spriteAnimation("Jump", 1);
    fallingAnimation = _spriteAnimation("Fall", 1);
    hitAnimation = _spriteAnimation("Hit", 7)..loop = false;
    appearingAnimation = _specialAnimation("Appearing", 7);
    disappearingAnimation = _specialAnimation("Desappearing", 7);

    //Az összes animáció
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };

    //Jelenlegi animáció
    current = PlayerState.idle;
  }


  SpriteAnimation _spriteAnimation(String state, int amount){

    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Main Characters/$character/$state (32x32).png"),
      SpriteAnimationData.sequenced(
        amount: amount, 
        stepTime: stepTime, 
        textureSize: Vector2.all(32),
       
        )
      );   
  }
  
  SpriteAnimation _specialAnimation(String state, int amount){

    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Main Characters/$state (96x96).png"),
      SpriteAnimationData.sequenced(
        amount: amount, 
        stepTime: stepTime, 
        textureSize: Vector2.all(96),
        loop: false
        
        )
      );   
  }

  
  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if(velocity.x < 0 && scale.x > 0){
      flipHorizontallyAroundCenter();

    }else if(velocity.x > 0 && scale.x < 0){
      flipHorizontallyAroundCenter();



    }
    if(velocity.y > 0) playerState = PlayerState.falling;
    if(velocity.y < 0) playerState = PlayerState.jumping;

    if(velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;



    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
 
    if(hasJumped && isOnGround){
      _playerJump(dt);
    }
    if(velocity.y > _gravity){
      
      isOnGround = false;
    }
    
    velocity.x = horizontalMovement * moveSpeed;

    position.x += velocity.x * dt;
    

  }

  void _playerJump(double dt) {
    if(game.playAudio){
      FlameAudio.play("jump.wav", volume: game.audioVolume -2);
    }
    velocity.y = -_jumpForce;
    position.y += velocity.y *dt;
    isOnGround = false;
    hasJumped = false;
  }
  
  void _checkHorizontalCollisions() {
    for(final block in collisionBlocks){
      if(!block.isPlatform){
        if(checkCollision(this, block)){
          if(velocity.x > 0){
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX -hitbox.width;
            break;
          }
          if(velocity.x < 0){
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.offsetX + hitbox.width;
            break;
          }

        }
      }else if(block.isBorderA){


        if(checkCollision(this, block)){
       
          hasBorder = true;
          break;
          
          
        }
      }else if(block.isBorderB){


        if(checkCollision(this, block)){
       
          hasBorder = false;
          break;
          
          
        }
      }

    }
  }
  
  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }
  
  void _verticalCollisions() {
    for(final block in collisionBlocks){
      if(block.isPlatform){
      
        }else if(block.isBorderA){
           if(checkCollision(this, block)){
             hasBorder = true;
             break;

        }
      }else if(block.isBorderB){
        if(checkCollision(this, block)){
    
          hasBorder = false;
          break;

        }
      }
      


      else{
        if(checkCollision(this, block)){
          if(velocity.y > 0){
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if(velocity.y < 0){
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
            break;
          }
        }
      }
    }
  }
  
  void respawn() async {
    if(game.playAudio){
      FlameAudio.play("hit.wav", volume: game.audioVolume);
    }
    late final respawnPosX;
    late final respawnPosY;
    final spawnPointsLayer = Level.level.tileMap.getLayer<ObjectGroup>("Spawnpoints");
    if(spawnPointsLayer != null){
      for(final spawnPoint in spawnPointsLayer.objects){
      switch (spawnPoint.class_) {
        case "Player":
          respawnPosX = spawnPoint.x;
          respawnPosY = spawnPoint.y;
          break;
    }}
    const canMoveDuration = Duration(milliseconds: 400);
    gotHit = true;
    current = PlayerState.hit;

    await animationTicker?.completed;
    animationTicker?.reset();

    scale.x = 1;
    position = Vector2(respawnPosX, respawnPosY) - Vector2.all(20);
    current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    velocity = Vector2.zero();
    position = Vector2(respawnPosX + 15, respawnPosY + 15);
    _updatePlayerState();
    Future.delayed(canMoveDuration, () => gotHit = false);
    ;
  }
  }




  void _reachedCheckpoint() async {
    reachedCheckpoint = true;
    if(game.playAudio){
      FlameAudio.play("disappear.wav", volume: game.audioVolume);
    }
    hasBorder = true;

    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }

    current = PlayerState.disappearing;

    await animationTicker?.completed;
    animationTicker?.reset();
    reachedCheckpoint = false;
    
    position = Vector2.all(-640);

    const waitToChangeDuration = Duration(seconds: 3);
    Future.delayed(waitToChangeDuration, () => game.loadNextLevel());
    Score.score = 0;

  }

  void collidedwithEnemy() {
    respawn();
  }
  
 
}