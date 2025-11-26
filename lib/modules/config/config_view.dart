import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/widgets/app_layout.dart';
import 'config_controller.dart';

class ConfigView extends GetView<ConfigController> {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    print('ConfigView build con controller hashCode: ${controller.hashCode}');

    return AppLayout(
      title: 'Configuración del juego',
      showBack: false,
      showDrawer: true,
      scrollable: true,
      body: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NOMBRE DEL JUGADOR
            const Text(
              'Nombre del jugador',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: controller.setUsername,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Escribe tu username',
              ),
            ),

            // AUTOS
            const Text(
              'Selecciona tu auto (2:1)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(
              height: 120,
              child: GetBuilder<ConfigController>(
                id: 'cars', // 👈 el mismo id que usamos en update(['cars'])
                builder: (c) {
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: c.cars.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final car = c.cars[index];
                      final isSelected = c.selectedCar.value?.id == car.id;
                      print('--- car.id: ${car.id}, isSelected: $isSelected');

                      return GestureDetector(
                        onTap: () => c.selectCar(car),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          width: 140,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.green.withOpacity(0.06)
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.green
                                  : Colors.grey.shade400,
                              width: isSelected ? 2.5 : 1.2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: AspectRatio(
                                        aspectRatio:
                                            2 / 1, // relación 2:1 del auto
                                        child: Image.asset(
                                          car.assetPath,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                car.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Relación 2:1',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // ESCENARIOS
            const Text(
              'Selecciona escenario',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: controller.scenarios.map((scenario) {
                final isSelected =
                    controller.selectedScenario.value?.id == scenario.id;
                return ChoiceChip(
                  label: Text(scenario.name),
                  selected: isSelected,
                  onSelected: (_) => controller.selectScenario(scenario),
                );
              }).toList(),
            ),

            // ORIENTACIÓN
            const Text(
              'Orientación de la pista',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ToggleButtons(
              isSelected: [
                controller.isVertical.value, // Vertical
                !controller.isVertical.value, // Horizontal
              ],
              onPressed: (index) {
                if (index == 0) {
                  controller.setOrientation(true); // Vertical
                } else {
                  controller.setOrientation(false); // Horizontal
                }
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('Vertical'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('Horizontal'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // BOTÓN INICIAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.canStartGame
                    ? controller.startGame
                    : null,
                child: const Text('Iniciar juego'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
