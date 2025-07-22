import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_widget_button.dart';
import '../../../sharedWidget/functions.dart';
import 'fund_collateral.dart';

class SecureFund extends ConsumerStatefulWidget {
  const SecureFund({super.key});

  @override
  ConsumerState<SecureFund> createState() => _SecureFundState();
}

class _SecureFundState extends ConsumerState<SecureFund> {
  bool isAvailableCashExpanded = false;
  bool isMarginUsedExpanded = false;
  bool isCollateralExpanded = false;

  @override
  Widget build(BuildContext context) {
    final funds = ref.watch(fundProvider);
    final theme = ref.watch(themeProvider);
    final trancation = ref.watch(transcationProvider);

    return Scaffold(
      backgroundColor: colors.colorWhite,
      body: ListView(
        children: [
          // Available Margin Section
          Container(
            color: colors.colorWhite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔷 Top Text Section with full padding
                Padding(
                  padding: const EdgeInsets.all(
                      16), // Only this section gets full padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextWidget.subText(
                          text: "Available Margin",
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 3,
                          theme: false),
                      const SizedBox(height: 8),
                      Text(
                        getFormatter(
                          value: double.parse(
                              "${funds.fundDetailModel?.avlMrg ?? 0.00}"),
                          v4d: false,
                          noDecimal: false,
                        ),
                        style: TextWidget.textStyle(
                          fontSize: 18,
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          fw: 0,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔷 Button Row with border and horizontal padding only
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: theme.isDarkMode
                                ? colors.dividerDark
                                : colors.dividerLight)),
                  ),
                  // margin: const EdgeInsets.symmetric(vertical: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      // Add Fund Button
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: theme.isDarkMode
                                      ? colors.primaryDark
                                      : colors.primaryLight,
                                  width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: theme.isDarkMode
                                  ? colors.primaryDark
                                  : colors.primaryLight,
                            ),
                            onPressed: () {
                              // trancation.changebool(true);
                              Navigator.pushNamed(context, Routes.fundscreen,
                                  arguments: trancation);
                            },
                            child: TextWidget.subText(
                                text: "Add Money",
                                theme: false,
                                color: !theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                                fw: 0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Withdraw Button
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: theme.isDarkMode
                                      ? colors.primaryLight
                                      : colors.primaryDark,
                                  width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor: colors.fundbuttonBg,
                            ),
                            onPressed: () async {
                              await trancation.fetchValidateToken(context);
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                () async {
                                  await trancation.ip();
                                  await trancation.fetchupiIdView(
                                    trancation.bankdetails!
                                        .dATA![trancation.indexss][1],
                                    trancation.bankdetails!
                                        .dATA![trancation.indexss][2],
                                  );
                                  await trancation.fetchcwithdraw(context);
                                },
                              );
                              trancation.changebool(false);
                              Navigator.pushNamed(
                                  context, Routes.withdrawscreen,
                                  arguments: trancation);
                            },
                            child: Text(
                              "Withdraw",
                              style: TextWidget.textStyle(
                                fontSize: 14,
                                theme: false,
                                color: colors.colorBlue,
                                fw: 0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Detailed Financial Information
          Container(
            color: colors.colorWhite,
            child: Column(
              children: [
                // Available cash - Expandable
                _buildExpandableInfoRow(
                  "Available cash",
                  getFormatter(
                      value: double.parse(
                          "${funds.fundDetailModel?.totCredit ?? 0.00}"),
                      v4d: false,
                      noDecimal: false),
                  theme,
                  isExpanded: isAvailableCashExpanded,
                  onTap: () {
                    setState(() {
                      isAvailableCashExpanded = !isAvailableCashExpanded;
                    });
                  },
                  expandedContent: _buildAvailableCashContent(funds, theme),
                ),

                // Margin used - Expandable
                _buildExpandableInfoRow(
                  "Margin used",
                  getFormatter(
                      value: double.parse(
                          "${funds.fundDetailModel?.utilizedMrgn ?? 0.00}"),
                      v4d: false,
                      noDecimal: false),
                  isExpanded: isMarginUsedExpanded,
                  onTap: () {
                    setState(() {
                      isMarginUsedExpanded = !isMarginUsedExpanded;
                    });
                  },
                  expandedContent: _buildMarginUsedContent(funds, theme),
                  theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableInfoRow(
    String title,
    String value,
    ThemesProvider theme, {
    required bool isExpanded,
    required VoidCallback onTap,
    Widget? expandedContent,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      TextWidget.subText(
                          text: title,
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 3),
                    ],
                  ),
                  Row(
                    children: [
                      TextWidget.subText(
                          text: value,
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          fw: 3),
                      const SizedBox(width: 4),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && expandedContent != null) expandedContent,
        ],
      ),
    );
  }

  Widget _buildAvailableCashContent(funds, theme) {
    // Only sublist if there is more than one item
    final filteredCredits = funds.listOfCredits.length > 1
        ? funds.listOfCredits
            .sublist(1)
            .where((item) =>
                item["name"] != "Collateral" &&
                item["name"] != "Opening Balance")
            .toList()
        : [];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (funds.listOfCredits.isNotEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget.subText(
                        text: "Cash Balance",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 3),
                    TextWidget.subText(
                        text: getFormatter(
                            value: double.parse(
                                "${funds.listOfCredits[0]["value"]}"),
                            v4d: false,
                            noDecimal: false),
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fw: 3),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    color: colors.colorDivider,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget.subText(
                      text: "Col - Cash Equivalent",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 3,
                    ),
                    TextWidget.subText(
                      text:
                          "${getFormatter(value: double.parse("${funds.pledgeAndUnpledgeModel?.cashEquivalent ?? 0.00}"), v4d: false, noDecimal: false)}",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 3,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    color: colors.colorDivider,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget.subText(
                      text: "Col -Non-Cash",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 3,
                    ),
                    TextWidget.subText(
                      text:
                          "${getFormatter(value: double.parse("${funds.pledgeAndUnpledgeModel?.noncashEquivalent ?? 0.00}"), v4d: false, noDecimal: false)}",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 3,
                    ),
                  ],
                ),
                filteredCredits.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          height: 1,
                          color: colors.colorDivider,
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            if (filteredCredits.isNotEmpty)
              ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredCredits.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                            text: "${filteredCredits[index]["name"]}",
                            theme: false,
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            fw: 3),
                        TextWidget.subText(
                            text: getFormatter(
                                value: double.parse(
                                    "${filteredCredits[index]["value"]}"),
                                v4d: false,
                                noDecimal: false),
                            theme: false,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            fw: 3),
                      ],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                            height: 1,
                            color: colors.colorDivider,
                          ),
                        ),
                      ],
                    );
                  }),
            SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildMarginUsedContent(funds, theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          // Span, Exposure, Option Premium from listOfUsedMrgn
          if (funds.listOfUsedMrgn.isNotEmpty) ...[
            ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: funds.listOfUsedMrgn.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget.subText(
                              text: "${funds.listOfUsedMrgn[index]["name"]}",
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              fw: 3),
                          TextWidget.subText(
                              text: getFormatter(
                                  value: double.parse(
                                      "${funds.listOfUsedMrgn[index]["value"]}"),
                                  v4d: false,
                                  noDecimal: false),
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              fw: 3),
                        ]),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    height: 1,
                    color: colors.colorDivider.withOpacity(0.5),
                  );
                }),
            Divider(
              height: 1,
              color: colors.colorDivider.withOpacity(0.5),
            ),
          ],

          // Unrealized Expenses
          if (funds.fundDetailModel?.pendordval != null &&
              funds.fundDetailModel!.pendordval != "0.00") ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget.subText(
                        text: "Unrealized Expenses",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 3),
                    TextWidget.subText(
                        text: getFormatter(
                            value: double.parse(
                                "${funds.fundDetailModel?.pendordval ?? 0.00}"),
                            v4d: false,
                            noDecimal: false),
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fw: 3),
                  ]),
            ),
            Divider(
              height: 1,
              color: colors.colorDivider.withOpacity(0.5),
            ),
          ],

          // Peak Margin
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.subText(
                      text: "Peak Margin",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 3),
                  TextWidget.subText(
                      text: getFormatter(
                          value: double.parse(
                              "${funds.fundDetailModel?.peakMar ?? 0.00}"),
                          v4d: false,
                          noDecimal: false),
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 3),
                ]),
          ),
          Divider(
            height: 1,
            color: colors.colorDivider.withOpacity(0.5),
          ),

          // Expiry Margin
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.subText(
                      text: "Expiry Margin",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 3),
                  TextWidget.subText(
                      text: getFormatter(
                          value: double.parse(
                              "${funds.fundDetailModel?.expiryMar ?? 0.00}"),
                          v4d: false,
                          noDecimal: false),
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 3),
                ]),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Row rowOfInfoData(
      String title1, String value1, String title2, String value2) {
    return Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextWidget.paraText(
            text: title1, theme: false, color: const Color(0xff666666), fw: 0),
        const SizedBox(height: 3),
        TextWidget.subText(
            text: value1, theme: false, color: const Color(0xff000000), fw: 0),
        const SizedBox(height: 2),
        Divider(height: 1, color: colors.colorDivider.withOpacity(0.5))
      ])),
      const SizedBox(width: 24),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextWidget.paraText(
            text: title2, theme: false, color: const Color(0xff666666), fw: 0),
        const SizedBox(height: 3),
        TextWidget.subText(
            text: value2, theme: false, color: const Color(0xff000000), fw: 0),
        const SizedBox(height: 2),
        Divider(height: 1, color: colors.colorDivider.withOpacity(0.5))
      ]))
    ]);
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
