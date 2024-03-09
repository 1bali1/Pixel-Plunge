import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent{
  bool isPlatform;
  bool isBorderA;
  bool isBorderB;
  CollisionBlock({position, size, this.isPlatform = false, this.isBorderA = false, this.isBorderB = false}) : super(position: position, size: size){debugMode = false;}

}