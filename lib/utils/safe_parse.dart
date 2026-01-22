/// Safe parsing utilities to prevent FormatException errors
/// when parsing strings to numbers
class SafeParse {
  /// Safely parses a string to double
  /// Returns [defaultValue] if parsing fails or input is null/empty
  ///
  /// Example:
  /// ```dart
  /// double value = SafeParse.toDouble("123.45"); // Returns 123.45
  /// double value = SafeParse.toDouble("invalid"); // Returns 0.0
  /// double value = SafeParse.toDouble("invalid", defaultValue: -1.0); // Returns -1.0
  /// ```
  static double toDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    final stringValue = value.toString().trim();
    if (stringValue.isEmpty) return defaultValue;

    return double.tryParse(stringValue) ?? defaultValue;
  }

  /// Safely parses a string to int
  /// Returns [defaultValue] if parsing fails or input is null/empty
  ///
  /// Example:
  /// ```dart
  /// int value = SafeParse.toInt("123"); // Returns 123
  /// int value = SafeParse.toInt("invalid"); // Returns 0
  /// int value = SafeParse.toInt("invalid", defaultValue: -1); // Returns -1
  /// ```
  static int toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();

    final stringValue = value.toString().trim();
    if (stringValue.isEmpty) return defaultValue;

    // Handle decimal strings by parsing as double first
    final doubleValue = double.tryParse(stringValue);
    if (doubleValue != null) return doubleValue.toInt();

    return int.tryParse(stringValue) ?? defaultValue;
  }

  /// Safely parses a string to double, returns null if parsing fails
  /// Useful when you need to distinguish between 0 and parse failure
  ///
  /// Example:
  /// ```dart
  /// double? value = SafeParse.toDoubleOrNull("123.45"); // Returns 123.45
  /// double? value = SafeParse.toDoubleOrNull("invalid"); // Returns null
  /// ```
  static double? toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    final stringValue = value.toString().trim();
    if (stringValue.isEmpty) return null;

    return double.tryParse(stringValue);
  }

  /// Safely parses a string to int, returns null if parsing fails
  /// Useful when you need to distinguish between 0 and parse failure
  ///
  /// Example:
  /// ```dart
  /// int? value = SafeParse.toIntOrNull("123"); // Returns 123
  /// int? value = SafeParse.toIntOrNull("invalid"); // Returns null
  /// ```
  static int? toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();

    final stringValue = value.toString().trim();
    if (stringValue.isEmpty) return null;

    // Handle decimal strings by parsing as double first
    final doubleValue = double.tryParse(stringValue);
    if (doubleValue != null) return doubleValue.toInt();

    return int.tryParse(stringValue);
  }
}
