import 'dart:async';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<PixelAdventure>{
  final String color;
  BackgroundTile({this.color = "Brown",position}) : super(position: position);
  final double scrollSpeed = 0.2;
  @override
  FutureOr<void> onLoad() {
    
    size = Vector2.all(64.6);

    
    sprite = Sprite(
      
     game.images.fromCache("Background/$color.png"),
    
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    priority = -11;
 
    position.y += scrollSpeed;
    double tileSize = 64;
    int scrollHeight = (game.size.y  / tileSize).floor();
    if (position.y > scrollHeight * tileSize) position.y = -tileSize;
    super.update(dt);
  }
}