import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/widgets/app_layout.dart';
import 'game_controller.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  final GameController controller = Get.find<GameController>();

  double _carX = 0;
  double _carY = 0;
  bool _carPositionInitialized = false;

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Juego',
      showBack: true,
      showDrawer: false,
      scrollable: false,
      body: Obx(() {
        // Esperamos a que se calcule el ancho de carril
        if (controller.laneWidth.value == 0) {
          return const Center(child: CircularProgressIndicator());
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final totalHeight = constraints.maxHeight;
            final isVertical = controller.isVertical.value;

            if (!_carPositionInitialized) {
              _initCarPosition(totalWidth, totalHeight, isVertical);
            }

            return GestureDetector(
              // Arrastre libre: horizontal en modo vertical, vertical en modo horizontal
              onPanUpdate: (details) =>
                  _handleDrag(details, totalWidth, totalHeight, isVertical),
              child: Stack(
                children: [
                  // Fondo del escenario
                  Positioned.fill(child: _buildBackground()),

                  // Carriles
                  Positioned.fill(
                    child: _buildLanes(totalWidth, totalHeight, isVertical),
                  ),

                  // TODO: aquí luego se pueden dibujar obstáculos / pickups
                  // ..._buildObstaclesLayer(),

                  // Auto
                  _buildCar(isVertical),

                  // HUD
                  Positioned(top: 0, left: 0, right: 0, child: _buildHud()),

                  // Controles de movimiento (opcional, además del drag)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: _buildControls(isVertical),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _initCarPosition(
    double totalWidth,
    double totalHeight,
    bool isVertical,
  ) {
    if (isVertical) {
      // Centrado horizontal, pegado a la parte baja
      _carX = totalWidth / 2;
      _carY = totalHeight - controller.carHeight - 32;
    } else {
      // A la izquierda, centrado verticalmente
      _carX = 32 + controller.carWidth / 2;
      _carY = totalHeight / 2;
    }
    _carPositionInitialized = true;
  }

  void _handleDrag(
    DragUpdateDetails details,
    double totalWidth,
    double totalHeight,
    bool isVertical,
  ) {
    setState(() {
      if (isVertical) {
        // Mover coche horizontalmente
        _carX += details.delta.dx;
        final halfCarW = controller.carWidth / 2;
        final minX = halfCarW + GameController.horizontalPadding;
        final maxX = totalWidth - halfCarW - GameController.horizontalPadding;
        _carX = _carX.clamp(minX, maxX);
      } else {
        // Mover coche verticalmente
        _carY += details.delta.dy;
        final halfCarH = controller.carHeight / 2;
        final minY = halfCarH + GameController.horizontalPadding;
        final maxY = totalHeight - halfCarH - GameController.horizontalPadding;
        _carY = _carY.clamp(minY, maxY);
      }
    });
  }

  Widget _buildBackground() {
    final scenarioId = controller.scenario?.id;

    switch (scenarioId) {
      case 'desierto':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFEEC373), // arena clara
                Color(0xFFE1A95F), // arena más oscura
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        );

      case 'nieve':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Color(0xFFD0E8FF), // azul muy claro
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        );

      case 'playa':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF87CEEB), // cielo
                Color(0xFFFFF5BA), // arena
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        );

      case 'ciudad':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey, Colors.black87],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        );

      case 'espacio':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Color(0xFF0A0A3B), // azul oscuro
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        );

      default:
        // Si por alguna razón no hay escenario, fondo neutro
        return Container(color: Colors.black87);
    }
  }

  Widget _buildLanes(double width, double height, bool isVertical) {
    final lanes = controller.lanesCount.value;
    final laneW = controller.laneWidth.value;
    final padding = GameController.horizontalPadding;

    return CustomPaint(
      size: Size(width, height),
      painter: _LanePainter(
        lanesCount: lanes,
        laneWidth: laneW,
        horizontalPadding: padding,
        isVertical: isVertical,
      ),
    );
  }

  Widget _buildCar(bool isVertical) {
    final carPath = controller.car?.assetPath ?? 'assets/cars/orange_car.png';

    if (isVertical) {
      // Posicionamiento basado en _carX / _carY
      return Positioned(
        left: _carX - controller.carWidth / 2,
        top: _carY,
        width: controller.carWidth,
        height: controller.carHeight,
        child: Image.asset(carPath, fit: BoxFit.contain),
      );
    } else {
      final carWidth = controller.carWidth;
      final carHeight = controller.carHeight;

      return Positioned(
        left: _carX - carWidth / 2,
        top: _carY - carHeight / 2,
        width: carWidth,
        height: carHeight,
        child: Transform.rotate(
          angle: 1.5708, // 90 grados en radianes
          child: Image.asset(carPath, fit: BoxFit.contain),
        ),
      );
    }
  }

  Widget _buildHud() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Jugador: ${controller.username}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_gas_station,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 4),
              Obx(
                () => Text(
                  '${controller.fuel.value.toInt()}%',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.circle, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Obx(
                () => Text(
                  '${controller.tyres.value}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Obx(
                () => Text(
                  '${controller.score.value}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls(bool isVertical) {
    // Controles secundarios, además del arrastre
    if (isVertical) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _carX -= controller.laneWidth.value / 2;
              });
            },
            icon: const Icon(Icons.arrow_left),
            label: const Text('Izquierda'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _carX += controller.laneWidth.value / 2;
              });
            },
            icon: const Icon(Icons.arrow_right),
            label: const Text('Derecha'),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _carY -= controller.carHeight;
              });
            },
            icon: const Icon(Icons.arrow_upward),
            label: const Text('Arriba'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _carY += controller.carHeight;
              });
            },
            icon: const Icon(Icons.arrow_downward),
            label: const Text('Abajo'),
          ),
        ],
      );
    }
  }
}

/// Painter simple para dibujar carriles
class _LanePainter extends CustomPainter {
  final int lanesCount;
  final double laneWidth;
  final double horizontalPadding;
  final bool isVertical;

  _LanePainter({
    required this.lanesCount,
    required this.laneWidth,
    required this.horizontalPadding,
    required this.isVertical,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (isVertical) {
      // carriles verticales
      final startX = horizontalPadding;
      for (int i = 0; i <= lanesCount; i++) {
        final x = startX + laneWidth * i;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    } else {
      // carriles horizontales
      final startY = horizontalPadding;
      for (int i = 0; i <= lanesCount; i++) {
        final y = startY + laneWidth * i;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LanePainter oldDelegate) {
    return oldDelegate.lanesCount != lanesCount ||
        oldDelegate.laneWidth != laneWidth ||
        oldDelegate.horizontalPadding != horizontalPadding ||
        oldDelegate.isVertical != isVertical;
  }
}
