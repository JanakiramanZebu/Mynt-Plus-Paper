import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/mf_model/sip_mf_list_model.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../sharedWidget/functions.dart';
import 'sip_pause_dialogue_web.dart';
import 'sip_cancel_dialogue_web.dart';

class MFSipDetailScreenWeb extends ConsumerWidget {
  final Xsip sipData;

  const MFSipDetailScreenWeb({
    super.key,
    required this.sipData,
  });

  bool get _isActive {
    return sipData.status?.toLowerCase() == 'active' || 
           sipData.status?.toLowerCase() == 'running';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 700,
        decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          borderRadius: BorderRadius.circular(5),
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
                  _buildHeader(context, theme),
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
                        padding: const EdgeInsets.all(6),
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
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 0, bottom: 20, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SIP Details Section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _buildSipDetailsSection(context, theme),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemesProvider theme) {
    return Text(
      sipData.name ?? "",
      style: WebTextStyles.dialogTitle(
        isDarkTheme: theme.isDarkMode,
        color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSipDetailsSection(BuildContext context, ThemesProvider theme) {
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    "Status",
                    _isActive
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.isDarkMode ? colors.profitDark : colors.profitLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "LIVE",
                              style: WebTextStyles.tableDataCompact(
                                isDarkTheme: theme.isDarkMode,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : (sipData.status ?? '').toUpperCase(),
                    theme,
                  ),
                  _buildInfoRow(
                    "Amount",
                    "${sipData.installmentAmount ?? '0.0'}",
                    theme,
                  ),
                  _buildInfoRow(
                    "Next Due Date",
                    sipData.NextSIPDate != null && sipData.NextSIPDate!.isNotEmpty
                        ? sipformatDateTime(value: sipData.NextSIPDate!)
                        : "-",
                    theme,
                  ),
                  _buildInfoRow(
                    "Start Date",
                    sipData.startDate != null && sipData.startDate!.isNotEmpty
                        ? sipformatDateTime(value: sipData.startDate!)
                        : "-",
                    theme,
                  ),
                ],
              ),
            ),
            // Vertical divider
            Container(
              width: 0.5,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: theme.isDarkMode
                  ? WebDarkColors.divider
                  : WebColors.divider,
            ),
            // Right column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    "End Date",
                    sipData.endDate != null && sipData.endDate!.isNotEmpty
                        ? sipformatDateTime(value: sipData.endDate!)
                        : "-",
                    theme,
                  ),
                  _buildInfoRow(
                    "Sip Reg No",
                    sipData.sIPRegnNo ?? "-",
                    theme,
                  ),
                  _buildInfoRow(
                    "Settlement Type",
                    sipData.settType ?? "-",
                    theme,
                  ),
                  _buildInfoRow(
                    "Frequency Type",
                    sipData.frequencyType ?? "-",
                    theme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, dynamic value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: WebTextStyles.dialogContent(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
            ),
          ),
          value is Widget
              ? value
              : Text(
                  value.toString(),
                  style: WebTextStyles.dialogContent(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildPauseButton(BuildContext context, ThemesProvider theme) {
    return SizedBox(
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.6) : colors.primaryLight,
            width: 1,
          ),
          color: theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.6) : colors.btnBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
            highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SipPauseDialogueWeb(sipData: sipData);
                },
              );
            },
            child: Center(
              child: Text(
                "Pause",
                style: TextWidget.textStyle(
                  fontSize: 14,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.colorWhite : colors.primaryLight,
                  fw: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelSipButton(BuildContext context, ThemesProvider theme) {
    return SizedBox(
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.6) : colors.primaryLight,
            width: 1,
          ),
          color: theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.6) : colors.btnBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
            highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SipCancelDialogueWeb(sipData: sipData);
                },
              );
            },
            child: Center(
              child: Text(
                "Cancel SIP",
                style: TextWidget.textStyle(
                  fontSize: 14,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.colorWhite : colors.primaryLight,
                  fw: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

