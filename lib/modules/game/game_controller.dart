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

  /// Lista de obstáculos y recogibles (gasolina, llantas) que se dibujan en la pista
  final obstacles = <ObstacleInstance>[].obs;

  final Random _rand = Random();

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
    if (obstacles.isNotEmpty) return;

    final lanes = lanesCount.value;
    if (lanes <= 0) return;

    final laneWidthLocal = laneWidth.value;
    final padding = horizontalPadding;
    final carW = carWidth;
    final carH = carHeight;

    for (int lane = 0; lane < lanes; lane++) {
      final laneCenterX = padding + laneWidthLocal * lane + laneWidthLocal / 2;

      // Obstáculo sólido (2:1) en la parte media
      obstacles.add(
        ObstacleInstance(
          type: ObstacleType.obstacle2x1,
          x: laneCenterX - (2 * carW) / 2,
          y: height * (0.25 + _rand.nextDouble() * 0.15),
          size: Size(2 * carW, carH),
          speed: height * 0.15,
        ),
      );

      // Gasolina (1:1) un poco más adelante
      obstacles.add(
        ObstacleInstance(
          type: ObstacleType.fuelPickup,
          x: laneCenterX - carW / 2,
          y: height * (0.50 + _rand.nextDouble() * 0.15),
          size: Size(carW, carH),
          speed: height * 0.12,
        ),
      );

      // Llantas / pickup pequeño (1:0.5) más cerca del final
      obstacles.add(
        ObstacleInstance(
          type: ObstacleType.tyrePickup,
          x: laneCenterX - carW / 2,
          y: height * (0.75 + _rand.nextDouble() * 0.10),
          size: Size(carW, carH * 0.5),
          speed: height * 0.10,
        ),
      );
    }
  }

  // TODO: aquí luego agregas lógica de:
  // - movimiento
  // - colisiones
  // - consumo de gasolina
}
