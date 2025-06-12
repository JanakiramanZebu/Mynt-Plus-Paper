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
    final mfProvide = ref.watch(mfProvider);
    final mfData = mfProvide.schemePeers;
    final factSheetData = mfProvide.factSheetDataModel?.data;
    
    // Early return if essential data is missing
    if (mfData == null || factSheetData == null) {
      return const SizedBox();
    }
    
    final isDarkMode = theme.isDarkMode;
    // Safe string manipulation with null checks
    final schemeType = mfStockData.schemeType?.isNotEmpty == true 
        ? "${mfStockData.schemeType![0].toUpperCase()}${mfStockData.schemeType!.substring(1).toLowerCase()}"
        : "Fund";
    final schemeSubCategory = mfStockData.sCHEMESUBCATEGORY?.replaceAll("Fund", '').replaceAll("Hybrid", "") ?? "";
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 27),
          Text(
            "Comparison with $schemeType:$schemeSubCategory",
            style: textStyle(
              isDarkMode ? colors.colorWhite : colors.colorBlack,
              17,
              FontWeight.w600
            )
          ),
          const SizedBox(height: 13),
          Text(
            "Comparison breakdown of ${factSheetData.fundName ?? ""} information",
            style: textStyle(
              isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w500
            )
          ),
          const SizedBox(height: 5),
          
          // Year selector
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode
                    ? colors.darkGrey
                    : const Color(0xffF1F3F8),
                  width: 2
                )
              )
            ),
            height: 42,
            child: mfProvide.comYears.isNotEmpty
              ? ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: mfProvide.comYears.length,
                itemBuilder: (_, int index) {
                  final yearItem = mfProvide.comYears[index];
                  final isSelected = yearItem["yearName"] == mfProvide.comYear;
                  
                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        width: 1,
                        color: isSelected
                          ? colors.colorBlack
                          : const Color(0xff666666),
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40))
                      ),
                    ),
                    onPressed: () async {
                      if (!isSelected && mfStockData.iSIN != null) {
                        await mfProvide.chngComYear(
                          yearItem["year"] ?? "",
                          yearItem["yearName"] ?? "",
                          mfStockData.iSIN!
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        yearItem["yearName"] ?? "",
                        style: textStyle(
                          isSelected
                            ? colors.colorBlack
                            : const Color(0xff666666),
                          14,
                          FontWeight.w600
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 10),
              )
              : const Center(child: Text("No comparison data available")),
          ),
          
          const SizedBox(height: 15),
          
          // Schemes list
          if (mfData.topSchemes != null && mfData.topSchemes!.isNotEmpty)
            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mfData.topSchemes!.length,
              itemBuilder: (_, int index) {
                final scheme = mfData.topSchemes![index];
                // Safely parse numeric values
                final double aum = double.tryParse(scheme.aum?.isEmpty == true ? "0.00" : scheme.aum ?? "0.00") ?? 0.00;
                final int rating = int.tryParse(scheme.fundRat ?? "0") ?? 0;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(scheme.name ?? "",
                      style: textStyle(colors.colorBlack, 15, FontWeight.w500)),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // AUM Column
                        Column(
                          children: [
                            Text(
                              aum.toStringAsFixed(2),
                              style: textStyle(
                                colors.colorBlack, 14, FontWeight.w600
                              )
                            ),
                            const SizedBox(height: 5),
                            Text("AUM (Cr) ",
                              style: textStyle(const Color(0xff999999), 13, FontWeight.w500)),
                          ],
                        ),

                        // Ratings Column  
                        Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              child: SizedBox(
                                height: 16,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 5,
                                  itemBuilder: (_, int ind) {
                                    return Icon(
                                      Icons.star,
                                      size: 16,
                                      color: rating <= ind
                                        ? const Color(0xff999999)
                                        : const Color(0xfff7cd6c),
                                    );
                                  },
                                  separatorBuilder: (_, __) => const SizedBox(width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Ratings",
                              style: textStyle(const Color(0xff999999), 14, FontWeight.w500),
                            ),
                          ],
                        ),

                        // Year Performance Column
                        Column(
                          children: [
                            Text("${scheme.yearPer ?? 0}%",
                              style: textStyle(colors.colorBlack, 15, FontWeight.w500)),
                            const SizedBox(height: 5),
                            Text("${scheme.yearName ?? ""} ",
                              style: textStyle(const Color(0xff999999), 12, FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                );
              },
              separatorBuilder: (_, __) => Divider(
                color: isDarkMode ? colors.darkColorDivider : colors.colorDivider
              ),
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "No comparison data available",
                  style: textStyle(
                    isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500
                  ),
                ),
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
