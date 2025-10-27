import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/mf_model/mutual_fundmodel.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../res/global_state_text.dart';
import '../../../../sharedWidget/functions.dart';

class MFRollingReturns extends ConsumerWidget {
  final MutualFundList mfStockData;
  const MFRollingReturns({super.key, required this.mfStockData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mfProvide = ref.watch(mfProvider);
    final factSheetData = mfProvide.factSheetDataModel?.data;
    
    // Early return if essential data is missing
    if (factSheetData == null) {
      return const SizedBox();
    }
    
    final isDarkMode = theme.isDarkMode;
    
    // Check if rolling data is available
    final hasRollingData = false; // Replace with actual check when data is available
    
    if (!hasRollingData) {
      return const SizedBox();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          TextWidget.headText(
            text: "Rolling Returns",
            theme: isDarkMode,
            fw: 1,
          ),
          const SizedBox(height: 10),
          
          // When rolling returns data is available, implement here
          TextWidget.subText(
            text: "No rolling returns data available for this fund",
            theme: isDarkMode,
            fw: 0,
            color: isDarkMode ? colors.colorWhite : const Color(0xff666666),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

