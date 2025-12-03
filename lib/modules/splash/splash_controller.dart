import 'package:get/get.dart';
import 'package:slider_app/routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _init();
  }

  Future<void> _init() async {
    // Aquí luego podrías cargar assets, escenarios desde JSON, etc.
    await Future.delayed(const Duration(seconds: 2));
    Get.offAllNamed(AppRoutes.config);
  }
}
