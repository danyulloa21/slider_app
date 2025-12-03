// lib/modules/gas_station/gas_station_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Asegúrate de importar el GameController para acceder al dinero
import '../game/game_controller.dart';
// o algo similar que no está funcionando

class GasStationController extends GetxController {
  // Obtenemos una referencia al GameController permanente
  final GameController _gameController = Get.find<GameController>();

  // Costo de recarga (debe coincidir con el precio usado en la vista)
  final double refillCost = 500.0; // <--- AJUSTA ESTE VALOR

  @override
  void onInit() {
    super.onInit();
    // 🚨 LLAMAMOS A LA FUNCIÓN DE VERIFICACIÓN AQUÍ 🚨
    checkForMandatoryGameOver();
  }

  /// Verifica si el jugador tiene suficiente dinero para la recarga mínima.
  void checkForMandatoryGameOver() {
    // final requiredMoney = _gameController.maxFuel.value * GameController.costPerFuelUnit;
    if (_gameController.money.value < refillCost) {
      // El jugador no puede pagar la recarga forzosa

      // 1. Opcional: Mostrar un mensaje al jugador (usando Get.snackbar o Get.dialog)
      Get.snackbar(
        '¡Sin fondos!',
        'No tienes suficiente dinero para rellenar el tanque. Fin del juego.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _gameController.finishGameAndGoToScoreboard();
    }
  }

  /// Lógica forzada de Game Over (navega al Scoreboard)
}
