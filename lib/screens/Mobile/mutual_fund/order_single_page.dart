// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../../provider/fund_provider.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/res.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../res/mynt_web_text_styles.dart';
import 'mf_cancel_alert.dart';
import 'mf_order_bottomsheet.dart';

class mforderdetscreen extends StatefulWidget {
  const mforderdetscreen({super.key});
  @override
  State<mforderdetscreen> createState() => _mforderdetscreen();
}

class _mforderdetscreen extends State<mforderdetscreen>
    with SingleTickerProviderStateMixin {
  @override
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
            borderRadius: BorderRadius.circular(16),
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
                  const SizedBox(height: 18),
                  if (mfdata.mforderdet?.data![0].status ==
                          'PAYMENT NOT INITIATED' ||
                      mfdata.mforderdet?.data![0].status == 'MODIFIED' ||
                      mfdata.mforderdet?.data![0].status ==
                          'CANCEL ERROR' ||
                      mfdata.mforderdet?.data![0].status ==
                          'MODIFY REJECTED' ||
                      mfdata.mforderdet?.data![0].status ==
                          'PAYMENT REJECTED')
                    ElevatedButton(
                      onPressed: () async {
                        ref.read(fundProvider).fetchFunds(context);
                        ref.read(transcationProvider).initialdata(context);
                        mfdata.fetchUpiDetail('', context);

                        // final isUpi = mfdata.paymentName == 'UPI';
                        // final isNetBanking =
                        //     mfdata.paymentName == 'NET BANKING';
                        // final isUpiValid =
                        //     isUpi ? mfdata.upiError == '' : true;

                        Navigator.pop(context);
                        _showBottomSheet(
                            context,
                            MfOrderBottomsheet(
                              data: mfdata.mforderdet?.data![0],
                              condval: 'reinitiatefromportfolio',
                            ));
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: MyntColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(
                            double.infinity, 45), // height: 48
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                          "Re-Initiate Payment",
                          style: MyntWebTextStyles.buttonXl(context, color: Colors.white),
                        ),
                    ),
                  const SizedBox(height: 18),
                  _buildCancelButton(theme, mfdata, context),
                  const SizedBox(height: 24),
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
                            ? MyntColors.lossDark
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
              color: mfdata.mforderdet?.data?[0].status == "ALLOCATED"
                  ? theme.isDarkMode
                      ? MyntColors.profitDark.withOpacity(0.1)
                      : MyntColors.profit.withOpacity(0.1)
                  : mfdata.mforderdet?.data?[0].status == "REJECTED" ||
                          mfdata.mforderdet?.data?[0].status == "CANCELLED" ||
                          mfdata.mforderdet?.data?[0].status ==
                              "PAYMENT DECLINED"
                      ? theme.isDarkMode
                          ? MyntColors.lossDark.withOpacity(0.1)
                          : MyntColors.loss.withOpacity(0.1)
                      : mfdata.mforderdet?.data?[0].status ==
                              inProgressStatuses
                                  .contains(mfdata.mforderdet?.data?[0].status)
                          ? MyntColors.pending.withOpacity(0.1)
                          : MyntColors.pending.withOpacity(0.1), // default fallback
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
                _getListStatusText(mfdata.mforderdet?.data?[0].status),
                style: MyntWebTextStyles.para(
                context,
                color: mfdata.mforderdet?.data?[0].status == "ALLOCATED"
                    ? theme.isDarkMode
                        ? MyntColors.profitDark
                        : MyntColors.profit
                    : mfdata.mforderdet?.data?[0].status == "REJECTED" ||
                            mfdata.mforderdet?.data?[0].status == "CANCELLED" ||
                            mfdata.mforderdet?.data?[0].status ==
                                "PAYMENT DECLINED"
                        ? theme.isDarkMode
                            ? MyntColors.lossDark
                            : MyntColors.loss
                        : mfdata.mforderdet?.data?[0].status ==
                                inProgressStatuses.contains(
                                    mfdata.mforderdet?.data?[0].status)
                            ? MyntColors.pending
                            : MyntColors.pending,
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

  String _getListStatusText(String? status) {
    if (status == "ALLOCATED") return 'ALLOCATED';
    if (status == "REJECTED") return 'REJECTED';
    if (status == "CANCELLED") return 'CANCELLED';
    if (status == "PAYMENT DECLINED") return 'PAYMENT DECLINED';
    if (status != null && inProgressStatuses.contains(status)) return status;

    return status ?? 'Unknown';
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

    if (!shouldShowCancel) return const SizedBox();

    return Row(
      children: [
        Expanded(
          flex: 6,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (mfdata.mforderdet?.data != null) {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return MfCancelAlert(
                          mfcancel: mfdata.mforderdet!.data!, message: "order");
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: theme.isDarkMode
                          ? MyntColors.textSecondaryDark.withOpacity(0.6)
                          : MyntColors.primary,
                      // foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      side: theme.isDarkMode
                          ? null
                          : BorderSide(
                              color: MyntColors.primary,
                              width: 1,
                            ),
                minimumSize: const Size(double.infinity, 40), // height: 48
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                          "Cancel Order",
                          style: MyntWebTextStyles.buttonXl(context, color: Colors.white)
                      ),
            ),
          ),
        ),
      ],
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

_showBottomSheet(BuildContext context, Widget bottomSheet) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width >= 1100
            ? MediaQuery.of(context).size.width * 0.25
            : MediaQuery.of(context).size.width * 0.90,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: bottomSheet,
      ),
    ),
  );
}
