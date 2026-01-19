import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../../models/mf_model/sip_mf_list_model.dart';
import '../../../../provider/thems.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/common_buttons_web.dart';
import 'sip_pause_dialogue_web.dart';
import 'sip_cancel_dialogue_web.dart';

class MFSipDetailScreenWeb extends ConsumerStatefulWidget {
  final Xsip sipData;

  const MFSipDetailScreenWeb({
    super.key,
    required this.sipData,
  });

  @override
  ConsumerState<MFSipDetailScreenWeb> createState() =>
      _MFSipDetailScreenWebState();
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
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildHeader(theme),
                    ),
                    MyntCloseButton(
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
                color: resolveThemeColor(context,
                    dark: MyntColors.dividerDark, light: MyntColors.divider),
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
    return Text(
      widget.sipData.name ?? "",
      style: MyntWebTextStyles.title(
        context,
        color: resolveThemeColor(context,
            dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Color _getStatusColor() {
    final status = (widget.sipData.status ?? '').toLowerCase();

    if (status == 'active' || status == 'running' || status == 'live') {
      return resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit);
    } else if (status == 'stopped' ||
        status == 'cancelled' ||
        status == 'rejected') {
      return resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
    } else {
      return resolveThemeColor(context,
          dark: MyntColors.primary, light: MyntColors.primary);
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
            widget.sipData.NextSIPDate != null &&
                    widget.sipData.NextSIPDate!.isNotEmpty
                ? sipformatDateTime(value: widget.sipData.NextSIPDate!)
                : "-",
            theme,
          ),
          _rowOfInfoData(
            "Start Date",
            widget.sipData.startDate != null &&
                    widget.sipData.startDate!.isNotEmpty
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title1,
              style: MyntWebTextStyles.bodySmall(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
                fontWeight: MyntFonts.regular,
              ),
            ),
            Text(
              value1,
              style: MyntWebTextStyles.bodySmall(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary),
                fontWeight: MyntFonts.medium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _rowOfInfoDataWithColor(
      String title, String value, ThemesProvider theme, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: MyntWebTextStyles.bodySmall(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
                fontWeight: MyntFonts.regular,
              ),
            ),
            Text(
              value,
              style: MyntWebTextStyles.bodySmall(
                context,
                color: valueColor,
                fontWeight: MyntFonts.medium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPauseButton(ThemesProvider theme) {
    return MyntOutlinedButton(
      label: "Pause",
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SipPauseDialogueWeb(sipData: widget.sipData);
          },
        );
      },
    );
  }

  Widget _buildCancelSipButton(ThemesProvider theme) {
    return MyntOutlinedButton(
      label: "Cancel SIP",
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SipCancelDialogueWeb(sipData: widget.sipData);
          },
        );
      },
    );
  }
}
