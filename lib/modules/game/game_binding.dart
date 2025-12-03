import 'package:get/get.dart';
import 'game_controller.dart';

class GameBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<GameController>(
      GameController(),
      permanent: true,
    ); // Hacemos el GameController permanente
  }
}
