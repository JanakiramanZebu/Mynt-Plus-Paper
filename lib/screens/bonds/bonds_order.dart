import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/bonds_data/bond_lists.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import '../../provider/bond_provider.dart';
import '../../provider/fund_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/cust_text_formfield.dart';
import '../../sharedWidget/list_divider.dart';

class BondsOrdert extends ConsumerWidget {
  final BondLists bondData;
  const BondsOrdert({super.key, required this.bondData});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    final bondsData = watch(bondProvider);
    return AlertDialog(
        backgroundColor: theme.isDarkMode
            ? const Color.fromARGB(255, 18, 18, 18)
            : colors.colorWhite,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        scrollable: true,
        actionsPadding:
            const EdgeInsets.only(left: 16, right: 16, bottom: 4, top: 4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        titlePadding: const EdgeInsets.only(left: 16, top: 6),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${bondData.name}',
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w600)),
              const SizedBox(height: 3),
              Row(children: [
                CustomExchBadge(exch: '${bondData.symbol}'),
                CustomExchBadge(exch: '${bondData.series}'),
                CustomExchBadge(exch: '${bondData.isin}')
              ])
            ]),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close_rounded),
              color:
                  theme.isDarkMode ? const Color(0xffBDBDBD) : colors.colorGrey,
            )
          ],
        ),
        content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const ListDivider(),
              const SizedBox(height: 8),
              Text("Unit",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
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
                      hintText: '${bondsData.minUnit}',
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
                        onTap: () {
                          bondsData
                              .minusUnit('${bondData.cutoffPrice ?? 0.00}');
                        },
                        child: SvgPicture.asset(
                            theme.isDarkMode
                                ? assets.darkCMinus
                                : assets.minusIcon,
                            fit: BoxFit.scaleDown),
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          bondsData.addUnit('${bondData.cutoffPrice ?? 0.00}');
                        },
                        child: SvgPicture.asset(
                            theme.isDarkMode ? assets.darkAdd : assets.addIcon,
                            fit: BoxFit.scaleDown),
                      ),
                      textCtrl: bondsData.unitValueCtrl,
                      onChanged: (value) {
                        bondsData.requireBal(value.isEmpty ? "0" : value,
                            '${bondData.cutoffPrice ?? 0.00}');
                      })),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Unit limits ${bondsData.minUnit} - ${bondsData.maxUnit}",
                    style: textStyle(colors.colorGrey, 12, FontWeight.w500)),
                Text(
                    "Ledger balance : ₹${bondsData.ledgerBalModel!.total ?? "0.00"}",
                    style: textStyle(colors.colorGrey, 12, FontWeight.w500))
              ]),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Text("Price: ",
                      style: textStyle(colors.colorGrey, 12, FontWeight.w500)),
                  Text("₹${bondData.cutoffPrice}",
                      style: textStyle(colors.colorBlue, 12, FontWeight.w500))
                ]),
                Row(children: [
                  Text("Required* : ",
                      style: textStyle(colors.colorGrey, 12, FontWeight.w500)),
                  Text("₹${bondsData.requiredAmt}",
                      style: textStyle(colors.colorBlue, 12, FontWeight.w500))
                ])
              ]),
              if (bondsData.requiredAmt >
                  double.parse(bondsData.ledgerBalModel!.total ?? "0.00")) ...[
              InkWell(
                onTap: ()async{
                  
                    await context.read(fundProvider).fetchHstoken(context);

                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.fundTransaction,
                        arguments: "fund");
                  
                },
                  child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                          color: const Color(0xffe3f2fd),
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(assets.dInfo,
                                color: colors.colorBlue),
                            Text(
                                " Insufficient balance, Add fund ₹${bondsData.requiredAmt - double.parse(bondsData.ledgerBalModel!.total ?? "0.00")} Click here",
                                style: textStyle(
                                    colors.colorBlue, 12, FontWeight.w500))
                          ])),
                )
              ]
            ])),
        actions: [
          ElevatedButton(
              onPressed: () async {
                // setState(() {

                // });
              },
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: !theme.isDarkMode
                      ? bondsData.requiredAmt >
                              double.parse(
                                  bondsData.ledgerBalModel!.total ?? "0.00")
                          ? const Color(0xfff5f5f5)
                          : colors.colorBlack
                      : bondsData.requiredAmt >
                              double.parse(
                                  bondsData.ledgerBalModel!.total ?? "0.00")
                          ? colors.darkGrey
                          : colors.colorbluegrey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
              child: Text("Invest ",
                  style: GoogleFonts.inter(
                      textStyle: textStyle(
                          !theme.isDarkMode
                              ? bondsData.requiredAmt >
                                      double.parse(
                                          bondsData.ledgerBalModel!.total ??
                                              "0.00")
                                  ? const Color(0xff999999)
                                  : colors.colorWhite
                              : bondsData.requiredAmt >
                                      double.parse(
                                          bondsData.ledgerBalModel!.total ??
                                              "0.00")
                                  ? colors.darkGrey
                                  : colors.colorBlack,
                          14,
                          FontWeight.w500))))
        ]);
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
