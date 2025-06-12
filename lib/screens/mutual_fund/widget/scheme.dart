import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readmore/readmore.dart';
import '../../../models/mf_model/mutual_fundmodel.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';

class MFSchemeInfo extends ConsumerWidget {
  final MutualFundList mfStockData;
  const MFSchemeInfo({super.key, required this.mfStockData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final factSheetData = ref.watch(mfProvider).factSheetDataModel?.data;
    
    // Early return if essential data is missing
    if (factSheetData == null) {
      return const SizedBox();
    }
    
    final isDarkMode = theme.isDarkMode;
    
    // Safely parse numbers
    final aum = double.tryParse(factSheetData.managerActiveFundsAumSum?.trim() ?? "0.00") ?? 0.00;
    final fundsManaged = (double.tryParse(factSheetData.managerNumberOfActiveFunds?.trim() ?? "0.0") ?? 0.0).ceil();
    
    // Check if manager description exists
    final hasManagerDescription = factSheetData.managerDetailedDescription?.isNotEmpty == true;
    
    return Container(
      color: isDarkMode ? Colors.black : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Text(
              "Fund Manager",
              style: textStyle(
                isDarkMode ? colors.colorWhite : colors.colorBlack,
                18,
                FontWeight.w600
              )
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xffEEF0F2), 
                  width: 1.5
                )
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    maxRadius: 24,
                    backgroundImage: NetworkImage(
                      "https://v3.mynt.in/mf/static/images/manager/${factSheetData.fundManager?.toLowerCase().trim() ?? "default"}.png"
                    )
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          factSheetData.fundManager ?? "N/A",
                          style: textStyle(
                            isDarkMode ? colors.colorWhite : colors.colorBlack,
                            16,
                            FontWeight.w500
                          )
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              factSheetData.managerDesignation?.isEmpty == true ? "----" : factSheetData.managerDesignation ?? "----",
                              style: textStyle(
                                isDarkMode ? colors.colorWhite : colors.colorBlack,
                                12,
                                FontWeight.w500
                              )
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "₹${aum.toStringAsFixed(2)} Cr",
                              style: textStyle(
                                isDarkMode ? colors.colorWhite : colors.colorBlack,
                                14,
                                FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${factSheetData.managerTotalExperience?.isEmpty == true ? "N/A" : factSheetData.managerTotalExperience} experience",
                              style: textStyle(
                                const Color(0xff999999), 
                                14,
                                FontWeight.w500
                              )
                            ),
                            Text(
                              "$fundsManaged funds managed",
                              style: textStyle(
                                const Color(0xff999999), 
                                12, 
                                FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            if(hasManagerDescription) ...[
              Text(
                "Manager Description",
                style: textStyle(
                  isDarkMode ? colors.colorWhite : colors.colorBlack,
                  16,
                  FontWeight.w500
                )
              ),
              const SizedBox(height: 8),
              ReadMoreText(
                factSheetData.managerDetailedDescription ?? "",
                style: textStyle(
                  isDarkMode ? colors.colorWhite : const Color(0xff666666), 
                  13, 
                  FontWeight.w500
                ).copyWith(height: 1.5),
                textAlign: TextAlign.left,
                trimLines: 3,
                moreStyle: isDarkMode ? textStyles.darkmorestyle : textStyles.morestyle,
                lessStyle: isDarkMode ? textStyles.darkmorestyle : textStyles.morestyle,
                colorClickableText: const Color(0xff0037B7),
                trimMode: TrimMode.Line,
                trimCollapsedText: 'Read more',
                trimExpandedText: ' Read less'
              ),
              const SizedBox(height: 47),
            ] else
              const SizedBox(height: 47),
          ],
        ),
      )
    );
  }
}
