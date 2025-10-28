import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/mf_model/sip_mf_list_model.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
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
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          ),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(context, theme),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildPauseButton(context, theme),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCancelSipButton(context, theme),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              sipData.name ?? "",
              style: TextWidget.textStyle(
                fontSize: 18,
                theme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                fw: 1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          // LIVE badge
          if (_isActive)
            Container(
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
            ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSipDetailsSection(BuildContext context, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SIP Details with dividers
        _buildInfoRowWithDivider(
          "SIP Register Date",
          sipformatDateTime(value: sipData.sIPRegnDate ?? ""),
          theme,
        ),
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

  Widget _buildInfoRowWithDivider(String title, String value, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextWidget.textStyle(
                fontSize: 14,
                theme: false,
                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                fw: 3,
              ),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextWidget.textStyle(
                  fontSize: 14,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  fw: 3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(
          thickness: 0.5,
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ],
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

