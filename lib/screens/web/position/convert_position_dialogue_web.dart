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
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/snack_bar.dart';

class ConvertPositionDialogueWeb extends ConsumerStatefulWidget {
  final PositionBookModel convertPosition;
  const ConvertPositionDialogueWeb({super.key, required this.convertPosition});

  @override
  ConsumerState<ConvertPositionDialogueWeb> createState() => _ConvertPositionDialogueWebState();
}

class _ConvertPositionDialogueWebState extends ConsumerState<ConvertPositionDialogueWeb> {
  late TextEditingController qty;
  late TextEditingController maxQty;

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
  void dispose() {
    qty.dispose();
    maxQty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF1F3F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${widget.convertPosition.symbol} ${widget.convertPosition.option} ${widget.convertPosition.exch}",
                    style: TextWidget.textStyle(
                      fontSize: 18,
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(20),
                    splashColor: theme.isDarkMode
                        ? colors.splashColorDark
                        : colors.splashColorLight,
                    highlightColor: theme.isDarkMode
                        ? colors.highlightDark
                        : colors.highlightLight,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.close,
                        size: 22,
                        color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Order Type Section
            Text(
              "Order Type",
              style: TextWidget.textStyle(
                fontSize: 14,
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 3,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Current product (NRML/MIS/CNC)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: theme.isDarkMode ? colors.darkGrey : colors.searchBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${widget.convertPosition.sPrdtAli}",
                    style: TextWidget.textStyle(
                      fontSize: 14,
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                      fw: 0,
                    ),
                  ),
                ),
                
                // Arrow icon
                SvgPicture.asset(
                  assets.rightarrow,
                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  width: 24,
                  height: 24,
                ),
                
                // Target product
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: colors.btnOutlinedBorder,
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                    style: TextWidget.textStyle(
                      fontSize: 14,
                      theme: false,
                      color: colors.colorWhite,
                      fw: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Quantity Section
            Text(
              "Quantity (${widget.convertPosition.ls})",
              style: TextWidget.textStyle(
                fontSize: 14,
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: qty,
              textAlign: TextAlign.center,
              style: TextWidget.textStyle(
                fontSize: 16,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                theme: false,
              ),
              decoration: InputDecoration(
                fillColor: theme.isDarkMode
                    ? colors.darkGrey
                    : const Color(0xffF1F3F8),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colors.primaryDark,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colors.primaryDark,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colors.primaryDark,
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  int number = int.tryParse(qty.text) ?? 0;

                  if (number > 999999) {
                    qty.text = qty.text.substring(0, 6);
                  }

                  String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                  if (newValue != value) {
                    qty.text = newValue;
                    qty.selection = TextSelection.fromPosition(
                      TextPosition(offset: newValue.length),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 24),
            
            // Convert Position Button
            SizedBox(
              width: double.infinity,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: colors.primaryDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
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
                      child: Text(
                        "Convert Position",
                        style: TextWidget.textStyle(
                          fontSize: 16,
                          theme: false,
                          color: colors.colorWhite,
                          fw: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
