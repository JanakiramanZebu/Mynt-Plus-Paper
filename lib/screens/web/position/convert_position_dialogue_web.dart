import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../models/portfolio_model/position_book_model.dart';
import '../../../models/portfolio_model/position_convertion_model.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
 
import '../../../res/res.dart';
 
import '../../../sharedWidget/snack_bar.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../../../sharedWidget/cust_text_formfield.dart';

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
        maxQty.text = (int.parse(maxQty.text) ~/ lotSize).toString();
      }

      if (widget.convertPosition.exch == "MCX") {
        qty.text = (int.parse(qty.text) ~/ lotSize).toString();
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
      backgroundColor: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: SizedBox(
        width: 350,
       
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),                margin: const EdgeInsets.only(bottom: 8),
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
                    "${widget.convertPosition.symbol} ${widget.convertPosition.option} ${widget.convertPosition.exch}",
                    style: WebTextStyles.dialogTitle(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: theme.isDarkMode ? WebDarkColors.iconSecondary : WebColors.iconSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                 padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisSize: MainAxisSize.min,
                    children: [
                Text(
                  "Order Type",
                  style: WebTextStyles.formLabel(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Current product (NRML/MIS/CNC)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode ? WebDarkColors.surfaceVariant : WebColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "${widget.convertPosition.sPrdtAli}",
                        style: WebTextStyles.bodySmall(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textSecondary,
                          fontWeight: WebFonts.semiBold,
                        ),
                      ),
                    ),
                    
                    // Arrow icon
                    SvgPicture.asset(
                      assets.rightarrow,
                      color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                      width: 18,
                      height: 18,
                    ),
                    
                    // Target product
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                        borderRadius: BorderRadius.circular(5),
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
                        style: WebTextStyles.bodySmall(
                          isDarkTheme: theme.isDarkMode,
                          color: Colors.white,
                          fontWeight: WebFonts.semiBold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Quantity Section
                Text(
                  "Quantity (${widget.convertPosition.ls})",
                  style: WebTextStyles.formLabel(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textSecondary,
                  ),
                ),
               const SizedBox(height: 10),
               SizedBox(
                 height: 40,
                 child: CustomTextFormField(
                   fillColor: theme.isDarkMode
                       ? WebDarkColors.backgroundTertiary
                       : WebColors.backgroundTertiary,
                   hintText: "0",
                   hintStyle: WebTextStyles.helperText(
                     isDarkTheme: theme.isDarkMode,
                     color: theme.isDarkMode
                         ? WebDarkColors.textSecondary
                         : WebColors.textSecondary,
                   ),
                   keyboardType: TextInputType.number,
                   style: WebTextStyles.formInput(
                     isDarkTheme: theme.isDarkMode,
                     color: theme.isDarkMode
                         ? WebDarkColors.textPrimary
                         : WebColors.textSecondary,
                   ),
                   textCtrl: qty,
                   textAlign: TextAlign.center,
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
               ),
                const SizedBox(height: 24),
                
                // Convert Position Button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        splashColor: Colors.white.withOpacity(0.2),
                        highlightColor: Colors.white.withOpacity(0.1),
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
                            style: WebTextStyles.buttonMd(
                              isDarkTheme: theme.isDarkMode,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                    ],
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
