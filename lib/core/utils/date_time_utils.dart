import 'package:intl/intl.dart';

// Date/time and currency formatting utilities for e-PREMANS.
//
// Always use these helpers for display purposes. Do not format dates or
// currency values inline in widgets.
class DateTimeUtils {
  DateTimeUtils._();

  static final DateFormat _dateDisplay = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeDisplay = DateFormat('dd MMM yyyy, HH:mm');
  static final DateFormat _timeDisplay = DateFormat('HH:mm');
  static final DateFormat _isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  // ---------------------------------------------------------------------------
  // Display formatters
  // ---------------------------------------------------------------------------

  /// Formats a date for display: e.g. "17 Sep 2026"
  static String formatDate(DateTime date) => _dateDisplay.format(date);

  /// Formats a date+time for display: e.g. "17 Sep 2026, 08:30"
  static String formatDateTime(DateTime dateTime) =>
      _dateTimeDisplay.format(dateTime);

  /// Formats time only: e.g. "08:30"
  static String formatTime(DateTime dateTime) => _timeDisplay.format(dateTime);

  /// Formats a nullable [DateTime], returning [fallback] if null.
  static String formatDateTimeOrFallback(DateTime? dateTime,
      {String fallback = '—'}) {
    if (dateTime == null) return fallback;
    return _dateTimeDisplay.format(dateTime);
  }

  // ---------------------------------------------------------------------------
  // Parsers
  // ---------------------------------------------------------------------------

  /// Safely parses an ISO 8601 string. Returns null on failure.
  static DateTime? tryParseIso(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  /// Parses an ISO 8601 string from JSON. Throws if null.
  static DateTime parseIso(String value) => DateTime.parse(value);

  /// Converts [DateTime] to ISO 8601 string for JSON/DB storage.
  static String toIso(DateTime dateTime) => _isoFormat.format(dateTime);

  // ---------------------------------------------------------------------------
  // Duration helpers
  // ---------------------------------------------------------------------------

  /// Returns the elapsed time as a human-readable string.
  /// Example: "2h 30m"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}

// ---------------------------------------------------------------------------
// Currency formatter
// ---------------------------------------------------------------------------

// IDR currency formatting for the e-PREMANS Service Report cost fields.
class CurrencyUtils {
  CurrencyUtils._();

  static final NumberFormat _idr = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Formats a [double] as Indonesian Rupiah.
  /// Example: 1500000.0 → "Rp 1.500.000"
  static String formatIdr(double amount) => _idr.format(amount);

  /// Formats a nullable [double], returning [fallback] if null or zero.
  static String formatIdrOrFallback(double? amount, {String fallback = '—'}) {
    if (amount == null) return fallback;
    return _idr.format(amount);
  }
}
