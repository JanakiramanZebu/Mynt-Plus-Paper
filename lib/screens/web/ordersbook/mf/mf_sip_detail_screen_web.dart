import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../../models/mf_model/sip_mf_list_model.dart';
import '../../../../provider/thems.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../sharedWidget/functions.dart';
import 'sip_pause_dialogue_web.dart';
import 'sip_cancel_dialogue_web.dart';

class MFSipDetailScreenWeb extends ConsumerStatefulWidget {
  final Xsip sipData;

  const MFSipDetailScreenWeb({
    super.key,
    required this.sipData,
  });

  @override
  ConsumerState<MFSipDetailScreenWeb> createState() => _MFSipDetailScreenWebState();
}

class _MFSipDetailScreenWebState extends ConsumerState<MFSipDetailScreenWeb> {
  bool get _isActive {
    return widget.sipData.status?.toLowerCase() == 'active' || 
           widget.sipData.status?.toLowerCase() == 'running';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
            width: 1,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button (fixed)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildHeader(theme),
                    ),
                    shadcn.TextButton(
                      density: shadcn.ButtonDensity.icon,
                      shape: shadcn.ButtonShape.circle,
                      size: shadcn.ButtonSize.normal,
                      child: const Icon(Icons.close),
                      onPressed: () {
                        shadcn.closeSheet(context);
                      },
                    ),
                  ],
                ),
              ),
              // Border divider
              Container(
                height: 1,
                color: shadcn.Theme.of(context).colorScheme.border,
              ),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SIP Details Section
                        _buildSipDetailsSection(theme),
                        // Action Buttons
                        _buildActionButtons(theme),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemesProvider theme) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    return Text(
      widget.sipData.name ?? "",
      style: WebTextStyles.dialogTitle(
        isDarkTheme: theme.isDarkMode,
        color: colorScheme.foreground,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Color _getStatusColor() {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    final status = (widget.sipData.status ?? '').toLowerCase();
    
    if (status == 'active' || status == 'running' || status == 'live') {
      return colorScheme.chart2;
    } else if (status == 'stopped' || status == 'cancelled' || status == 'rejected') {
      return colorScheme.destructive;
    } else {
      return colorScheme.chart1;
    }
  }

  Widget _buildSipDetailsSection(ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowOfInfoDataWithColor(
            "Status",
            _isActive ? "LIVE" : (widget.sipData.status ?? '').toUpperCase(),
            theme,
            _getStatusColor(),
          ),
          _rowOfInfoData(
            "Amount",
            widget.sipData.installmentAmount ?? '0.0',
            theme,
          ),
          _rowOfInfoData(
            "Next Due Date",
            widget.sipData.NextSIPDate != null && widget.sipData.NextSIPDate!.isNotEmpty
                ? sipformatDateTime(value: widget.sipData.NextSIPDate!)
                : "-",
            theme,
          ),
          _rowOfInfoData(
            "Start Date",
            widget.sipData.startDate != null && widget.sipData.startDate!.isNotEmpty
                ? sipformatDateTime(value: widget.sipData.startDate!)
                : "-",
            theme,
          ),
          _rowOfInfoData(
            "End Date",
            widget.sipData.endDate != null && widget.sipData.endDate!.isNotEmpty
                ? sipformatDateTime(value: widget.sipData.endDate!)
                : "-",
            theme,
          ),
          _rowOfInfoData(
            "Sip Reg No",
            widget.sipData.sIPRegnNo ?? "-",
            theme,
          ),
          _rowOfInfoData(
            "Settlement Type",
            widget.sipData.settType ?? "-",
            theme,
          ),
          _rowOfInfoData(
            "Frequency Type",
            widget.sipData.frequencyType ?? "-",
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemesProvider theme) {
    // Check if any buttons should be shown
    if (!_isActive) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPauseButton(theme),
          const SizedBox(height: 12),
          _buildCancelSipButton(theme),
        ],
      ),
    );
  }

  Widget _rowOfInfoData(String title1, String value1, ThemesProvider theme) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title1,
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: colorScheme.mutedForeground,
                fontWeight: WebFonts.regular,
              ),
            ),
            Text(
              value1,
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: colorScheme.mutedForeground,
                fontWeight: WebFonts.medium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _rowOfInfoDataWithColor(String title, String value, ThemesProvider theme, Color valueColor) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: colorScheme.mutedForeground,
                fontWeight: WebFonts.regular,
              ),
            ),
            Text(
              value,
              style: WebTextStyles.sub(
                isDarkTheme: theme.isDarkMode,
                color: valueColor,
                fontWeight: WebFonts.medium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPauseButton(ThemesProvider theme) {
    final backgroundColor = theme.isDarkMode
        ? WebDarkColors.textSecondary.withOpacity(0.6)
        : WebColors.buttonSecondary;
    final textColor = theme.isDarkMode ? Colors.white : WebColors.primaryLight;
    final borderColor = theme.isDarkMode ? WebDarkColors.primaryLight : WebColors.primaryLight;
    
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: shadcn.TextButton(
        size: shadcn.ButtonSize.large,
        density: shadcn.ButtonDensity.dense,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SipPauseDialogueWeb(sipData: widget.sipData);
            },
          );
        },
        shape: shadcn.ButtonShape.rectangle,
        child: Text(
          "Pause",
          style: WebTextStyles.buttonMd(
            isDarkTheme: theme.isDarkMode,
            color: textColor,
            fontWeight: WebFonts.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelSipButton(ThemesProvider theme) {
    final backgroundColor = theme.isDarkMode
        ? WebDarkColors.textSecondary.withOpacity(0.6)
        : WebColors.buttonSecondary;
    final textColor = theme.isDarkMode ? Colors.white : WebColors.primaryLight;
    final borderColor = theme.isDarkMode ? WebDarkColors.primaryLight : WebColors.primaryLight;
    
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: shadcn.TextButton(
        size: shadcn.ButtonSize.large,
        density: shadcn.ButtonDensity.dense,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SipCancelDialogueWeb(sipData: widget.sipData);
            },
          );
        },
        shape: shadcn.ButtonShape.rectangle,
        child: Text(
          "Cancel SIP",
          style: WebTextStyles.buttonMd(
            isDarkTheme: theme.isDarkMode,
            color: textColor,
            fontWeight: WebFonts.bold,
          ),
        ),
      ),
    );
  }
}
