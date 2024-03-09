import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_adventure/components/buttons.dart';
import 'package:pixel_adventure/components/characters.dart';
import 'package:pixel_adventure/components/music.dart';
import 'package:pixel_adventure/components/texts.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Lobby extends World with HasGameRef<PixelAdventure>{
  late TiledComponent lobby;
  late CameraComponent lobbyCam;
  TextComponent pixelPlungeText = TextComponent( text: "Pixel Plunge", textRenderer: TextPaint(style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 80, fontFamily: "Hind")));
  TextComponent chooseText = TextComponent( text: "Choose a character!", textRenderer: TextPaint(style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 50, fontFamily: "Hind")));
 
  Lobby();

  Future<void> loadLobby() async {
    lobby = await TiledComponent.load("lobby.tmx", Vector2.all(16));
    Future.delayed(const Duration(seconds: 1),(){
          
    add(lobby);
    lobbyCam = CameraComponent.withFixedResolution(width: 1000, height: 480, world: this);
    lobbyCam.viewfinder.position = Vector2(1000, 330);
    lobbyCam.priority = 0;
    lobbyCam.viewfinder.zoom = 1;
    gameRef.add(lobbyCam);
  
    add(BackgroundMusic());
    _loadCharacters();
    _addTexts();
    _addButtons();
    });
}
   void _loadCharacters(){
     final charactersLayer = lobby.tileMap.getLayer<ObjectGroup>("Characters");
     if(charactersLayer != null){
      for(final character in charactersLayer.objects){

        final characterObject = CharactersA(
       
          character: character.name,
          position: Vector2(character.x, character.y),
          size: Vector2(character.width, character.height)

        );
        add(characterObject);
            

        }
      
        }
      }
    void _addTexts(){
     final textsLayer = lobby.tileMap.getLayer<ObjectGroup>("Texts");
     if(textsLayer != null){
      for(final text in textsLayer.objects){
        
        final textObject = PPTexts(
          sizeFont: text.properties.getValue("size"),
          textR: text.name,
          position: Vector2(text.x, text.y),
          size: Vector2(text.width, text.height)

        );
        add(textObject);

        }
      
        }
      }
      
        void _addButtons() {
          final buttonsLayer = lobby.tileMap.getLayer<ObjectGroup>("Buttons");
          if(buttonsLayer != null){
            for(final button in buttonsLayer.objects){
              final buttonObject = AddButtons(
                button: button.name,
                position: Vector2(button.x, button.y),
                size: Vector2(button.width, button.height)
              );
              add(buttonObject);
            }
          }
        }



}
