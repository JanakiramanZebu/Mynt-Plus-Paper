import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/mf_model/mutual_fundmodel.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/cust_text_formfield.dart';
import '../../sharedWidget/custom_switch_btn.dart';
import '../../sharedWidget/list_divider.dart';

class MFOrderScreen extends StatefulWidget {
  final MutualFundList mfData;
  const MFOrderScreen({super.key, required this.mfData});

  @override
  State<MFOrderScreen> createState() => _MFOrderScreenState();
}

class _MFOrderScreenState extends State<MFOrderScreen> {
  bool islumpSum = true;

  TextEditingController invAmt=TextEditingController();

  @override
  void initState() {
    setState(() {
      invAmt.text="${widget.mfData.minimumPurchaseAmount}";
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = watch(themeProvider);
      return AlertDialog(
          backgroundColor: theme.isDarkMode
              ? const Color.fromARGB(255, 18, 18, 18)
              : colors.colorWhite,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
          actionsPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 4, top: 4),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          titlePadding: const EdgeInsets.only(left: 16, top: 16),
          // scrollable: true,
          title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("${widget.mfData.fSchemeName}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w500)),
                const SizedBox(height: 4),
                SizedBox(
                    height: 18,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          CustomExchBadge(
                              exch: widget.mfData.schemeName!.contains("GROWTH")
                                  ? "GROWTH"
                                  : widget.mfData.schemeName!
                                          .contains("IDCW PAYOUT")
                                      ? "IDCW PAYOUT"
                                      : widget.mfData.schemeName!
                                              .contains("IDCW REINVESTMENT")
                                          ? "IDCW REINVESTMENT"
                                          : widget.mfData.schemeName!
                                                  .contains("IDCW")
                                              ? "IDCW"
                                              : "NORMAL"),
                          CustomExchBadge(exch: "${widget.mfData.schemeType}"),
                          CustomExchBadge(
                              exch: widget.mfData.sCHEMESUBCATEGORY!
                                  .replaceAll("Fund", '')
                                  .replaceAll("Hybrid", "")
                                  .toUpperCase())
                        ])))
              ]),
          content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ListView(shrinkWrap: true, children: [
                const ListDivider(),
                const SizedBox(height: 10),
                Text("Choose tenure",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w500)),
                SizedBox(height: 8),
                Row(children: [
                  Text("Lumpsum",
                      style: textStyle(
                          Color(islumpSum ? 0xff3E4763 : 0xff666666),
                          14,
                          FontWeight.w500)),
                  const SizedBox(width: 8),
                  CustomSwitch(
                      onChanged: (bool value) {
                        setState(() {
                          islumpSum = value;
                        });
                      },
                      value: islumpSum),
                  const SizedBox(width: 8),
                  Text("Monthly SIP",
                      style: textStyle(
                          Color(!islumpSum ? 0xff3E4763 : 0xff666666),
                          14,
                          FontWeight.w500)),
                ]),
                const SizedBox(height: 8),
                Text("Investment amount",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w500)),
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    height: 44,
                    child: CustomTextFormField(
                        textAlign: TextAlign.start,
                        fillColor: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        hintText: ' ',
                        hintStyle: textStyle(
                            const Color(0xff666666), 15, FontWeight.w400),
                        inputFormate: [FilteringTextInputFormatter.digitsOnly],
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            16,
                            FontWeight.w600),
                        prefixIcon: InkWell(
                          onTap: () {},
                          child: SvgPicture.asset(
                              theme.isDarkMode
                                  ? assets.darkCMinus
                                  : assets.minusIcon,
                              fit: BoxFit.scaleDown),
                        ),
                        suffixIcon: InkWell(
                            onTap: () {
                              ;
                            },
                            child: SvgPicture.asset(
                                theme.isDarkMode
                                    ? assets.darkAdd
                                    : assets.addIcon,
                                fit: BoxFit.scaleDown)),
                        textCtrl: invAmt,
                        onChanged: (value) {})),
                Text(
                    "  Min. ₹${widget.mfData.minimumPurchaseAmount} (multiple of ${widget.mfData.purchaseAmountMultiplier})",
                    style: textStyle(colors.colorGrey, 12, FontWeight.w500)),
                SizedBox(height: 8),
                Text("Payment method",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w500)),
                SizedBox(height: 8),
                Text("Bank account",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w500)),
                SizedBox(height: 8),
                Text("UPI ID (Virtual payment address)",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w500)),
                SizedBox(height: 8),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SvgPicture.asset(assets.dInfo, color: colors.colorBlue),
                  Expanded(
                      child: Text(
                          " NAV will be allotted on the day funds are realised at the clearing corporation.",
                          style:
                              textStyle(colors.colorBlue, 12, FontWeight.w500)))
                ])
              ])),
          actions: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    Text("AUM ",
                        style:
                            textStyle(colors.colorGrey, 12, FontWeight.w500)),
                    Text(
                        (double.parse(widget.mfData.aUM!.isEmpty
                                    ? "0.00"
                                    : widget.mfData.aUM!) /
                                10000000)
                            .toStringAsFixed(2),
                        style:
                            textStyle(colors.colorBlue, 12, FontWeight.w500)),
                    Text(" Cr.",
                        style:
                            textStyle(colors.colorGrey, 12, FontWeight.w500)),
                  ],
                ),
                SizedBox(height: 3),
                Row(children: [
                  Text("NAV ",
                      style: textStyle(colors.colorGrey, 12, FontWeight.w500)),
                  Text("₹${widget.mfData.nETASSETVALUE}",
                      style: textStyle(colors.colorBlue, 12, FontWeight.w500))
                ])
              ]),
              Row(children: [
                ElevatedButton(
                    onPressed: () async {
                      // setState(() {

                      // });
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorbluegrey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    child: Text("Cancel",
                        style: GoogleFonts.inter(
                            textStyle: textStyle(
                                !theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500)))),
                SizedBox(width: 10),
                ElevatedButton(
                    onPressed: () async {
                      // setState(() {

                      // });
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: !theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorbluegrey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    child: Text("Invest",
                        style: GoogleFonts.inter(
                            textStyle: textStyle(
                                !theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500))))
              ])
            ])
          ]);
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
