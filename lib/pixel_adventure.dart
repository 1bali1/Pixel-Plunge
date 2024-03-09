import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';

import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/lobby.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';


class PixelAdventure extends FlameGame with 
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks
        {

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late CameraComponent cam;

  String musicTheme = "lobby";
  bool playAudio = false;
  double audioVolume = 4;
  double bgAudioVolume = 0.2;

  Player player = Player(character: "Mask Dude");
  late JoystickComponent joystick;
  bool showJoystick = true;
  List<String> levelNames = ["level_01", "level_02", "level_03"];
  int currentLevel = 0;
  late Lobby lobby;
  bool inLobby = true;
  bool lobbyState = false;
  late CameraComponent lobbyCam;



  @override
  Future<void> onLoad() async {
    await images.loadAllImages();
    await FlameAudio.audioCache.loadAll(["hit.wav", "disappear.wav", "saw.mp3","jump.wav", "level.mp3", "lobby.mp3", "bounce.wav", "collect_fruit.wav", "plant.mp3"]);
    Lobby lobby = Lobby();
    await lobby.loadLobby();
    add(lobby);
    FlameAudio.bgm.initialize();
    return super.onLoad();
  }

  
  @override
  void update(double dt) {

    if(!inLobby && lobbyState){
      removeWhere((component) => component is Lobby);
      loadLevel();
      if(showJoystick){
        addJoystick();
        add(JumpButton());
      }


    lobbyState = false;
    }    
    if(!lobbyState && !inLobby){
      if(showJoystick){
       updateJoystick();
      }
    }


   
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 10,
      size: 5,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 50, bottom: 35),
    );

    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.downLeft:
      case JoystickDirection.upLeft:
      case JoystickDirection.left:
        player.horizontalMovement = -1;
        
        break;
      case JoystickDirection.downRight:
      case JoystickDirection.upRight:
      case JoystickDirection.right:
        player.horizontalMovement = 1;
        
        break;


      default:
        player.horizontalMovement = 0;
         break;
    }
  }
  
  void loadNextLevel() {
    removeWhere((component) => component is Level);

    if (currentLevel< levelNames.length - 1) {
      currentLevel++;
      loadLevel();
    } else {
     
      currentLevel = 0;
      loadLevel();
    }
  }

  void loadLevel() {
    Future.delayed(const Duration(seconds: 1),(){

      Level world = Level(
         player: player,
         levelName: levelNames[currentLevel]
       );

      cam = CameraComponent.withFixedResolution(width: 900, height: 430, world: world);
      cam.viewfinder.position = Vector2(player.position.x, player.position.y);
      cam.viewfinder.zoom = 1.2;
      cam.priority = 0;


      addAll([cam,world]);

    });
  }

}