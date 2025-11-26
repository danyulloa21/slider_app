import 'package:flutter/material.dart';

enum ObstacleType {
  obstacle2x1,
  obstacle1x1,
  recarga1x1,
  recarga1x05,
  tyrePickup,
  fuelPickup,
}

class ObstacleInstance {
  final ObstacleType type;

  /// Posición en pixeles
  double x;
  double y;

  /// Tamaño actual del sprite
  final Size size;

  /// Velocidad vertical (px por tick)
  double speed;

  /// Indica si ya fue procesado (colisión o recogido)
  bool consumed;

  ObstacleInstance({
    required this.type,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    this.consumed = false,
  });

  /// Mover hacia abajo
  void updatePosition(double dt) {
    y += speed * dt;
  }

  /// Rect para detección de colisiones
  Rect get rect => Rect.fromLTWH(x, y, size.width, size.height);
}
