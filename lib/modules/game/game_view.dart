import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/widgets/app_layout.dart';
import '../../data/models/obstacle_model.dart';
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

  // Size? _playAreaSize;
  Timer? _gameLoopTimer;

  @override
  void initState() {
    super.initState();
    // Loop simple de ~60 FPS
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      controller.updateGame(16 / 1000);
    });
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    super.dispose();
  }

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

        // Leemos también el estado de game over dentro del mismo Obx
        final isGameOver = controller.isGameOver.value;

        return LayoutBuilder(
  builder: (context, constraints) {
    final totalWidth = constraints.maxWidth;
    final totalHeight = constraints.maxHeight;
    final isVertical = controller.isVertical.value;
    
    // Usar addPostFrameCallback para inicializar después del build
    if (!_carPositionInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initCarPosition(totalWidth, totalHeight, isVertical);
        controller.updateCarPosition(_carX, _carY);
        _carPositionInitialized = true;
      });
    }
    
    // Generar obstáculos después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.generateObstaclesForSize(totalWidth, totalHeight);
    });
    
    return GestureDetector(
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
          // Obstáculos y pickups (gasolina, llantas)
          Positioned.fill(child: _buildObstaclesLayer()),
          // Auto
          _buildCar(isVertical),
          // HUD
          Positioned(top: 0, left: 0, right: 0, child: _buildHud()),
          // Overlay de Game Over cuando no hay combustible
          if (isGameOver)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: const Center(
                  child: Text(
                    '¡Sin combustible! Redirigiendo a la gasolinera...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
    // Si el juego ya terminó, no permitimos mover el coche
    if (controller.isGameOver.value) return;

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
      controller.updateCarPosition(_carX, _carY);
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

  Widget _buildObstaclesLayer() {
    return Obx(
      () => Stack(
        children: controller.obstacles.map((o) {
          Color baseColor;
          IconData? icon;

          switch (o.type) {
            case ObstacleType.obstacle2x1:
            case ObstacleType.obstacle1x1:
              baseColor = Colors.brown.shade700;
              icon = Icons.warning_rounded;
              break;
            case ObstacleType.fuelPickup:
            case ObstacleType.recarga1x1:
            case ObstacleType.recarga1x05:
              baseColor = const Color.fromRGBO(23, 175, 61, 1);
              icon = Icons.money;
              break;
            case ObstacleType.tyrePickup:
              baseColor = const Color.fromRGBO(23, 175, 61, 1);
              icon = Icons.money; // representa cambio de llantas
              break;
          }

          return Positioned(
            left: o.x,
            top: o.y,
            width: o.width,
            height: o.height,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    baseColor.withValues(alpha: 0.9),
                    baseColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.6),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: (o.height * 0.45).clamp(10.0, 20.0),
                ),
              ),
            ),
          );
        }).toList(),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.55,
        ), // Usé .withOpacity en lugar de .withValues(alpha: 0.55) para evitar errores si no es una función propia de tu AppLayout
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: jugador y orientación / escenario
          Row(
            children: [
              Expanded(
                child: Text(
                  controller.username.isNotEmpty
                      ? 'Jugador: ${controller.username}'
                      : 'Jugador invitado',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.terrain, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    controller.scenario?.name.toUpperCase() ?? 'SIN ESCENARIO',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Barra de combustible
          Row(
            children: [
              const Icon(
                Icons.local_gas_station,
                color: Colors.orangeAccent,
                size: 18,
              ),
              const SizedBox(width: 6),
              const Text(
                'Combustible',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() {
                  // **¡IMPORTANTE!** Ahora usamos maxFuel.value en lugar de 100
                  final fuelPercent =
                      controller.fuel.value.clamp(0, controller.maxFuel.value) /
                      controller.maxFuel.value;
                  Color barColor;
                  if (fuelPercent > 0.6) {
                    barColor = Colors.greenAccent;
                  } else if (fuelPercent > 0.3) {
                    barColor = Colors.yellowAccent;
                  } else {
                    barColor = Colors.redAccent;
                  }

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: fuelPercent,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),
              Obx(
                () => Text(
                  // Mostramos el valor actual y el máximo
                  '${controller.fuel.value.toInt()}/${controller.maxFuel.value.toInt()}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Fila inferior: llantas, puntaje y DINERO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Llantas (Tyres)
              Row(
                children: [
                  const Icon(
                    Icons.circle,
                    color: Colors.lightBlueAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Llantas',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(width: 6),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '${controller.tyres.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Puntaje (Score/Distancia)
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  const Text(
                    'Puntaje',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(width: 6),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.amber, Colors.deepOrangeAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${controller.score.value}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ¡NUEVA! Dinero (Money)
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.greenAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Dinero',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(width: 6),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${controller.money.value}', // Usamos la nueva variable 'money'
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
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
      ..color = Colors.white.withValues(alpha: 0.5)
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
