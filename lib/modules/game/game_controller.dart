import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:slider_app/data/services/storage_service.dart';
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

  //Constantes del juego
  static const double costPerFuelUnit = 0.5;
  static const int costToUpgradeTank = 100;
  static const int costperTyre = 100;
  static const int maxTyres = 5;
  static const double upgradeAmount = 50.0; // velocidad máxima de la pista

  // Config de carriles y vista
  final lanesCount = 3.obs;
  final laneWidth = 0.0.obs;
  final isVertical = true.obs;

  // Estado del jugador
  final laneIndex = 0.obs; // 0..lanesCount-1
  final fuel = 0.0.obs; // Gasolina actual
  final maxFuel = 100.0.obs; // Capacidad de Gasolina máxima
  final tyres = 3.obs; // vidas
  final score = 0.obs;
  final money = 0.obs; // dinero recogido

  /// Posición actual del coche en la pista
  final carX = 0.0.obs;
  final carY = 0.0.obs;

  /// Actualiza la posición del coche (llamado desde la vista)
  void updateCarPosition(double x, double y) {
    carX.value = x;
    carY.value = y;
  }

  // 1. Recargar Combustible
  void refillFuel(double amount) {
    final cost = amount * costPerFuelUnit;

    if (money.value >= cost) {
      // 1. Deducir el dinero
      money.value -= cost.toInt();

      // 2. Añadir el combustible, limitándolo a la capacidad máxima (maxFuel)
      fuel.value = (fuel.value + amount).clamp(0, maxFuel.value);

      // Opcional: Mostrar un mensaje de éxito
      Get.snackbar('Recarga Exitosa', 'Tanque lleno por \$${cost.toInt()}');
    } else {
      // Esto no debería pasar si la vista deshabilita el botón, pero es bueno
      // tener una verificación.
      Get.snackbar(
        'Error',
        'Dinero insuficiente para recargar.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 2. Mejorar Capacidad del Tanque
  void upgradeFuelCapacity() {
    const cost = costToUpgradeTank;

    if (fuel.value < maxFuel.value) {
      Get.snackbar(
        'Gas requerido',
        'Debes recargar el tanque antes de mejorar la capacidad.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
      );
      return;
    }

    if (money.value >= cost) {
      // 1. Deducir el dinero
      money.value -= cost;

      // 2. Aumentar la capacidad máxima
      maxFuel.value += upgradeAmount;

      // Opcional: Mostrar un mensaje de éxito
      Get.snackbar(
        '¡Mejora Comprada!',
        'Tu tanque ahora tiene capacidad para ${maxFuel.value.toInt()} unidades.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        'Dinero insuficiente para la mejora.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // comprar llantas
  void buyTyre() {
    const cost = costperTyre;

    if (fuel.value < maxFuel.value) {
      Get.snackbar(
        'Gas requerido',
        'Debes recargar el tanque antes de mejorar la capacidad.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
      );
      return;
    }

    if (money.value >= cost && tyres.value < maxTyres) {
      // 1. Deducir el dinero
      money.value -= cost;
      // 2. Aumentar las llantas
      tyres.value += 1;

      // Mostrar un mensaje de éxito
      Get.snackbar(
        '¡Nivel de Llantas Mejorado!',
        'Tu multiplicador de score es ahora ${scoreMultiplier.toStringAsFixed(2)}x.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (tyres.value >= maxTyres) {
      Get.snackbar(
        'Llantas al maximo',
        'Ya tienes el maximo nivel de llantas',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        'Dinero insuficiente para la mejora (\$$cost).',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  double get scoreMultiplier {
    // 1 llanta = 1.0x, 2 llantas = 1.25x, ..., 5 llantas = 2.0x
    final int currentTyres = tyres.value.clamp(1, maxTyres);

    // Fórmula: 1.0 + (Nivel - 1) * 0.25
    return 1.0 + (currentTyres - 1) * 0.25;
  }

  // 3. Continuar el Juego
  void continueGame() {
    if (fuel.value > 0) {
      // 1. Desactivar el estado de Game Over
      fuel.value = maxFuel.value; // Recargamos un 20% del tanque
      isGameOver.value = false;
      // Reiniciamos los obstáculos para que no sigan moviéndose detrás de la vista.
      obstacles.clear();
      // 2. Volver a la vista del juego
      // Usamos Get.offNamed() para reemplazar la GasStationView con la GameView
      // y evitar que el usuario presione "Atrás" para volver a la gasolinera.
      Get.offNamed('/game');
    } else {
      // Esto no debería pasar ya que el botón está deshabilitado en la vista
      Get.snackbar(
        'Espera',
        'Debes recargar combustible para continuar.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void resetGame() {
    // Mantiene: money.value, maxFuel.value

    // Reinicia los valores de la partida
    score.value = 0;
    tyres.value = 1; // Llantas o vidas iniciales
    money.value = 0;
    maxFuel.value = 100.0;

    laneIndex.value = lanesCount.value ~/ 2;
    obstacles.clear();
    isGameOver.value = false;

    // El combustible se inicializa al máximo de la capacidad actual
    fuel.value = maxFuel.value;

    _scoreSent = false;
    _playAreaSize = null;
    Get.offAllNamed('/game');
  }

  /// Lista de obstáculos y recogibles (gasolina, llantas) que se dibujan en la pista
  final obstacles = <ObstacleInstance>[].obs;

  final Random _rand = Random();
  Size? _playAreaSize;

  /// Indica si el jugador ya perdió (por ejemplo, sin combustible)
  final isGameOver = false.obs;

  /// Servicio para guardar el puntaje en Supabase
  final SupabaseService _supabaseService = SupabaseService();

  /// Bandera para no enviar el score múltiples veces al terminar la partida
  bool _scoreSent = false;

  @override
  void onInit() {
    super.onInit();
    final ok = _readArguments();
    if (ok) {
      _configureLayout();
      _startNewGameSession();
    }
  }

  void _startNewGameSession() {
    // 1. Establecer los valores base de una partida nueva
    maxFuel.value = 100.0; // Siempre inicia con la capacidad base
    money.value = 0; // Siempre inicia con 0 dinero

    // 2. Llama a la lógica de reinicio (si existe)
    // Si no tienes un `resetGame` usa esta lógica directamente aquí.
    fuel.value = maxFuel.value;
    score.value = 0;
    tyres.value = 1;
    // ... otros reinicios si los tienes
  }

  bool _readArguments() {
    final args = Get.arguments as Map<String, dynamic>?;

    // Si no hay argumentos o vienen vacíos, no permitimos iniciar el juego
    if (args == null || args.isEmpty) {
      _handleMissingConfig();
      return false;
    }

    final name = (args['username'] as String?)?.trim();
    final selectedCar = args['car'] as CarModel?;
    final selectedScenario = args['scenario'] as ScenarioModel?;
    final vertical = args['isVertical'] as bool? ?? true;

    // Validamos que vengan los datos mínimos para poder jugar
    if (name == null ||
        name.isEmpty ||
        selectedCar == null ||
        selectedScenario == null) {
      _handleMissingConfig();
      return false;
    }

    username = name;
    car = selectedCar;
    scenario = selectedScenario;
    isVertical.value =
        vertical; // 👈 crea un RxBool isVertical en este controller

    return true;
  }

  void _handleMissingConfig() {
    // Mostramos un mensaje y redirigimos a la pantalla de configuración.
    // Usamos addPostFrameCallback para asegurarnos de que el árbol esté montado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Evitamos apilar múltiples snackbars si ya hay una abierta
      if (Get.isSnackbarOpen == true) return;

      Get.snackbar(
        'Configuración requerida',
        'Configura tu nombre, carro y escenario antes de jugar.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );

      // Regresamos a la pantalla de configuración si es posible
      if (Get.currentRoute != '/config') {
        Get.offAllNamed('/config');
      } else if (Navigator.canPop(Get.context!)) {
        Get.back();
      }
    });
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

      // Distribuimos SPAWN en "bandas" para que no se apilen todos juntos
      final band = _rand.nextDouble();
      double spawnPoint;
      if (band < 0.33) {
        // Aparece por arriba de la pantalla (entra hacia el jugador)
        spawnPoint =
            -(isVertical.value ? height : width) *
            (0.3 + _rand.nextDouble() * 0.7);
      } else if (band < 0.66) {
        // Cerca del área central
        spawnPoint =
            (isVertical.value ? height : width) *
            (0.1 + _rand.nextDouble() * 0.8);
      } else {
        // Más alejado hacia abajo (para sensación de profundidad / avance)
        spawnPoint =
            (isVertical.value ? height : width) *
            (1.0 + _rand.nextDouble() * 0.8);
      }

      double initialX, initialY;

      if (isVertical.value) {
        initialX = laneCenterX - w / 2;
        initialY = spawnPoint;
      } else {
        initialX = spawnPoint;
        initialY = laneCenterX - h / 2;
      }

      obstacles.add(
        ObstacleInstance(
          type: type,
          x: initialX,
          y: initialY,
          size: Size(w, h),
          speed: height * speedFactor,
        ),
      );
    }
  }

  /// Actualiza la lógica del juego (movimiento de obstáculos, colisiones, etc.).
  /// [dt] es el delta de tiempo en segundos desde el último frame.
  void updateGame(double dt) {
    const double scoreSpeed = 50.0;

    // Si el juego ya terminó, no seguimos actualizando nada
    if (isGameOver.value) return;
    fuel.value = max(0, fuel.value - dt * 3); // Consumo pasivo de gasolina

    if (fuel.value <= 0) {
      isGameOver.value = true;
      Get.offNamed('/gas_station');
      return;
    }
    final double scoreIncrease = scoreSpeed * dt * scoreMultiplier;
    score.value += scoreIncrease.toInt();
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

    // Colisiones con el coche
    final carR = carRect;
    for (final o in obstacles) {
      if (o.consumed) continue;
      if (o.rect.overlaps(carR)) {
        _handleCollision(o);
        if (isGameOver.value) return; // salimos si ya terminó el juego
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

  Future<void> _onGameOverIfNeeded() async {
    if (_scoreSent) return;
    _scoreSent = true;

    // Si por alguna razón no hay username o el score es 0, no mandamos nada
    if (username.isEmpty || score.value <= 0) {
      return;
    }

    try {
      await _supabaseService.checkAndUpsertPlayer(
        playerName: username,
        score: score.value,
      );
    } catch (e) {
      debugPrint('❌ Error al guardar score en Supabase: $e');
    }
  }

  void finishGameAndGoToScoreboard() {
    isGameOver.value = true; // Asegurarse de que el juego se detenga
    _onGameOverIfNeeded(); // Guardar el score
    Get.offAllNamed('/scoreboard'); // Navegar a la pantalla de resultados
  }

  void _handleCollision(ObstacleInstance o) {
    switch (o.type) {
      case ObstacleType.obstacle2x1:
      case ObstacleType.obstacle1x1:
        // ❌ COLISIÓN CON OBSTÁCULO MALO (GAME OVER INMEDIATO)
        // Forzamos el Game Over
        if (isGameOver.value) return;
        isGameOver.value = true;
        // Llamamos a la lógica final (guardar score, mostrar pantalla de derrota)
        _onGameOverIfNeeded();
        Get.snackbar(
          '¡ACCIDENTE!',
          'Has colisionado. El juego comenzará de nuevo.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        Get.offAllNamed('/scoreboard');
        resetGame();
        break;

      case ObstacleType.fuelPickup:
      case ObstacleType.recarga1x1:
      case ObstacleType.recarga1x05:
      case ObstacleType.tyrePickup:
        money.value += 10;
        break;
    }
    o.consumed = true;
  }
}
