import 'package:get/get.dart';
import 'package:slider_app/data/models/scoreboard_model.dart';

import '../../data/services/storage_service.dart';

/// Controlador del scoreboard.
/// Se encarga de consultar los mejores puntajes desde Supabase
/// y exponerlos de forma reactiva a la vista.
class ScoreboardController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();

  /// Lista de puntajes ordenados (mayor a menor).
  final RxList<PlayerScore> scores = <PlayerScore>[].obs;

  /// Indicador de carga.
  final RxBool isLoading = false.obs;

  /// Mensaje de error (si algo falla al cargar).
  final RxString errorMessage = ''.obs;

  /// Nombre del jugador actual (opcional), para resaltarlo en la vista.
  String? currentUsername;

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    fetchScores();
  }

  /// Lee argumentos que lleguen a la ruta del scoreboard (por ejemplo, username).
  void _readArguments() {
    final args = Get.arguments;

    if (args is Map && args['username'] is String) {
      final name = (args['username'] as String).trim();
      if (name.isNotEmpty) {
        currentUsername = name;
      }
    }
  }

  /// Obtiene los mejores puntajes desde la tabla 'players' en Supabase.
  ///
  /// Trae los top 20 ordenados de mayor a menor.
  Future<void> fetchScores() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _supabaseService.client
          .from('players')
          .select('player_name, points')
          .order('points', ascending: false)
          .limit(20);

      final List<PlayerScore> list = [];

      for (final row in response as List) {
        final rawName = row['player_name'];
        final rawPoints = row['points'];

        final name = (rawName ?? '').toString().trim();
        if (name.isEmpty) continue;

        int points;
        if (rawPoints is int) {
          points = rawPoints;
        } else {
          points = int.tryParse(rawPoints.toString()) ?? 0;
        }

        list.add(PlayerScore(name: name, points: points));
      }

      scores.assignAll(list);
    } catch (e) {
      // Guardamos un mensaje amigable; la vista puede mostrarlo.
      errorMessage.value =
          'No se pudieron cargar los puntajes. Intenta más tarde.';
      // Si quisieras, podrías agregar aquí un log adicional usando SupabaseService,
      // pero para consultas de lectura normalmente basta con manejar el error localmente.
    } finally {
      isLoading.value = false;
    }
  }

  /// Indica si el registro pertenece al jugador actual (para resaltarlo en la UI).
  bool isCurrentUser(PlayerScore score) {
    if (currentUsername == null) return false;
    return score.name == currentUsername;
  }

  void restartGame() {
    Get.offAllNamed('/config');
  }
}
