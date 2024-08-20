import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/mf_model/mutual_fundmodel.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart'; 

class MFComparison extends ConsumerWidget {
  final MutualFundList mfStockData;
  const MFComparison({super.key, required this.mfStockData});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    final mfData = watch(mfProvider).schemePeers!;
    final mfProvide = watch(mfProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
              "Comparison with ${mfStockData.schemeType![0].toUpperCase()}${mfStockData.schemeType!.substring(1).toLowerCase()} :${mfStockData.sCHEMESUBCATEGORY!.replaceAll("Fund", '').replaceAll("Hybrid", "")}",
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  16,
                  FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
              "Comparison breakdown of ${mfProvide.factSheetDataModel!.data!.fundName} information",
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  12,
                  FontWeight.w500)),
          Container(
              padding: const EdgeInsets.only(bottom: 8),
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          width: 6))),
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: mfProvide.comYears.length,
                itemBuilder: (BuildContext context, int index) {
                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        width: 1,
                        color: mfProvide.comYears[index]["yearName"] ==
                                mfProvide.comYear
                            ? colors.colorBlack
                            : const Color(0xff666666),
                      ),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40))),
                    ),
                    onPressed: () async {
                      mfProvide.chngComYear(
                          mfProvide.comYears[index]["year"],
                          mfProvide.comYears[index]["yearName"],
                          mfStockData.iSIN!);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        mfProvide.comYears[index]["yearName"],
                        style: textStyle(
                            mfProvide.comYears[index]["yearName"] ==
                                    mfProvide.comYear
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
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mfData.topSchemes!.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${mfData.topSchemes![index].name}",
                      style: textStyle(colors.colorBlack, 14, FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("AUM (Cr): ",
                              style: textStyle(const Color(0xff999999), 12,
                                  FontWeight.w500)),
                          Text(
                              (double.parse(
                                      mfData.topSchemes![index].aum!.isEmpty
                                          ? "0.00"
                                          : mfData.topSchemes![index].aum!))
                                  .toStringAsFixed(2),
                              style: textStyle(
                                  colors.colorBlack, 12, FontWeight.w500)),
                        ],
                      ),
                      Row(
                        children: [
                          Text("${mfData.topSchemes![index].yearName}: ",
                              style: textStyle(const Color(0xff999999), 12,
                                  FontWeight.w500)),
                          Text("${mfData.topSchemes![index].yearPer}%",
                              style: textStyle(
                                  colors.colorBlack, 12, FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                      margin: const EdgeInsets.only(top: 2),
                      height: 16,
                      child: Row(
                        children: [
                          Text("Ratings: ",
                              style: textStyle(const Color(0xff999999), 12,
                                  FontWeight.w500)),
                          Expanded(
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 5,
                              itemBuilder: (BuildContext context, int ind) {
                                return Icon(Icons.star,
                                    size: 16,
                                    color: int.parse(mfData.topSchemes![index]
                                                    .fundRat ??
                                                "0") <=
                                            ind
                                        ? const Color(0xff999999)
                                        : const Color(0xfff7cd6c));
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const SizedBox(width: 2);
                              },
                            ),
                          ),
                        ],
                      ))
                ],
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider);
            },
          ),
          const SizedBox(height: 40),

          
        ],
      ),
    );
  }
}
