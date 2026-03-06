import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';

import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/list_divider.dart';

class PledgeList extends StatefulWidget {
  const PledgeList({super.key, required});

  @override
  State<PledgeList> createState() => _PledgeList();
}

class _PledgeList extends State<PledgeList> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final ledgerprovider = ref.watch(ledgerProvider);
      final theme = ref.read(themeProvider);

      return Container(
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.only(
                  top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
              child: TextWidget.titleText(
                  text: "Pledge Details",
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  textOverflow: TextOverflow.ellipsis,
                  theme: theme.isDarkMode,
                  fw: 1),
            ),
            ListDivider(),

            // List items
            Flexible(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 8.0),
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ledgerprovider.listforpledge.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final value = ledgerprovider.listforpledge[index];
                      return Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextWidget.subText(
                                    align: TextAlign.start,
                                    text: "Symbol : ",
                                    textOverflow: TextOverflow.ellipsis,
                                    theme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    fw: 0),
                                TextWidget.subText(
                                    align: TextAlign.start,
                                    text: "${value['symbol'] ?? '-'}",
                                    textOverflow: TextOverflow.ellipsis,
                                    theme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    fw: 0),
                              ]),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  TextWidget.subText(
                                      align: TextAlign.start,
                                      text: "Segment : ",
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                      fw: 0),
                                  TextWidget.subText(
                                      align: TextAlign.start,
                                      text: "${value['segments'] ?? '-'}",
                                      textOverflow: TextOverflow.ellipsis,
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  TextWidget.subText(
                                      align: TextAlign.start,
                                      text: "Total Qty : ",
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                      fw: 0),
                                  TextWidget.subText(
                                      align: TextAlign.start,
                                      text: "${value['quantity'] ?? '-'}",
                                      textOverflow: TextOverflow.ellipsis,
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
                    separatorBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 6.0,
                          bottom: 6.0,
                        ),
                        child: Divider(
                          color: theme.isDarkMode
                              ? const Color(0xffB5C0CF).withOpacity(.15)
                              : const Color(0xffF1F3F8),
                          thickness: 1.0,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: theme.isDarkMode
                              ? colors.textSecondaryDark.withOpacity(0.6)
                              : colors.btnBg,
                          side: theme.isDarkMode
                              ? null
                              : BorderSide(
                                  color: colors.primaryLight,
                                  width: 1,
                                ),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 45,
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
                          ledgerprovider.beforecdsl(
                              context,
                              ledgerprovider.pledgeandunpledge!.cLIENTCODE
                                  .toString(),
                              ledgerprovider.pledgeandunpledge!.bOID
                                  .toString(),
                              ledgerprovider.pledgeandunpledge!.cLIENTNAME
                                  .toString(),
                              ledgerprovider.listforpledge);
                        },
                        child: ledgerprovider.pledgeloader == true
                            ? SpinKitThreeBounce(
                                color: Colors.grey,
                                size: 24,
                              )
                            : TextWidget.subText(
                                text: "Submit",
                                color: colors.colorWhite,
                                theme: theme.isDarkMode,
                                fw: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
