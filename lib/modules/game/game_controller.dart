import 'package:get/get.dart';
import 'package:slider_app/data/models/obstacle_model.dart';
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

  // Obstáculos / pickups
  final obstacles = <ObstacleInstance>[].obs;

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

  // TODO: aquí luego agregas lógica de:
  // - spawn de obstáculos
  // - movimiento
  // - colisiones
  // - consumo de gasolina
}
