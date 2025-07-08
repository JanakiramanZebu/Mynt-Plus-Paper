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
    return Consumer(builder: (context, ref, child) {
      final theme = ref.watch(themeProvider);
      final mfdata = ref.watch(mfProvider);

      // Check if order data is null
      final hasData = mfdata.mforderdet?.data != null;

      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          leadingWidth: 41,
          titleSpacing: 6,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios,
                  color:
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          backgroundColor:
              theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          shadowColor: const Color(0xffECEFF3),
          title: Text("Order details",
              style: textStyles.appBarTitleTxt.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              )),
        ),
        body: hasData
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderHeader(theme, mfdata),
                    const SizedBox(height: 16),
                    if (mfdata.mforderdet?.data?.orderstatus != "VALID") ...[
                      TextWidget.titleText(
                          align: TextAlign.right,
                          text: _getStatusText(
                              mfdata.mforderdet?.data?.orderstatus),
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          textOverflow: TextOverflow.ellipsis,
                          theme: theme.isDarkMode,
                          fw: 3),

                      const SizedBox(height: 8),
                      TextWidget.subText(
                          align: TextAlign.right,
                          text: "${mfdata.mforderdet?.data?.orderremarks ?? "No remarks available"}",
                          color: theme.isDarkMode
                                ? colors.colorWhite
                                : const Color(0xFFF33E4B),
                          textOverflow: TextOverflow.ellipsis,
                          theme: theme.isDarkMode,
                          fw: 3),
                       
                    ],
                    
                    const SizedBox(height: 20),
                    TextWidget.subText(
                        align: TextAlign.right,
                        text: "Order details",
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 3),
                    const SizedBox(height: 24),
                    _buildDetailsSection(theme, mfdata),
                    const SizedBox(height: 20),
                    _buildCancelButton(theme, mfdata, context),
                  ],
                ),
              )
            : const Center(child: NoDataFound()),
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
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget.subText(
                                  align: TextAlign.start,
                                  text: mfdata.mforderdet?.data?.schemename ??
                                      "Unknown Scheme",
                                  color: theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                  textOverflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  theme: theme.isDarkMode,
                                  fw: 0),
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
          SvgPicture.asset(
            _getStatusIcon(mfdata.mforderdet?.data?.orderstatus),
            width: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: TextWidget.paraText(
                align: TextAlign.right,
                text: _getStatusLabel(mfdata.mforderdet?.data?.orderstatus),
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                textOverflow: TextOverflow.ellipsis,
                theme: theme.isDarkMode,
                fw: 3),
          )
        ],
      ),
    ]);
  }

  String _getStatusIcon(String? status) {
    if (status == "VALID") return assets.completedIcon;
    if (status == "INVALID") return assets.cancelledIcon;
    return assets.warningIcon;
  }

  String _getStatusLabel(String? status) {
    if (status == "VALID") return 'Success';
    if (status == "INVALID") return 'Failed';
    if (status == "PENDING") return 'Pending';
    return status ?? 'Unknown';
  }

  Widget _buildDetailsSection(ThemesProvider theme, dynamic mfdata) {
    return Column(
      children: [
        rowOfInfoData(
            "Transaction Type",
            mfdata.mforderdet?.data?.buysell == "P" ? "Purchase" : "Redemption",
            theme),
        const SizedBox(height: 10),
        Divider(
          color:
              theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          thickness: 1.0,
        ),
        const SizedBox(height: 10),
        rowOfInfoData(
            "Order Type",
            mfdata.mforderdet?.data?.ordertype == "NRM" ? "Lumpsum" : "SIP",
            theme),
        const SizedBox(height: 10),
        Divider(
          color:
              theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          thickness: 1.0,
        ),
        const SizedBox(height: 10),
        rowOfInfoData(
            "Price", "${mfdata.mforderdet?.data?.amount ?? "0.00"}", theme),
        const SizedBox(height: 10),
        Divider(
          color:
              theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          thickness: 1.0,
        ),
        const SizedBox(height: 10),
        rowOfInfoData(
            "Units", "${mfdata.mforderdet?.data?.units ?? "0.00"}", theme),
        const SizedBox(height: 10),
        Divider(
          color:
              theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          thickness: 1.0,
        ),
        const SizedBox(height: 10),
        rowOfInfoData(
            "Date", "${mfdata.mforderdet?.data?.date ?? "N/A"}", theme),
        const SizedBox(height: 10),
        Divider(
          color:
              theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          thickness: 1.0,
        ),
        const SizedBox(height: 10),
        rowOfInfoData("Date & Time",
            "${mfdata.mforderdet?.data?.dateTime ?? "N/A"}", theme),
        const SizedBox(height: 10),
        Divider(
          color:
              theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          thickness: 1.0,
        ),
        const SizedBox(height: 10),
        rowOfInfoData("Order No",
            "${mfdata.mforderdet?.data?.ordernumber ?? "N/A"}", theme),
        const SizedBox(height: 10),
        Divider(
          color:
              theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          thickness: 1.0,
        ),
        const SizedBox(height: 10),
        rowOfInfoData(
            "Folio No",
            "${mfdata.mforderdet?.data?.foliono?.isEmpty ?? true ? "---" : mfdata.mforderdet?.data?.foliono}",
            theme),
        const SizedBox(height: 10),
        Divider(
          color:
              theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          thickness: 1.0,
        ),
      ],
    );
  }

  Widget _buildCancelButton(
      ThemesProvider theme, dynamic mfdata, BuildContext context) {
    // Check if we should show the cancel button
    final shouldShowCancel = mfdata.mforderdet?.data?.ordertype == "NRM" &&
        mfdata.mforderdet?.data?.buysell == "R" &&
        mfdata.mforderdet?.data?.orderstatus == "PENDING";

    if (!shouldShowCancel) return const SizedBox();

    return SizedBox(
      width: double.infinity, // Makes the button full width
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
          backgroundColor: Colors.white, // White background
          foregroundColor:
              const Color.fromARGB(255, 0, 0, 0), // Text and icon color
          side: const BorderSide(
              color: Color.fromARGB(255, 0, 0, 0),
              width: 1.5), // Outlined border
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20), // Optional: rounded corners
          ),
        ),
        child: const Text(
          "Cancel Order",
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Row rowOfInfoData(String title1, String value1, ThemesProvider theme) {
    return Row(children: [
      Expanded(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            TextWidget.subText(
                align: TextAlign.right,
                text: title1,
                color: theme.isDarkMode
                    ? colors.textPrimary
                    : colors.textPrimaryLight,
                textOverflow: TextOverflow.ellipsis,
                theme: theme.isDarkMode,
                fw: 3),
            TextWidget.subText(
                align: TextAlign.right,
                text: value1,
                color: theme.isDarkMode
                    ? colors.textPrimary
                    : colors.textPrimaryLight,
                textOverflow: TextOverflow.ellipsis,
                theme: theme.isDarkMode,
                fw: 3),
          ])),
    ]);
  }
}
