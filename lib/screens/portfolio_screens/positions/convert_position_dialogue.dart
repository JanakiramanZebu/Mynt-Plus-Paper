import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      backgroundColor: theme.isDarkMode
          ? const Color.fromARGB(255, 18, 18, 18)
          : colors.colorWhite,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      scrollable: true,
      actionsPadding:
          const EdgeInsets.only(left: 16, right: 16, bottom: 14, top: 3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      titlePadding: const EdgeInsets.only(left: 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.titleText(
              text: 'Position Convertion',
              theme: false,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 1),
          IconButton(
              splashRadius: 20,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close_rounded,
                  color:
                      theme.isDarkMode ? colors.colorWhite : colors.iconColor))
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            const ListDivider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWidget.titleText(
                    text: "${widget.convertPosition.symbol} ",
                    theme: false,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 3,
                    textOverflow: TextOverflow.ellipsis,
                    align: TextAlign.center),
                TextWidget.titleText(
                    text: "${widget.convertPosition.option}  ",
                    theme: false,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 3,
                    textOverflow: TextOverflow.ellipsis,
                    align: TextAlign.center),
                CustomExchBadge(exch: "${widget.convertPosition.exch}")
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                      color: colors.btnBg,
                      borderRadius: BorderRadius.circular(5)),
                  child: TextWidget.subText(
                      text: "${widget.convertPosition.sPrdtAli}",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      fw: 1),
                ),
                const Icon(Icons.double_arrow_sharp),
                Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    decoration: BoxDecoration(
                        color: colors.btnBg,
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
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        fw: 1)),
              ],
            ),
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const SizedBox(height: 8),
                    TextWidget.subText(
                        text: "Max Quantity",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 0),
                    const SizedBox(height: 8),
                    SizedBox(
                        height: 44,
                        child: TextFormField(
                          readOnly: true,
                          style: TextWidget.textStyle(
                              fontSize: 16,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              theme: false,
                              fw: 3),
                          controller: maxQty,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            fillColor: colors.btnBg,
                            filled: true,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 5),
                          ),
                        ))
                  ])),
              const SizedBox(width: 32),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const SizedBox(height: 8),
                    TextWidget.subText(
                        text: "Quantity",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 0),
                    const SizedBox(height: 8),
                    SizedBox(
                        height: 44,
                        child: TextFormField(
                            decoration: InputDecoration(
                              fillColor: colors.btnBg,
                              filled: true,
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 5),
                            ),
                            controller: qty,
                            textAlign: TextAlign.center,
                            style: TextWidget.textStyle(
                                fontSize: 16,
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                                theme: false,
                                fw: 3),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                int number = int.tryParse(qty.text) ?? 0;

                                if (number > 999999) {
                                  qty.text = qty.text
                                      .substring(0, 6); // Restrict max value
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
                  ]))
            ]),
            const SizedBox(height: 12)
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: colors.btnBg,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: colors.btnOutlinedBorder,
                width: 1,
              ),
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
                    ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                        context,
                        qty.text.isEmpty
                            ? 'Quantity can not be empty'
                            : "Quantity can not be 0"));
                  } else if (int.parse(qty.text) > int.parse(maxQty.text)) {
                    setState(() {
                      qty.text = maxQty.text;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                        context,
                        'Quantity can not be greater than Max Quantity'));
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
                  child: TextWidget.subText(
                    text: "Convert",
                    theme: false,
                    color: theme.isDarkMode
                        ? colors.primaryDark
                        : colors.primaryLight,
                    fw: 1,
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
