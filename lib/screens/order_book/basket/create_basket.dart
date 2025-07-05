import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import '../../../locator/locator.dart';
import '../../../locator/preference.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';

class CreateBasket extends ConsumerStatefulWidget {
  const CreateBasket({super.key});

  @override
  ConsumerState<CreateBasket> createState() => _CreateBasketState();
}

class _CreateBasketState extends ConsumerState<CreateBasket> {
  final Preferences pref = locator<Preferences>();

  TextEditingController textCtrl = TextEditingController();
  String? errorText;

  bool _isProcessing = false;

  Future<void> _handleButton() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final trimmedText = textCtrl.text.trim();
    final List<String> bskt = [];

    try {
      if (trimmedText.isEmpty) {
        setState(() => errorText = "Please enter basket name");
        return;
      }

      final List listofBasket =
          pref.bsktList!.isEmpty ? [] : jsonDecode(pref.bsktList ?? '[]');

      if (listofBasket.isNotEmpty) {
        for (var element in listofBasket) {
          bskt.add(element['bsketName'].toString().toLowerCase());
        }

        if (bskt.contains(trimmedText.toLowerCase())) {
          setState(() => errorText = "Basket name already exist");
          return;
        }
      }

      setState(() => errorText = "");

      await ref.read(orderProvider).createBasketOrder(trimmedText, context);
    } catch (e) {
      setState(() => errorText = "An error occurred. Please try again.");
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.isDarkMode ? Colors.black : Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color(0xff999999),
              blurRadius: 4.0,
              offset: Offset(2.0, 0.0),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomDragHandler(),
            Container(
              padding: const EdgeInsets.only(left: 16.0, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.titleText(
                    text: 'Create Basket',
                    theme: theme.isDarkMode,
                    fw: 1,
                  ),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 150));
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(20),
                      splashColor: theme.isDarkMode
                          ? Colors.white.withOpacity(0.15)
                          : Colors.black.withOpacity(0.15),
                      highlightColor: theme.isDarkMode
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: theme.isDarkMode
                              ? const Color(0xffBDBDBD)
                              : colors.colorGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
              height: 0,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.isDarkMode
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFEEEEEE),
                        width: 1,
                      ),
                    ),
                    child: TextFormField(
                      controller: textCtrl,
                      autofocus: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9 ]')),
                      ],
                      style: TextWidget.textStyle(
                        fontSize: 14,
                        theme: theme.isDarkMode,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter basket name",
                        hintStyle: TextWidget.textStyle(
                          fontSize: 14,
                          color: const Color(0xff666666),
                          theme: theme.isDarkMode,
                          fw: 0,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isCollapsed: false,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: (value) {
                        setState(() {
                          if (textCtrl.text.trim().isNotEmpty) {
                            errorText = null;
                          } else {
                            errorText = "Please enter basket name";
                          }
                        });
                      },
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextWidget.captionText(
                        text: errorText!,
                        color: colors.darkred,
                        theme: theme.isDarkMode,
                        fw: 0,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handleButton,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size(0, 40), // width, height

                        backgroundColor: colors.btnOutlinedBorder,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: (_isProcessing)
                          ? const SizedBox(
                              width: 18,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Color(0xff666666)),
                            )
                          : TextWidget.subText(
                              text: "Create",
                              color: !theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              theme: theme.isDarkMode,
                              fw: 0,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
