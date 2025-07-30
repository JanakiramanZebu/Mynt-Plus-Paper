// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/screens/mutual_fund/mf_timeline.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/ipo_time_line.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_exch_badge.dart';
// import '../../sharedWidget/loader_ui.dart';
import '../../sharedWidget/loader_ui.dart';
import '../mutual_fund_old/cancle_xsip_resone.dart';
// import '../mutual_fund_old/mf_order_filter_sheet.dart';
import '../portfolio_screens/mfHoldings/mf_holding_screen.dart';
import '../mutual_fund/mf_cancel_alert.dart';

class mforderdetscreen extends StatefulWidget {
  const mforderdetscreen({super.key});
  @override
  State<mforderdetscreen> createState() => _mforderdetscreen();
}

class _mforderdetscreen extends State<mforderdetscreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.05,
        maxChildSize: 0.99,
        builder: (context, scrollController) {
          return Consumer(builder: (context, ref, child) {
            final theme = ref.watch(themeProvider);
            final mfdata = ref.watch(mfProvider);

            // Check if order data is null
            final hasData = mfdata.mforderdet?.data != null;

            return Scaffold(
                 backgroundColor: Colors.transparent,
              body: hasData
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Expanded(
                        child: SingleChildScrollView(
                           controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOrderHeader(theme, mfdata),
                              const SizedBox(height: 18),
                              _buildCancelButton(theme, mfdata, context),
                            const SizedBox(height: 24),
                              _buildDetailsSection(theme, mfdata),
                              const SizedBox(height: 20),
                              if (mfdata.mforderdet?.data![0].status !=
                                  "PLACED") ...[
                                      TextWidget.subText(
              align: TextAlign.right,
              text: "Reason",
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              fw: 3),
                              
                                const SizedBox(height: 8),
                                TextWidget.subText(
                                    align: TextAlign.start,
                                    text:
                                        "${mfdata.mforderdet?.data![0].remarks ?? "No remarks available"}",
                                    color: colors.loss,
                                    textOverflow: TextOverflow.ellipsis,
                                    theme: theme.isDarkMode,
                                    maxLines: 3,
                                    fw: 3),
                              ],
                            ],
                          ),
                        ),
                      ),
                    )
                  : const Center(child: NoDataFound()),
            );
          });
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
      const SizedBox(width: 0),
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
                              TextWidget.titleText(
                                  align: TextAlign.start,
                                  text: mfdata.mforderdet?.data?[0].name ??
                                      "Unknown Scheme",
                                  color: theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                  textOverflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  theme: theme.isDarkMode,
                                  fw: 1),
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
              color:mfdata.mforderdet?.data?[0].status == "PLACED"
                  ? colors.profit.withOpacity(0.1)
                  : mfdata.mforderdet?.data?[0].status == "NOT PLACED"
                      ? colors.loss.withOpacity(0.1)
                      : mfdata.mforderdet?.data?[0].status == "PENDING"
                          ? colors.pending.withOpacity(0.1)
                          : colors.pending.withOpacity(0.1), // default fallback
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextWidget.paraText(
                text: _getStatusLabel(mfdata.mforderdet?.data?[0].status),
                theme: false,
                color: mfdata.mforderdet?.data?[0].status == "PLACED"
                    ? colors.profit
                    : mfdata.mforderdet?.data?[0].status == "NOT PLACED"
                        ? colors.loss
                        : mfdata.mforderdet?.data?[0].status == "PENDING"
                            ? colors.pending
                            : colors.pending),
          ),
          
          // Padding(
          //   padding: const EdgeInsets.only(left: 4.0),
          //   child: TextWidget.paraText(
          //       align: TextAlign.right,
          //       text: _getStatusLabel(mfdata.mforderdet?.data?[0].status),
          //       color: theme.isDarkMode
          //           ? colors.textPrimaryDark
          //           : colors.textPrimaryLight,
          //       textOverflow: TextOverflow.ellipsis,
          //       theme: theme.isDarkMode,
          //       fw: 3),
          // )
        ],
      ),
    ]);
  }

  String _getStatusIcon(String? status) {
    if (status == "PLACED") return assets.completedIcon;
    if (status == "NOT PLACED") return assets.cancelledIcon;
    return assets.warningIcon;
  }

  String _getStatusLabel(String? status) {
    if (status == "PLACED") return 'Success';
    if (status == "NOT PLACED") return 'Failed';
    if (status == "PENDING") return 'Pending';
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
            "${mfdata.mforderdet?.data?[0].orderVal ?? "0.00"}", theme),
       
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
                backgroundColor: colors.btnBg,
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                side: BorderSide(
                  color: colors.btnOutlinedBorder,
                  width: 1,
                ),
                minimumSize: Size(double.infinity, 40), // height: 48
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: TextWidget.subText(
                  align: TextAlign.right,
                  text: "Cancel Order",
                  color:
                      theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                  textOverflow: TextOverflow.ellipsis,
                  theme: theme.isDarkMode,
                  fw: 2),
            ),
          ),
        ),
      ],
    );
  }

   Column rowOfInfoData(String title1, String value1, ThemesProvider theme) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextWidget.subText(
              align: TextAlign.right,
              text: title1,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              fw: 3),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: TextWidget.subText(
                align: TextAlign.right,
                text: value1,
                color: theme.isDarkMode
                    ? colors.textPrimary
                    : colors.textPrimaryLight,
                theme: theme.isDarkMode,
                fw: 3),
          ),
        ]),
        const SizedBox(height: 8),
        Divider(
          thickness: 0,
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        )
      ],
    );
  }
}
