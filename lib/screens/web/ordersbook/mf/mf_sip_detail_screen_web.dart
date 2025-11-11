import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/mf_model/sip_mf_list_model.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../res/web_colors.dart';
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
     backgroundColor: WebColors.surface,
      child: Container(
         width: 500,
        height: MediaQuery.of(context).size.height * 0.60,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.60,
        ),
        decoration: BoxDecoration(
          // color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          borderRadius: BorderRadius.circular(5),
          // border: Border.all(
          //   color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          // ),
        ),
        child: Column(
           mainAxisSize: MainAxisSize.min,
          children: [
            // Header
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 16, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Action Buttons - Only show when status is ACTIVE
                    // if (sipData.status?.toUpperCase() == "ACTIVE" || 
                    //     sipData.status?.toUpperCase() == "RUNNING")
                    //   Row(
                    //     children: [
                    //       Expanded(
                    //         child: _buildPauseButton(context, theme),
                    //       ),
                    //       const SizedBox(width: 12),
                    //       Expanded(
                    //         child: _buildCancelSipButton(context, theme),
                    //       ),
                    //     ],
                    //   ),
                    // if (sipData.status?.toUpperCase() == "ACTIVE" || 
                    //     sipData.status?.toUpperCase() == "RUNNING")
                    //   const SizedBox(height: 24),
                    
                    // SIP Details Section
                    _buildSipDetailsSection(context, theme),
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
      style: TextWidget.textStyle(
        fontSize: 16,
        theme: theme.isDarkMode,
        color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
        fw: 1,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSipDetailsSection(BuildContext context, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SIP Details",
          style: TextWidget.textStyle(
            fontSize: 15,
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            fw: 2,
          ),
        ),
        const SizedBox(height: 8),


        _buildInfoRowWithDivider(
          "Status",
          _isActive
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "LIVE",
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      theme: false,
                      color: colors.colorWhite,
                      fw: 2,
                    ),
                  ),
                )
              : (sipData.status ?? '').toUpperCase(),
          theme,
        ),
        
        // SIP Details with dividers
        _buildInfoRowWithDivider(
          "Amount",
          "${sipData.installmentAmount ?? '0.0'}",
          theme,
        ),
        _buildInfoRowWithDivider(
          "Next Due Date",
          sipData.NextSIPDate != null && sipData.NextSIPDate!.isNotEmpty
              ? sipformatDateTime(value: sipData.NextSIPDate!)
              : "-",
          theme,
        ),
        _buildInfoRowWithDivider(
          "Start Date",
          sipData.startDate != null && sipData.startDate!.isNotEmpty
              ? sipformatDateTime(value: sipData.startDate!)
              : "-",
          theme,
        ),
        _buildInfoRowWithDivider(
          "End Date",
          sipData.endDate != null && sipData.endDate!.isNotEmpty
              ? sipformatDateTime(value: sipData.endDate!)
              : "-",
          theme,
        ),
        _buildInfoRowWithDivider(
          "Sip Reg No",
          sipData.sIPRegnNo ?? "-",
          theme,
        ),
        _buildInfoRowWithDivider(
          "Settlement Type",
          sipData.settType ?? "-",
          theme,
        ),
        _buildInfoRowWithDivider(
          "Frequency Type",
          sipData.frequencyType ?? "-",
          theme,
        ),
      ],
    );
  }

  Widget _buildInfoRowWithDivider(
      String title, dynamic value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextWidget.textStyle(
              fontSize: 14,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 1,
            ),
          ),
          value is Widget
              ? value
              : Text(
                  value.toString(),
                  textAlign: TextAlign.end,
                  style: TextWidget.textStyle(
                    fontSize: 14,
                    theme: false,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 1,
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

