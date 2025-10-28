import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/screens/Mobile/mutual_fund/mf_cancel_alert.dart';
import 'package:mynt_plus/screens/Mobile/mutual_fund/mf_order_bottomsheet.dart';
import '../../../../models/mf_model/mf_order_det_model.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/fund_provider.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';


class MFOrderDetailScreenWeb extends ConsumerStatefulWidget {
  final Data mfOrderData;

  const MFOrderDetailScreenWeb({
    super.key,
    required this.mfOrderData,
  });

  @override
  ConsumerState<MFOrderDetailScreenWeb> createState() => _MFOrderDetailScreenWebState();
}

class _MFOrderDetailScreenWebState extends ConsumerState<MFOrderDetailScreenWeb> {
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
    final mfdata = ref.read(mfProvider);

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
            _buildHeader(theme),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Re-Initiate Payment Button (if applicable)
                    if (_shouldShowReinitiate())
                      _buildReinitiateButton(theme, mfdata),
                    
                    if (_shouldShowReinitiate())
                      const SizedBox(height: 24),
                    
                    // Cancel Order Button (if applicable)
                    if (_shouldShowCancel())
                      _buildCancelOrderButton(theme, mfdata),
                    
                    if (_shouldShowCancel())
                      const SizedBox(height: 24),
                    
                    // Order Details Section
                    _buildOrderDetailsSection(theme),
                    
                    // Reason/Remarks Section
                    if (_shouldShowReason()) ...[
                      const SizedBox(height: 24),
                      _buildReasonSection(theme),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemesProvider theme) {
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
              widget.mfOrderData.name ?? "Unknown Scheme",
              style: TextWidget.textStyle(
                fontSize: 18,
                theme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                fw: 1,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 12),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusBadgeColor(theme),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getStatusText(),
              style: TextWidget.textStyle(
                fontSize: 12,
                theme: false,
                color: _getStatusTextColor(theme),
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

  Color _getStatusBadgeColor(ThemesProvider theme) {
    if (widget.mfOrderData.status == "ALLOCATED") {
      return theme.isDarkMode
          ? colors.profitDark.withOpacity(0.1)
          : colors.profitLight.withOpacity(0.1);
    } else if (widget.mfOrderData.status == "REJECTED" ||
        widget.mfOrderData.status == "CANCELLED" ||
        widget.mfOrderData.status == "PAYMENT DECLINED") {
      return theme.isDarkMode
          ? colors.lossDark.withOpacity(0.1)
          : colors.lossLight.withOpacity(0.1);
    }
    return colors.pending.withOpacity(0.1);
  }

  Color _getStatusTextColor(ThemesProvider theme) {
    if (widget.mfOrderData.status == "ALLOCATED") {
      return theme.isDarkMode ? colors.profitDark : colors.profitLight;
    } else if (widget.mfOrderData.status == "REJECTED" ||
        widget.mfOrderData.status == "CANCELLED" ||
        widget.mfOrderData.status == "PAYMENT DECLINED") {
      return theme.isDarkMode ? colors.lossDark : colors.lossLight;
    }
    return colors.pending;
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
    return SizedBox(
      width: double.infinity,
      child: Container(
        height: 50,
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
            onTap: () async {
              ref.read(fundProvider).fetchFunds(context);
              ref.read(transcationProvider).initialdata(context);
              mfdata.fetchUpiDetail('', context);

              Navigator.pop(context);

              _showBottomSheet(
                context,
                MfOrderBottomsheet(
                  data: widget.mfOrderData,
                  condval: 'reinitiatefromportfolio',
                ),
              );
            },
            child: Center(
              child: Text(
                "Re-Initiate Payment",
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

  Widget _buildCancelOrderButton(ThemesProvider theme, MFProvider mfdata) {
    if (!_shouldShowCancel()) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: Container(
        height: 50,
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
            onTap: () async {
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
            child: Center(
              child: Text(
                "Cancel Order",
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

  Widget _buildOrderDetailsSection(ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Order Details",
          style: TextWidget.textStyle(
            fontSize: 16,
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            fw: 3,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRowWithDivider(
          "Transaction Type",
          widget.mfOrderData.buySell == "P" ? "Purchase" : "Redemption",
          theme,
        ),
        _buildInfoRowWithDivider(
          "Order Type",
          widget.mfOrderData.orderType == "NRM" ? "Lumpsum" : "SIP",
          theme,
        ),
        _buildInfoRowWithDivider(
          "Amount",
          "${widget.mfOrderData.orderVal ?? "0.00"}",
          theme,
        ),
        _buildInfoRowWithDivider(
          "Date & Time",
          widget.mfOrderData.datetime ?? "N/A",
          theme,
        ),
        _buildInfoRowWithDivider(
          "Order No",
          widget.mfOrderData.orderId ?? "N/A",
          theme,
        ),
        _buildInfoRowWithDivider(
          "Folio No",
          (widget.mfOrderData.folioNo?.isEmpty ?? true)
              ? "---"
              : widget.mfOrderData.folioNo ?? "---",
          theme,
        ),
      ],
    );
  }

  Widget _buildReasonSection(ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Reason",
          style: TextWidget.textStyle(
            fontSize: 16,
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
            fw: 3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.mfOrderData.remarks ?? "No remarks available",
          style: TextWidget.textStyle(
            fontSize: 14,
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
            fw: 3,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
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

