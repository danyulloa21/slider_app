import 'package:flutter/material.dart';

class GameSizeConfig {
  final double screenWidth;
  final double screenHeight;

  /// Ancho real del coche (2:1)
  final double carWidth;

  GameSizeConfig(this.screenWidth, this.screenHeight, this.carWidth);

  double get carHeight => carWidth * 0.5; // relación 2:1

  // Obstáculos 2:1
  Size get obstacle2x1 => Size(carWidth * 0.8, carWidth * 0.4);

  // Obstáculos 1:1
  Size get obstacle1x1 => Size(carWidth * 0.7, carWidth * 0.7);

  // Recarga 1:1
  Size get recarga1x1 => Size(carWidth * 0.5, carWidth * 0.5);

  // Recarga 1:0.5
  Size get recarga1x05 => Size(carWidth * 0.5, carWidth * 0.25);
}
