import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class CharactersA extends SpriteAnimationComponent with HasGameRef<PixelAdventure>, TapCallbacks{
  final String character;
  CharactersA({
    this.character = "Ninja Frog",
    position,
    size,
    
   }) : super(
    position: position,
    size: size,
   );

  @override
  FutureOr<void> onLoad() {
 
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache("Main Characters/$character/Idle (32x32).png"), 
      SpriteAnimationData.sequenced(
        amount: 11, 
        stepTime: 0.05, 
        textureSize: Vector2.all(32)
      ));
   
    return super.onLoad();
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.inLobby = false;
    game.lobbyState = true;
    game.player.character = character;
    PixelAdventure().loadLevel();
    FlameAudio.bgm.stop();
    
    if(game.playAudio){
      
      FlameAudio.bgm.play("level.mp3", volume: game.bgAudioVolume);
    }
    super.onTapUp(event);
  }

}