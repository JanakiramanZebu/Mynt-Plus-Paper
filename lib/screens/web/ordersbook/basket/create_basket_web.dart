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
      children: [
        // Header with close button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: const EdgeInsets.only(bottom: 8),
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
                style: WebTextStyles.dialogTitle(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
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
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.close,
                      size: 20,
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
        Flexible(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Basket Name Label
                  Text(
                    "Basket Name",
                    style: WebTextStyles.formLabel(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Basket Name Input
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
                      hintStyle: WebTextStyles.helperText(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.textSecondary
                            : WebColors.textSecondary,
                      ),
                      keyboardType: TextInputType.text,
                      style: WebTextStyles.formInput(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textSecondary,
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
                  // Error Text
                  if (errorText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorText!,
                      style: WebTextStyles.helperText(
                        isDarkTheme: theme.isDarkMode,
                        color: WebDarkColors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(5),
                          splashColor: Colors.white.withOpacity(0.2),
                          highlightColor: Colors.white.withOpacity(0.1),
                          onTap: _isProcessing ? null : _handleButton,
                          child: Center(
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
                                    'Create Basket',
                                    style: WebTextStyles.buttonMd(
                                      isDarkTheme: theme.isDarkMode,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
