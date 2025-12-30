import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_font_web.dart';
import '../../../res/web_colors.dart';
import '../../../sharedWidget/custom_drag_handler.dart';

class MarginDetailsSheetWeb extends StatefulWidget {
  const MarginDetailsSheetWeb({super.key});

  @override
  State<MarginDetailsSheetWeb> createState() => _MarginDetailsSheetWebState();
}

class _MarginDetailsSheetWebState extends State<MarginDetailsSheetWeb> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final orderMargin = ref.watch(orderProvider).orderMarginModel;
      final orderBrokerage = ref.watch(orderProvider).getBrokerageModel;
      final clientFundDetail = ref.watch(fundProvider).fundDetailModel;

      final theme = ref.watch(themeProvider);
      return Dialog(
        backgroundColor: theme.isDarkMode
            ? WebDarkColors.surface
            : WebColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close icon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.isDarkMode
                          ? WebDarkColors.divider
                          : WebColors.divider,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Margin',
                      style: WebTextStyles.sub(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        splashColor: theme.isDarkMode
                            ? Colors.white.withOpacity(.15)
                            : Colors.black.withOpacity(.15),
                        highlightColor: theme.isDarkMode
                            ? Colors.white.withOpacity(.08)
                            : Colors.black.withOpacity(.08),
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: theme.isDarkMode
                                ? WebDarkColors.iconSecondary
                                : WebColors.iconSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content area with padding
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text("Margin used",
                    //         style: textStyle(
                    //             !theme.isDarkMode
                    //                 ? colors.colorBlack
                    //                 : colors.colorWhite,
                    //             14,
                    //             FontWeight.w500)),
                    //     Text("${orderMargin.marginused}",
                    //         style: textStyle(
                    //                 orderMargin.remarks ==
                    //                         "Insufficient Balance"
                    //                     ? colors.darkred
                    //                     :
                    //             !theme.isDarkMode
                    //                 ? colors.colorBlack
                    //                 : colors.colorWhite,
                    //             14,
                    //             FontWeight.w500))
                    //   ],
                    // ),
                    // Divider(
                    //     color: theme.isDarkMode
                    //         ? colors.darkColorDivider
                    //         : colors.colorDivider,
                    //     height: 20),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text("Margin used previous",
                    //         style: textStyle(
                    //             !theme.isDarkMode
                    //                 ? colors.colorBlack
                    //                 : colors.colorWhite,
                    //             14,
                    //             FontWeight.w500)),
                    //     Text("${orderMargin.marginusedprev}",
                    //         style: textStyle(
                    //             !theme.isDarkMode
                    //                 ? colors.colorBlack
                    //                 : colors.colorWhite,
                    //             14,
                    //             FontWeight.w500))
                    //   ],
                    // ),
                    // Divider(
                    //     color: theme.isDarkMode
                    //         ? colors.darkColorDivider
                    //         : colors.colorDivider,
                    //     height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Required",
                            style: WebTextStyles.custom(
                              fontSize: 13,
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  : WebColors.textPrimary,
                              fontWeight: WebFonts.semiBold,
                            )),
                        Text(
                            "${orderMargin?.ordermargin ?? 0.00}",
                            style: WebTextStyles.custom(
                              fontSize: 13,
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  : WebColors.textPrimary,
                              fontWeight: WebFonts.bold,
                            )),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Balance",
                            style: WebTextStyles.custom(
                              fontSize: 13,
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  : WebColors.textPrimary,
                              fontWeight: WebFonts.bold,
                            )),
                        Text(
                            "${clientFundDetail?.avlMrg ?? 0.00}",
                            style: WebTextStyles.custom(
                              fontSize: 13,
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  : WebColors.textPrimary,
                              fontWeight: WebFonts.semiBold,
                            )),
                      ],
                    ),

                    if (orderMargin?.remarks != null &&
                        orderMargin?.remarks == "Insufficient Balance") ...[
                      Divider(
                          color: theme.isDarkMode
                              ? WebDarkColors.divider
                              : WebColors.divider,
                          height: 20),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                "Remarks - ",
                                style: WebTextStyles.custom(
                                  fontSize: 13,
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textPrimary,
                                  fontWeight: WebFonts.semiBold,
                                )),
                            Text(
                                orderMargin?.remarks ?? '',
                                style: WebTextStyles.custom(
                                  fontSize: 13,
                                  isDarkTheme: theme.isDarkMode,
                                  color: orderMargin?.remarks ==
                                          "Insufficient Balance"
                                      ? (theme.isDarkMode
                                          ? WebDarkColors.error
                                          : WebColors.error)
                                      : (theme.isDarkMode
                                          ? WebDarkColors.success
                                          : WebColors.success),
                                  fontWeight: WebFonts.bold,
                                )),
                          ])
                      ],
                      
                      const SizedBox(height: 16),

                if (orderBrokerage!.emsg ==
                    "Error Occurred : Invalid order details/brokerage plan not set") ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Get update your brokerage details. Reach out our support",
                        textAlign: TextAlign.center,
                        style: WebTextStyles.sub(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                          fontWeight: WebFonts.regular,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final Uri url = Uri(scheme: 'tel', path: "9380108010");
                        await launchUrl(url);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 40),
                        backgroundColor: theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        "Call now",
                        style: WebTextStyles.custom(
                          fontSize: 13,
                          isDarkTheme: theme.isDarkMode,
                          color: WebColors.surface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Approx Charges",
                        style: WebTextStyles.custom(
                          fontSize: 14,
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                
                  Column(children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "Brokerage Amt",
                                        style: WebTextStyles.custom(
                                          fontSize: 13,
                                          isDarkTheme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? WebDarkColors.textPrimary
                                              : WebColors.textPrimary,
                                          fontWeight: WebFonts.semiBold,
                                        )),
                                    Text(
                                        "${orderBrokerage.brkageAmt}",
                                        style: WebTextStyles.custom(
                                          fontSize: 13,
                                          isDarkTheme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? WebDarkColors.textPrimary
                                              : WebColors.textPrimary,
                                          fontWeight: WebFonts.bold,
                                        )),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "STT total",
                                        style: WebTextStyles.custom(
                                          fontSize: 13,
                                          isDarkTheme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? WebDarkColors.textPrimary
                                              : WebColors.textPrimary,
                                          fontWeight: WebFonts.semiBold,
                                        )),
                                    Text(
                                        "${orderBrokerage.sttAmt}",
                                        style: WebTextStyles.custom(
                                          fontSize: 13,
                                          isDarkTheme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? WebDarkColors.textPrimary
                                              : WebColors.textPrimary,
                                          fontWeight: WebFonts.bold,
                                        )),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "Exchange charges",
                                        style: WebTextStyles.custom(
                                          fontSize: 13,
                                          isDarkTheme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? WebDarkColors.textPrimary
                                              : WebColors.textPrimary,
                                          fontWeight: WebFonts.semiBold,
                                        )),
                                    Text(
                                        "${orderBrokerage.exchChrg}",
                                        style: WebTextStyles.custom(
                                          fontSize: 13,
                                          isDarkTheme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? WebDarkColors.textPrimary
                                              : WebColors.textPrimary,
                                          fontWeight: WebFonts.bold,
                                        )),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "SEBI charges",
                                        style: WebTextStyles.custom(
                                          fontSize: 13,
                                          isDarkTheme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? WebDarkColors.textPrimary
                                              : WebColors.textPrimary,
                                          fontWeight: WebFonts.semiBold,
                                        )),
                                    Text(
                                        "${orderBrokerage.sebiChrg}",
                                        style: WebTextStyles.custom(
                                          fontSize: 13,
                                          isDarkTheme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? WebDarkColors.textPrimary
                                              : WebColors.textPrimary,
                                          fontWeight: WebFonts.bold,
                                        )),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "Stamp duty",
                                          style: WebTextStyles.custom(
                                            fontSize: 13,
                                            isDarkTheme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? WebDarkColors.textPrimary
                                                : WebColors.textPrimary,
                                            fontWeight: WebFonts.semiBold,
                                          )),
                                      Text(
                                          "${orderBrokerage.stampDuty}",
                                          style: WebTextStyles.custom(
                                            fontSize: 13,
                                            isDarkTheme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? WebDarkColors.textPrimary
                                                : WebColors.textPrimary,
                                            fontWeight: WebFonts.bold,
                                          )),
                                    ]),
                                const SizedBox(height: 10),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "Clearing charges",
                                          style: WebTextStyles.custom(
                                            fontSize: 13,
                                            isDarkTheme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? WebDarkColors.textPrimary
                                                : WebColors.textPrimary,
                                            fontWeight: WebFonts.semiBold,
                                          )),
                                      Text(
                                          "${orderBrokerage.clrChrg}",
                                          style: WebTextStyles.custom(
                                            fontSize: 13,
                                            isDarkTheme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? WebDarkColors.textPrimary
                                                : WebColors.textPrimary,
                                            fontWeight: WebFonts.bold,
                                          )),
                                    ]),
                                const SizedBox(height: 10),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "GST",
                                          style: WebTextStyles.custom(
                                            fontSize: 13,
                                            isDarkTheme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? WebDarkColors.textPrimary
                                                : WebColors.textPrimary,
                                            fontWeight: WebFonts.semiBold,
                                          )),
                                      Text(
                                          "${orderBrokerage.gst}",
                                          style: WebTextStyles.custom(
                                            fontSize: 13,
                                            isDarkTheme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? WebDarkColors.textPrimary
                                                : WebColors.textPrimary,
                                            fontWeight: WebFonts.bold,
                                          )),
                                    ]),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "View exact charges in contract note at the end of the day",
                                      style: WebTextStyles.para(
                                        isDarkTheme: theme.isDarkMode,
                                        color: theme.isDarkMode
                                            ? WebDarkColors.textPrimary
                                            : WebColors.textPrimary,
                                            fontWeight: WebFonts.semiBold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                  ),
                  ],
                    ],
                  ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class ChargesDetailsBottomsheet extends StatefulWidget {
  const ChargesDetailsBottomsheet({super.key});

  @override
  State<ChargesDetailsBottomsheet> createState() =>
      _ChargesDetailsBottomsheetState();
}

class _ChargesDetailsBottomsheetState extends State<ChargesDetailsBottomsheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final orderBrokerage = ref.watch(orderProvider).getBrokerageModel;
      final orderProvide = ref.watch(orderProvider);
      final theme = ref.watch(themeProvider);
      return orderProvide.getBrokerageModel!.emsg ==
              "Error Occurred : Invalid order details/brokerage plan not set"
          ? Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xff999999),
                        blurRadius: 4.0,
                        offset: Offset(2.0, 0.0))
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomDragHandler(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "Get update your brokerage details. Reach out our support",
                            textAlign: TextAlign.center,
                            style: WebTextStyles.sub(
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  : WebColors.textPrimary,
                              fontWeight: WebFonts.medium,
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                              onPressed: () async {
                                final Uri url =
                                    Uri(scheme: 'tel', path: "9380108010");
                                await launchUrl(url);
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: theme.isDarkMode
                                      ? WebDarkColors.primary
                                      : WebColors.primary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  )),
                              child: Text("Call now",
                                  style: WebTextStyles.sub(
                                    isDarkTheme: theme.isDarkMode,
                                    color: WebColors.surface,
                                    fontWeight: WebFonts.semiBold,
                                  ))),
                        ),
                      ],
                    ),
                  ),
                ],
              ))
          : Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xff999999),
                        blurRadius: 4.0,
                        offset: Offset(2.0, 0.0))
                  ]),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomDragHandler(),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Charges and Taxes",
                                  style: WebTextStyles.title(
                                    isDarkTheme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? WebDarkColors.textPrimary
                                        : WebColors.textPrimary,
                                    fontWeight: WebFonts.bold,
                                  ))
                            ])),
                    Divider(
                        color: theme.isDarkMode
                            ? WebDarkColors.divider
                            : WebColors.divider),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Brokerage Amt",
                                  style: WebTextStyles.sub(
                                    isDarkTheme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? WebDarkColors.textPrimary
                                        : WebColors.textPrimary,
                                    fontWeight: WebFonts.medium,
                                  )),
                              Text("${orderBrokerage?.brkageAmt}",
                                  style: WebTextStyles.sub(
                                    isDarkTheme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? WebDarkColors.textPrimary
                                        : WebColors.textPrimary,
                                    fontWeight: WebFonts.medium,
                                  ))
                            ],
                          ),
                          Divider(
                              color: theme.isDarkMode
                                  ? WebDarkColors.divider
                                  : WebColors.divider,
                              height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("STT total",
                                  style: WebTextStyles.sub(
                                    isDarkTheme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? WebDarkColors.textPrimary
                                        : WebColors.textPrimary,
                                    fontWeight: WebFonts.medium,
                                  )),
                              Text("${orderBrokerage?.sttAmt}",
                                  style: WebTextStyles.sub(
                                    isDarkTheme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? WebDarkColors.textPrimary
                                        : WebColors.textPrimary,
                                    fontWeight: WebFonts.medium,
                                  ))
                            ],
                          ),
                          Divider(
                              color: theme.isDarkMode
                                  ? WebDarkColors.divider
                                  : WebColors.divider,
                              height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Exchange charges",
                                  style: WebTextStyles.sub(
                                    isDarkTheme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? WebDarkColors.textPrimary
                                        : WebColors.textPrimary,
                                    fontWeight: WebFonts.medium,
                                  )),
                              Text("${orderBrokerage?.exchChrg}",
                                  style: WebTextStyles.sub(
                                    isDarkTheme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? WebDarkColors.textPrimary
                                        : WebColors.textPrimary,
                                    fontWeight: WebFonts.medium,
                                  ))
                            ],
                          ),
                          Divider(
                              color: theme.isDarkMode
                                  ? WebDarkColors.divider
                                  : WebColors.divider,
                              height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("SEBI charges",
                                  style: WebTextStyles.sub(
                                    isDarkTheme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? WebDarkColors.textPrimary
                                        : WebColors.textPrimary,
                                    fontWeight: WebFonts.medium,
                                  )),
                              Text("${orderBrokerage?.sebiChrg}",
                                  style: WebTextStyles.sub(
                                    isDarkTheme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? WebDarkColors.textPrimary
                                        : WebColors.textPrimary,
                                    fontWeight: WebFonts.medium,
                                  ))
                            ],
                          ),
                          Divider(
                              color: theme.isDarkMode
                                  ? WebDarkColors.divider
                                  : WebColors.divider,
                              height: 20),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Stamp duty",
                                    style: WebTextStyles.sub(
                                      isDarkTheme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? WebDarkColors.textPrimary
                                          : WebColors.textPrimary,
                                      fontWeight: WebFonts.medium,
                                    )),
                                Text("${orderBrokerage?.stampDuty}",
                                    style: WebTextStyles.sub(
                                      isDarkTheme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? WebDarkColors.textPrimary
                                          : WebColors.textPrimary,
                                      fontWeight: WebFonts.medium,
                                    ))
                              ]),
                          Divider(
                              color: theme.isDarkMode
                                  ? WebDarkColors.divider
                                  : WebColors.divider,
                              height: 20),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Clearing charges",
                                    style: WebTextStyles.sub(
                                      isDarkTheme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? WebDarkColors.textPrimary
                                          : WebColors.textPrimary,
                                      fontWeight: WebFonts.medium,
                                    )),
                                Text("${orderBrokerage?.clrChrg}",
                                    style: WebTextStyles.sub(
                                      isDarkTheme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? WebDarkColors.textPrimary
                                          : WebColors.textPrimary,
                                      fontWeight: WebFonts.medium,
                                    ))
                              ]),
                          Divider(
                              color: theme.isDarkMode
                                  ? WebDarkColors.divider
                                  : WebColors.divider,
                              height: 20),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("GST",
                                    style: WebTextStyles.sub(
                                      isDarkTheme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? WebDarkColors.textPrimary
                                          : WebColors.textPrimary,
                                      fontWeight: WebFonts.medium,
                                    )),
                                Text("${orderBrokerage?.gst}",
                                    style: WebTextStyles.sub(
                                      isDarkTheme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? WebDarkColors.textPrimary
                                          : WebColors.textPrimary,
                                      fontWeight: WebFonts.medium,
                                    ))
                              ]),
                          const SizedBox(height: 10)
                        ]))
                  ]));
    });
  }
}
