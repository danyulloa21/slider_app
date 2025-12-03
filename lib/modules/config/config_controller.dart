import 'package:get/get.dart';
import 'package:slider_app/routes/app_pages.dart';

import '../../data/models/car_model.dart';
import '../../data/models/scenario_model.dart';

class ConfigController extends GetxController {
  final username = ''.obs;
  final cars = <CarModel>[].obs;
  final scenarios = <ScenarioModel>[].obs;

  final selectedCar = Rxn<CarModel>();
  final selectedScenario = Rx<ScenarioModel?>(null);

  /// true = pista vertical, false = pista horizontal
  final isVertical = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    cars.assignAll([
      const CarModel(
        id: 'orange',
        name: 'Auto Naranja',
        assetPath: 'assets/cars/orange_car.png',
      ),
      const CarModel(
        id: 'red',
        name: 'Auto Rojo',
        assetPath: 'assets/cars/red_car.png',
      ),
      const CarModel(
        id: 'yellow',
        name: 'Auto Amarillo',
        assetPath: 'assets/cars/yellow_car.png',
      ),
    ]);

    scenarios.assignAll([
      const ScenarioModel(id: 'desierto', name: 'Desierto'),
      const ScenarioModel(id: 'nieve', name: 'Nieve'),
      const ScenarioModel(id: 'playa', name: 'Playa'),
      const ScenarioModel(id: 'ciudad', name: 'Ciudad'),
      const ScenarioModel(id: 'espacio', name: 'Espacio'),
    ]);
  }

  void setUsername(String value) {
    username.value = value.trim();
  }

  void selectCar(CarModel car) {
    selectedCar.value = car;
    // Forzamos rebuild de la sección de autos
    update(['cars']);
  }

  void selectScenario(ScenarioModel scenario) {
    selectedScenario.value = scenario;
  }

  void setOrientation(bool vertical) {
    isVertical.value = vertical;
  }

  bool get canStartGame =>
      username.value.isNotEmpty &&
      selectedCar.value != null &&
      selectedScenario.value != null;

  void startGame() {
    if (!canStartGame) return;

    Get.toNamed(
      AppRoutes.game,
      arguments: {
        'username': username.value,
        'car': selectedCar.value,
        'scenario': selectedScenario.value,
        'isVertical': isVertical.value,
      },
    );
  }
}
