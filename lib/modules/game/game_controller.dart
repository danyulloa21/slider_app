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

  /// Indica si el jugador ya perdió (por ejemplo, sin combustible)
  final isGameOver = false.obs;

  @override
  void onInit() {
    super.onInit();
    _readArguments();
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
    // Guardamos el área de juego para usarla en el loop
    _playAreaSize = Size(width, height);

    // Solo generamos una nueva "oleada" si ya no hay obstáculos activos
    if (obstacles.isNotEmpty) return;

    final lanes = lanesCount.value;
    if (lanes <= 0) return;

    final laneWidthLocal = laneWidth.value;
    final padding = horizontalPadding;

    // Cantidad base de obstáculos por oleada (escala con número de carriles)
    final int baseCount = max(3, lanes * 2);

    // Posibles tipos de obstáculos / pickups
    final types = <ObstacleType>[
      ObstacleType.obstacle2x1,
      ObstacleType.obstacle1x1,
      ObstacleType.fuelPickup,
      ObstacleType.recarga1x1,
      ObstacleType.recarga1x05,
      ObstacleType.tyrePickup,
    ];

    for (int i = 0; i < baseCount; i++) {
      // Elegimos carril aleatorio
      final lane = _rand.nextInt(lanes);
      final laneCenterX = padding + laneWidthLocal * lane + laneWidthLocal / 2;

      // Elegimos tipo aleatorio (con todos mezclados)
      final type = types[_rand.nextInt(types.length)];

      // Definimos tamaño según tipo, respetando proporciones del enunciado
      double w;
      double h;
      double speedFactor;

      switch (type) {
        case ObstacleType.obstacle2x1:
          // Obstáculo 2:1 ajustado al carril
          w = laneWidthLocal * 0.9;
          h = w / 2;
          speedFactor = 0.26;
          break;
        case ObstacleType.obstacle1x1:
          // Obstáculo cuadrado dentro del carril
          w = laneWidthLocal * 0.7;
          h = w;
          speedFactor = 0.24;
          break;
        case ObstacleType.fuelPickup:
        case ObstacleType.recarga1x1:
          // Pickup cuadrado más pequeño
          w = laneWidthLocal * 0.5;
          h = w;
          speedFactor = 0.22;
          break;
        case ObstacleType.recarga1x05:
        case ObstacleType.tyrePickup:
          // 1:0.5
          w = laneWidthLocal * 0.5;
          h = w * 0.5;
          speedFactor = 0.2;
          break;
      }

      // Distribuimos Y en "bandas" para que no se apilen todos juntos
      final band = _rand.nextDouble();
      double y;
      if (band < 0.33) {
        // Aparece por arriba de la pantalla (entra hacia el jugador)
        y = -height * (0.3 + _rand.nextDouble() * 0.7);
      } else if (band < 0.66) {
        // Cerca del área central
        y = height * (0.1 + _rand.nextDouble() * 0.8);
      } else {
        // Más alejado hacia abajo (para sensación de profundidad / avance)
        y = height * (1.0 + _rand.nextDouble() * 0.8);
      }

      obstacles.add(
        ObstacleInstance(
          type: type,
          x: laneCenterX - w / 2,
          y: y,
          size: Size(w, h),
          speed: height * speedFactor,
        ),
      );
    }
  }

  /// Actualiza la lógica del juego (movimiento de obstáculos, colisiones, etc.).
  /// [dt] es el delta de tiempo en segundos desde el último frame.
  void updateGame(double dt) {
    // Si el juego ya terminó, no seguimos actualizando nada
    if (isGameOver.value) return;

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

    // Si se quedó sin combustible, marcamos fin de juego y detenemos la lógica
    if (fuel.value <= 0) {
      isGameOver.value = true;
      return;
    }

    // Colisiones con el coche
    final carR = carRect;
    for (final o in obstacles) {
      if (o.consumed) continue;
      if (o.rect.overlaps(carR)) {
        _handleCollision(o);
      }
    }

    // Si después de una colisión también nos quedamos sin combustible,
    // volvemos a marcar game over
    if (fuel.value <= 0) {
      isGameOver.value = true;
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
