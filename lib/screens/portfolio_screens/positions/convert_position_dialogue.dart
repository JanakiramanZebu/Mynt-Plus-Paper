import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/portfolio_model/position_book_model.dart';
import '../../../models/portfolio_model/position_convertion_model.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/cust_text_formfield.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/snack_bar.dart';

class ConvertPositionDialogue extends StatefulWidget {
  final PositionBookModel convertPosition;
  const ConvertPositionDialogue({super.key, required this.convertPosition});

  @override
  State<ConvertPositionDialogue> createState() =>
      _ConvertPositionDialogueState();
}

class _ConvertPositionDialogueState extends State<ConvertPositionDialogue> {
  TextEditingController qty = TextEditingController();
  TextEditingController maxQty = TextEditingController();

  @override
  void initState() {
    super.initState();

    setState(() {
      maxQty = TextEditingController(
          text: widget.convertPosition.netqty!.replaceAll("-", ""));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
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
          Text('Position Convertion',
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  16,
                  FontWeight.w600)),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close_rounded,
                  color: theme.isDarkMode
                      ? const Color(0xffBDBDBD)
                      : colors.colorGrey))
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
                Text("${widget.convertPosition.symbol} ",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: textStyles.appBarTitleTxt.copyWith(
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack)),
                Text("${widget.convertPosition.option}  ",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: textStyles.appBarTitleTxt.copyWith(
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack)),
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
                        color: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        borderRadius: BorderRadius.circular(5)),
                    child: Text("${widget.convertPosition.sPrdtAli}",
                        style: textStyles.scripNameTxtStyle.copyWith(
                            color: context.read(themeProvider).isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack))),
                const Icon(Icons.double_arrow_sharp),
                Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                        widget.convertPosition.sPrdtAli == "MIS" &&
                                (widget.convertPosition.exch == "NSE" ||
                                    widget.convertPosition.exch == "BSE")
                            ? "CNC"
                            : widget.convertPosition.sPrdtAli == "MIS"
                                ? "NRML"
                                : widget.convertPosition.sPrdtAli == "CNC"
                                    ? "MIS"
                                    : "MIS",
                        style: textStyles.scripNameTxtStyle.copyWith(
                            color: context.read(themeProvider).isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack))),
              ],
            ),
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const SizedBox(height: 8),
                    headerTitleText("Max Quantity", theme),
                    const SizedBox(height: 8),
                    SizedBox(
                        height: 44,
                        child: CustomTextFormField(
                          fillColor: theme.isDarkMode ? colors.darkGrey : null,
                          isReadable: true,
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              16,
                              FontWeight.w600),
                          textCtrl: maxQty,
                          textAlign: TextAlign.center,
                        ))
                  ])),
              const SizedBox(width: 32),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const SizedBox(height: 8),
                    headerTitleText("Quantity", theme),
                    const SizedBox(height: 8),
                    SizedBox(
                        height: 44,
                        child: CustomTextFormField(
                            fillColor:
                                theme.isDarkMode ? colors.darkGrey : null,
                            inputFormate:[FilteringTextInputFormatter.digitsOnly],
                            hintText: maxQty.text,
                            hintStyle: textStyle(
                                const Color(0xff666666), 15, FontWeight.w400),
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                16,
                                FontWeight.w600),
                            textCtrl: qty,
                            textAlign: TextAlign.center,
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
          child: ElevatedButton(
            onPressed: () async {
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
                    context, 'Quantity can not be greater than Max Quantity'));
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
                        qty: qty.text,
                        trantype: widget.convertPosition.netqty!.startsWith('-')
                            ? "S"
                            : "B",
                        tsym: "${widget.convertPosition.tsym}");
                context
                    .read(portfolioProvider)
                    .fetchPositionConverstion(positionConvertionInput, context);
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor:
                  theme.isDarkMode ? colors.colorbluegrey : colors.colorBlack,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
            ),
            child: Text("Convert",
                style: textStyle(
                    !theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500)),
          ),
        ),
      ],
    );
  }

  Text headerTitleText(String text, ThemesProvider theme) {
    return Text(text,
        style: textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            14,
            FontWeight.w500));
  }
}
