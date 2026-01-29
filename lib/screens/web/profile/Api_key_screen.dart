import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/api_key_provider.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'package:share_plus/share_plus.dart';

class ApiKeyScreen extends ConsumerStatefulWidget {
  const ApiKeyScreen({
    super.key,
  });

  @override
  ConsumerState<ApiKeyScreen> createState() => _TotpScreenState();
}

class _TotpScreenState extends ConsumerState<ApiKeyScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// Calculate days remaining until expiry
  String _getDaysRemaining(String? exd) {
    if (exd == null || exd.isEmpty) return "";
    try {
      final expiryTimestamp = int.parse(exd) * 1000;
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      final now = DateTime.now();
      final difference = expiryDate.difference(now).inDays;
      return "($difference days)";
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final apikeys = ref.watch(apikeyprovider);

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          color: resolveThemeColor(context,
              dark: MyntColors.backgroundColorDark,
              light: MyntColors.backgroundColor),
          border: Border(
            top: BorderSide(
              color: resolveThemeColor(context,
                  dark: MyntColors.dividerDark,
                  light: MyntColors.backgroundColor),
            ),
            left: BorderSide(
              color: resolveThemeColor(context,
                  dark: MyntColors.dividerDark,
                  light: MyntColors.backgroundColor),
            ),
            right: BorderSide(
              color: resolveThemeColor(context,
                  dark: MyntColors.dividerDark,
                  light: MyntColors.backgroundColor),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),
                  // API Key Info Section (Generate API, Expire date, Vendor code)
                  if (apikeys.apikeyres != null && apikeys.apikeyres!.apistatus != "NOT_PRESENT") ...[
                    _buildInfoRow(
                      'Generate API',
                      apikeys.apikeyres!.apistatus ?? '--',
                      isStatus: true,
                      statusColor: apikeys.apikeyres!.apistatus == "VALID"
                          ? MyntColors.profit
                          : MyntColors.loss,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Expire date',
                      '${readTimestamp(int.parse("${apikeys.apikeyres!.exd}000"))} ${_getDaysRemaining(apikeys.apikeyres!.exd)}',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Vender code(vc)',
                      apikeys.apikeyres!.uid ?? '--',
                    ),
                    const SizedBox(height: 16),
                  ],
                  apikeys.apikeyres!.apistatus == "NOT_PRESENT"
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "It looks like you haven't created an API key yet. Click below to generate your first key and get started.",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: MyntWebTextStyles.bodySmall(context,
                                          darkColor: MyntColors.textPrimaryDark,
                                          lightColor: MyntColors.textPrimary),
                                    ),
                                    const SizedBox(height: 8.0),
                                  ],
                                ),
                                const SizedBox(height: 16.0),
                                SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await ref
                                          .read(apikeyprovider)
                                          .fetchgenerateapikey(context, "1 year",
                                              apikeys.apikeyres!.apistatus ?? "");
                                      await ref
                                          .read(apikeyprovider)
                                          .fetchapikey(context);

                                      Clipboard.setData(ClipboardData(
                                          text: "${apikeys.apikeyres!.apikey}"));
                                      successMessage(context,
                                          'API Key has been ${apikeys.generateApikey?.status} and copied');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: MyntColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      "Generate API Key",
                                      style: MyntWebTextStyles.bodySmall(context,
                                          color: Colors.white,
                                          fontWeight: MyntFonts.semiBold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox(),
                  apikeys.apikeyres!.apistatus != "NOT_PRESENT"
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'API Key',
                                  style: MyntWebTextStyles.bodySmall(context,
                                      darkColor: MyntColors.textPrimaryDark,
                                      lightColor: MyntColors.textPrimary,
                                      fontWeight: MyntFonts.medium),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      readTimestamp(int.parse(
                                          "${apikeys.apikeyres!.exd}000")),
                                      style: MyntWebTextStyles.para(context,
                                          darkColor: MyntColors.textSecondaryDark,
                                          lightColor: MyntColors.textSecondary),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: apikeys.apikeyres!.apistatus ==
                                                  "VALID"
                                              ? resolveThemeColor(context,
                                                  dark: MyntColors.profit
                                                      .withValues(alpha: 0.2),
                                                  light: MyntColors.profit
                                                      .withValues(alpha: 0.2))
                                              : resolveThemeColor(context,
                                                  dark: MyntColors.loss
                                                      .withValues(alpha: 0.2),
                                                  light: MyntColors.loss
                                                      .withValues(alpha: 0.2)),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          child: Text(
                                            "${apikeys.apikeyres!.apistatus}",
                                            style: MyntWebTextStyles.caption(
                                                context,
                                                color: apikeys.apikeyres!
                                                            .apistatus ==
                                                        "VALID"
                                                    ? MyntColors.profit
                                                    : MyntColors.loss,
                                                fontWeight: MyntFonts.medium),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Container(
                              decoration: BoxDecoration(
                                color: resolveThemeColor(context,
                                    dark: MyntColors.listItemBgDark,
                                    light: MyntColors.listItemBg),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: MyntColors.primary,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        apikeys.hidePass
                                            ? "•" *
                                                apikeys.apikeyres!.apikey!.length
                                            : "${apikeys.apikeyres!.apikey}",
                                        overflow: TextOverflow.ellipsis,
                                        style: MyntWebTextStyles.para(context,
                                            darkColor: MyntColors.textPrimaryDark,
                                            lightColor: MyntColors.textPrimary),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        _buildIconButton(
                                          icon: apikeys.hidePass
                                              ? "assets/icon/eye-off.svg"
                                              : "assets/icon/eye.svg",
                                          onTap: () => apikeys.hiddenPass(),
                                          useSvg: true,
                                        ),
                                        const SizedBox(width: 4),
                                        _buildIconButton(
                                          iconData: Icons.share_outlined,
                                          onTap: () async {
                                            await Future.delayed(
                                                const Duration(milliseconds: 150));
                                            await Share.share(
                                              "API Key\n${apikeys.apikeyres!.apikey}",
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 4),
                                        _buildIconButton(
                                          iconData: Icons.copy,
                                          onTap: () async {
                                            await Future.delayed(
                                                const Duration(milliseconds: 150));
                                            Clipboard.setData(ClipboardData(
                                                text:
                                                    "${apikeys.apikeyres!.apikey}"));
                                            successMessage(context,
                                                "Auth key copied to clipboard");
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                  const SizedBox(height: 18.0),
                  apikeys.apikeyres!.apistatus != "NOT_PRESENT" &&
                              apikeys.apikeyres!.apistatus != "VALID" ||
                          apikeys.apikeyres!.apistatus == "EXPIRED"
                      ? SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async {
                              await ref
                                  .read(apikeyprovider)
                                  .fetchgenerateapikey(context, "1 year",
                                      apikeys.apikeyres!.apistatus ?? "");
                              await ref.read(apikeyprovider).fetchapikey(context);
                              await Future.delayed(
                                  const Duration(milliseconds: 50));

                              if (apikeys.apikeyres?.apikey != null) {
                                Clipboard.setData(ClipboardData(
                                    text: "${apikeys.apikeyres!.apikey}"));
                                successMessage(context,
                                    'API Key has been ${apikeys.generateApikey?.status} and copied');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: MyntColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Generate API Key",
                              style: MyntWebTextStyles.bodySmall(context,
                                  color: Colors.white,
                                  fontWeight: MyntFonts.semiBold),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            const SizedBox(height: 30.0)
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    String? icon,
    IconData? iconData,
    required VoidCallback onTap,
    bool useSvg = false,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        customBorder: const CircleBorder(),
        splashColor: resolveThemeColor(context,
            dark: MyntColors.rippleDark, light: MyntColors.rippleLight),
        highlightColor: resolveThemeColor(context,
            dark: MyntColors.highlightDark, light: MyntColors.highlightLight),
        onTap: onTap,
        child: Container(
          height: 32,
          width: 32,
          padding: const EdgeInsets.all(6),
          child: Center(
            child: useSvg && icon != null
                ? SvgPicture.asset(
                    icon,
                    width: 18,
                    colorFilter: ColorFilter.mode(
                      resolveThemeColor(context,
                          dark: MyntColors.textSecondaryDark,
                          light: MyntColors.textSecondary),
                      BlendMode.srcIn,
                    ),
                  )
                : Icon(
                    iconData,
                    size: 18,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false, Color? statusColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: MyntWebTextStyles.para(context,
                darkColor: MyntColors.textSecondaryDark,
                lightColor: MyntColors.textSecondary),
          ),
        ),
        Text(
          ':  ',
          style: MyntWebTextStyles.para(context,
              darkColor: MyntColors.textSecondaryDark,
              lightColor: MyntColors.textSecondary),
        ),
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (statusColor ?? MyntColors.profit).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: MyntWebTextStyles.para(context,
                  color: statusColor ?? MyntColors.profit,
                  fontWeight: MyntFonts.medium),
            ),
          )
        else
          Text(
            value,
            style: MyntWebTextStyles.para(context,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary),
          ),
      ],
    );
  }
}
