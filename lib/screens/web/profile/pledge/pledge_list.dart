import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/mynt_loader.dart';

import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
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

      return Container(
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: resolveThemeColor(context,
              dark: Colors.black, light: Colors.white),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.only(
                  top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
              child: Text("Pledge Details",
                  overflow: TextOverflow.ellipsis,
                  style: MyntWebTextStyles.body(context,
                      darkColor: MyntColors.textPrimaryDark,
                      lightColor: MyntColors.textPrimary,
                      fontWeight: MyntFonts.semiBold)),
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
                                Text("Symbol : ",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: MyntWebTextStyles.body(context,
                                        darkColor: MyntColors.textSecondaryDark,
                                        lightColor: MyntColors.textSecondary,
                                        fontWeight: MyntFonts.medium)),
                                Text("${value['symbol'] ?? '-'}",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: MyntWebTextStyles.body(context,
                                        darkColor: MyntColors.textPrimaryDark,
                                        lightColor: MyntColors.textPrimary,
                                        fontWeight: MyntFonts.medium)),
                              ]),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Segment : ",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: MyntWebTextStyles.body(context,
                                          darkColor: MyntColors.textSecondaryDark,
                                          lightColor: MyntColors.textSecondary,
                                          fontWeight: MyntFonts.medium)),
                                  Text("${value['segments'] ?? '-'}",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: MyntWebTextStyles.body(context,
                                          darkColor: MyntColors.textPrimaryDark,
                                          lightColor: MyntColors.textPrimary,
                                          fontWeight: MyntFonts.medium)),
                                ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Total Qty : ",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: MyntWebTextStyles.body(context,
                                          darkColor: MyntColors.textSecondaryDark,
                                          lightColor: MyntColors.textSecondary,
                                          fontWeight: MyntFonts.medium)),
                                  Text("${value['quantity'] ?? '-'}",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: MyntWebTextStyles.body(context,
                                          darkColor: MyntColors.textPrimaryDark,
                                          lightColor: MyntColors.textPrimary,
                                          fontWeight: MyntFonts.medium)),
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
                          color: resolveThemeColor(context,
                              dark: MyntColors.dividerDark,
                              light: MyntColors.divider),
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
                          backgroundColor: resolveThemeColor(context,
                              dark: MyntColors.textSecondaryDark.withValues(alpha: 0.6),
                              light: MyntColors.listItemBg),
                          side: isDarkMode(context)
                              ? null
                              : BorderSide(
                                  color: MyntColors.primary,
                                  width: 1,
                                ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text("Cancel",
                            style: MyntWebTextStyles.body(context,
                                color: resolveThemeColor(context,
                                    dark: Colors.white,
                                    light: MyntColors.primary),
                                fontWeight: MyntFonts.bold)),
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
                            backgroundColor: resolveThemeColor(context,
                                dark: MyntColors.primaryDark,
                                light: MyntColors.primary),
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
                            ? MyntLoader.inline(color: Colors.white)
                            : Text("Submit",
                                style: MyntWebTextStyles.body(context,
                                    color: Colors.white,
                                    fontWeight: MyntFonts.bold)),
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
