import 'package:encrypt/encrypt.dart';
import '../../api/core/api_core.dart';

String encryptionFunction(String payload) {
  final key =
      Key.fromBase64(base64Url.encode(utf8.encode("N#j2L^8pq9Fb\$d@1")));
  final iv = IV.fromUtf8("3790514682037125");
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final encryptedPayload = encrypter.encrypt(payload, iv: iv);
  return encryptedPayload.base64;
}

 decryptionFunction(String payld) {
  final payload = payld;
  final derivedKey =
      Key.fromBase64(base64.encode(utf8.encode("N#j2L^8pq9Fb\$d@1")));
  final iv = IV.fromUtf8("3790514682037125");
  final encryptedData = Encrypted.fromBase64(payload);
  final decrypter = Encrypter(AES(derivedKey, mode: AESMode.cbc));
  final decryptedData = decrypter.decrypt(encryptedData, iv: iv);
  return decryptedData;
}

parseJson(String responseBody) {
  List<dynamic> jsonData = jsonDecode(responseBody);

  // Iterate over the list
  for (var item in jsonData) {
    // Now you can treat each item as a map
    Map<String, dynamic> mapItem = item;
  }
}

String hideAccountNumber(String accountNumber) {
  // Guard clause for empty or short account numbers
  if (accountNumber.isEmpty) {
    return '';
  }
  const int visibleDigits = 4;
  if (accountNumber.length <= visibleDigits) {
    return accountNumber;
  }
  final visiblePart =
      accountNumber.substring(accountNumber.length - visibleDigits);
  final hiddenPart = 'X' * (accountNumber.length - visibleDigits);
  return hiddenPart + visiblePart;
}
