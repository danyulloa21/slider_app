import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/obstacle_model.dart';
import '../../data/models/car_model.dart';
import '../../data/models/scenario_model.dart';
import '../../core/utils/game_size_config.dart';

class GameController extends GetxController {
  static const double horizontalPadding = 16.0;

  late final String username;
  CarModel? car;
  ScenarioModel? scenario;

  late GameSizeConfig sizeConfig;

  // Config de carriles y vista
  final lanesCount = 3.obs;
  final laneWidth = 0.0.obs;
  final isVertical = true.obs;

  // Estado del jugador
  final laneIndex = 0.obs; // 0..lanesCount-1
  final fuel = 100.0.obs; // 0..100
  final tyres = 3.obs; // vidas
  final score = 0.obs;

  /// Posición actual del coche en la pista
  final carX = 0.0.obs;
  final carY = 0.0.obs;

  /// Actualiza la posición del coche (llamado desde la vista)
  void updateCarPosition(double x, double y) {
    carX.value = x;
    carY.value = y;
  }

  /// Lista de obstáculos y recogibles (gasolina, llantas) que se dibujan en la pista
  final obstacles = <ObstacleInstance>[].obs;

  final Random _rand = Random();
  Size? _playAreaSize;

  @override
  void onInit() {
    super.onInit();
    _readArguments();
  }

  @override
  void onReady() {
    super.onReady();
    _configureLayout();
  }

  void _readArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    username = args['username'] as String? ?? 'Player';
    car = args['car'] as CarModel?;
    scenario = args['scenario'] as ScenarioModel?;
    final vertical = args['isVertical'] as bool? ?? true;
    isVertical.value =
        vertical; // 👈 crea un RxBool isVertical en este controller
  }

  void _configureLayout() {
    final size = Get.size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    int chosenLanes = 5;
    double chosenCarWidth = 0;
    double chosenLaneWidth = 0;

    // Buscamos el mayor número de carriles (hasta 5) que quepa
    // respetando laneWidth = 1.1 * carWidth y un padding lateral.
    for (int lanes = 5; lanes >= 2; lanes--) {
      final availableWidth =
          screenWidth - horizontalPadding * 2; // restamos padding lateral
      final possibleCarWidth = availableWidth / (lanes * 1.1);

      // definimos un mínimo razonable para que el coche no sea microscópico
      if (possibleCarWidth >= 60) {
        chosenLanes = lanes;
        chosenCarWidth = possibleCarWidth;
        chosenLaneWidth = possibleCarWidth * 1.1;
        break;
      }
    }

    lanesCount.value = chosenLanes;
    laneWidth.value = chosenLaneWidth;

    sizeConfig = GameSizeConfig(screenWidth, screenHeight, chosenCarWidth);

    // empezamos en el carril central
    laneIndex.value = chosenLanes ~/ 2;
  }

  // Helpers para tamaños del auto
  double get carWidth => sizeConfig.carWidth;
  double get carHeight => sizeConfig.carHeight;

  // Cálculo de la posición horizontal del auto
  double carLeft(double totalWidth) {
    final laneW = laneWidth.value;
    return horizontalPadding + laneW * laneIndex.value + (laneW - carWidth) / 2;
  }

  /// Rectángulo del coche en coordenadas de la pista, usado para colisiones.
  Rect get carRect {
    // Escalamos el rectángulo de colisión para que sea más "justo"
    const hitboxScale = 0.7;
    final hitWidth = carWidth * hitboxScale;
    final hitHeight = carHeight * hitboxScale;

    if (isVertical.value) {
      // En vertical, el coche se dibuja con top = _carY y height = carHeight
      final centerX = carX.value;
      final centerY = carY.value + carHeight / 2;
      return Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: hitWidth,
        height: hitHeight,
      );
    } else {
      // En horizontal, el coche se dibuja centrado en (_carX, _carY)
      final centerX = carX.value;
      final centerY = carY.value;
      return Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: hitWidth,
        height: hitHeight,
      );
    }
  }

  // Movimiento entre carriles
  void moveLeft() {
    if (laneIndex.value > 0) {
      laneIndex.value--;
    }
  }

  void moveRight() {
    if (laneIndex.value < lanesCount.value - 1) {
      laneIndex.value++;
    }
  }

  void generateObstaclesForSize(double width, double height) {
    _playAreaSize = Size(width, height);

    if (obstacles.isNotEmpty) return;

    final lanes = lanesCount.value;
    if (lanes <= 0) return;

    final laneWidthLocal = laneWidth.value;
    final padding = horizontalPadding;
    final carW = carWidth;
    final carH = carHeight;

    for (int lane = 0; lane < lanes; lane++) {
      final laneCenterX = padding + laneWidthLocal * lane + laneWidthLocal / 2;

      // 1) Obstáculo sólido (2:1) aparece desde arriba, ajustado al ancho del carril
      final obstacleW =
          laneWidthLocal * 0.9; // un poco más angosto que el carril
      final obstacleH = obstacleW / 2; // relación ~2:1

      obstacles.add(
        ObstacleInstance(
          type: ObstacleType.obstacle2x1,
          x: laneCenterX - obstacleW / 2,
          y: -height * (0.2 + _rand.nextDouble() * 0.2), // entra por arriba
          size: Size(obstacleW, obstacleH),
          speed: height * 0.25, // un poco más rápido
        ),
      );

      // 2) Gasolina (1:1) con probabilidad 70%
      if (_rand.nextDouble() < 0.7) {
        obstacles.add(
          ObstacleInstance(
            type: ObstacleType.fuelPickup,
            x: laneCenterX - carW / 2,
            y: height * (0.4 + _rand.nextDouble() * 0.4),
            size: Size(carW, carH),
            speed: height * 0.22,
          ),
        );
      }

      // 3) Llantas (1:0.5) con probabilidad 50%
      if (_rand.nextDouble() < 0.5) {
        obstacles.add(
          ObstacleInstance(
            type: ObstacleType.tyrePickup,
            x: laneCenterX - carW / 2,
            y: height * (0.9 + _rand.nextDouble() * 0.6),
            size: Size(carW, carH * 0.5),
            speed: height * 0.2,
          ),
        );
      }
    }
  }

  /// Actualiza la lógica del juego (movimiento de obstáculos, colisiones, etc.).
  /// [dt] es el delta de tiempo en segundos desde el último frame.
  void updateGame(double dt) {
    final playSize = _playAreaSize;
    if (playSize == null) return;
    if (obstacles.isEmpty) return;

    // Movimiento de obstáculos (sensación de que la pista avanza hacia el jugador)
    for (final o in obstacles) {
      if (isVertical.value) {
        o.y += o.speed * dt;
      } else {
        o.x -= o.speed * dt;
      }
    }

    // Consumo de gasolina constante
    fuel.value = max(fuel.value - 3 * dt, 0);

    // Colisiones con el coche
    final carR = carRect;
    for (final o in obstacles) {
      if (o.consumed) continue;
      if (o.rect.overlaps(carR)) {
        _handleCollision(o);
      }
    }

    // Eliminamos obstáculos fuera de pantalla o ya consumidos
    obstacles.removeWhere((o) {
      if (o.consumed) return true;
      if (isVertical.value) {
        return o.y > playSize.height + 50;
      } else {
        return o.x < -50;
      }
    });

    // Si ya no hay obstáculos, generamos una nueva "oleada"
    if (obstacles.isEmpty) {
      generateObstaclesForSize(playSize.width, playSize.height);
    }
  }

  void _handleCollision(ObstacleInstance o) {
    switch (o.type) {
      case ObstacleType.obstacle2x1:
      case ObstacleType.obstacle1x1:
        tyres.value = max(tyres.value - 1, 0);
        fuel.value = max(fuel.value - 15, 0);
        break;
      case ObstacleType.fuelPickup:
      case ObstacleType.recarga1x1:
      case ObstacleType.recarga1x05:
        fuel.value = min(fuel.value + 25, 100);
        score.value += 5;
        break;
      case ObstacleType.tyrePickup:
        tyres.value = min(tyres.value + 1, 4);
        score.value += 10;
        break;
    }
    o.consumed = true;
  }
}
