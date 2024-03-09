import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/plant.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/score.dart';

import 'package:pixel_adventure/components/trampoline.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Level extends World with HasGameRef<PixelAdventure>{
  final String levelName;
  final Player player;
  

  Level({required this.levelName, required this.player});
  static late TiledComponent level;
  
  List<CollisionBlock> collisionBlocks = [];



  @override
  FutureOr<void> onLoad() async{
    
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));
    

    add(level);
    
    
    //_scrollingBackground();
    _spawningObjects();
    _addCollisions();
    add(Score());
    Future.delayed(const Duration(milliseconds: 50),(){
      gameRef.cam.viewfinder.position = player.position;
      Player.hasBorder = false;
    });
    

    return super.onLoad();
  }

  
  void _scrollingBackground() {
    
    final backgroundLayer = level.tileMap.getLayer("Background");
    if(backgroundLayer != null){
      final backgroundColor = backgroundLayer.properties.getValue("BackgroundColor");
      const tileSize = 64;

      final numTilesY = (game.size.y / tileSize).floor();
      final numTilesX = (game.size.x / tileSize).floor();

      for(double y = 0; y < game.size.y /numTilesY;y++){
        for(double x = 0;x < numTilesX;x++){
           final backgroundTile = BackgroundTile(
           color: backgroundColor ?? "Brown",
           position: Vector2(x * tileSize, y * tileSize)
         );

         add(backgroundTile);

        }
        
      }


      
    }
  }
  
  void _spawningObjects() {
    
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("Spawnpoints");

    if(spawnPointsLayer != null){
      for(final spawnPoint in spawnPointsLayer.objects){
      switch (spawnPoint.class_) {
        case "Player":
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          player.scale.x = 1;
          add(player);
          
          break;
        case "Fruit":
          final fruit = Fruit(
            fruit: spawnPoint.name,
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(spawnPoint.width, spawnPoint.height)
          );
          add(fruit);
          break;
        case "Saw":
          final isVertical = spawnPoint.properties.getValue("isVertical");
          final offNeg = spawnPoint.properties.getValue("offNeg");
          final offPos = spawnPoint.properties.getValue("offPos");
          final saw = Saw(
            isVertical: isVertical,
            offNeg: offNeg,
            offPos: offPos,
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(spawnPoint.width, spawnPoint.height)
          );
          add(saw);
          break;
        case "Checkpoint":    
          final checkpoint = Checkpoint(
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(spawnPoint.width, spawnPoint.height)
          );     
          add(checkpoint);
          break;
        case "Trampoline":
        final offJump = spawnPoint.properties.getValue("offJump");
          final trampoline = Trampoline(
            position: Vector2(spawnPoint.x, spawnPoint.y),
            size: Vector2(spawnPoint.width, spawnPoint.height),
            offJump: offJump
          );
          add(trampoline);

          break;
        case "sawAudio":
  
         // final sawAudioVolume = spawnPoint.properties.getValue("volume");
         // final sawAudio = SawAudio(
          //  volume: sawAudioVolume,
           // position: Vector2(spawnPoint.x, spawnPoint.y),
          //  size: Vector2(spawnPoint.width, spawnPoint.height),
          //);
          //add(sawAudio);
          
          break;
          case "Plant":
            final plantId = spawnPoint.properties.getValue("id");
            final attackDirection = spawnPoint.properties.getValue("attackDirection");
            final plant = Plant(
              plantId: plantId,
              attackDirection: attackDirection,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
         
            );
            add(plant);
            break;
    
        default:
       
      }
    }
    }
  }
  
  void _addCollisions() {

    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>("Collisions");

    if(collisionsLayer != null){
      for(final collision in collisionsLayer.objects){
        switch (collision.class_) {
          case "Platform":
            
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true
            );

            collisionBlocks.add(platform);
            add(platform);
            break;
          
          case "BorderA":
            
            final borderA = CollisionBlock(
              
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isBorderA: true,
              isPlatform: true
            );

            collisionBlocks.add( borderA);
            add( borderA);
            break;
          case "BorderB":
            
            final  borderB = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isBorderB: true,
              isPlatform: true
            );

            collisionBlocks.add(borderB);
            add(borderB);
            break;
 
            
          default:

            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }

    
    

    player.collisionBlocks = collisionBlocks;
  }

}