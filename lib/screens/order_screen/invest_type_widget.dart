import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
 
import '../../models/marketwatch_model/scrip_info.dart';
import '../../provider/order_input_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/enums.dart'; 

class InvesTypeWidget extends ConsumerWidget {
  final ScripInfoModel scripInfo;
  final String ordType;
  const InvesTypeWidget(
      {super.key, required this.scripInfo, required this.ordType});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final orderInput = watch(ordInputProvider);
    final theme = context.read(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text("Investment type",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500))),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          if (scripInfo.exch != "NCOM") ...[
            Radio<InvestType>(
              fillColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.disabled)) {
                  return const Color(0xff666666);
                }
                return theme.isDarkMode
                    ? colors.colorWhite
                    : const Color(0xff666666);
              }),
              activeColor: theme.isDarkMode
                  ? colors.colorWhite
                  : const Color(0xff666666),
              value: InvestType.intraday,
              groupValue: ordType == "OCO"
                  ? orderInput.ocoInvestType
                  : orderInput.investType,
              onChanged: (InvestType? value) {
                orderInput.chngInvesType(value!, ordType);
              },
            ),
            Text('Intraday',
                style: textStyle(
                    theme.isDarkMode
                        ? ordType == "OCO"
                            ? Color(
                                orderInput.ocoInvestType == InvestType.intraday
                                    ? 0xffffffff
                                    : 0xff666666)
                            : Color(orderInput.investType == InvestType.intraday
                                ? 0xffffffff
                                : 0xff666666)
                        : ordType == "OCO"
                            ? Color(
                                orderInput.ocoInvestType == InvestType.intraday
                                    ? 0xff3E4763
                                    : 0xff666666)
                            : Color(orderInput.investType == InvestType.intraday
                                ? 0xff3E4763
                                : 0xff666666),
                    14,
                    FontWeight.w500))
          ],
          Radio<InvestType>(
            fillColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return const Color(0xff666666);
              }
              return theme.isDarkMode
                  ? colors.colorWhite
                  : const Color(0xff666666);
            }),
            activeColor:
                theme.isDarkMode ? colors.colorWhite : const Color(0xff666666),
            value: scripInfo.seg == "EQT"
                ? InvestType.delivery
                : InvestType.carryForward,
            groupValue: ordType == "OCO"
                ? orderInput.ocoInvestType
                : orderInput.investType,
            onChanged: (InvestType? value) {
              orderInput.chngInvesType(value!, ordType);
            },
          ),
          Text(scripInfo.seg == "EQT" ? 'Delivery' : "Carry Forward",
              style: textStyle(
                  theme.isDarkMode
                      ? ordType == "OCO"
                          ? Color(
                              orderInput.ocoInvestType == InvestType.delivery ||
                                      orderInput.ocoInvestType ==
                                          InvestType.carryForward
                                  ? 0xffffffff
                                  : 0xff666666)
                          : Color(
                              orderInput.investType == InvestType.delivery ||
                                      orderInput.investType ==
                                          InvestType.carryForward
                                  ? 0xffffffff
                                  : 0xff666666)
                      : ordType == "OCO"
                          ? Color(orderInput.ocoInvestType ==
                                      InvestType.delivery ||
                                  orderInput.ocoInvestType ==
                                      InvestType.carryForward
                              ? 0xff3E4763
                              : 0xff666666)
                          : Color(
                              orderInput.investType == InvestType.delivery ||
                                      orderInput.investType ==
                                          InvestType.carryForward
                                  ? 0xff3E4763
                                  : 0xff666666),
                  14,
                  FontWeight.w500))
        ]),
      ],
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
