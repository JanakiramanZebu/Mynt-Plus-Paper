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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mfData = ref.watch(mfProvider).schemePeers!;
    final mfProvide = ref.watch(mfProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 27),
          Text(
              "Comparison with ${mfStockData.schemeType![0].toUpperCase()}${mfStockData.schemeType!.substring(1).toLowerCase()} :${mfStockData.sCHEMESUBCATEGORY!.replaceAll("Fund", '').replaceAll("Hybrid", "")}",
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  17,
                  FontWeight.w600)),
          const SizedBox(height: 13),
          Text(
              "Comparison breakdown of ${mfProvide.factSheetDataModel!.data!.fundName} information",
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w500)),
                  const SizedBox(height: 5),
          Container(
              padding: const EdgeInsets.only(bottom: 8),
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          width: 2))),
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
           const SizedBox(height: 15),
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
                      style: textStyle(colors.colorBlack, 15, FontWeight.w500)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                              (double.parse(
                                      mfData.topSchemes![index].aum!.isEmpty
                                          ? "0.00"
                                          : mfData.topSchemes![index].aum!))
                                  .toStringAsFixed(2),
                              style: textStyle(
                                  colors.colorBlack, 14, FontWeight.w600)),
                                    const SizedBox(height: 5),
                          Text("AUM (Cr) ",
                              style: textStyle(const Color(0xff999999), 13,
                                  FontWeight.w500)),
                         
                        ],
                      ),

Column(
children: [
    Container(
  margin: const EdgeInsets.only(top: 2),
  child: SingleChildScrollView(  // Make the entire Column scrollable
    child: Column(
      children: [
        // ListView displaying the stars with fixed height
        SizedBox(
          height: 16,  // Set height explicitly for ListView
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (BuildContext context, int ind) {
              return Icon(
                Icons.star,
                size: 16,
                color: int.parse(mfData.topSchemes![index].fundRat ?? "0") <= ind
                    ? const Color(0xff999999)
                    : const Color(0xfff7cd6c),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(width: 2);
            },
          ),
        ),
                                    const SizedBox(height: 5),

        Text(
          "Ratings",
          style: textStyle(const Color(0xff999999), 14, FontWeight.w500),
        ),
      ],
    ),
  ),
)

],
),



                      Column(
                        children: [

                         
                          Text("${mfData.topSchemes![index].yearPer}%",
                              style: textStyle(
                                  colors.colorBlack, 15, FontWeight.w500)),
                                                                      const SizedBox(height: 5),

                                   Text("${mfData.topSchemes![index].yearName} ",
                              style: textStyle(const Color(0xff999999), 12,
                                  FontWeight.w500)),
                        ],
                      ),
                   
                    ],
                  ),
                  const SizedBox(height: 15),
              

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
