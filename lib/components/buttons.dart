import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class AddButtons extends SpriteAnimationComponent with HasGameRef<PixelAdventure>, TapCallbacks{
  String button;
  AddButtons({
    this.button = "Volume",
    position,
    size
  }) : super(
    position: position,
    size: size
  );
  @override
  FutureOr<void> onLoad(){
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache("Menu/Buttons/$button.png"),
      SpriteAnimationData.sequenced(
        amount: 1, 
        stepTime: 1, 
        textureSize: Vector2(21,22))
    );

    return super.onLoad();
  }
 @override
  void onTapUp(TapUpEvent event) {
    if(button == "Volume"){
      _changeButtonStyle("VolumeX");
      button = "VolumeX";
      game.playAudio = false;
      
    }else if(button == "VolumeX"){
      _changeButtonStyle("Volume");
      button = "Volume";
      game.playAudio = true;
    }

    super.onTapUp(event);
  }
  
  void _changeButtonStyle(String Button) {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache("Menu/Buttons/$Button.png"),
      SpriteAnimationData.sequenced(
        amount: 1, 
        stepTime: 1, 
        textureSize: Vector2(21,22))
    );
  }
  




}