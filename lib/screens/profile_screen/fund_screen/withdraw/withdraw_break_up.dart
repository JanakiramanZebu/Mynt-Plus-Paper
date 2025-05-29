// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/list_divider.dart';

class BreakUpDetails extends ConsumerStatefulWidget {
  final TranctionProvider withdraw;
  const BreakUpDetails({super.key, required this.withdraw});

  @override
  ConsumerState<BreakUpDetails> createState() => _BreakUpDetailsState();
}

class _BreakUpDetailsState extends ConsumerState<BreakUpDetails> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              boxShadow: const [
                BoxShadow(
                    color: Color(0xff999999),
                    blurRadius: 4.0,
                    offset: Offset(2.0, 0.0))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(child: CustomDragHandler()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      "Withdraw Summary",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          15,
                          FontWeight.w600),
                    ),
                  ),
                  IconButton(
                      splashRadius: 20,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close_rounded)),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        headerTitleText("Available cash"),
                        contantTitleText(
                            "₹ ${widget.withdraw.payoutdetails!.totalLedger}",
                            theme),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const ListDivider(),
                    SizedBox(
                      height:
                          widget.withdraw.payoutdetails!.collateral == "0.00"
                              ? 0
                              : 10,
                    ),
                    widget.withdraw.payoutdetails!.collateral == "0.00"
                        ? Container()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              headerTitleText(
                                "Collateral Value",
                              ),
                              contantTitleText(
                                  "₹ ${widget.withdraw.payoutdetails!.brkcollamt}",
                                  theme),
                            ],
                          ),
                    SizedBox(
                      height:
                          widget.withdraw.payoutdetails!.collateral == "0.00"
                              ? 0
                              : 10,
                    ),
                    widget.withdraw.payoutdetails!.collateral == "0.00"
                        ? Container()
                        : const ListDivider(),
                    SizedBox(
                      height:
                          widget.withdraw.payoutdetails!.fD == "0.00" ? 0 : 10,
                    ),
                    widget.withdraw.payoutdetails!.fD == "0.00"
                        ? Container()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              headerTitleText("Fixed deposit"),
                              contantTitleText(
                                  "₹ ${widget.withdraw.payoutdetails!.fD}",
                                  theme),
                            ],
                          ),
                    SizedBox(
                      height:
                          widget.withdraw.payoutdetails!.fD == "0.00" ? 0 : 10,
                    ),
                    widget.withdraw.payoutdetails!.fD == "0.00"
                        ? Container()
                        : const ListDivider(),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        headerTitleText("Margin Used"),
                        Text(
                          "₹ ${widget.withdraw.payoutdetails!.margin}",
                          style: widget.withdraw.payoutdetails?.margin == "0.00"
                              ? textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w600)
                              : textStyle(colors.darkred, 14, FontWeight.w600),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const ListDivider(),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        headerTitleText("Withdrawable amount"),
                        contantTitleText(
                            "₹ ${widget.withdraw.payoutdetails!.withdrawAmount}",
                            theme),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const ListDivider(),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Text headerTitleText(String text) {
    return Text(
      text,
      style: textStyle(colors.colorGrey, 14, FontWeight.w500),
    );
  }

  Text contantTitleText(String text, ThemesProvider theme) {
    return Text(
      text,
      style: textStyle(theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          14, FontWeight.w600),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
