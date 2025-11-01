class SentryException implements Exception {
  final String message;
  final Object? cause;
  final Map<String, dynamic>? extra;

  SentryException(this.message, {this.cause, this.extra});

  @override
  String toString() {
    final c = cause != null ? ' cause: $cause' : '';
    final x = extra != null ? ' extra: $extra' : '';
    return 'SentryException: $message$c$x';
  }
}
