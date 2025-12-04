import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../game/game_controller.dart'; // Asegúrate que esta ruta sea correcta: lib/modules/game/game_controller.dart

class GasStationView extends GetView<GameController> {
  const GasStationView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Instancia el controlador (ya lo hace GetView, pero es útil para claridad)
    final GameController controller = Get.find<GameController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('⛽️ Gasolinera (Pit Stop)'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Evita que aparezca el botón de "atrás"
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Resumen de Recursos ---
            _buildResourceSummary(controller),
            const SizedBox(height: 20),

            // --- 1. Sección de Combustible (Refill) ---
            _buildFuelRefillCard(controller),
            const SizedBox(height: 20),

            // --- 2. Sección de Upgrade de Tanque ---
            _buildTankUpgradeCard(controller),
            const SizedBox(height: 20),

            // --- 3. Sección de Mejora de Llantas (Multiplicador) ---
            _buildTyresUpgradeCard(controller),
            const SizedBox(height: 30),
          ],
        ),
      ),
      // --- Botón de Continuar ---
      // --- Botones de Continuar y Salir ---
bottomNavigationBar: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Obx(
    () => Row(
      children: [
        // Botón de Salir
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Get.defaultDialog(
                title: 'Salir del juego',
                middleText: '¿Estás seguro que quieres salir?',
                textConfirm: 'Sí',
                textCancel: 'No',
                onConfirm: () {
                  Get.back(); // Cierra el diálogo
                  controller.finishGameAndGoToScoreboard(); // Sale del juego
                },
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'SALIR',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12), // Espacio entre botones
        // Botón de Continuar
        Expanded(
          child: ElevatedButton(
            onPressed: (controller.fuel.value > 0)
                ? controller.continueGame
                : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Colors.green,
            ),
            child: const Text(
              'CONTINUAR',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  ),
),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildResourceSummary(GameController controller) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '💰 Tus Recursos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Obx(() => _buildResourceRow(
                  icon: Icons.monetization_on,
                  label: 'Dinero:',
                  value: '\$${controller.money.value}',
                  color: Colors.green,
                )),
            Obx(() => _buildResourceRow(
                  icon: Icons.local_gas_station,
                  label: 'Capacidad de Tanque:',
                  value: '${controller.maxFuel.value.toInt()}',
                  color: Colors.red,
                )),
            Obx(() => _buildResourceRow(
                  icon: Icons.tire_repair,
                  label: 'Nivel de Llantas:',
                  value:
                      '${controller.tyres.value} (Multiplicador: ${controller.scoreMultiplier.toStringAsFixed(2)}x)',
                  color: Colors.blue,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildFuelRefillCard(GameController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⛽️ Recargar Combustible',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Obx(
              () => Text(
                'Combustible actual: ${controller.fuel.value.toInt()} / ${controller.maxFuel.value.toInt()}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => ElevatedButton.icon(
                onPressed: controller.fuel.value < controller.maxFuel.value
                    ? () {
                        // Recargamos la diferencia total hasta el máximo
                        final amountToRefill = controller.maxFuel.value - controller.fuel.value;
                        controller.refillFuel(amountToRefill); 
                      }
                    : null,
                icon: const Icon(Icons.add),
                label: Text(
                  'Recargar Tanque Completo (\$${(controller.maxFuel.value * GameController.costPerFuelUnit).toStringAsFixed(0)})',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTankUpgradeCard(GameController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🚀 Mejorar Tanque de Gasolina',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Obx(
              () => Text(
                'Próxima Capacidad: ${(controller.maxFuel.value + GameController.upgradeAmount).toInt()}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Text(
              'Costo: \$${GameController.costToUpgradeTank}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Obx(
              () => ElevatedButton.icon(
                onPressed: controller.money.value >= GameController.costToUpgradeTank
                    ? controller.upgradeFuelCapacity
                    : null,
                icon: const Icon(Icons.upgrade),
                label: const Text('Mejorar Capacidad'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTyresUpgradeCard(GameController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏎️ Mejorar Nivel de Llantas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Obx(() {
              // Comprueba si ya estás en el nivel máximo
              if (controller.tyres.value >= GameController.maxTyres) {
                return const Text(
                  '¡Nivel Máximo Alcanzado!',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                );
              }

              // Muestra el próximo nivel y multiplicador
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Próximo Nivel: ${controller.tyres.value + 1}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Multiplicador Próximo: ${(controller.scoreMultiplier + 0.25).toStringAsFixed(2)}x',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Costo: \$${GameController.costperTyre}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: controller.tyres.value < GameController.maxTyres &&
                            controller.money.value >= GameController.costperTyre
                        ? controller.buyTyre
                        : null,
                    icon: const Icon(Icons.speed),
                    label: const Text('Mejorar Multiplicador de Score'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}