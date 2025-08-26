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
import '../../../sharedWidget/cust_text_formfield.dart';

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

      // Validate basket name length (minimum 2 characters, maximum 20 characters)
      if (trimmedText.length < 2) {
        setState(() => errorText = "Basket name must be at least 2 characters");
        return;
      }

      if (trimmedText.length > 20) {
        setState(() => errorText = "Basket name must be less than 20 characters");
        return;
      }

      // Validate basket name contains only alphanumeric characters, spaces, and basic symbols
      final RegExp validNamePattern = RegExp(r'^[a-zA-Z0-9\s\-_]+$');
      if (!validNamePattern.hasMatch(trimmedText)) {
        setState(() => errorText = "Basket name can only contain letters, numbers, spaces, hyphens and underscores");
        return;
      }

      // Check both user-specific and general basket lists for duplicates
      final userId = pref.clientId;
      List listofBasket = [];
      
      if (userId != null && userId.isNotEmpty) {
        // Check user-specific baskets
        final userBaskets = pref.getBasketListForUser(userId) ?? "";
        if (userBaskets.isNotEmpty) {
          listofBasket = jsonDecode(userBaskets);
        }
      } else {
        // Check general baskets
        final generalBaskets = pref.bsktList ?? "";
        if (generalBaskets.isNotEmpty) {
          listofBasket = jsonDecode(generalBaskets);
        }
      }

      if (listofBasket.isNotEmpty) {
        for (var element in listofBasket) {
          bskt.add(element['bsketName'].toString().toLowerCase());
        }

        if (bskt.contains(trimmedText.toLowerCase())) {
          setState(() => errorText = "Basket name already exists");
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // const CustomDragHandler(),
              Container(
                padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget.titleText(
                      text: 'Create Basket',
                      color : theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
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
                             color:  theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
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
                    SizedBox(
                      height: 45,
                      child: CustomTextFormField(
                        fillColor: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                            autofocus: true,
                        onChanged: (value) {
                          setState(() {
                            if (textCtrl.text.trim().isNotEmpty) {
                              errorText = null;
                            } else {
                              errorText = "Please enter basket name";
                            }
                          });
                        },
                        hintText: "Enter basket name",
                        hintStyle: TextWidget.textStyle(
                            fontSize: 14,
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                        ),
                        keyboardType: TextInputType.text,
                        style: TextWidget.textStyle(
                            fontSize: 16,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            theme: theme.isDarkMode,
                        ),
                        textCtrl: textCtrl,
                        textAlign: TextAlign.start,
                        inputFormate: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9 ]')),
                        ],
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
                      child: OutlinedButton(
                        onPressed: _isProcessing ? null : _handleButton,
                        style: OutlinedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size(0, 45), // width, height
          
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
                                color: colors.colorWhite
                                   ,
                                theme: theme.isDarkMode,
                                fw: 2,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
