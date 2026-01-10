import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:mynt_plus/screens/Mobile/mutual_fund/mf_cancel_alert.dart';
import 'package:mynt_plus/screens/Mobile/mutual_fund/mf_order_bottomsheet.dart';
import '../../../../models/mf_model/mf_order_det_model.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/fund_provider.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/res.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';

class MFOrderDetailScreenWeb extends ConsumerStatefulWidget {
  final Data mfOrderData;

  const MFOrderDetailScreenWeb({
    super.key,
    required this.mfOrderData,
  });

  @override
  ConsumerState<MFOrderDetailScreenWeb> createState() =>
      _MFOrderDetailScreenWebState();
}

class _MFOrderDetailScreenWebState
    extends ConsumerState<MFOrderDetailScreenWeb> {
  final inProgressStatuses = {
    "PAYMENT NOT INITIATED",
    "MODIFIED",
    "PAYMENT INITATED",
    "PAYMENT INIT",
    "PAYMENT COMPLETED",
    "CANCEL ERROR",
    "WAIT FOR ALLOTMENT",
    "MODIFY REJECTED",
    "PAYMENT REJECTED"
  };

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
                        _buildActionButtons(theme),
                        // Order Details Section
                        _buildOrderDetailsSection(theme, hasButtons: _shouldShowReinitiate() || _shouldShowCancel()),
                        // Reason/Remarks Section
                        if (_shouldShowReason()) ...[
                          const SizedBox(height: 16),
                          _buildReasonSection(theme),
                        ],
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
      widget.mfOrderData.name ?? "Unknown Scheme",
      style: WebTextStyles.dialogTitle(
        isDarkTheme: theme.isDarkMode,
        color: colorScheme.foreground,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Color _getStatusColor() {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    final status = (widget.mfOrderData.status ?? '').toUpperCase();
    
    if (status == "ALLOCATED" || status == "COMPLETED") {
      return colorScheme.chart2;
    } else if (status == "REJECTED" ||
        status == "CANCELLED" ||
        status == "PAYMENT DECLINED") {
      return colorScheme.destructive;
    }
    return colorScheme.chart1;
  }

  String _getStatusText() {
    final status = widget.mfOrderData.status;
    if (status == "ALLOCATED") return 'ALLOCATED';
    if (status == "REJECTED") return 'REJECTED';
    if (status == "CANCELLED") return 'CANCELLED';
    if (status == "PAYMENT DECLINED") return 'PAYMENT DECLINED';
    if (status != null && inProgressStatuses.contains(status)) return status;
    return status ?? 'Unknown';
  }

  bool _shouldShowReinitiate() {
    final status = widget.mfOrderData.status;
    return status == 'PAYMENT NOT INITIATED' ||
        status == 'MODIFIED' ||
        status == 'PAYMENT INITATED' ||
        status == 'PAYMENT INIT' ||
        status == 'PAYMENT COMPLETED' ||
        status == 'CANCEL ERROR' ||
        status == 'WAIT FOR ALLOTMENT' ||
        status == 'MODIFY REJECTED' ||
        status == 'PAYMENT REJECTED';
  }

  bool _shouldShowCancel() {
    final status = widget.mfOrderData.status;
    return widget.mfOrderData.orderType == "NRM" &&
        widget.mfOrderData.buySell == "R" &&
        status == "PENDING";
  }

  bool _shouldShowReason() {
    return widget.mfOrderData.status != "PLACED";
  }

  Widget _buildReinitiateButton(ThemesProvider theme, MFProvider mfdata) {
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
        onPressed: () async {
          ref.read(fundProvider).fetchFunds(context);
          ref.read(transcationProvider).initialdata(context);
          mfdata.fetchUpiDetail('', context);

          shadcn.closeSheet(context);

          _showBottomSheet(
            context,
            MfOrderBottomsheet(
              data: widget.mfOrderData,
              condval: 'reinitiatefromportfolio',
            ),
          );
        },
        shape: shadcn.ButtonShape.rectangle,
        child: Text(
          "Re-Initiate Payment",
          style: WebTextStyles.buttonMd(
            isDarkTheme: theme.isDarkMode,
            color: textColor,
            fontWeight: WebFonts.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelOrderButton(ThemesProvider theme, MFProvider mfdata) {
    if (!_shouldShowCancel()) return const SizedBox.shrink();

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
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return MfCancelAlert(
                mfcancel: widget.mfOrderData,
                message: "order",
              );
            },
          );
        },
        shape: shadcn.ButtonShape.rectangle,
        child: Text(
          "Cancel Order",
          style: WebTextStyles.buttonMd(
            isDarkTheme: theme.isDarkMode,
            color: textColor,
            fontWeight: WebFonts.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailsSection(ThemesProvider theme, {bool hasButtons = false}) {
    return Padding(
      padding: EdgeInsets.only(top: hasButtons ? 12 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            _rowOfInfoDataWithColor(
            "Status",
            _getStatusText(),
            theme,
            _getStatusColor(),
          ),
          _rowOfInfoData(
            "Transaction Type",
            widget.mfOrderData.buySell == "P" ? "Purchase" : "Redemption",
            theme,
          ),
          _rowOfInfoData(
            "Order Type",
            widget.mfOrderData.orderType == "NRM" ? "Lumpsum" : "SIP",
            theme,
          ),
          _rowOfInfoData(
            "Amount",
            widget.mfOrderData.orderVal ?? "0.00",
            theme,
          ),
          _rowOfInfoData(
            "Date & Time",
            widget.mfOrderData.datetime ?? "N/A",
            theme,
          ),
          _rowOfInfoData(
            "Order No",
            widget.mfOrderData.orderId ?? "N/A",
            theme,
          ),
          _rowOfInfoData(
            "Folio No",
            (widget.mfOrderData.folioNo?.isEmpty ?? true)
                ? "---"
                : widget.mfOrderData.folioNo ?? "---",
            theme,
          ),
        
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemesProvider theme) {
    // Check if any buttons should be shown
    if (!_shouldShowReinitiate() && !_shouldShowCancel()) {
      return const SizedBox.shrink();
    }
    
    final mfdata = ref.read(mfProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_shouldShowReinitiate()) ...[
            _buildReinitiateButton(theme, mfdata),
            const SizedBox(height: 12),
          ],
          _buildCancelOrderButton(theme, mfdata),
        ],
      ),
    );
  }

  Widget _buildReasonSection(ThemesProvider theme) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    final reason = widget.mfOrderData.remarks ?? "No remarks available";
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Reason",
          style: WebTextStyles.sub(
            isDarkTheme: theme.isDarkMode,
            color: colorScheme.mutedForeground,
            fontWeight: WebFonts.regular,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          reason,
          style: WebTextStyles.sub(
            isDarkTheme: theme.isDarkMode,
            color: colorScheme.mutedForeground,
            fontWeight: WebFonts.medium,
          ),
        ),
        const SizedBox(height: 16),
      ],
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

  void _showBottomSheet(BuildContext context, Widget bottomSheet) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: colors.colorWhite,
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: bottomSheet,
      ),
    );
  }
}
