import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Sistema de registro y captura de errores persistente para Shadow Vault.
///
/// Permite capturar excepciones de Flutter, errores asíncronos y eventos
/// críticos del juego (muerte de jefes, subidas de nivel, recolección de gemas).
class LogManager {
  LogManager._();

  static final List<String> _inMemoryLogs = [];
  static const int _maxInMemoryLogs = 600;
  static File? _logFile;

  static List<String> get logs => List.unmodifiable(_inMemoryLogs);

  /// Inicializa la captura global de errores y el archivo de log persistente.
  static Future<void> initialize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _logFile = File('${dir.path}/shadow_vault_logs.txt');
      if (_logFile!.existsSync()) {
        final existingLines = await _logFile!.readAsLines();
        if (existingLines.isNotEmpty) {
          final startIdx = existingLines.length > 300 ? existingLines.length - 300 : 0;
          _inMemoryLogs.addAll(existingLines.sublist(startIdx));
        }
      }
      log('--- Sesión iniciada: ${DateTime.now()} ---');
    } catch (e) {
      debugPrint('LogManager: No se pudo inicializar archivo de logs: $e');
    }

    // Capturar errores del framework de Flutter
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      log('CRITICAL FLUTTER ERROR: ${details.exceptionAsString()}\nStack:\n${details.stack}');
      originalOnError?.call(details);
    };

    // Capturar errores asíncronos de Dart no controlados
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      log('UNHANDLED ASYNC ERROR: $error\nStack:\n$stack');
      return true; // Evitar cierre abrupto si es recuperable
    };
  }

  /// Añade una entrada al registro con timestamp.
  static void log(String message) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';
    final entry = '[$timeStr] $message';

    debugPrint(entry);
    _inMemoryLogs.add(entry);

    if (_inMemoryLogs.length > _maxInMemoryLogs) {
      _inMemoryLogs.removeRange(0, _inMemoryLogs.length - _maxInMemoryLogs);
    }

    _writeEntryToFile(entry);
  }

  static void _writeEntryToFile(String entry) {
    if (_logFile == null) return;
    try {
      _logFile!.writeAsStringSync('$entry\n', mode: FileMode.append, flush: true);
    } catch (_) {}
  }

  /// Retorna todo el contenido actual del log como una sola cadena para copiar.
  static String getFormattedLogs() {
    if (_inMemoryLogs.isEmpty) return 'No hay registros guardados en esta sesión.';
    return _inMemoryLogs.join('\n');
  }

  /// Limpia el registro en memoria y en disco.
  static void clear() {
    _inMemoryLogs.clear();
    try {
      if (_logFile != null && _logFile!.existsSync()) {
        _logFile!.writeAsStringSync('--- Registro reiniciado: ${DateTime.now()} ---\n');
      }
    } catch (_) {}
    log('Registro de logs limpiado.');
  }
}
