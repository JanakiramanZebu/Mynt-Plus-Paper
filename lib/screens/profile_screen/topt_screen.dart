import 'dart:async';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';

import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_drag_handler.dart';

class TotpScreen extends ConsumerStatefulWidget {
  final String secretKey;
  const TotpScreen({super.key, required this.secretKey});

  @override
  ConsumerState<TotpScreen> createState() => _TotpScreenState();
}

class _TotpScreenState extends ConsumerState<TotpScreen> {
  bool isObscure = true;
  String otp = 'Loading...';
  late Timer timer;
  String totpkey = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  int remainingSeconds = 30;
  double progressValue = 1.0;

  @override
  void initState() {
    super.initState();
    setTOTP();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String base32ToHex(String base32) {
    var base32Chars = totpkey;
    String bits = '';
    String hex = '';

    for (int i = 0; i < base32.length; i++) {
      int val = base32Chars.indexOf(base32[i].toUpperCase());
      bits += val.toRadixString(2).padLeft(5, '0');
    }

    for (int i = 0; i + 8 <= bits.length; i += 8) {
      String byte = bits.substring(i, i + 8);
      hex += int.parse(byte, radix: 2).toRadixString(16).padLeft(2, '0');
    }

    return hex;
  }

  Uint8List hexToBytes(String hex) {
    List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  void setTOTP() async {
    generateTOTP();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      generateTOTP();
      setState(() {
        int currentSecond = DateTime.now().second;
        remainingSeconds = 30 - (currentSecond % 30);
        progressValue = remainingSeconds / 30;
      });
    });
  }

  void generateTOTP() async {
    String key = base32ToHex(widget.secretKey);

    int epoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int time = (epoch ~/ 30);
    String timeHex = time.toRadixString(16).padLeft(16, '0');

    Uint8List timeBuffer = hexToBytes(timeHex);
    Uint8List keyBuffer = hexToBytes(key);

    Hmac hmac = Hmac(sha1, keyBuffer);
    Digest digest = hmac.convert(timeBuffer);

    List<int> hash = digest.bytes;
    int offset = hash[hash.length - 1] & 0xf;
    int binary = ((hash[offset] & 0x7f) << 24) |
        ((hash[offset + 1] & 0xff) << 16) |
        ((hash[offset + 2] & 0xff) << 8) |
        (hash[offset + 3] & 0xff);

    int otpNumber = binary % 1000000;
    String otpCode = otpNumber.toString().padLeft(6, '0');

    setState(() {
      otp = otpCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    // final screenheight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomDragHandler(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                TextWidget.titleText(
                    text: 'Your TOTP',
                    theme: false,
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack,
                    fw: 1),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: otp));
                    ScaffoldMessenger.of(context).showSnackBar(
                        successMessage(context, "TOTP copied to clipboard"));

                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.symmetric(
                            horizontal: BorderSide(
                                color: theme.isDarkMode
                                    ? colors.darkGrey
                                    : const Color(0xffEEF0F2),
                                width: 1.5),
                            vertical: BorderSide(
                                color: theme.isDarkMode
                                    ? colors.darkGrey
                                    : const Color(0xffEEF0F2),
                                width: 1.5))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextWidget.custmText(
                                  text:
                                      "${otp.substring(0, 3)} ${otp.substring(3, 6)}",
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  fs: 24,
                                  fw: 2,
                                  theme: false,
                                  letterSpacing: 2),
                              const SizedBox(
                                width: 8,
                              ),
                              const Icon(Icons.copy, size: 20),
                            ],
                          ),
                          // const SizedBox(height: 8),
                          // const Icon(Icons.copy, size: 24),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: progressValue,
                            backgroundColor: theme.isDarkMode
                                ? colors.colorLightBlue.withOpacity(0.2)
                                : colors.colorBlue.withOpacity(0.2),
                            color: theme.isDarkMode
                                ? colors.colorLightBlue
                                : colors.colorBlue,
                            minHeight: 6,
                          ),
                          const SizedBox(height: 14),
                          TextWidget.paraText(
                              text: '$remainingSeconds seconds remaining',
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              fw: 3),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextWidget.titleText(
                    text: 'Authenticator Key',
                    theme: false,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 1),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: colors.colorbluegrey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextWidget.paraText(
                              text: isObscure
                                  ? "••••••••••••••••••••"
                                  : widget.secretKey,
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              fw: 0,
                              textOverflow: TextOverflow.ellipsis),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isObscure = !isObscure;
                            });
                          },
                          child: Icon(
                            isObscure ? Icons.visibility_off : Icons.visibility,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: widget.secretKey));
                            ScaffoldMessenger.of(context).showSnackBar(
                                successMessage(
                                    context, "Auth key copied to clipboard"));

                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.copy, size: 22),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 30.0)
        ],
      ),
    );
  }
}
