import 'dart:ui';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

/// Servicio centralizado para gestionar todas las interacciones con Supabase.
///
/// Encapsula autenticación, consultas y operaciones CRUD en la tabla 'players'.
class SupabaseService {
  final SupabaseClient _client;

  /// Constructor. Recibe el cliente de Supabase (por defecto usa Supabase.instance.client).
  SupabaseService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Registra errores en la tabla 'error_logs' para diagnóstico en producción.
  ///
  /// Espera que exista una tabla con columnas:
  /// - scope (text)
  /// - message (text)
  /// - user_id (uuid, nullable)
  /// - created_at (timestamptz)
  Future<void> _logError({
    required String scope,
    required String message,
    String? userId,
  }) async {
    try {
      await _client.from('error_logs').insert({
        'scope': scope,
        'message': message,
        'user_id': userId ?? _client.auth.currentUser?.id,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // No hacemos nada aquí para evitar loops de error.
    }
  }

  void _showErrorSnackbar(String title, String message) {
    if (Get.isSnackbarOpen == true) return;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFB00020),
      colorText: const Color(0xFFFFFFFF),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  /// Obtiene el cliente de Supabase (útil si necesitas acceso directo en casos especiales).
  SupabaseClient get client => _client;

  /// Obtiene el usuario actualmente autenticado.
  User? get currentUser => _client.auth.currentUser;

  /// Obtiene la sesión actual.
  Session? get currentSession => _client.auth.currentSession;

  /// Stream que emite cambios en el estado de autenticación.
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  // ============================================================================
  // AUTENTICACIÓN
  // ============================================================================

  /// Inicia sesión con email y contraseña.
  ///
  /// Retorna `true` si la autenticación fue exitosa, `false` en caso contrario.
  Future<bool> signIn({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        await _logError(
          scope: 'signIn',
          message: 'No session returned for email $email',
        );
        _showErrorSnackbar(
          'Error de autenticación',
          'No se pudo iniciar sesión. Intenta nuevamente más tarde.',
        );
        return false;
      } else {
        // Podrías loggear un evento de login exitoso si lo deseas.
        return true;
      }
    } catch (error) {
      await _logError(
        scope: 'signIn',
        message: 'Excepción al hacer signIn: $error',
      );
      _showErrorSnackbar(
        'Error de autenticación',
        'Ocurrió un problema al conectar con el servidor.',
      );
      return false;
    }
  }

  /// Cierra la sesión actual.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      await _logError(
        scope: 'signOut',
        message: 'Error al hacer signOut: $error',
      );
      _showErrorSnackbar(
        'Error al cerrar sesión',
        'No se pudo cerrar la sesión correctamente.',
      );
    }
  }

  // ============================================================================
  // OPERACIONES EN LA TABLA 'players'
  // ============================================================================

  /// Inserta un nuevo jugador en la tabla 'players'.
  ///
  /// Si no hay sesión activa, intenta hacer sign-in primero usando credenciales del .env.
  ///
  /// Parámetros:
  /// - [playerName]: Nombre del jugador.
  /// - [points]: Puntos iniciales del jugador.
  /// - [userId]: ID del usuario propietario (opcional, por defecto usa un ID fijo).
  Future<void> insertPlayer({
    required String playerName,
    required int points,
    String? userId,
  }) async {
    final session = _client.auth.currentSession;
    final user = _client.auth.currentUser;

    if (session == null || user == null) {
      // Intenta autenticarse si no hay sesión usando credenciales del .env
      final email = dotenv.env['AUTH_EMAIL'];
      final password = dotenv.env['AUTH_PASSWORD'];

      if (email != null && password != null) {
        await signIn(email: email, password: password);
      } else {
        await _logError(
          scope: 'insertPlayer',
          message:
              'No se encontraron credenciales en .env para insertar jugador "$playerName".',
        );
        _showErrorSnackbar(
          'Error al guardar puntaje',
          'No se pudo autenticar para guardar tu puntaje.',
        );
        return;
      }
    }

    try {
      final newPlayer = {
        'player_name': playerName,
        'points': points,
        'user_id': userId ?? _client.auth.currentUser?.id,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client
          .from('players')
          .upsert(newPlayer, onConflict: 'player_name');
    } on PostgrestException catch (error) {
      await _logError(
        scope: 'insertPlayer',
        message:
            'PostgrestException al insertar jugador "$playerName": ${error.message}',
        userId: userId ?? _client.auth.currentUser?.id,
      );
      _showErrorSnackbar(
        'Error al guardar puntaje',
        'No se pudo guardar tu puntaje en el servidor.',
      );
    } catch (error) {
      await _logError(
        scope: 'insertPlayer',
        message: 'Error inesperado al insertar jugador "$playerName": $error',
        userId: userId ?? _client.auth.currentUser?.id,
      );
      _showErrorSnackbar(
        'Error al guardar puntaje',
        'Ocurrió un problema inesperado al guardar tu puntaje.',
      );
    }
  }

  /// Actualiza los puntos de un jugador existente en la tabla 'players'.
  ///
  /// Filtra por el nombre del jugador.
  ///
  /// Parámetros:
  /// - [playerName]: Nombre del jugador a actualizar.
  /// - [points]: Nuevos puntos del jugador.
  Future<void> updatePlayer({
    required String playerName,
    required int points,
  }) async {
    try {
      final updatedData = {
        'player_name': playerName,
        'points': points,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client
          .from('players')
          .update(updatedData)
          .eq('player_name', playerName);
    } on PostgrestException catch (error) {
      await _logError(
        scope: 'updatePlayer',
        message:
            'PostgrestException al actualizar jugador "$playerName": ${error.message}',
      );
      _showErrorSnackbar(
        'Error al actualizar puntaje',
        'No se pudo actualizar tu puntaje.',
      );
    } catch (error) {
      await _logError(
        scope: 'updatePlayer',
        message: 'Error inesperado al actualizar jugador "$playerName": $error',
      );
      _showErrorSnackbar(
        'Error al actualizar puntaje',
        'Ocurrió un problema inesperado al actualizar tu puntaje.',
      );
    }
  }

  /// Verifica si un jugador existe. Si existe, lo actualiza; si no, lo inserta (UPSERT).
  ///
  /// Parámetros:
  /// - [playerName]: Nombre del jugador.
  /// - [score]: Puntos a asignar o actualizar.
  Future<void> checkAndUpsertPlayer({
    required String playerName,
    required int score,
  }) async {
    try {
      final response = await _client
          .from('players')
          .select('id, player_name, points')
          .eq('player_name', playerName)
          .limit(1);

      if (response.isNotEmpty) {
        // Jugador existe → UPDATE
        await updatePlayer(playerName: playerName, points: score);
      } else {
        // Jugador NO existe → INSERT
        await insertPlayer(playerName: playerName, points: score);
      }
    } on PostgrestException catch (error) {
      await _logError(
        scope: 'checkAndUpsertPlayer',
        message:
            'PostgrestException al buscar/upsert jugador "$playerName": ${error.message}',
      );
      _showErrorSnackbar(
        'Error al guardar puntaje',
        'No se pudo guardar tu puntaje en el servidor.',
      );
    } catch (error) {
      await _logError(
        scope: 'checkAndUpsertPlayer',
        message:
            'Error inesperado al hacer upsert de jugador "$playerName": $error',
      );
      _showErrorSnackbar(
        'Error al guardar puntaje',
        'Ocurrió un problema inesperado al guardar tu puntaje.',
      );
    }
  }

  /// Recupera los puntos de un jugador desde la tabla 'players'.
  ///
  /// Retorna los puntos si el jugador existe, o `null` si no se encuentra.
  ///
  /// Parámetros:
  /// - [playerName]: Nombre del jugador a buscar.
  Future<int?> retrievePoints({required String playerName}) async {
    try {
      final response = await _client
          .from('players')
          .select('points')
          .eq('player_name', playerName)
          .limit(1);

      if (response.isNotEmpty) {
        final playerData = response.first;
        final points = playerData['points'] as int;
        return points;
      } else {
        return null;
      }
    } catch (error) {
      await _logError(
        scope: 'retrievePoints',
        message: 'Error al recuperar puntos de "$playerName": $error',
      );
      _showErrorSnackbar(
        'Error al recuperar puntaje',
        'No se pudieron recuperar tus puntos desde el servidor.',
      );
      return null;
    }
  }
}
