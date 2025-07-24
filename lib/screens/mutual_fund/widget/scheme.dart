import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readmore/readmore.dart';
import '../../../models/mf_model/mutual_fundmodel.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
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
            const SizedBox(height: 10),
            TextWidget.titleText(
                      align: TextAlign.right,
                      text:"Fund Manager",
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 3),
            const SizedBox(height: 15),
             
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
                      "https://v3.mynt.in/mfapi/static/images/manager/${factSheetData.fundManager?.toLowerCase().trim() ?? "default"}.png"
                    )
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text:  factSheetData.fundManager ?? "N/A",
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark
                                                        :  colors.textPrimaryLight,  
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                         
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             TextWidget.paraText(
                                                    align: TextAlign.right,
                                                    text:  factSheetData.managerDesignation?.isEmpty == true ? "----" : factSheetData.managerDesignation ?? "----",
                                                    color: theme.isDarkMode
                                                        ?  colors.textSecondaryDark
                                                        :  colors.textSecondaryLight, 
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                             
                            const SizedBox(height: 2),
                            TextWidget.paraText(
                                                    align: TextAlign.right,
                                                    text:  "₹${aum.toStringAsFixed(2)} Cr",
                                                    color: theme.isDarkMode
                                                        ?  colors.textSecondaryDark
                                                        :  colors.textSecondaryLight, 
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                             
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             TextWidget.paraText(
                                                    align: TextAlign.right,
                                                    text:  "${factSheetData.managerTotalExperience?.isEmpty == true ? "N/A" : factSheetData.managerTotalExperience} experience",
                                                    color: theme.isDarkMode
                                                        ?  colors.textSecondaryDark
                                                        :  colors.textSecondaryLight, 
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                             TextWidget.paraText(
                                                    align: TextAlign.right,
                                                    text: "$fundsManaged funds managed",
                                                    color: theme.isDarkMode
                                                        ?  colors.textSecondaryDark
                                                        :  colors.textSecondaryLight, 
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                             
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
                  TextWidget.titleText(
                      align: TextAlign.right,
                      text: "Manager Description",
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 3),
               
              const SizedBox(height: 8),

              ReadMoreText(
                factSheetData.managerDetailedDescription ?? "",
                style: textStyle(
                  isDarkMode ? colors.colorWhite : const Color(0xff666666), 
                  12, 
                  FontWeight.w400
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
              const SizedBox(height: 80),
            ] else
              const SizedBox(height: 47),
          ],
        ),
      )
    );
  }
}
