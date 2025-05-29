import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../provider/order_input_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart'; 
import '../../sharedWidget/cust_text_formfield.dart';
import 'gtt_bottom_sheet.dart';

class GttCondition extends ConsumerWidget {
  final bool isOco;
  final bool isGtt;
  final bool isModify;
  const GttCondition(
      {super.key,
      required this.isOco,
      required this.isGtt,
      required this.isModify});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderInput = ref.watch(ordInputProvider);
    final theme = ref.read(themeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Alert",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : const Color(0xff666666),
                        14,
                        FontWeight.w500)),
                const SizedBox(height: 3),
                conditionBtn("Alert", isOco ? "LTP" : orderInput.actAlert,
                    context, orderInput, isModify, theme)
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Condition",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : const Color(0xff666666),
                        14,
                        FontWeight.w500)),
                const SizedBox(height: 3),
                conditionBtn("Condition", isOco ? "Grater" : orderInput.actCond,
                    context, orderInput, isModify, theme)
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Value *",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : const Color(0xff666666),
                        14,
                        FontWeight.w500)),
                const SizedBox(height: 6),
                if (isGtt && !isOco)
                  SizedBox(
                      height: 40,
                      child: CustomTextFormField(
                        fillColor: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        hintText: "0",
                        hintStyle: textStyle(
                            const Color(0xff666666), 15, FontWeight.w400),
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            16,
                            FontWeight.w600),
                        textAlign: TextAlign.start,
                        onChanged: (value) {},
                        textCtrl: orderInput.val1Ctrl,
                      )),
                if (isOco)
                  SizedBox(
                      height: 40,
                      child: CustomTextFormField(
                        fillColor: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        hintText: "0",
                        hintStyle: textStyle(
                            const Color(0xff666666), 15, FontWeight.w400),
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            16,
                            FontWeight.w600),
                        textAlign: TextAlign.start,
                        onChanged: (value) {},
                        textCtrl: orderInput.val2Ctrl,
                      ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton conditionBtn(
      String condition,
      String val,
      BuildContext context,
      OrderInputProvider orderInput,
      bool isModify,
      ThemesProvider theme) {
    return ElevatedButton(
        onPressed: orderInput.disableGTTCond || isModify
            ? () {}
            : () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    useSafeArea: true,
                    isDismissible: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16))),
                    context: context,
                    builder: (context) => GttBottomSheet(data: condition));
              },
        style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            backgroundColor:
                theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
            shape: const StadiumBorder()),
        child: Row(
          children: [
            Expanded(
              child: Text(val,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle(
                      theme.isDarkMode
                          ? Color(orderInput.disableGTTCond || isModify
                              ? 0xff666666
                              : 0xffffffff)
                          : Color(orderInput.disableGTTCond || isModify
                              ? 0xff666666
                              : 0xff000000),
                      14,
                      FontWeight.w600)),
            ),
            const Icon(Icons.arrow_drop_down, color: Color(0xff666666))
          ],
        ));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

class PriceTypeBtn extends ConsumerWidget {
  final bool isOco;
  final bool isGtt;
  final String ltp;
  const PriceTypeBtn({
    super.key,
    required this.ltp,
    required this.isOco,
    required this.isGtt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderInput = ref.watch(ordInputProvider);
    final theme = ref.read(themeProvider);
    return SizedBox(
        height: 38,
        child: ListView.separated(
            padding: const EdgeInsets.only(left: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return isGtt && !isOco
                  ? ElevatedButton(
                      onPressed: () {
                        orderInput.chngGTTPriceType(orderInput.prcTypes[index]);

                        if (orderInput.actPrcType == "Market" ||
                            orderInput.actPrcType == "SL MKT") {
                          orderInput.priceCtrl.text = "Market";
                        } else {
                          orderInput.priceCtrl.text = ltp;
                        }
                        FocusScope.of(context).unfocus();
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          backgroundColor: !theme.isDarkMode
                              ? orderInput.actPrcType !=
                                      orderInput.prcTypes[index]
                                  ? const Color(0xffF1F3F8)
                                  : colors.colorBlack
                              : orderInput.actPrcType !=
                                      orderInput.prcTypes[index]
                                  ? colors.darkGrey
                                  : colors.colorbluegrey,
                          shape: const StadiumBorder()),
                      child: Text(orderInput.prcTypes[index],
                          overflow: TextOverflow.ellipsis,
                          style: textStyle(
                              !theme.isDarkMode
                                  ? orderInput.actPrcType !=
                                          orderInput.prcTypes[index]
                                      ? const Color(0xff666666)
                                      : colors.colorWhite
                                  : orderInput.actPrcType !=
                                          orderInput.prcTypes[index]
                                      ? const Color(0xff666666)
                                      : colors.colorBlack,
                              14,
                              orderInput.actPrcType ==
                                      orderInput.prcTypes[index]
                                  ? FontWeight.w600
                                  : FontWeight.w500)))
                  : ElevatedButton(
                      onPressed: () {
                        orderInput.chngOCOPriceType(orderInput.prcTypes[index]);
                        if (orderInput.actOcoPrcType == "Market" ||
                            orderInput.actOcoPrcType == "SL MKT") {
                          orderInput.ocoPriceCtrl.text = "Market";
                        } else {
                          orderInput.ocoPriceCtrl.text = ltp;
                        }

                        FocusScope.of(context).unfocus();
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          backgroundColor: !theme.isDarkMode
                              ? orderInput.actOcoPrcType !=
                                      orderInput.prcTypes[index]
                                  ? const Color(0xffF1F3F8)
                                  : colors.colorBlack
                              : orderInput.actOcoPrcType !=
                                      orderInput.prcTypes[index]
                                  ? colors.darkGrey
                                  : colors.colorWhite,
                          shape: const StadiumBorder()),
                      child: Text(orderInput.prcTypes[index],
                          overflow: TextOverflow.ellipsis,
                          style: textStyle(
                              !theme.isDarkMode
                                  ? orderInput.actOcoPrcType !=
                                          orderInput.prcTypes[index]
                                      ? const Color(0xff666666)
                                      : colors.colorWhite
                                  : orderInput.actOcoPrcType !=
                                          orderInput.prcTypes[index]
                                      ? const Color(0xff666666)
                                      : colors.colorBlack,
                              14,
                              orderInput.actOcoPrcType ==
                                      orderInput.prcTypes[index]
                                  ? FontWeight.w600
                                  : FontWeight.w500)));
            },
            separatorBuilder: (context, index) {
              return const SizedBox(width: 8);
            },
            itemCount: orderInput.prcTypes.length));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
