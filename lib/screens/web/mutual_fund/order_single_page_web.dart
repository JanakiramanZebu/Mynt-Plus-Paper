// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../provider/transcation_provider.dart';
import '../../../provider/fund_provider.dart';
import '../../../sharedWidget/common_buttons_web.dart';
import 'mf_cancel_alert_web.dart';
import 'mf_order_bottomsheet_web.dart';

class mforderdetscreenWeb extends StatefulWidget {
  const mforderdetscreenWeb({super.key});
  @override
  State<mforderdetscreenWeb> createState() => _mforderdetscreenWebState();
}

class _mforderdetscreenWebState extends State<mforderdetscreenWeb>
    with SingleTickerProviderStateMixin {
  bool _isReinitiateLoading = false;

  @override
  final inProgressStatuses = {
    "PAYMENT NOT INITIATED",
    "MODIFIED",
    "PAYMENT INITATED",
    "PAYMENT INIT",
    "PAYMENT COMPLETED",
    "WAIT FOR ALLOTMENT",
  };
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final theme = ref.watch(themeProvider);
      final mfdata = ref.watch(mfProvider);

      // Check if order data is null
      final hasData = mfdata.mforderdet?.data != null;

      if (!hasData) {
        return const Center(child: NoDataFound(
          secondaryEnabled: false,
        ));
      }

      return SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: theme.isDarkMode ? MyntColors.backgroundColorDark : MyntColors.backgroundColor,
            borderRadius: BorderRadius.circular(0),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order Details",
                          style: MyntWebTextStyles.title(
                            context,
                            color: theme.isDarkMode
                                ? MyntColors.textPrimaryDark
                                : MyntColors.textPrimary,
                            fontWeight: MyntFonts.semiBold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close,
                            color: theme.isDarkMode
                                ? MyntColors.iconDark
                                : MyntColors.icon,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.isDarkMode ? MyntColors.dividerDark : MyntColors.divider,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOrderHeader(theme, mfdata),
                  _buildCancelButton(theme, mfdata, context),
                  _buildReinitiateButton(theme, mfdata, context, ref),
                  const SizedBox(height: 8),
                  _buildDetailsSection(theme, mfdata),
                  const SizedBox(height: 20),
                  if (mfdata.mforderdet?.data![0].status != "PLACED") ...[
                    Text(
                        "Reason",
                        style: MyntWebTextStyles.body(
                        context,
                        color: theme.isDarkMode
                            ? MyntColors.textSecondaryDark
                            : MyntColors.textSecondary,
                        ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        mfdata.mforderdet?.data![0].remarks ??
                            "No remarks available",
                        style: MyntWebTextStyles.body(
                        context,
                        color: theme.isDarkMode
                            ? MyntColors.errorDark
                            : MyntColors.loss,
                        ),
                        maxLines: 3,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  String _getStatusText(String? status) {
    if (status == null) return "Status";
    if (status == "PENDING") return "Pending Reason";
    if (status == "INVALID") return "Reject Reason";
    return "$status Reason";
  }

  Widget _buildOrderHeader(ThemesProvider theme, dynamic mfdata) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  mfdata.mforderdet?.data?[0].name ??
                                      "Unknown Scheme",
                                  style: MyntWebTextStyles.title(
                                  context,
                                  color: theme.isDarkMode
                                      ? MyntColors.textPrimaryDark
                                      : MyntColors.textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(mfdata.mforderdet?.data?[0].status, theme).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Tooltip(
              message: _getListStatusText(mfdata.mforderdet?.data?[0].status),
              child: Text(
                  _getListStatusText(mfdata.mforderdet?.data?[0].status),
                  style: MyntWebTextStyles.para(
                  context,
                  color: _getStatusColor(mfdata.mforderdet?.data?[0].status, theme),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    ]);
  }

  String _getStatusIcon(String? status) {
    if (status == "PLACED") return assets.completedIcon;
    if (status == "NOT PLACED") return assets.cancelledIcon;
    return assets.warningIcon;
  }

  static const _greenStatuses = {
    "ALLOCATED",
    "PAYMENT COMPLETED",
    "PLACED",
  };
  static const _redStatuses = {
    "REJECTED",
    "CANCELLED",
    "PAYMENT DECLINED",
    "PAYMENT REJECTED",
    "CANCEL ERROR",
    "MODIFY REJECTED",
    "INVALID",
  };

  Color _getStatusColor(String? status, ThemesProvider theme) {
    if (_greenStatuses.contains(status)) {
      return theme.isDarkMode ? colors.profitDark : colors.profitLight;
    } else if (_redStatuses.contains(status)) {
      return theme.isDarkMode ? colors.lossDark : colors.lossLight;
    }
    return colors.pending;
  }

  String _getListStatusText(String? status) {
    return status ?? '-';
  }

  Widget _buildDetailsSection(ThemesProvider theme, dynamic mfdata) {
    return Column(
      children: [
        rowOfInfoData(
            "Transaction Type",
            mfdata.mforderdet?.data?[0].buySell == "P"
                ? "Purchase"
                : "Redemption",
            theme),

        rowOfInfoData(
            "Order Type",
            mfdata.mforderdet?.data?[0].orderType == "NRM" ? "Lumpsum" : "SIP",
            theme),

        rowOfInfoData("Amount",
            double.tryParse(mfdata.mforderdet?.data?[0].orderVal?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00', theme),

        // rowOfInfoData(
        //     "Units", "${mfdata.mforderdet?.data?[0].units ?? "0.00"}", theme),
        // const SizedBox(height: 10),

        // rowOfInfoData(
        //     "Date", "${mfdata.mforderdet?.data?[0].datetime ?? "N/A"}", theme),

        rowOfInfoData("Date & Time",
            "${mfdata.mforderdet?.data?[0].datetime ?? "N/A"}", theme),

        rowOfInfoData("Order No",
            "${mfdata.mforderdet?.data?[0].orderId ?? "N/A"}", theme),

        rowOfInfoData(
            "Folio No",
            "${mfdata.mforderdet?.data?[0].folioNo?.isEmpty ?? true ? "---" : mfdata.mforderdet?.data?[0].folioNo}",
            theme),
      ],
    );
  }

  Widget _buildCancelButton(
      ThemesProvider theme, dynamic mfdata, BuildContext context) {
    // Check if we should show the cancel button
    final shouldShowCancel = mfdata.mforderdet?.data?[0].orderType == "NRM" &&
        mfdata.mforderdet?.data?[0].buySell == "R" &&
        mfdata.mforderdet?.data?[0].status == "PENDING";

    if (!shouldShowCancel) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: SizedBox(
        height: 44,
        child: MyntOutlinedButton(
          label: "Cancel Order",
          onPressed: () async {
            if (mfdata.mforderdet?.data != null) {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MfCancelAlertWeb(
                      mfcancel: mfdata.mforderdet!.data!, message: "order");
                },
              );
            }
          },
          isFullWidth: true,
          textColor: resolveThemeColor(context,
              dark: MyntColors.lossDark, light: MyntColors.loss),
        ),
      ),
    );
  }

  Widget _buildReinitiateButton(
      ThemesProvider theme, dynamic mfdata, BuildContext context, WidgetRef ref) {
    final status = mfdata.mforderdet?.data?[0].status;
    final shouldShow = status == 'PAYMENT NOT INITIATED' ||
        status == 'MODIFIED' ||
        status == 'CANCEL ERROR' ||
        status == 'MODIFY REJECTED' ||
        status == 'PAYMENT REJECTED';

    if (!shouldShow) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        height: 44,
        child: MyntPrimaryButton(
          label: "Reinitiate Payment",
          isLoading: _isReinitiateLoading,
          onPressed: _isReinitiateLoading ? () {} : () async {
            setState(() => _isReinitiateLoading = true);

            await ref.read(fundProvider).fetchFunds(context);
            await ref.read(transcationProvider).fetchfundbanks(context);
            ref.read(transcationProvider).initialdata(context);
            await mfdata.fetchUpiDetail('', context);

            if (!context.mounted) return;

            // Save order data before closing
            final orderData = mfdata.mforderdet?.data![0];

            if (mounted) setState(() => _isReinitiateLoading = false);

            // Close the details panel and show payment dialog after it's fully closed
            Navigator.pop(context);

            // Use a short delay to ensure the pop animation completes and context is clean
            await Future.delayed(const Duration(milliseconds: 100));

            final navContext = Navigator.of(context, rootNavigator: true).context;
            if (!navContext.mounted) return;

            showDialog(
              context: navContext,
              barrierDismissible: false,
              builder: (dialogContext) => WillPopScope(
                onWillPop: () async => mfdata.ispaymentcalled != true,
                child: Dialog(
                  insetPadding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(dialogContext).size.width >= 1100
                        ? MediaQuery.of(dialogContext).size.width * 0.30
                        : MediaQuery.of(dialogContext).size.width >= 800
                            ? MediaQuery.of(dialogContext).size.width * 0.50
                            : MediaQuery.of(dialogContext).size.width * 0.90,
                    child: MfOrderBottomsheetWeb(
                      data: orderData,
                      condval: 'reinitiatefromportfolio',
                    ),
                  ),
                ),
              ),
            );
          },
          isFullWidth: true,
        ),
      ),
    );
  }

  Widget rowOfInfoData(String title1, String value1, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode ? MyntColors.dividerDark : MyntColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title1,
              style: MyntWebTextStyles.body(
                context,
                color: theme.isDarkMode
                    ? MyntColors.textSecondaryDark
                    : MyntColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value1,
              style: MyntWebTextStyles.body(
                context,
                color: theme.isDarkMode
                    ? MyntColors.textPrimaryDark
                    : MyntColors.textPrimary,
                fontWeight: MyntFonts.medium,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
