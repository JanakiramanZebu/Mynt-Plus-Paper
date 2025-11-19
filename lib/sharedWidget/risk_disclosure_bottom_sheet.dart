import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/locator/preference.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../locator/locator.dart';
import '../res/global_state_text.dart';
import '../res/web_colors.dart';
import '../res/global_font_web.dart';
import 'functions.dart';
import 'custom_drag_handler.dart';

class RiskDisclousreBottomSheet extends ConsumerWidget {
  const RiskDisclousreBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    final Preferences pref = locator<Preferences>();

    // Check if running on web
    final isWeb = getResponsiveWidth(context) == 600;

    if (isWeb) {
      // Web dialog UI
      return _buildWebDialog(context, theme, pref);
    } else {
      // Mobile bottom sheet UI (existing design)
      return _buildMobileBottomSheet(context, theme, pref);
    }
  }

  Widget _buildWebDialog(
      BuildContext context, ThemesProvider theme, Preferences pref) {
    return Container(
      width: 500,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
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
                  'Risk Disclosures on Derivatives',
                  style: WebTextStyles.dialogTitle(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textPrimary,
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
                    onTap: () {
                      pref.setRiskDiscloser(true);
                      Navigator.of(context).pop();
                    },
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
          // Content
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 16, top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildWebBulletPoint(
                      "9 out of 10 individual traders in the equity Futures and Options (F&O) segment incurred net losses.",
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildWebBulletPoint(
                      "On average, the loss-making traders registered a net trading loss close to ₹50,000.",
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildWebBulletPoint(
                      "Over and above the net trading losses incurred, loss makers expended an additional 28% of net trading losses as transaction costs.",
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildWebBulletPoint(
                      "Those making net trading profits incurred between 15% to 50% of such profits as transaction costs.",
                      theme,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Source: SEBI study dated January 25, 2023, on 'Analysis of Profit and Loss of Individual Traders dealing in equity Futures and Options (F&O) Segment,' wherein Aggregate Level findings are based on annual Profit/Loss incurred by individual traders in equity F&O during FY 2021-22.",
                      style: WebTextStyles.para(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.textSecondary
                            : WebColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
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
                            onTap: () {
                              pref.setRiskDiscloser(true);
                              Navigator.pop(context);
                            },
                            child: Center(
                              child: Text(
                                'I Understand',
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
      ),
    );
  }

  Widget _buildWebBulletPoint(String text, ThemesProvider theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: WebTextStyles.bodySmall(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBottomSheet(
      BuildContext context, ThemesProvider theme, Preferences pref) {
    return SafeArea(
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            border: Border(
              top: BorderSide(
                color: theme.isDarkMode
                    ? colors.textSecondaryDark.withOpacity(0.5)
                    : colors.colorWhite,
              ),
              left: BorderSide(
                color: theme.isDarkMode
                    ? colors.textSecondaryDark.withOpacity(0.5)
                    : colors.colorWhite,
              ),
              right: BorderSide(
                color: theme.isDarkMode
                    ? colors.textSecondaryDark.withOpacity(0.5)
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
                const SizedBox(height: 10),
                Row(children: [
                  TextWidget.titleText(
                    text: '  Risk disclosures on derivatives',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 1,
                    textOverflow: TextOverflow.ellipsis,
                  )
                ]),
                Column(children: [
                  const SizedBox(height: 12),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(Icons.circle,
                            size: 9.5, color: colors.primaryLight)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextWidget.subText(
                      text:
                          "9 out of 10 individual traders in the equity Futures and Options (F&O) segment incurred net losses.",
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                    ))
                  ]),
                  const SizedBox(height: 12),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(Icons.circle,
                            size: 9.5, color: colors.primaryLight)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextWidget.subText(
                      text:
                          "On average, the loss-making traders registered a net trading loss close to ₹50,000.",
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                    ))
                  ]),
                  const SizedBox(height: 12),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.circle,
                            size: 9.5, color: colors.primaryLight)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextWidget.subText(
                      text:
                          "Over and above the net trading losses incurred, loss makers expended an additional 28% of net trading losses as transaction costs.",
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                    ))
                  ]),
                  const SizedBox(height: 12),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.circle,
                            size: 9.5, color: colors.primaryLight)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextWidget.subText(
                      text:
                          "Those making net trading profits incurred between 15% to 50% of such profits as transaction costs.",
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                    ))
                  ]),
                  const SizedBox(height: 12),
                  Text(
                    "Source: SEBI study dated January 25, 2023, on 'Analysis of Profit and Loss of Individual Traders dealing in equity Futures and Options (F&O) Segment,' wherein Aggregate Level findings are based on annual Profit/Loss incurred by individual traders in equity F&O during FY 2021-22.",
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12)
                ]),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () async {
                          pref.setRiskDiscloser(true);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: theme.isDarkMode
                                ? colors.primaryDark
                                : colors.primaryLight,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        child: TextWidget.subText(
                          text: "I Understand",
                          color: colors.colorWhite,
                          theme: theme.isDarkMode,
                          fw: 2,
                        ),
                      )),
                ),
                const SizedBox(height: 14)
              ])),
    );
  }
}
