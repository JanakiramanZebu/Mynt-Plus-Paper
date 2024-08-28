import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../provider/bond_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/functions.dart';
import 'bonds_order.dart';

class BondsList extends ConsumerWidget {
  const BondsList({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);

    final bondsData = watch(bondProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("Top Bonds",
              style: textStyle(Colors.black, 18, FontWeight.w600)),
        ),
        Container(
            padding: const EdgeInsets.only(bottom: 12),
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        width: 6))),
            height: 54,
            child: ListView.separated(
              padding: const EdgeInsets.only(left: 16),
              scrollDirection: Axis.horizontal,
              itemCount: bondsData.topBonds.length,
              itemBuilder: (BuildContext context, int index) {
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      width: 1,
                      color: bondsData.topBonds[index] == bondsData.topBond
                          ? colors.colorBlack
                          : const Color(0xff666666),
                    ),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40))),
                  ),
                  onPressed: () async {
                    bondsData.changeBondType(bondsData.topBonds[index]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text(
                      bondsData.topBonds[index],
                      style: textStyle(
                          bondsData.topBonds[index] == bondsData.topBond
                              ? colors.colorBlack
                              : const Color(0xff666666),
                          14,
                          FontWeight.w600),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(width: 10);
              },
            )),
        bondsData.bondLists!.isEmpty
            ? const Center(child: NoDataFound())
            : ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: bondsData.bondLists!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${bondsData.bondLists![index].name}",
                                style: textStyles.scripNameTxtStyle.copyWith(
                                    color: theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack)),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                CustomExchBadge(
                                    exch:
                                        "${bondsData.bondLists![index].symbol}"),
                                Text(
                                    "  ${bondsData.bondLists![index].biddingStartDate} ${bondsData.bondLists![index].dailyStartTime!.substring(0, bondsData.bondLists![index].dailyStartTime!.length - 3)} to ${bondsData.bondLists![index].biddingEndDate!.substring(5, 16)} ${bondsData.bondLists![index].dailyEndTime!.substring(0, bondsData.bondLists![index].dailyStartTime!.length - 3)}",
                                    style: textStyle(const Color(0xff666666),
                                        12, FontWeight.w500)),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Divider(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text("Min. Qty: ",
                                        style: textStyle(
                                            const Color(0xff666666),
                                            13,
                                            FontWeight.w500)),
                                    Text(
                                        "${(int.parse(bondsData.bondLists![index].lotSize ?? "0") / double.parse(bondsData.bondLists![index].faceValue ?? "0")).ceil()}",
                                        style: textStyle(colors.colorBlack, 13,
                                            FontWeight.w600)),
                                  ],
                                ),
                                Text("Lot size",
                                    style: textStyle(const Color(0xff666666),
                                        13, FontWeight.w500)),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text("Min. Inv: ",
                                        style: textStyle(
                                            const Color(0xff666666),
                                            13,
                                            FontWeight.w500)),
                                    Text(
                                        "₹${bondsData.bondLists![index].minBidQuantity}",
                                        style: textStyle(colors.colorBlack, 13,
                                            FontWeight.w600)),
                                  ],
                                ),
                                Row(
                                  // ignore: unnecessary_string_interpolations
                                  children: [
                                    Text(
                                        "${(double.parse(bondsData.bondLists![index].issueSize ?? "0.00") / 10000000).ceil()}",
                                        style: textStyle(colors.colorBlack, 13,
                                            FontWeight.w600)),
                                    Text(" Cr",
                                        style: textStyle(
                                            const Color(0xff666666),
                                            13,
                                            FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: ()async {
                                 await  bondsData
                                    .fetchLedgerBal();
                                bondsData
                                    .changeUnits(bondsData.bondLists![index]);

                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return BondsOrdert(
                                          bondData:
                                              bondsData.bondLists![index]);
                                    });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: const Color(0xffF1F3F8),
                                    borderRadius: BorderRadius.circular(30)),
                                child: Text("Invest",
                                    style: textStyles.scripNameTxtStyle
                                        .copyWith(
                                            color: theme.isDarkMode
                                                ? colors.colorLightBlue
                                                : colors.colorBlue)),
                              ),
                            )
                          ]));
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(height: 12);
                },
              )
      ],
    );
  }

   
}
