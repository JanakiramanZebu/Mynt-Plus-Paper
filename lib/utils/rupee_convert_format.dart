/// High-performance Indian number formatting utility.
///
/// Optimized for frequent updates (e.g., real-time P&L with WebSocket price ticks).
/// Uses pure Dart string manipulation to avoid the overhead of intl package.
///
/// Indian numbering system groups digits as:
/// - First group from right: 3 digits (hundreds)
/// - All subsequent groups: 2 digits (thousands, lakhs, crores)
///
/// Examples:
/// - 1234 -> 1,234
/// - 12345 -> 12,345
/// - 123456 -> 1,23,456
/// - 1234567 -> 12,34,567
/// - 12345678 -> 1,23,45,678
class RupeeFormat {
  RupeeFormat._();

  /// Formats a number to Indian comma-separated format with specified decimal places.
  ///
  /// [value] - The number to format (can be int, double, or num)
  /// [decimalPlaces] - Number of decimal places (default: 2)
  /// [showSign] - Whether to show + sign for positive numbers (default: false)
  ///
  /// Returns formatted string like "1,23,456.78" or "+1,23,456.78"
  ///
  /// Example:
  /// ```dart
  /// RupeeFormat.format(1234567.89); // "12,34,567.89"
  /// RupeeFormat.format(-1234567.89); // "-12,34,567.89"
  /// RupeeFormat.format(1234567.89, showSign: true); // "+12,34,567.89"
  /// ```
  static String format(
    num value, {
    int decimalPlaces = 2,
    bool showSign = false,
  }) {
    final bool isNegative = value < 0;
    final double absValue = value.abs().toDouble();

    // Handle zero case
    if (absValue == 0) {
      return decimalPlaces > 0 ? '0.${'0' * decimalPlaces}' : '0';
    }

    // Round to specified decimal places
    final String fixedStr = absValue.toStringAsFixed(decimalPlaces);

    // Split into integer and decimal parts
    final int dotIndex = fixedStr.indexOf('.');
    final String integerPart = dotIndex > 0 ? fixedStr.substring(0, dotIndex) : fixedStr;
    final String decimalPart = dotIndex > 0 ? fixedStr.substring(dotIndex) : '';

    // Format the integer part with Indian grouping
    final String formattedInteger = _formatIntegerPart(integerPart);

    // Build result
    final StringBuffer result = StringBuffer();
    if (isNegative) {
      result.write('-');
    } else if (showSign && value > 0) {
      result.write('+');
    }
    result.write(formattedInteger);
    result.write(decimalPart);

    return result.toString();
  }

  /// Formats a string number to Indian comma-separated format.
  ///
  /// [value] - String representation of the number
  /// [decimalPlaces] - Number of decimal places (default: 2)
  /// [showSign] - Whether to show + sign for positive numbers (default: false)
  ///
  /// Returns formatted string or "0.00" if parsing fails.
  ///
  /// Example:
  /// ```dart
  /// RupeeFormat.formatString("1234567.89"); // "12,34,567.89"
  /// RupeeFormat.formatString("invalid"); // "0.00"
  /// ```
  static String formatString(
    String value, {
    int decimalPlaces = 2,
    bool showSign = false,
  }) {
    if (value.isEmpty) {
      return decimalPlaces > 0 ? '0.${'0' * decimalPlaces}' : '0';
    }

    // Remove existing commas and whitespace
    final String cleanValue = value.replaceAll(',', '').trim();

    // Try to parse
    final double? parsed = double.tryParse(cleanValue);
    if (parsed == null || parsed.isNaN || parsed.isInfinite) {
      return decimalPlaces > 0 ? '0.${'0' * decimalPlaces}' : '0';
    }

    return format(parsed, decimalPlaces: decimalPlaces, showSign: showSign);
  }

  /// Formats a number with rupee symbol prefix.
  ///
  /// [value] - The number to format
  /// [decimalPlaces] - Number of decimal places (default: 2)
  /// [showSign] - Whether to show + sign for positive numbers (default: false)
  ///
  /// Example:
  /// ```dart
  /// RupeeFormat.formatWithRupee(1234567.89); // "₹12,34,567.89"
  /// RupeeFormat.formatWithRupee(-1234.56); // "-₹1,234.56"
  /// ```
  static String formatWithRupee(
    num value, {
    int decimalPlaces = 2,
    bool showSign = false,
  }) {
    final bool isNegative = value < 0;
    final String formatted = format(
      value.abs(),
      decimalPlaces: decimalPlaces,
      showSign: false,
    );

    if (isNegative) {
      return '-₹$formatted';
    } else if (showSign && value > 0) {
      return '+₹$formatted';
    }
    return '₹$formatted';
  }

  /// Formats a string number with rupee symbol prefix.
  ///
  /// [value] - String representation of the number
  /// [decimalPlaces] - Number of decimal places (default: 2)
  /// [showSign] - Whether to show + sign for positive numbers (default: false)
  static String formatStringWithRupee(
    String value, {
    int decimalPlaces = 2,
    bool showSign = false,
  }) {
    final String cleanValue = value.replaceAll(',', '').trim();
    final double? parsed = double.tryParse(cleanValue);

    if (parsed == null || parsed.isNaN || parsed.isInfinite) {
      return decimalPlaces > 0 ? '₹0.${'0' * decimalPlaces}' : '₹0';
    }

    return formatWithRupee(parsed, decimalPlaces: decimalPlaces, showSign: showSign);
  }

  /// Formats large numbers in compact form (L for Lakh, Cr for Crore).
  ///
  /// [value] - The number to format
  /// [decimalPlaces] - Number of decimal places for the compact value (default: 2)
  ///
  /// Example:
  /// ```dart
  /// RupeeFormat.formatCompact(125000); // "1.25 L"
  /// RupeeFormat.formatCompact(25000000); // "2.50 Cr"
  /// RupeeFormat.formatCompact(1234); // "1,234.00"
  /// ```
  static String formatCompact(num value, {int decimalPlaces = 2}) {
    final bool isNegative = value < 0;
    final double absValue = value.abs().toDouble();

    String result;
    if (absValue >= 10000000) {
      // Crore (1 Cr = 10 million)
      result = '${(absValue / 10000000).toStringAsFixed(decimalPlaces)} Cr';
    } else if (absValue >= 100000) {
      // Lakh (1 L = 100 thousand)
      result = '${(absValue / 100000).toStringAsFixed(decimalPlaces)} L';
    } else {
      // Regular formatting for smaller numbers
      result = format(absValue, decimalPlaces: decimalPlaces);
    }

    return isNegative ? '-$result' : result;
  }

  /// Formats large numbers in compact form with rupee symbol.
  ///
  /// [value] - The number to format
  /// [decimalPlaces] - Number of decimal places (default: 2)
  static String formatCompactWithRupee(num value, {int decimalPlaces = 2}) {
    final bool isNegative = value < 0;
    final String formatted = formatCompact(value.abs(), decimalPlaces: decimalPlaces);

    if (isNegative) {
      return '-₹$formatted';
    }
    return '₹$formatted';
  }

  /// Internal method to format the integer part with Indian grouping.
  ///
  /// Indian grouping: last 3 digits from right, then groups of 2.
  /// Example: 12345678 -> 1,23,45,678
  static String _formatIntegerPart(String integerPart) {
    final int length = integerPart.length;

    // No formatting needed for numbers with 3 or fewer digits
    if (length <= 3) {
      return integerPart;
    }

    // Last 3 digits form the rightmost group
    final String lastThree = integerPart.substring(length - 3);

    // Everything before the last 3 digits needs to be grouped in 2s
    String remaining = integerPart.substring(0, length - 3);

    // Process the remaining part in groups of 2 from right to left
    final List<String> groups = [];
    while (remaining.isNotEmpty) {
      if (remaining.length >= 2) {
        groups.insert(0, remaining.substring(remaining.length - 2));
        remaining = remaining.substring(0, remaining.length - 2);
      } else {
        groups.insert(0, remaining);
        remaining = '';
      }
    }

    // Build the result: groups joined by comma, then comma, then last three
    final StringBuffer result = StringBuffer();
    result.write(groups.join(','));
    result.write(',');
    result.write(lastThree);

    return result.toString();
  }
}

/// Extension on num for convenient Indian number formatting.
extension RupeeFormatExtension on num {
  /// Formats this number to Indian comma-separated format.
  ///
  /// Example:
  /// ```dart
  /// 1234567.89.toIndianFormat(); // "12,34,567.89"
  /// ```
  String toIndianFormat({int decimalPlaces = 2, bool showSign = false}) {
    return RupeeFormat.format(
      this,
      decimalPlaces: decimalPlaces,
      showSign: showSign,
    );
  }

  /// Formats this number with rupee symbol in Indian format.
  ///
  /// Example:
  /// ```dart
  /// 1234567.89.toIndianRupee(); // "₹12,34,567.89"
  /// ```
  String toIndianRupee({int decimalPlaces = 2, bool showSign = false}) {
    return RupeeFormat.formatWithRupee(
      this,
      decimalPlaces: decimalPlaces,
      showSign: showSign,
    );
  }

  /// Formats this number in compact Indian format (L, Cr).
  ///
  /// Example:
  /// ```dart
  /// 1234567.toIndianCompact(); // "12.35 L"
  /// ```
  String toIndianCompact({int decimalPlaces = 2}) {
    return RupeeFormat.formatCompact(this, decimalPlaces: decimalPlaces);
  }
}

/// Extension on String for convenient Indian number formatting.
extension RupeeFormatStringExtension on String {
  /// Parses and formats this string to Indian comma-separated format.
  ///
  /// Example:
  /// ```dart
  /// "1234567.89".toIndianFormat(); // "12,34,567.89"
  /// ```
  String toIndianFormat({int decimalPlaces = 2, bool showSign = false}) {
    return RupeeFormat.formatString(
      this,
      decimalPlaces: decimalPlaces,
      showSign: showSign,
    );
  }

  /// Parses and formats this string with rupee symbol in Indian format.
  ///
  /// Example:
  /// ```dart
  /// "1234567.89".toIndianRupee(); // "₹12,34,567.89"
  /// ```
  String toIndianRupee({int decimalPlaces = 2, bool showSign = false}) {
    return RupeeFormat.formatStringWithRupee(
      this,
      decimalPlaces: decimalPlaces,
      showSign: showSign,
    );
  }
}
