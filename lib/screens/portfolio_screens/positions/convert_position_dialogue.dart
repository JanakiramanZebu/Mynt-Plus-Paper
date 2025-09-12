import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../models/portfolio_model/position_book_model.dart';
import '../../../models/portfolio_model/position_convertion_model.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/cust_text_formfield.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/snack_bar.dart';

class ConvertPositionDialogue extends ConsumerStatefulWidget {
  final PositionBookModel convertPosition;
  const ConvertPositionDialogue({super.key, required this.convertPosition});

  @override
  ConsumerState<ConvertPositionDialogue> createState() =>
      _ConvertPositionDialogueState();
}

class _ConvertPositionDialogueState
    extends ConsumerState<ConvertPositionDialogue> {
  TextEditingController qty = TextEditingController();
  TextEditingController maxQty = TextEditingController();

  @override
  void initState() {
    super.initState();

    setState(() {
      maxQty = TextEditingController(
          text: widget.convertPosition.netqty!.replaceAll("-", ""));
      qty = TextEditingController(text: maxQty.text);
      int lotSize = int.parse("${widget.convertPosition.ls ?? 0}");

      if (widget.convertPosition.exch == "MCX") {
        maxQty.text = (int.parse(maxQty.text) / lotSize).toInt().toString();
      }

      if (widget.convertPosition.exch == "MCX") {
        qty.text = (int.parse(qty.text) / lotSize).toInt().toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    return AlertDialog(
       backgroundColor: theme
                                                                        .isDarkMode
                                                                    ? const Color(
                                                                        0xFF121212)
                                                                    : const Color(
                                                                        0xFFF1F3F8),
      titlePadding:
          const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      scrollable: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      actionsPadding:
          const EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 8),
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextWidget.titleText(
                text:
                    "${widget.convertPosition.symbol} ${widget.convertPosition.option} ${widget.convertPosition.exch}",
                theme: false,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 1,
                textOverflow: TextOverflow.ellipsis,
              ),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () async {
                    await Future.delayed(const Duration(milliseconds: 150));
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(20),
                  splashColor: theme.isDarkMode
                      ? colors.splashColorDark
                      : colors.splashColorLight,
                  highlightColor: theme.isDarkMode
                      ? colors.splashColorDark
                      : colors.splashColorLight,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.close_rounded,
                      size: 22,
                     color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget.subText(
                text: "Order Type",
                theme: false,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 3),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                      color: colors.btnBg,
                      borderRadius: BorderRadius.circular(5)),
                  child: TextWidget.subText(
                      text: "${widget.convertPosition.sPrdtAli}",
                      theme: false,
                      color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                      fw: 0),
                ),
                SvgPicture.asset(
                  assets.rightarrow,
                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  width: 20,
                  height: 20,
                ),
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                        color: colors.btnOutlinedBorder,
                        borderRadius: BorderRadius.circular(5)),
                    child: TextWidget.subText(
                        text: widget.convertPosition.sPrdtAli == "MIS" &&
                                (widget.convertPosition.exch == "NSE" ||
                                    widget.convertPosition.exch == "BSE")
                            ? "CNC"
                            : widget.convertPosition.sPrdtAli == "MIS"
                                ? "NRML"
                                : widget.convertPosition.sPrdtAli == "CNC"
                                    ? "MIS"
                                    : "MIS",
                        theme: false,
                        color: colors.colorWhite,
                        fw: 0)),
              ],
            ),
            const SizedBox(height: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextWidget.subText(
                  text: "Quantity (${widget.convertPosition.ls})",
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0),
              const SizedBox(height: 10),
              SizedBox(
                  height: 40,
                  child: TextFormField(
                      decoration: InputDecoration(
                         fillColor: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color: colors.primaryDark,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 5),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color: colors.primaryDark,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color: colors.primaryDark,
                            width: 1,
                          ),
                        ),
                      ),
                      controller: qty,
                      textAlign: TextAlign.center,
                      style: TextWidget.textStyle(
                          fontSize: 16,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          theme: false,
                          ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          int number = int.tryParse(qty.text) ?? 0;

                          if (number > 999999) {
                            qty.text =
                                qty.text.substring(0, 6); // Restrict max value
                          }

                          String newValue =
                              value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (newValue != value) {
                            qty.text = newValue;
                            qty.selection = TextSelection.fromPosition(
                              TextPosition(offset: newValue.length),
                            );
                          }
                        }
                      })),
            ]),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: colors.primaryDark,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Material(
              color: Colors.transparent,
              shape: const BeveledRectangleBorder(),
              child: InkWell(
                customBorder: const BeveledRectangleBorder(),
                splashColor: theme.isDarkMode
                    ? colors.splashColorDark
                    : colors.splashColorLight,
                highlightColor: theme.isDarkMode
                    ? colors.highlightDark
                    : colors.highlightLight,
                onTap: () async {
                  if (qty.text.isEmpty || qty.text == "0") {
                    showResponsiveWarningMessage(
                        context,
                        qty.text.isEmpty
                            ? 'Quantity can not be empty'
                            : "Quantity can not be 0");
                  } else if (int.parse(qty.text) > int.parse(maxQty.text)) {
                    setState(() {
                      qty.text = maxQty.text;
                    });
                    showResponsiveWarningMessage(
                        context,
                        'Quantity can not be greater than Max Quantity');
                  } else {
                    PositionConvertionInput positionConvertionInput =
                        PositionConvertionInput(
                            exch: "${widget.convertPosition.exch}",
                            postype: "DAY",
                            prd: widget.convertPosition.sPrdtAli == "MIS" &&
                                    (widget.convertPosition.exch == "NSE" ||
                                        widget.convertPosition.exch == "BSE")
                                ? "C"
                                : widget.convertPosition.sPrdtAli == "MIS"
                                    ? "M"
                                    : widget.convertPosition.sPrdtAli == "CNC"
                                        ? "I"
                                        : "I",
                            prevprd: "${widget.convertPosition.prd}",
                            qty: widget.convertPosition.exch == 'MCX'
                                ? (int.parse(qty.text) *
                                        int.parse(widget.convertPosition.ls
                                            .toString()))
                                    .toInt()
                                    .toString()
                                : qty.text,
                            trantype:
                                widget.convertPosition.netqty!.startsWith('-')
                                    ? "S"
                                    : "B",
                            tsym: "${widget.convertPosition.tsym}");
                    ref.read(portfolioProvider).fetchPositionConverstion(
                        positionConvertionInput, context);
                  }
                },
                child: Center(
                  child: TextWidget.titleText(
                    text: "Convert Position",
                    theme: false,
                    color: colors.colorWhite,
                    fw: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
