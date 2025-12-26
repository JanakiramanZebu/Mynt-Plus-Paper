import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';

import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/list_divider.dart';

class PledgeList extends StatefulWidget {
  const PledgeList({super.key, required});

  @override
  State<PledgeList> createState() => _PledgeList();
}

class DropdownItem {
  final String value;
  final String label;
  final bool isEnabled;

  DropdownItem({
    required this.value,
    required this.label,
    this.isEnabled = true,
  });
}

class _PledgeList extends State<PledgeList> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    double notional = 0.0;
    return Consumer(builder: (context, WidgetRef ref, _) {
      final ledgerprovider = ref.watch(ledgerProvider);
      String selectedValue = ledgerprovider.segmentvalue;
      final theme = ref.read(themeProvider);

      List<DropdownItem> dropdownItems = [];

      final segmentMap = {
        'Futures And Options': ['NSE_FNO', 'BSE_FNO'],
        'Commodities': ['MCX'],
        'Currencies': ['CD_NSE', 'CD_BSE'],
      };

      dropdownItems.add(
        DropdownItem(
          value: "Margin Trading Facility",
          label: "Margin Trading Facility",
          isEnabled:
              ledgerprovider.segresponse['mtf_status'] == false ? false : true,
        ),
      );
// Optional: remove duplicates if needed (based on value)
      final seen = <String>{};
      dropdownItems =
          dropdownItems.where((item) => seen.add(item.value)).toList();
      print("$dropdownItems printprintprintpritn");
      return Stack(
        children: [
          DraggableScrollableSheet(
            initialChildSize: 0.60,
            minChildSize: .4,
            maxChildSize: .99,
            expand: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color:
                      theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
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
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomDragHandler(),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, left: 16.0, bottom: 8.0),
                        child: TextWidget.titleText(
                            text: "Pledge Details",
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            fw: 1),
                      ),
                      const ListDivider(),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 8.0),
                            child: ListView.separated(
                              physics: const ScrollPhysics(),
                              itemCount: ledgerprovider.listforpledge.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final value =
                                    ledgerprovider.listforpledge[index];
                                return Column(
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          TextWidget.subText(
                                              align: TextAlign.start,
                                              text: "Symbol : ",
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                              fw: 0),
                                          TextWidget.subText(
                                              align: TextAlign.start,
                                              text: "${value['symbol'] ?? '-'}",
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              color: theme.isDarkMode
                                                  ? colors.textPrimaryDark
                                                  : colors.textPrimaryLight,
                                              fw: 0),
                                        ]),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            TextWidget.subText(
                                                align: TextAlign.start,
                                                text: "Segment : ",
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                color: theme.isDarkMode
                                                    ? colors.textSecondaryDark
                                                    : colors.textSecondaryLight,
                                                fw: 0),
                                            TextWidget.subText(
                                                align: TextAlign.start,
                                                text:
                                                    "${value['segments'] ?? '-'}",
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                fw: 0),
                                          ]),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            TextWidget.subText(
                                                align: TextAlign.start,
                                                text: "Total Qty : ",
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                color: theme.isDarkMode
                                                    ? colors.textSecondaryDark
                                                    : colors.textSecondaryLight,
                                                fw: 0),
                                            TextWidget.subText(
                                                align: TextAlign.start,
                                                text:
                                                    "${value['quantity'] ?? '-'}",
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                fw: 0),
                                          ]),
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: 6.0,
                                    bottom: 6.0,
                                  ),
                                  child: Divider(
                                    color: theme.isDarkMode
                                        ? const Color(0xffB5C0CF)
                                            .withOpacity(.15)
                                        : const Color(0xffF1F3F8),
                                    thickness: 1.0,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: screenheight * 0.14,
                        // decoration: BoxDecoration(
                        //     color: theme.isDarkMode
                        //         ? const Color(0xffB5C0CF).withOpacity(.15)
                        //         : const Color(0xffF1F3F8)),
                      ),
                    ]),
              );
            },
          ),
          Positioned(
            bottom: 1,
            left: 1,
            right: 1,
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 12.0, left: 16.0),
                        child: Container(
                          height: 45,
                          width: screenWidth * 0.43,
                          margin: const EdgeInsets.only(right: 12, top: 15),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // ledgerprovider.screenclickedpledge = '';
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: theme.isDarkMode
                                  ? colors.textSecondaryDark.withOpacity(0.6)
                                  : colors.btnBg,
                              // foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                              side: theme.isDarkMode
                                  ? null
                                  : BorderSide(
                                      color: colors.primaryLight,
                                      width: 1,
                                    ),
                              minimumSize:
                                  const Size(double.infinity, 45), // height: 48
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: TextWidget.subText(
                                text: "Cancel",
                                color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.primaryLight,
                                theme: theme.isDarkMode,
                                fw: 2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                            height: 45,
                            width: screenWidth * 0.43,
                            margin: const EdgeInsets.only(right: 12, top: 15),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  backgroundColor: !theme.isDarkMode
                                      ? colors.primaryLight
                                      : colors.primaryDark,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5))),
                              onPressed: () async {
                                // Give UI time to update before navigation

                                // Now call the CDSL navigation method

                                ledgerprovider.beforecdsl(
                                    context,
                                    ledgerprovider.pledgeandunpledge!.cLIENTCODE
                                        .toString(),
                                    ledgerprovider.pledgeandunpledge!.bOID
                                        .toString(),
                                    ledgerprovider.pledgeandunpledge!.cLIENTNAME
                                        .toString(),
                                    ledgerprovider.listforpledge);
                                // First close this bottom sheet to avoid context issues
                              },
                              child: ledgerprovider.pledgeloader == true
                                  ? const SpinKitThreeBounce(
                                      color: Colors.grey,
                                      size: 24,
                                    )
                                  : TextWidget.subText(
                                      text: "Submit",
                                      color: colors.colorWhite,
                                      theme: theme.isDarkMode,
                                      fw: 2),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
