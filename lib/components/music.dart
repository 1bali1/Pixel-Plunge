
import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class BackgroundMusic extends SpriteAnimationComponent with HasGameRef<PixelAdventure>{
  bool backgroundAudio = false;
  bool levelMusic = false;

  @override
  FutureOr<void> onLoad() {
    if(game.playAudio){
      FlameAudio.bgm.initialize();
      FlameAudio.bgm.play("lobby.mp3", volume: game.bgAudioVolume);
      backgroundAudio = true;
    }
    return super.onLoad();
  }
   
   @override
   void update(double dt) {
    
    if(!game.lobbyState){
      if(!game.playAudio && backgroundAudio){
      FlameAudio.bgm.stop();
      backgroundAudio = false;
     }
     if(game.playAudio && !backgroundAudio){
       FlameAudio.bgm.initialize();
       FlameAudio.bgm.play("lobby.mp3", volume: game.bgAudioVolume);
       backgroundAudio = true;
     }

    }
    super.update(dt);
  }
}