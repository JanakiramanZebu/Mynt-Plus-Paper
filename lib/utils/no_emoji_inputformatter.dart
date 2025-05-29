import 'package:flutter/services.dart';

/// A RegExp that matches most emoji sequences.
/// You can customize this or import it from your own `constant.dart`.
final _emojiRegExp = RegExp(
  r'[\u{1F600}-\u{1F64F}' // Emoticons
  r'\u{1F300}-\u{1F5FF}' // Misc Symbols and Pictographs
  r'\u{1F680}-\u{1F6FF}' // Transport & Map
  r'\u{2600}-\u{26FF}'   // Misc symbols
  r'\u{2700}-\u{27BF}]', // Dingbats
  unicode: true,
);

class NoEmojiInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // strip out any emojis
    final stripped = newValue.text.replaceAll(_emojiRegExp, '');
    // if nothing changed, keep the old cursor; otherwise, let it collapse at the end
    final selection = stripped == newValue.text
        ? newValue.selection
        : TextSelection.collapsed(offset: stripped.length);
    return TextEditingValue(text: stripped, selection: selection);
  }
}
