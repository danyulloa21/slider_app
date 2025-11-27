import 'package:get/get.dart';

import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import '../modules/config/config_binding.dart';
import '../modules/config/config_view.dart';
import '../modules/game/game_binding.dart';
import '../modules/game/game_view.dart';
// scoreboard después

part 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.config,
      page: () => const ConfigView(),
      binding: ConfigBinding(),
    ),
    GetPage(
      name: AppRoutes.game,
      page: () => const GameView(),
      binding: GameBinding(),
      transition: Transition.noTransition,
    ),
    // scoreboard luego
  ];
}
