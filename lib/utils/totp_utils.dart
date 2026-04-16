import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// TOTP Utility class for generating Time-based One-Time Passwords
/// This matches the Vue.js implementation in DeskMynt.vue
class TotpUtils {
  static const String _base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  
  /// Convert Base32 encoded string to hex
  static String base32ToHex(String base32) {
    StringBuffer bits = StringBuffer();
    StringBuffer hex = StringBuffer();

    for (int i = 0; i < base32.length; i++) {
      final val = _base32Chars.indexOf(base32[i].toUpperCase());
      if (val >= 0) {
        bits.write(val.toRadixString(2).padLeft(5, '0'));
      }
    }

    final bitString = bits.toString();
    for (int i = 0; i + 8 <= bitString.length; i += 8) {
      final byte = bitString.substring(i, i + 8);
      hex.write(int.parse(byte, radix: 2).toRadixString(16).padLeft(2, '0'));
    }

    return hex.toString();
  }

  /// Convert hex string to Uint8List
  static Uint8List hexToBytes(String hex) {
    List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  /// Generate TOTP code from secret key
  /// Uses HMAC-SHA1 algorithm with 30-second time step
  static String generateTotp(String secretKey, {int digits = 6, int period = 30}) {
    try {
      // Convert base32 secret to hex
      final key = base32ToHex(secretKey);
      
      // Get current time step
      final epoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final time = (epoch ~/ period).toRadixString(16).padLeft(16, '0');
      
      // Convert to bytes
      final keyBytes = hexToBytes(key);
      final timeBytes = hexToBytes(time);
      
      // Calculate HMAC-SHA1
      final hmac = Hmac(sha1, keyBytes);
      final digest = hmac.convert(timeBytes);
      final hash = digest.bytes;
      
      // Dynamic truncation
      final offset = hash[hash.length - 1] & 0x0f;
      final binaryCode = ((hash[offset] & 0x7f) << 24) |
          ((hash[offset + 1] & 0xff) << 16) |
          ((hash[offset + 2] & 0xff) << 8) |
          (hash[offset + 3] & 0xff);
      
      // Generate OTP  
      final otp = binaryCode % _pow(10, digits);
      
      return otp.toString().padLeft(digits, '0');
    } catch (e) {
      return '';
    }
  }

  /// Power function for integers
  static int _pow(int base, int exp) {
    int result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  /// Get remaining seconds until next TOTP refresh
  static int getRemainingSeconds({int period = 30}) {
    final epoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return period - (epoch % period);
  }

  /// Format TOTP code with space in the middle (e.g., "123 456")
  static String formatTotp(String totp) {
    if (totp.length == 6) {
      return '${totp.substring(0, 3)} ${totp.substring(3, 6)}';
    }
    return totp;
  }
}
