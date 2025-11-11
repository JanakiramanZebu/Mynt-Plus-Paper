import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/order_provider.dart';

import '../../../../locator/locator.dart';
import '../../../../locator/preference.dart';
import '../../../../provider/thems.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../sharedWidget/cust_text_formfield.dart';

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.isDarkMode
                    ? WebDarkColors.divider
                    : WebColors.divider,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Basket',
                style: WebTextStyles.sub(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: theme.isDarkMode
                      ? Colors.white.withOpacity(.15)
                      : Colors.black.withOpacity(.15),
                  highlightColor: theme.isDarkMode
                      ? Colors.white.withOpacity(.08)
                      : Colors.black.withOpacity(.08),
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: theme.isDarkMode
                          ? WebDarkColors.iconSecondary
                          : WebColors.iconSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: CustomTextFormField(
                  fillColor: theme.isDarkMode
                      ? WebDarkColors.backgroundTertiary
                      : WebColors.backgroundTertiary,
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
                  hintStyle: WebTextStyles.custom(
                    fontSize: 13,
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textSecondary
                        : WebColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  keyboardType: TextInputType.text,
                  style: WebTextStyles.custom(
                    fontSize: 13,
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textCtrl: textCtrl,
                  textAlign: TextAlign.start,
                  autofocus: true,
                  inputFormate: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z0-9 ]'),
                    ),
                  ],
                ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    errorText!,
                    style: WebTextStyles.custom(
                      fontSize: 12,
                      isDarkTheme: theme.isDarkMode,
                      color: WebDarkColors.loss,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handleButton,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.isDarkMode
                        ? WebDarkColors.primary
                        : WebColors.primary,
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Create',
                          style: WebTextStyles.custom(
                            fontSize: 13,
                            isDarkTheme: theme.isDarkMode,
                            color: WebColors.surface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
