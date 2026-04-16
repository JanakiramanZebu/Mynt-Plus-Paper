import 'dart:async';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';

import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/list_divider.dart';

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
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
           borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
         color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
         border: Border(
                                  top: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  left: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  right: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                ),

         
        ),
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
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: TextWidget.titleText(
                        text: 'Your TOTP',
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        fw: 0),
                  ),
        
                  const ListDivider(),
                  // const SizedBox(height: 16),
        
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextWidget.subText(
                        text: 'Token',
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                            fw: 1,
                        ),
                  ),
                  
                  Material(
                    color: Colors.transparent,
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      // borderRadius: BorderRadius.circular(15),
                      splashColor: theme.isDarkMode
                          ? colors.splashColorDark
                          : colors.splashColorLight,
                      highlightColor: theme.isDarkMode
                          ? colors.highlightDark
                          : colors.highlightLight,
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 150));
                        Clipboard.setData(ClipboardData(text: otp));
                            successMessage(context, "TOTP copied to clipboard");
        
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextWidget.titleText(
                                    text:
                                        "${otp.substring(0, 3)} ${otp.substring(3, 6)}",
                                    color: theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    fw: 0,
                                    theme: false,
                                    ),
                                const SizedBox(width: 4),
                                Material(
                                  color: Colors.transparent,
                                  shape: const CircleBorder(),
                                  clipBehavior: Clip.hardEdge,
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    splashColor: theme.isDarkMode
                                        ? colors.splashColorDark
                                        : colors.splashColorLight,
                                    highlightColor: theme.isDarkMode
                                        ? colors.highlightDark
                                        : colors.highlightLight,
                                    onTap: () async {
                                      await Future.delayed(
                                          const Duration(milliseconds: 150));
                                      Clipboard.setData(ClipboardData(text: otp));
                                          successMessage(context, "TOTP copied to clipboard");
                                      Navigator.pop(context);
                                    },
                                    child: SizedBox(
                                      height: 32,
                                      width: 32,
                                      child: Center(
                                        child: Icon(Icons.copy, size: 18, color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // const SizedBox(height: 8),
                            // const Icon(Icons.copy, size: 24),
                            const SizedBox(height: 10),
                            // LinearProgressIndicator(
                            //   value: progressValue,
                            //   backgroundColor: theme.isDarkMode
                            //       ? colors.colorLightBlue.withOpacity(0.2)
                            //       : colors.colorBlue.withOpacity(0.2),
                            //   color: theme.isDarkMode
                            //       ? colors.colorLightBlue
                            //       : colors.colorBlue,
                            //   minHeight: 6,
                            // ),
                            // const SizedBox(height: 14),
                            TextWidget.subText(
                                text: '$remainingSeconds sec',
                                theme: false,
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                                fw: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextWidget.subText(
                      text: 'Authenticator Key',
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 0),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
              color: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: colors.primaryLight,
                                  width: 1,
                                ),
                     
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
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                                fw: 0,
                                textOverflow: TextOverflow.ellipsis),
                          ),
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.hardEdge,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              splashColor: theme.isDarkMode
                                  ? colors.splashColorDark
                                  : colors.splashColorLight,
                              highlightColor: theme.isDarkMode
                                  ? colors.highlightDark
                                  : colors.highlightLight,
                              onTap: () async {
                                await Future.delayed(
                                    const Duration(milliseconds: 150));
                                setState(() {
                                  isObscure = !isObscure;
                                });
                              },
                              child: SizedBox(
                                height: 32,
                                width: 32,
                                child: Center(
                                  child: Icon(
                                    isObscure ? Icons.visibility_off : Icons.visibility,
                                    size: 18,
                                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.hardEdge,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              splashColor: theme.isDarkMode
                                  ? colors.splashColorDark
                                  : colors.splashColorLight,
                              highlightColor: theme.isDarkMode
                                  ? colors.highlightDark
                                  : colors.highlightLight,
                              onTap: () async {
                                await Future.delayed(
                                    const Duration(milliseconds: 150));
                                Clipboard.setData(
                                    ClipboardData(text: widget.secretKey));
                                    successMessage(
                                        context, "Auth key copied to clipboard");
                                Navigator.pop(context);
                              },
                              child: SizedBox(
                                height: 32,
                                width: 32,
                                child: Center(
                                  child: Icon(Icons.copy, size: 18, color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30.0)
          ],
        ),
      ),
    );
  }
}
