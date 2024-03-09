import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class PPTexts extends TextComponent with HasGameRef<PixelAdventure>{
  final String textR;
  final double sizeFont;
  TextComponent textComponent = TextComponent( text: "", textRenderer: TextPaint(style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 50, fontFamily: "Hind")));
 
  PPTexts({
    this.sizeFont = 50,
    this.textR = "Pixel Plunge",
    position,
    size
  }) : super(
    position: Vector2(position.x -410, position.y - 80),
    size: size
  );
  @override
  FutureOr<void> onLoad() {
    textComponent.text = textR;
    textComponent.position = position ;
    textComponent.size = size;
    if(textR == "Choose a character!"){
      textComponent.textRenderer = TextPaint(style: TextStyle(color: Color.fromARGB(255, 236, 234, 234), fontSize: sizeFont, fontFamily: "Hind"));

    }else{
      textComponent.textRenderer = TextPaint(style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: sizeFont, fontFamily: "Hind"));
    }
    
    add(textComponent);



  
    return super.onLoad();
  }
}