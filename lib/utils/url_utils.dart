/// URL encoding utilities for handling special characters in API requests
class UrlUtils {
  /// Encodes a string to be safe for use in URL parameters
  /// 
  /// This method handles all Unicode characters including:
  /// - Special characters like &, %, =, +, space, etc.
  /// - Unicode characters from different languages
  /// - Symbols and emojis
  /// 
  /// Example:
  /// ```dart
  /// String encoded = UrlUtils.encodeParameter("M&M Ltd"); // Returns "M%26M%20Ltd"
  /// ```
  static String encodeParameter(String value) {
    return Uri.encodeComponent(value);
  }
  
  /// Encodes multiple parameters and returns them as a Map
  /// 
  /// Example:
  /// ```dart
  /// Map<String, String> params = UrlUtils.encodeParameters({
  ///   'tsym': 'M&M Ltd',
  ///   'exch': 'NSE & BSE'
  /// });
  /// ```
  static Map<String, String> encodeParameters(Map<String, String> parameters) {
    return parameters.map((key, value) => MapEntry(key, encodeParameter(value)));
  }
  
  /// Encodes a full query string
  /// 
  /// Example:
  /// ```dart
  /// String query = UrlUtils.encodeQueryString({
  ///   'tsym': 'M&M Ltd',
  ///   'exch': 'NSE'
  /// }); // Returns "tsym=M%26M%20Ltd&exch=NSE"
  /// ```
  static String encodeQueryString(Map<String, String> parameters) {
    return parameters.entries
        .map((entry) => '${encodeParameter(entry.key)}=${encodeParameter(entry.value)}')
        .join('&');
  }
}