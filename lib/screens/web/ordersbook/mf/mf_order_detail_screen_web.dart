import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:mynt_plus/screens/Mobile/mutual_fund/mf_cancel_alert.dart';
import '../../../../models/mf_model/mf_order_det_model.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../sharedWidget/common_buttons_web.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Order Details title
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: resolveThemeColor(context,
                    dark: MyntColors.dividerDark, light: MyntColors.divider),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  shadcn.closeSheet(context);
                },
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Order Details',
                style: MyntWebTextStyles.title(
                  context,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFundNameHeader(theme),
                  const SizedBox(height: 16),
                  _buildActionButtons(theme),
                  // Order Details Section
                  _buildOrderDetailsSection(theme,
                      hasButtons: _shouldShowCancel()),
                  // Reason/Remarks Section
                  if (_shouldShowReason()) ...[
                    _buildReasonSection(theme),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFundNameHeader(ThemesProvider theme) {
    return Text(
      widget.mfOrderData.name ?? "Unknown Scheme",
      style: MyntWebTextStyles.title(
        context,
        color: resolveThemeColor(context,
            dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
      ),
      // overflow: TextOverflow.ellipsis, // Allow full name to wrap
    );
  }

  Color _getStatusColor() {
    final status = (widget.mfOrderData.status ?? '').toUpperCase();

    if (status == "ALLOCATED" || status == "COMPLETED") {
      return resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit);
    } else if (status == "REJECTED" ||
        status == "CANCELLED" ||
        status == "PAYMENT DECLINED") {
      return resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
    }
    return resolveThemeColor(context,
        dark: MyntColors.primary, light: MyntColors.primary);
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

  bool _shouldShowCancel() {
    final status = widget.mfOrderData.status;
    return widget.mfOrderData.orderType == "NRM" &&
        widget.mfOrderData.buySell == "R" &&
        status == "PENDING";
  }

  bool _shouldShowReason() {
    return widget.mfOrderData.status != "PLACED";
  }

  Widget _buildCancelOrderButton(ThemesProvider theme, MFProvider mfdata) {
    if (!_shouldShowCancel()) return const SizedBox.shrink();

    return MyntOutlinedButton(
      label: "Cancel Order",
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
    );
  }

  Widget _buildOrderDetailsSection(ThemesProvider theme,
      {bool hasButtons = false}) {
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
    if (!_shouldShowCancel()) {
      return const SizedBox.shrink();
    }

    final mfdata = ref.read(mfProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCancelOrderButton(theme, mfdata),
        ],
      ),
    );
  }

  Widget _buildReasonSection(ThemesProvider theme) {
    final reason = widget.mfOrderData.remarks ?? "No remarks available";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: resolveThemeColor(
              context,
              dark: MyntColors.dividerDark,
              light: MyntColors.divider,
            ),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Reason",
                style: MyntWebTextStyles.body(
                  context,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textPrimaryDark,
                      light: MyntColors.textPrimary),
                  fontWeight: MyntFonts.medium,
                ),
              ),
              // Spacer or Empty for alignment if needed
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reason,
            style: MyntWebTextStyles.body(
              context,
              color: resolveThemeColor(context,
                  dark: MyntColors
                      .lossDark, // Assuming reason is usually an error/rejection
                  light: MyntColors.loss),
              fontWeight: MyntFonts.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowOfInfoData(String title1, String value1, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: resolveThemeColor(
              context,
              dark: MyntColors.dividerDark,
              light: MyntColors.divider,
            ),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title1,
              style: MyntWebTextStyles.body(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary),
                fontWeight: MyntFonts.medium,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value1,
              textAlign: TextAlign.end,
              style: MyntWebTextStyles.body(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary),
                fontWeight: MyntFonts.medium,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowOfInfoDataWithColor(
      String title, String value, ThemesProvider theme, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: resolveThemeColor(
              context,
              dark: MyntColors.dividerDark,
              light: MyntColors.divider,
            ),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: MyntWebTextStyles.body(
                context,
                color: resolveThemeColor(context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary),
                fontWeight: MyntFonts.medium,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: valueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: MyntWebTextStyles.body(
                  context,
                  color: valueColor,
                  fontWeight: MyntFonts.medium,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
