import 'package:sentry_flutter/sentry_flutter.dart';
import '../../errors/logger.dart';

class SentryService {
  static final SentryService _instance = SentryService._internal();
  factory SentryService() => _instance;
  SentryService._internal();

  final AppLogger _logger = AppLogger();

  /// Capture exception and optionally attach context. Returns sentry id.
  Future<SentryId> captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
    bool log = true,
  }) async {
    if (log) {
      _logger.error(
        'Sentry captureException: $exception',
        error: exception,
        stackTrace: stackTrace,
      );
    }
    try {
      final id = await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      return id;
    } catch (e, st) {
      _logger.error(
        'Failed to send event to Sentry: $e',
        error: e,
        stackTrace: st,
      );
      return SentryId.empty();
    }
  }

  /// Capture simple message
  Future<SentryId> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
  }) async {
    _logger.info('Sentry captureMessage: $message');
    try {
      final id = await Sentry.captureMessage(message, level: level);
      return id;
    } catch (e, st) {
      _logger.error(
        'Failed to send message to Sentry: $e',
        error: e,
        stackTrace: st,
      );
      return SentryId.empty();
    }
  }

  /// Convenience to report Flutter errors / stack traces
  Future<SentryId> reportError(
    dynamic error,
    StackTrace stack, {
    String? context,
  }) async {
    _logger.error('Reporting error: $error', error: error, stackTrace: stack);
    final extra = context != null ? {'context': context} : null;
    return captureException(error, stackTrace: stack, extra: extra, log: false);
  }

  /// Run async function capturing and rethrowing exceptions (useful for tests/guards)
  Future<T> runGuarded<T>(Future<T> Function() body, {String? hint}) async {
    try {
      return await body();
    } catch (e, st) {
      await captureException(
        e,
        stackTrace: st,
        extra: hint != null ? {'hint': hint} : null,
      );
      rethrow;
    }
  }
}
