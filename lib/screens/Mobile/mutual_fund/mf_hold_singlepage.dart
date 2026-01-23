import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
// import '../../sharedWidget/loader_ui.dart';
// import '../mutual_fund_old/mf_order_filter_sheet.dart';
import 'redeem_new_bottomsheet.dart';

class mfholdsinlepage extends StatefulWidget {
  const mfholdsinlepage({super.key});
  @override
  State<mfholdsinlepage> createState() => _mfholdsinlepage();
}

class _mfholdsinlepage extends State<mfholdsinlepage>
    with SingleTickerProviderStateMixin {
  // Helper method to safely format values
  String _formatValue(String? value) {
    return (value == null || value.isEmpty) ? "0.00" : value;
  }

  // Helper method to determine color based on value
  Color _getColorBasedOnValue(String? valueStr, ThemesProvider theme) {
    final value = double.tryParse(valueStr ?? "0") ?? 0;
    return value >= 0 ? theme.isDarkMode ? colors.profitDark : colors.profitLight : theme.isDarkMode ? colors.lossDark : colors.lossLight;
  }


  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final theme = ref.watch(themeProvider);
      final mfdata = ref.watch(mfProvider);

      // Check if data is available
      final hasData = mfdata.holssinglelist != null &&
          mfdata.holssinglelist!.isNotEmpty &&
          mfdata.holssinglelist![0] != null;

      return Scaffold(
        backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        body: Column(
          children: [
            // Header with close button and title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.isDarkMode 
                        ? colors.darkColorDivider 
                        : colors.colorDivider,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      size: 24,
                      color: theme.isDarkMode 
                          ? colors.textPrimaryDark 
                          : colors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextWidget.titleText(
                    text: "Holding Details",
                    color: theme.isDarkMode 
                        ? colors.textPrimaryDark 
                        : colors.textPrimaryLight,
                    fw: 1,
                    theme: theme.isDarkMode,
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: hasData
                  ? _buildHoldingDetails(context, theme, mfdata)
                  : const Center(child: NoDataFound(
                      secondaryEnabled: false,
                    )),
            ),
          ],
        ),
      );
    });
  }

  // Extracted method to build holding details
  Widget _buildHoldingDetails(
      BuildContext context, ThemesProvider theme, MFProvider mfdata) {
    final data = mfdata.holssinglelist![0];

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fund name with logo
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fund logo
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    "https://v3.mynt.in/mfapi/static/images/mf/${data.iSIN?.substring(0, 4) ?? 'default'}.png",
                  ),
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(width: 12),
                // Fund name
                Expanded(
                  child: TextWidget.subText(
                    text: data.name ?? "Unknown Fund",
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    textOverflow: TextOverflow.ellipsis,
                    theme: theme.isDarkMode,
                    maxLines: 2,
                    fw: 1,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            // Redeem button (outlined)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  mfdata.recdemevalu();
                  Navigator.of(context, rootNavigator: true).pop();
                  
                  // Show redeem screen as 30% width right-side panel
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: 'Dismiss',
                    barrierColor: Colors.transparent,
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (dialogContext, animation, secondaryAnimation) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: MediaQuery.of(dialogContext).size.width * 0.3, // 30% width
                            height: MediaQuery.of(dialogContext).size.height,
                            decoration: BoxDecoration(
                              color: Theme.of(dialogContext).scaffoldBackgroundColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(-2, 0),
                                ),
                              ],
                            ),
                            child: const RedemptionBottomScreenNew(),
                          ),
                        ),
                      );
                    },
                    transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        )),
                        child: child,
                      );
                    },
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: theme.isDarkMode 
                        ? colors.primaryDark 
                        : colors.primaryLight,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: TextWidget.subText(
                  text: "Redeem",
                  color: theme.isDarkMode 
                      ? colors.primaryDark 
                      : colors.primaryLight,
                  fw: 2,
                  theme: theme.isDarkMode,
                ),
              ),
            ),

            const SizedBox(height: 24),

            rowOfInfoData(
              "Returns",
              "${_formatValue(data.profitLoss)} (${(double.tryParse(data.changeprofitLoss ?? '0') ?? 0).toStringAsFixed(2)}%)",
              theme,
              valueColor: _getColorBasedOnValue(data.profitLoss, theme),
            ),

            // Units and Avg Price
            rowOfInfoData(
              "Units",
              "${data.avgQty ?? '0'}",
              theme,
            ),

            rowOfInfoData(
              "Avg Price",
              "${data.avgNav ?? '0'}",
              theme,
            ),

            rowOfInfoData(
              "NAV",
              "${data.curNav ?? '0'}",
              theme,
            ),

            // Pledged Units and Current NAV
            rowOfInfoData(
              "Pledged Units",
              "0",
              theme,
            ),

            rowOfInfoData(
              "Current",
              "${data.currentValue ?? '0'}",
              theme,
            ),

            // Invested and Current Value
            rowOfInfoData(
              "Invested",
              "${data.investedValue ?? '0'}",
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Column rowOfInfoData(String title1, String value1, ThemesProvider theme,
      {Color? valueColor}) {
    return Column(children: [
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.subText(
              // align: TextAlign.right,
              text: title1,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              fw: 0),
          TextWidget.subText(
              align: TextAlign.right,
              text: value1,
              color: valueColor ??
                  (theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight),
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              fw: 0),
        ],
      ),
      const SizedBox(height: 8),
      Divider(
        thickness: 0,
        color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
      )
    ]);
  }

  void _showBottomSheet(BuildContext context, Widget BottomSheet) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        useSafeArea: true,
        isDismissible: true,
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: BottomSheet));
  }
}
