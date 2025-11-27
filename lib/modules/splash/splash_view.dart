import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO / CAR ANIMATION
                  AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutBack,
                    child: Image.asset(
                      'assets/cars/orange_car.png', // Ajusta si tu asset está en otra ruta
                      width: 140,
                      height: 140,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // TITLE
                  const Text(
                    'Slider Game',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // SUBTITLE
                  Text(
                    'Cargando experiencia...',
                    style: TextStyle(
                      color: Colors.white.withAlpha((0.7 * 255).toInt()),
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // LOADING INDICATOR
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // BOTTOM DECORATION
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Icon(
                    Icons.sports_motorsports,
                    size: 28,
                    color: Colors.white.withAlpha((0.4 * 255).toInt()),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Powered by Dany Ulloa',
                    style: TextStyle(
                      color: Colors.white.withAlpha((0.4 * 255).toInt()),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
