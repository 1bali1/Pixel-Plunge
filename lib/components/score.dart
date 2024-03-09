import 'dart:async';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Score extends Component with HasGameRef<PixelAdventure> {
  TextComponent textComponent = TextComponent(text: "Score • 0");
  
  static int score = 0;
  Score();
  

  @override
  Future<void> onLoad() async {

    
    textComponent.anchor = Anchor.topLeft;
    textComponent.position = Vector2(10, 10);
    textComponent.size = Vector2(20, 20);
    gameRef.add(textComponent);

    return super.onLoad();
  }

  void updateScore(int num) {
    score += num;

    
  }
  @override
  void update(double dt) {
    textComponent.text = "Score • $score";
    super.update(dt);
  }
}
