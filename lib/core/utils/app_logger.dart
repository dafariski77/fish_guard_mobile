import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight persistent on-device logger for production & real-device debugging.
/// Writes to `debugPrint` (visible via `adb logcat -s flutter`) and retains
/// the latest [_maxEntries] lines in [SharedPreferences].
abstract final class AppLogger {
  static const String _storageKey = 'fish_guard_debug_logs_v1';
  static const int _maxEntries = 80;
  static final List<String> _memoryBuffer = [];

  static Future<void> info(String tag, String message) =>
      _log('INFO', tag, message);

  static Future<void> warn(String tag, String message) =>
      _log('WARN', tag, message);

  static Future<void> error(
    String tag,
    String message, [
    Object? err,
    StackTrace? stackTrace,
  ]) {
    final full = err != null ? '$message | $err' : message;
    if (stackTrace != null) {
      debugPrint('[$tag] STACK: $stackTrace');
    }
    return _log('ERROR', tag, full);
  }

  static Future<void> _log(String level, String tag, String message) async {
    final now = DateTime.now();
    final ts =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final line = '[$ts][$level][$tag] $message';
    debugPrint(line);

    _memoryBuffer.insert(0, line);
    if (_memoryBuffer.length > _maxEntries) {
      _memoryBuffer.removeLast();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_storageKey) ?? <String>[];
      final updated = [line, ...existing];
      if (updated.length > _maxEntries) {
        updated.removeRange(_maxEntries, updated.length);
      }
      await prefs.setStringList(_storageKey, updated);
    } catch (_) {
      // Ignore storage errors in headless tests or restricted contexts
    }
  }

  static Future<List<String>> getLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_storageKey);
      if (stored != null && stored.isNotEmpty) {
        return stored;
      }
    } catch (_) {}
    return List.unmodifiable(_memoryBuffer);
  }

  static Future<void> clearLogs() async {
    _memoryBuffer.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (_) {}
  }
}
