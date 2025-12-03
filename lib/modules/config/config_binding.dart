import 'package:get/get.dart';
import 'config_controller.dart';

class ConfigBinding extends Bindings {
  @override
  void dependencies() {
    // Inyecta el ConfigController cuando entres a la ruta /config
    Get.put<ConfigController>(ConfigController());
  }
}
