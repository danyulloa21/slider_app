import 'package:get/get.dart';
import '../game/game_controller.dart'; // Asegúrate que esta ruta sea correcta: lib/modules/game/game_controller.dart

class GasStationBinding extends Bindings {
  @override
  void dependencies() {
    // Solo buscamos el GameController que ya está activo
    Get.lazyPut(() => Get.find<GameController>()); 
  }
}