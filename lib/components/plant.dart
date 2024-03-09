import "dart:async";
import "dart:math";
import "package:flame/collisions.dart";
import "package:flame/components.dart";
import "package:flame_audio/flame_audio.dart";
import "package:flame_tiled/flame_tiled.dart";
import "package:pixel_adventure/components/bullet.dart";
import "package:pixel_adventure/components/level.dart";
import "package:pixel_adventure/components/player.dart";
import "package:pixel_adventure/pixel_adventure.dart";

enum State { idle, attack, hit }

class Plant extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final int attackDirection;
  final String plantId;
  
  Plant({
    this.plantId = "1",
    this.attackDirection = 1,
    position,
    size,
 
  }) : super (
    position: position,
    size: size
  );
  late Timer attackTimer;
  late final int audioBoxId;
  bool playAudioPlant = false;

  static const stepTime = 0.05;
  static const tileSize = 16;
  static const runSpeed = 80;
  final textureSize = Vector2(44, 42);

  Vector2 velocity = Vector2.zero();
  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = -1;
  bool gotStomped = false;
  bool attacked = false;

  double _attackTimer = 0.0; 
  static const double attackInterval = 2.0; 

  late final Player player;
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _attackAnimation;
  late final SpriteAnimation _hitAnimation;
  final soundRange = 400;

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    
    player = game.player;
    add(
      RectangleHitbox(
        position: Vector2(4, 6),
        size: Vector2(24, 26),
      ),
    );
    _loadAllAnimations();
    if(attackDirection == 1){
      flipHorizontallyAroundCenter();
    }
    _attack();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    double distance = sqrt(pow(game.player.position.x - position.x, 2) + pow(game.player.position.y - position.y, 2));
    if (distance < soundRange) {
      playAudioPlant = true;
    }else{
      playAudioPlant = false;
    }
  
    _attackTimer += dt; 
    if (!gotStomped) {

      if (_attackTimer >= attackInterval && !gotStomped) {

        _attack(); 
        _attackTimer = 0.0; 
        
      
    }
    }
   
    super.update(dt);
  }



  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation("Idle", 11);
    _attackAnimation = _spriteAnimation("Attack", 8)..loop = false ..stepTime = 0.08;
    _hitAnimation = _spriteAnimation("Hit", 15)..loop = false;

    animations = {
      State.idle: _idleAnimation,
      State.attack: _attackAnimation,
      State.hit: _hitAnimation,
    };

    current = State.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Enemies/Plant/$state (44x42).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }



  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {

    collidedWithPlayer();
    super.onCollisionStart(intersectionPoints, other);
  }


  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playAudio && playAudioPlant) {
        FlameAudio.play("bounce.wav", volume: game.audioVolume);
      }
      gotStomped = true;
      current = State.hit;
      await animationTicker?.completed;
      animationTicker?.reset();
      removeFromParent();
    } else {
      player.collidedwithEnemy();
    }
  }
  
  void _attack() async{
   
    current = State.attack;
    Future.delayed(const Duration(milliseconds: 400),(){
      if(game.playAudio && playAudioPlant){
        FlameAudio.play("plant.mp3", volume: game.audioVolume);
      }
      
       _shootBullet();
    });
    
    
    Future.delayed(const Duration(milliseconds: 1000),(){
      current = State.idle;
    });

  }
  

  void _shootBullet() {
    final spawnPointsLayer = Level.level.tileMap.getLayer<ObjectGroup>("Spawnpoints");

    if(spawnPointsLayer != null){
      for(final spawnPoint in spawnPointsLayer.objects){
        final bulletName = "PlantBullet$plantId";
         if (spawnPoint.name == bulletName) {
            final bullet = Bullet(
            
              attackDirection: attackDirection,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
    
          );
          Level.level.add(bullet);
         }
        
        //  final isVertical = spawnPoint.properties.getValue("isVertical");
       //   final offNeg = spawnPoint.properties.getValue("offNeg");
      //  final offPos = spawnPoint.properties.getValue("offPos");




      }}
      }

}
  