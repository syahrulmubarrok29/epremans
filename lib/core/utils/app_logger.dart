// ignore_for_file: avoid_print

// Lightweight logging utility for e-PREMANS.
//
// All log output is gated behind [kDebugMode] — nothing is printed in
// release builds. Replace with a proper logging package (e.g. `logger`) if
// structured/remote logging is required in a later phase.
import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  /// Log an informational message.
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '[INFO]';
      print('$prefix $message');
    }
  }

  /// Log a warning message.
  static void warn(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag][WARN]' : '[WARN]';
      print('$prefix $message');
    }
  }

  /// Log an error message with an optional exception and stack trace.
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag][ERROR]' : '[ERROR]';
      print('$prefix $message');
      if (error != null) print('  Exception: $error');
      if (stackTrace != null) print('  StackTrace: $stackTrace');
    }
  }

  /// Log a debug message (most verbose — use sparingly).
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag][DEBUG]' : '[DEBUG]';
      print('$prefix $message');
    }
  }
}
