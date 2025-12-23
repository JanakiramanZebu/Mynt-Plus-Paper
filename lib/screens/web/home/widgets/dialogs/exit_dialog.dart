import 'package:flutter/material.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/res/global_font_web.dart';

class ExitDialog {
  static Future<bool> show(BuildContext context, bool isDarkMode) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: isDarkMode
                  ? WebDarkColors.surface
                  : WebColors.backgroundTertiary,
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              scrollable: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              actionsPadding: const EdgeInsets.only(
                  bottom: 16, right: 16, left: 16, top: 8),
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () async {
                            await Future.delayed(
                                const Duration(milliseconds: 150));
                            Navigator.of(context).pop(false);
                          },
                          borderRadius: BorderRadius.circular(20),
                          splashColor: isDarkMode
                              ? WebDarkColors.primary.withOpacity(0.1)
                              : WebColors.primary.withOpacity(0.1),
                          highlightColor: isDarkMode
                              ? WebDarkColors.primary.withOpacity(0.05)
                              : WebColors.primary.withOpacity(0.05),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.close_rounded,
                              size: 22,
                              color: isDarkMode
                                  ? WebDarkColors.iconSecondary
                                  : WebColors.iconSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        "Do you want to Exit the App?",
                        style: WebTextStyles.sub(
                          isDarkTheme: isDarkMode,
                          color: isDarkMode
                              ? WebDarkColors.textSecondary
                              : WebColors.textPrimary,
                          fontWeight: WebFonts.regular,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 45),
                      side: BorderSide(
                          color: isDarkMode
                              ? WebDarkColors.border
                              : WebColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: isDarkMode
                          ? WebDarkColors.primary
                          : WebColors.primary,
                    ),
                    child: Text(
                      "Exit",
                      style: WebTextStyles.title(
                        isDarkTheme: isDarkMode,
                        color: WebDarkColors.textPrimary,
                        fontWeight: WebFonts.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
