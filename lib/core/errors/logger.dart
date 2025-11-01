import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error, critical }

/// A clean and extensible logger class for Flutter projects.
/// Supports dev and prod modes, integrates easily with Sentry/Firebase.
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  bool enableConsoleLogs = kDebugMode;

  /// Optional external error tracker (Sentry, Crashlytics, etc.)
  Future<void> Function(String message, dynamic error, StackTrace stack)? externalErrorHandler;

  void log(
    String message, {
    LogLevel level = LogLevel.info,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final tag = level.name.toUpperCase();

    // Console logging (dev mode)
    if (enableConsoleLogs) {
      developer.log(
        "[$timestamp] [$tag] $message",
        name: 'AppLogger',
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (level.index >= LogLevel.error.index && externalErrorHandler != null) {
      externalErrorHandler!.call(message, error, stackTrace ?? StackTrace.current);
    }
  }

  /// Convenience methods
  void debug(String message) => log(message, level: LogLevel.debug);
  void info(String message) => log(message, level: LogLevel.info);
  void warn(String message) => log(message, level: LogLevel.warning);
  void error(String message, {dynamic error, StackTrace? stackTrace}) =>
      log(message, level: LogLevel.error, error: error, stackTrace: stackTrace);
  void critical(String message, {dynamic error, StackTrace? stackTrace}) =>
      log(message, level: LogLevel.critical, error: error, stackTrace: stackTrace);
}
