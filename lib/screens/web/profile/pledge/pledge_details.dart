import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import '../../../../models/marketwatch_model/get_quotes.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/portfolio_provider.dart';
// import '../../mutual_fund/mf_stock_detail_screen.dart';
import '../../../../provider/thems.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../sharedWidget/cust_text_formfield.dart';
// import '../../../../sharedWidget/custom_drag_handler.dart';

class PledgeDeytails extends StatefulWidget {
  final dynamic data;
  const PledgeDeytails({super.key, required this.data});

  @override
  State<PledgeDeytails> createState() => _PledgeDeytails();
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

class _PledgeDeytails extends State<PledgeDeytails> {
  bool _isLoadingMf = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    double notional = 0.0;

    return Consumer(builder: (context, WidgetRef ref, _) {
      ref.read(themeProvider);
      final ledgerdata = ref.watch(ledgerProvider);
      final marketwatch = ref.watch(marketWatchProvider);
      final mfPortfolio = ref.read(mfProvider);
      // MF name lookup for GR series
      String mfname = "";
      if (widget.data.sERIES == "GR") {
        final isin = widget.data.iSIN?.toString() ?? "";
        if (mfPortfolio.mfholdingnew?.data != null && isin.isNotEmpty) {
          for (var mfData in mfPortfolio.mfholdingnew!.data!) {
            if (mfData.iSIN == isin) {
              mfname = mfData.name ?? "";
              break;
            }
          }
        }
      }
      // final myController = TextEditingController(text: ledgerdata.selectnetpledge.text);
      // String selectedValue = ledgerdata.segmentvalue;
      String? selectedValue;
      print(
          "$selectedValue selectedValueselectedValueselectedValueselectedValue");
      //     if (ledgerdata.pledgeandunpledge!.data!.isNotEmpty) {
      //       for (var i = 0; i < ledgerdata.pledgeandunpledge!.data!.length; i++) {
      //         final val = ledgerdata.pledgeandunpledge!.data![i];
      //       if (val.nSESYMBOL == ) {}}
      //     }

      int netValue = ledgerdata.screenpledge == 'pledge'
          ? (widget.data.nET is String)
              ? double.parse(widget.data.nET!).toInt()
              : (widget.data.cOLQTY as double).toInt()
          : (widget.data.cOLQTY is String)
              ? double.parse(widget.data.cOLQTY!).toInt()
              : (widget.data.cOLQTY as double).toInt();
      List<DropdownItem> dropdownItems = [];

     final segmentMap = {
        'Margin': ['NSE_FNO', 'BSE_FNO', 'MCX'],
        'Commodities': ['MCX'],
        'Currencies': ['CD_NSE', 'CD_BSE'],
      };

      final eligibleSegments = widget.data.eligibleSegments!;
      final companyCodes = ledgerdata.segresponse['company_code'];

      for (final segment in eligibleSegments) {
        final matchingCodes = segmentMap[segment];

        if (matchingCodes != null) {
          final hasMatchingCode =
              companyCodes.any((code) => matchingCodes.contains(code));

          if (ledgerdata.segresponse['mtf_status'] == true) {
            if (ledgerdata.segmentvaluedummy == 'Margin Trading Facility') {
              if (hasMatchingCode) {
                dropdownItems.add(
                  DropdownItem(
                    value: segment,
                    label: segment,
                    isEnabled: false,
                  ),
                );
                print("Added: $segment");
              } else {
                dropdownItems.add(
                  DropdownItem(
                    value: segment,
                    label: segment,
                    isEnabled: false,
                  ),
                );
                print("No matching company code for $segment");
              }
              dropdownItems.add(
                DropdownItem(
                  value: "Margin Trading Facility",
                  label: "Margin Trading Facility",
                  isEnabled: true,
                ),
              );
            } else if (ledgerdata.segmentvaluedummy == '') {
              if (hasMatchingCode) {
                dropdownItems.add(
                  DropdownItem(
                    value: segment,
                    label: segment,
                    isEnabled: true,
                  ),
                );
                print("Added: $segment");
              } else {
                dropdownItems.add(
                  DropdownItem(
                    value: segment,
                    label: segment,
                    isEnabled: true,
                  ),
                );
                print("No matching company code for $segment");
              }
              dropdownItems.add(
                DropdownItem(
                  value: "Margin Trading Facility",
                  label: "Margin Trading Facility",
                  isEnabled: true,
                ),
              );
            } else {
              if (hasMatchingCode) {
                dropdownItems.add(
                  DropdownItem(
                    value: segment,
                    label: segment,
                    isEnabled: true,
                  ),
                );
                print("Added: $segment");
              } else {
                dropdownItems.add(
                  DropdownItem(
                    value: segment,
                    label: segment,
                    isEnabled: true,
                  ),
                );
                print("No matching company code for $segment");
              }
              dropdownItems.add(
                DropdownItem(
                  value: "Margin Trading Facility",
                  label: "Margin Trading Facility",
                  isEnabled: false,
                ),
              );
            }
          } else {
            if (hasMatchingCode) {
              dropdownItems.add(
                DropdownItem(
                  value: segment,
                  label: segment,
                  isEnabled: true,
                ),
              );
              print("Added: $segment");
            } else {
              dropdownItems.add(
                DropdownItem(
                  value: segment,
                  label: segment,
                  isEnabled: false,
                ),
              );
              print("No matching company code for $segment");
            }
            dropdownItems.add(
              DropdownItem(
                value: "Margin Trading Facility",
                label: "Margin Trading Facility",
                isEnabled: false,
              ),
            );
          }
        } else {
          print("Segment $segment is not in segmentMap");
        }
      }

// Optional: remove duplicates if needed (based on value)
      final seen = <String>{};
      dropdownItems =
          dropdownItems.where((item) => seen.add(item.value)).toList();

      print("${dropdownItems} printprintprintpritn");

      return WillPopScope(
        onWillPop: () async {
          if (ledgerdata.listforpledge == []) {
            ledgerdata.changesegvaldummy('');
          }
          Navigator.pop(context);
          print(
              "objectobjectobjectobjectobjectobjectobjectobject ${screenheight * 0.00038}");
          return true;
        },
        child: Stack(
          children: [
          SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: resolveThemeColor(context, dark: MyntColors.backgroundColorDark, light: MyntColors.backgroundColor),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            splashColor: resolveThemeColor(context, dark: MyntColors.rippleDark, light: MyntColors.rippleLight),
                                        highlightColor: resolveThemeColor(context, dark: MyntColors.highlightDark, light: MyntColors.highlightLight),
                                            onTap: (){},
                            // onTap: widget.data.sERIES == "GR" ? () async {
                            //         final isin = widget.data.iSIN?.toString() ?? "";
                            //         if (isin.isEmpty) return;
                            //         final mf = ref.read(mfProvider);
                            //         try {
                            //           setState(() => _isLoadingMf = true);
                            //           mf.loaderfun();
                            //           await mf.fetchFactSheet(isin);
                            //           final mfInstance = await mf.fetchSinglePageMfData(isin);
                            //           if (mounted) setState(() => _isLoadingMf = false);
                            //           if (mf.factSheetDataModel?.stat != "Not Ok") {
                            //             if (mfInstance == null || !context.mounted) return;
                            //             showModalBottomSheet(
                            //               isScrollControlled: true,
                            //               shape: const RoundedRectangleBorder(
                            //                 borderRadius: BorderRadius.only(
                            //                   topLeft: Radius.circular(16),
                            //                   topRight: Radius.circular(16),
                            //                 ),
                            //               ),
                            //               isDismissible: true,
                            //               enableDrag: false,
                            //               useSafeArea: true,
                            //               context: context,
                            //               builder: (context) => Container(
                            //                 padding: EdgeInsets.only(
                            //                   bottom: MediaQuery.of(context).viewInsets.bottom,
                            //                 ),
                            //                 child: MFStockDetailScreen(mfStockData: mfInstance),
                            //               ),
                            //             );
                            //           }
                            //         } catch (e) {
                            //           if (mounted) setState(() => _isLoadingMf = false);
                            //           print("Error opening MF detail: $e");
                            //         }
                            //       } : () async {
                            //         final portfolio = ref.read(portfolioProvider);
                            //         final isin = widget.data.iSIN?.toString() ?? "";
                            //         String matchedToken = "";
                            //         String matchedExch = "";
                            //         if (portfolio.holdingsModel != null && isin.isNotEmpty) {
                            //           for (var holding in portfolio.holdingsModel!) {
                            //             if (holding.exchTsym != null && holding.exchTsym!.isNotEmpty) {
                            //               final exchTsym = holding.exchTsym![0];
                            //               if (exchTsym.isin == isin) {
                            //                 matchedToken = exchTsym.token ?? "";
                            //                 matchedExch = exchTsym.exch ?? "";
                            //                 break;
                            //               }
                            //             }
                            //           }
                            //         }
                            //         if (matchedToken.isEmpty || matchedExch.isEmpty) {
                            //           return;
                            //         }
                            //         await marketwatch.fetchScripQuoteIndex(matchedToken, matchedExch, context);
                            //     final quots = marketwatch.getQuotes;
                            //     if (quots == null) {
                            //       return;
                            //     }
                            //       DepthInputArgs depthArgs = DepthInputArgs(
                            //         exch: marketwatch.getQuotes?.exch?.toString() ?? "",
                            //         token: marketwatch.getQuotes?.token?.toString() ?? "",
                            //         tsym: marketwatch.getQuotes?.tsym?.toString() ?? "",
                            //         instname: marketwatch.getQuotes?.instname?.toString() ?? "",
                            //         symbol: marketwatch.getQuotes?.symbol?.toString() ?? "",
                            //         expDate: marketwatch.getQuotes?.expDate?.toString() ?? "",
                            //         option: marketwatch.getQuotes?.option?.toString() ?? "");
                                    
                            //         marketwatch.calldepthApis(
                            //             context,
                            //             depthArgs,
                            //             "");
                            //       },
                      child: Padding(
                          padding: const EdgeInsets.only(
                              top: 16.0, left: 16.0, bottom: 8.0, right: 16.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: widget.data.sERIES == "GR" ? screenWidth * 0.65 : null,
                                      child: Text(
                                          widget.data.sERIES == "GR" && mfname.isNotEmpty ? mfname : widget.data.nSESYMBOL.toString(),
                                          maxLines: 2,
                                          style: MyntWebTextStyles.title(context,
                                              color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
                                              fontWeight: MyntFonts.semiBold),
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    ledgerdata.screenpledge == 'pledge'
                                        ? Text(
                                            "${double.tryParse(widget.data.estimated.toString())!.toStringAsFixed(2)} (${widget.data.estPercentage}%)",
                                            overflow: TextOverflow.ellipsis,
                                            style: MyntWebTextStyles.para(context,
                                                color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary)),
                                          )
                                        : Text(
                                            "${double.tryParse(widget.data.margin.toString())!.toStringAsFixed(2)}",
                                            overflow: TextOverflow.ellipsis,
                                            style: MyntWebTextStyles.para(context,
                                                color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary)),
                                          ),
                                  ],
                                ),
                                Text(
                                    netValue.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: MyntWebTextStyles.title(context,
                                        color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary)),
                                ),
                              ])),
                    ),
                  ),
                  // Padding(
                  //   padding:
                  //       const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 8.0),
                  //   child: TextWidget.titleText(
                  //       text: ledgerdata.screenpledge == 'pledge'
                  //           ? "Pledge Details"
                  //           : "Unpledge Details",
                  //       textOverflow: TextOverflow.ellipsis,
                  //       theme: theme.isDarkMode,
                  //       color: theme.isDarkMode
                  //           ? colors.textPrimaryDark
                  //           : colors.textPrimaryLight,
                  //       fw: 1),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //     top: 2.0,
                  //     bottom: 0.0,
                  //   ),
                  //   child: Divider(
                  //     color: theme.isDarkMode
                  //         ? const Color(0xffB5C0CF).withOpacity(.15)
                  //         : const Color(0xffF1F3F8),
                  //     thickness: 6.0,
                  //   ),
                  // ),
                  // Padding(
                  //   padding:
                  //       const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                  //   child: Column(
                  //     children: [
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Row(
                  //             children: [
                  //               TextWidget.paraText(
                  //                   text: 'Symbol : ',
                  //                   color: theme.isDarkMode
                  //                       ? colors.textSecondaryDark
                  //                       : colors.textSecondaryLight,
                  //                   textOverflow: TextOverflow.ellipsis,
                  //                   theme: theme.isDarkMode,
                  //                   fw: 3),
                  //               TextWidget.paraText(
                  //                   text: widget.data.nSESYMBOL.toString(),
                  //                   color: theme.isDarkMode
                  //                       ? colors.textSecondaryDark
                  //                       : colors.textSecondaryLight,
                  //                   textOverflow: TextOverflow.ellipsis,
                  //                   theme: theme.isDarkMode,
                  //                   fw: 3),
                  //             ],
                  //           ),
                  //           // Row(
                  //           //   children: [
                  //           //     TextWidget.paraText(
                  //           //         text: 'Total Qty : ',
                  //           //         color: theme.isDarkMode
                  //           //             ? colors.textSecondaryDark
                  //           //             : colors.textSecondaryLight,
                  //           //         textOverflow: TextOverflow.ellipsis,
                  //           //         theme: theme.isDarkMode,
                  //           //         fw: 3),
                  //           //     TextWidget.paraText(
                  //           //         text: netValue.toString(),
                  //           //         color: theme.isDarkMode
                  //           //             ? colors.textSecondaryDark
                  //           //             : colors.textSecondaryLight,
                  //           //         textOverflow: TextOverflow.ellipsis,
                  //           //         theme: theme.isDarkMode,
                  //           //         fw: 3),
                  //           //   ],
                  //           // ),
                  //         ],
                  //       ),
                  //       Padding(
                  //         padding: const EdgeInsets.only(top: 12.0),
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //           children: [
                  //             Row(
                  //               children: [
                  //                 TextWidget.paraText(
                  //                     text: 'Mar / Est : ',
                  //                     color: theme.isDarkMode
                  //                         ? colors.textSecondaryDark
                  //                         : colors.textSecondaryLight,
                  //                     textOverflow: TextOverflow.ellipsis,
                  //                     theme: theme.isDarkMode,
                  //                     fw: 3),
                  //                 TextWidget.paraText(
                  //                     text:
                  //                         "${double.tryParse(widget.data.estimated.toString())!.toStringAsFixed(2)} (${widget.data.estPercentage}%)",
                  //                     textOverflow: TextOverflow.ellipsis,
                  //                     theme: theme.isDarkMode,
                  //                     fw: 3),
                  //               ],
                  //             ),
                  //             if ((double.tryParse(widget.data.cOLQTY.toString())!
                  //                         .toInt() >
                  //                     0) &&
                  //                 ledgerdata.screenpledge == 'pledge')
                  //               Row(
                  //                 children: [
                  //                   TextWidget.subText(
                  //                       text: 'Pledged Qty : ',
                  //                       color: Color(0xFF696969),
                  //                       textOverflow: TextOverflow.ellipsis,
                  //                       theme: theme.isDarkMode,
                  //                       fw: 0),
                  //                   TextWidget.subText(
                  //                       text:
                  //                           "${double.tryParse(widget.data.cOLQTY.toString())!.toInt()} ",
                  //                       textOverflow: TextOverflow.ellipsis,
                  //                       theme: theme.isDarkMode,
                  //                       fw: 1),
                  //                 ],
                  //               ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${ledgerdata.screenpledge == 'pledge' ? 'Pledge' : 'Unpledge'} Qty up to ${netValue.toString()}",
                            overflow: TextOverflow.ellipsis,
                            style: MyntWebTextStyles.bodySmall(context,
                                color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
                                fontWeight: MyntFonts.semiBold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                              height: 44,
                              child: CustomTextFormField(
                                  textAlign: TextAlign.start,
                                  fillColor: resolveThemeColor(context, dark: MyntColors.inputBgDark, light: MyntColors.inputBg),
                                  hintText: '0',
                                  keyboardType: TextInputType.number,
                                  inputFormate: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                    LengthLimitingTextInputFormatter(
                                        15), // Limit to 15 characters
                                  ],
                                  hintStyle: MyntWebTextStyles.para(context,
                                    color: resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary).withValues(alpha: 0.4),
                                  ),
                                  style: MyntWebTextStyles.body(context,
                                    color: resolveThemeColor(context, dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
                                  ),
                                  textCtrl: ledgerdata.selectnetpledge,
                                  onChanged: (value) {
                                    netValue = 0;
                                    ledgerdata.screenpledge == 'pledge'
                                        ? ledgerdata.setselectnetpledge(value,
                                            "${(double.parse(widget.data.nSOHQTY.toString()).toInt()) + (double.parse(widget.data.sOHQTY.toString()).toInt())}")
                                        : ledgerdata.setselectnetpledge(value,
                                            "${(double.parse(widget.data.cOLQTY.toString()).toInt()) + (double.parse(widget.data.sOHQTY.toString()).toInt())}");
                                  })),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                          child: Text(
                              ledgerdata.pledgeerrormsg,
                              overflow: TextOverflow.ellipsis,
                              style: MyntWebTextStyles.caption(context,
                                  color: resolveThemeColor(context, dark: MyntColors.lossDark, light: MyntColors.loss)),
                          ),
                        ),
                        if (ledgerdata.screenpledge == 'pledge') ...[
                          Text(
                            'Which segment do you want to pledge the stocks',
                            style: MyntWebTextStyles.bodySmall(
                              context,
                              darkColor: MyntColors.textPrimaryDark,
                              lightColor: MyntColors.textPrimary,
                              fontWeight: MyntFonts.medium,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Segment chip buttons
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: dropdownItems.map((item) {
                              final isSelected =
                                  widget.data.segmentselect == item.value;
                              final isDisabled = !item.isEnabled;

                              final chipWidget = MouseRegion(
                                cursor: isDisabled
                                    ? SystemMouseCursors.forbidden
                                    : SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: isDisabled
                                      ? null
                                      : () {
                                          ledgerdata.changesegval(
                                              item.value, widget.data);
                                          if (ledgerdata
                                              .listforpledge.isEmpty) {
                                            ledgerdata
                                                .changesegvaldummy("");
                                          } else {
                                            ledgerdata.changesegvaldummy(
                                                item.value);
                                          }
                                        },
                                  child: Opacity(
                                    opacity: isDisabled ? 0.45 : 1.0,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isDisabled
                                              ? resolveThemeColor(context,
                                                  dark: MyntColors
                                                      .borderMutedDark,
                                                  light: MyntColors
                                                      .borderMuted)
                                              : isSelected
                                                  ? resolveThemeColor(
                                                      context,
                                                      dark: MyntColors
                                                          .primaryDark,
                                                      light: MyntColors
                                                          .primary)
                                                  : resolveThemeColor(
                                                      context,
                                                      dark: MyntColors
                                                          .borderMutedDark,
                                                      light: MyntColors
                                                          .borderMuted),
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                        color: isDisabled
                                            ? resolveThemeColor(context,
                                                    dark: MyntColors
                                                        .borderMutedDark,
                                                    light: MyntColors
                                                        .borderMuted)
                                                .withValues(alpha: 0.15)
                                            : isSelected
                                                ? resolveThemeColor(
                                                        context,
                                                        dark: MyntColors
                                                            .primaryDark,
                                                        light: MyntColors
                                                            .primary)
                                                    .withValues(
                                                        alpha: 0.08)
                                                : Colors.transparent,
                                      ),
                                      child: Text(
                                        item.label,
                                        style:
                                            MyntWebTextStyles.bodySmall(
                                          context,
                                          fontWeight: isSelected
                                              ? MyntFonts.semiBold
                                              : MyntFonts.medium,
                                          color: isDisabled
                                              ? resolveThemeColor(
                                                  context,
                                                  dark: MyntColors
                                                      .textSecondaryDark,
                                                  light: MyntColors
                                                      .textSecondary)
                                              : isSelected
                                                  ? resolveThemeColor(
                                                      context,
                                                      dark: MyntColors
                                                          .primaryDark,
                                                      light: MyntColors
                                                          .primary)
                                                  : resolveThemeColor(
                                                      context,
                                                      dark: MyntColors
                                                          .textPrimaryDark,
                                                      light: MyntColors
                                                          .textPrimary),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );

                              return isDisabled
                                  ? Tooltip(
                                      message:
                                          '${item.label} is not available for this scrip',
                                      child: chipWidget,
                                    )
                                  : chipWidget;
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          // Note box
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isDarkMode(context)
                                  ? MyntColors.textSecondaryDark
                                      .withValues(alpha: 0.1)
                                  : const Color(0xffFCEFD4),
                            ),
                            child: Text(
                              'Note: Please ensure that you submit separate pledge requests for MTF and other segments (FO, CD, and Commodities). Combining pledges for MTF and other segments is not permitted. However, combining pledges for FO, CD, and Commodities segments is allowed.',
                              maxLines: 7,
                              overflow: TextOverflow.ellipsis,
                              style: MyntWebTextStyles.para(
                                context,
                                darkColor: MyntColors.textSecondaryDark,
                                lightColor: MyntColors.textSecondary,
                                fontWeight: MyntFonts.regular,
                              ),
                            ),
                          ),
                        ],
                        ledgerdata.dayforpledgeunpledge == 'Saturday' ||
                                ledgerdata.dayforpledgeunpledge == 'Sunday'
                            ? Container(
                                margin: const EdgeInsets.only(
                                    bottom: 16.0, top: 8.0),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                     color: isDarkMode(context) ? MyntColors.textSecondaryDark.withValues(alpha: 0.2) : const Color(0xffFCEFD4)),
                                child: Text(
                                    "Note: Pledge requests process on exchange working days, submissions on weekends or exchange holidays are handled the next working day.",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 7,
                                    style: MyntWebTextStyles.para(context,
                                        color: resolveThemeColor(context, dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary)),
                                ),
                              )
                            : SizedBox(),
                        SafeArea(
                          child: Container(
                              height: 45,
                              width: screenWidth,
                              margin: const EdgeInsets.only(top: 8.0),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      backgroundColor: ((ledgerdata.screenpledge == 'unpledge' &&
                                                  (ledgerdata.pledgesubtn ==
                                                      false)) ||
                                              (ledgerdata.screenpledge == 'pledge' &&
                                                  (ledgerdata.pledgesubtn == false ||
                                                      widget.data.segmentselect.toString() ==
                                                          "null")))
                                          ? resolveThemeColor(context, dark: MyntColors.borderMutedDark, light: MyntColors.borderMuted)
                                          : resolveThemeColor(context, dark: MyntColors.primaryDark, light: MyntColors.primary),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5))),
                                  onPressed: () {
                                    if ((ledgerdata.screenpledge ==
                                                'pledge' &&
                                            (widget.data.segmentselect !=
                                                    'null' &&
                                                ledgerdata.pledgesubtn !=
                                                    false)) ||
                                        (ledgerdata.screenpledge ==
                                                'unpledge' &&
                                            (ledgerdata.pledgesubtn !=
                                                false))) {
                                      if (ledgerdata.screenpledge ==
                                          'pledge') {
                                        ledgerdata.dummypledgeval(
                                            widget.data,
                                            ledgerdata.selectnetpledge.text,
                                            "pledge");
                                        ledgerdata.changesegval(
                                            widget.data.segmentselect
                                                .toString(),
                                            widget.data);
                                        ledgerdata.listforpledgefunction(
                                            context,
                                            ledgerdata.segmentvalue,
                                            widget.data.nSESYMBOL.toString(),
                                            widget.data.iSIN.toString(),
                                            widget.data.aMOUNT.toString(),
                                            ledgerdata.selectnetpledge.text,
                                            widget.data.nET.toString(),
                                            "pledge",
                                            widget.data);
                                        ledgerdata.changesegvaldummy(widget
                                            .data.segmentselect
                                            .toString());
                                      } else {
                                        ledgerdata.dummypledgeval(
                                            widget.data,
                                            ledgerdata.selectnetpledge.text,
                                            "unpledge");
                                        ledgerdata.listforpledgefunction(
                                            context,
                                            ledgerdata.segmentvalue,
                                            widget.data.nSESYMBOL.toString(),
                                            widget.data.iSIN.toString(),
                                            widget.data.aMOUNT.toString(),
                                            ledgerdata.selectnetpledge.text,
                                            widget.data.nET.toString(),
                                            "unpledge",
                                            widget.data);
                                      }
                                      // ledgerdata.changesegval("");
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text("Submit",
                                      style: MyntWebTextStyles.bodySmall(context,
                                          color: MyntColors.textWhite,
                                          fontWeight: MyntFonts.semiBold)))),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                ]),
          ),
        ),
          if (_isLoadingMf)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: resolveThemeColor(context, dark: MyntColors.backgroundColorDark, light: MyntColors.backgroundColor).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
