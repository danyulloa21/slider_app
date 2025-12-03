import 'package:get/get.dart';
import 'package:slider_app/modules/scoreboard/scoreboard_binding.dart';
import 'package:slider_app/modules/scoreboard/scoreboard_view.dart';
import '../modules/gas_station/gas_station_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import '../modules/config/config_binding.dart';
import '../modules/config/config_view.dart';
import '../modules/game/game_binding.dart';
import '../modules/game/game_view.dart';
import '../modules/gas_station/gas_station_binding.dart';
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
    GetPage(
      name: AppRoutes.scoreboard,
      page: () => const ScoreboardView(),
      binding: ScoreboardBinding(),
    ),
    GetPage(
      name: AppRoutes.gasStation, 
      page: () => const GasStationView(), 
      binding: GasStationBinding(),
    ),
    GetPage(
      name: '/config', 
      page: () => const ConfigView(), 
      binding: ConfigBinding(),
    ),
    GetPage(
      name: '/scoreboard',
      page: () => const ScoreboardView(), 
      binding: ScoreboardBinding(),
    ),
  ];
}
