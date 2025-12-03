import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slider_app/core/widgets/app_layout.dart';

import 'scoreboard_controller.dart';

class ScoreboardView extends GetView<ScoreboardController> {
  const ScoreboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Scoreboard',
      scrollable: false,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return _buildErrorState();
        }

        if (controller.scores.isEmpty) {
          return _buildEmptyState();
        }

        return _buildScoreList();
      }),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.fetchScores,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.leaderboard_outlined, size: 48, color: Colors.white70),
            SizedBox(height: 16),
            Text(
              'Aún no hay puntajes registrados.\n¡Sé el primero en jugar y aparecer aquí!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'Top jugadores',
            style: Theme.of(
              Get.context!,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Los mejores puntajes',
            style: Theme.of(Get.context!).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: controller.scores.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final score = controller.scores[index];
              final isCurrent = controller.isCurrentUser(score);
              final isTopThree = index < 3;

              return _buildScoreTile(
                rank: index + 1,
                name: score.name,
                points: score.points,
                isCurrent: isCurrent,
                isTopThree: isTopThree,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: controller.restartGame, // Llama al método del controlador
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Empezar Partida Nueva',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreTile({
    required int rank,
    required String name,
    required int points,
    required bool isCurrent,
    required bool isTopThree,
  }) {
    Color bgColor = Colors.white.withValues(alpha: 0.04);
    Gradient? gradient;
    Color borderColor = Colors.white.withValues(alpha: 0.08);

    if (isTopThree) {
      switch (rank) {
        case 1:
          gradient = const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          borderColor = Colors.amberAccent;
          break;
        case 2:
          gradient = const LinearGradient(
            colors: [Color(0xFFC0C0C0), Color(0xFF9E9E9E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          borderColor = Colors.grey;
          break;
        case 3:
          gradient = const LinearGradient(
            colors: [Color(0xFFCD7F32), Color(0xFF8D5524)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          borderColor = const Color(0xFFCD7F32);
          break;
      }
    }

    if (isCurrent && !isTopThree) {
      bgColor = const Color(0xFF1E3A8A).withValues(alpha: 0.8);
      borderColor = const Color(0xFF3B82F6);
    }

    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? bgColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.black.withValues(alpha: 0.4),
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isTopThree || isCurrent
                ? FontWeight.bold
                : FontWeight.w500,
          ),
        ),
        subtitle: isCurrent
            ? const Text(
                'Tu puntaje',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              )
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 18, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                '$points',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
