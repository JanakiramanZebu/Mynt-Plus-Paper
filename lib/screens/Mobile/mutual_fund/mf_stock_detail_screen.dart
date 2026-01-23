import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/mf_model/mutual_fundmodel.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/splash_loader.dart';
import 'widget/allocation.dart';
import 'widget/overview.dart';
import 'widget/performance.dart';
import 'widget/scheme.dart';
import 'mf_order_screen.dart';

class MFStockDetailScreen extends StatefulWidget {
  final MutualFundList mfStockData;
  final bool fromSearch;

  // final TaxSaving mfStockData;
  //  final mfData = mfProvider;
  const MFStockDetailScreen({super.key, required this.mfStockData, this.fromSearch = false});

//    final MutualFundList mfStockData1;
//  MFStockDetailScreen({super.key, required this.mfStockData1});

  @override
  State<MFStockDetailScreen> createState() => _MFStockDetailScreenState();
}

class _MFStockDetailScreenState extends State<MFStockDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      final fund = ref.watch(fundProvider);
      final mfData = ref.watch(mfProvider);

      return Scaffold(
        backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        body: Stack(
          children: [
            Column(
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
                        text: "Fund Details",
                        color: theme.isDarkMode 
                            ? colors.textPrimaryDark 
                            : colors.textPrimaryLight,
                        fw: 1,
                        theme: theme.isDarkMode,
                      ),
                    ],
                  ),
                ),
                
                // Fund info section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fund name and NAV
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(
                              "https://v3.mynt.in/mfapi/static/images/mf/${mfData.factSheetDataModel?.data?.amccode ?? widget.mfStockData.aMCCode ?? 'default'}.png",
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget.subText(
                                  text: _formatFundName(mfData),
                                  color: theme.isDarkMode 
                                      ? colors.textPrimaryDark 
                                      : colors.textPrimaryLight,
                                  fw: 1,
                                  theme: theme.isDarkMode,
                                  textOverflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    TextWidget.paraText(
                                      text: "NAV: ₹${mfData.factSheetDataModel?.data?.currentNAV ?? '--'}",
                                      color: theme.isDarkMode 
                                          ? colors.textSecondaryDark 
                                          : colors.textSecondaryLight,
                                      fw: 0,
                                      theme: theme.isDarkMode,
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: TextWidget.captionText(
                                        text: widget.mfStockData.type ?? "Equity",
                                        color: theme.isDarkMode 
                                            ? colors.textSecondaryDark 
                                            : colors.textSecondaryLight,
                                        fw: 0,
                                        theme: theme.isDarkMode,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Action buttons - One-time (outlined) and SIP (filled)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: mfData.singleloader == true ? null : () async {
                                final isin = widget.mfStockData.iSIN;
                                final schemeCode = widget.mfStockData.schemeCode;

                                if (widget.mfStockData.sIPFLAG == "Y" &&
                                    isin != null &&
                                    schemeCode != null) {
                                  await mfData.invertfun(isin, schemeCode, context);
                                  String amt = widget.mfStockData.minimumPurchaseAmount ?? "0";
                                  mfData.invAmt.text = amt.split('.').first;
                                }
                                mfData.orderchangetitle("One-time");
                                mfData.orderpagetite("SDS");
                                mfData.chngOrderType("One-time");
                                
                                // Close the side panel first, then navigate
                                Navigator.of(context, rootNavigator: true).pop();
                                showGeneralDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  barrierLabel: 'Dismiss',
                                  transitionDuration: const Duration(milliseconds: 200),
                                  pageBuilder: (context, animation, secondaryAnimation) {
                                    return Align(
                                      alignment: Alignment.centerRight,
                                      child: Material(
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width >= 1100
                                              ? MediaQuery.of(context).size.width * 0.25
                                              : MediaQuery.of(context).size.width * 0.90,
                                          height: MediaQuery.of(context).size.height,
                                          child: MFOrderScreen(mfData: widget.mfStockData),
                                        ),
                                      ),
                                    );
                                  },
                                  transitionBuilder: (context, animation, secondaryAnimation, child) {
                                    return SlideTransition(
                                      position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
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
                                text: "One-time",
                                color: theme.isDarkMode 
                                    ? colors.primaryDark 
                                    : colors.primaryLight,
                                fw: 2,
                                theme: theme.isDarkMode,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: mfData.singleloader == true ? null : () async {
                                final isin = widget.mfStockData.iSIN;
                                final schemeCode = widget.mfStockData.schemeCode;

                                if (widget.mfStockData.sIPFLAG == "Y" &&
                                    isin != null &&
                                    schemeCode != null) {
                                  await mfData.invertfun(isin, schemeCode, context);
                                  String amt = widget.mfStockData.minimumPurchaseAmount ?? "0";
                                  mfData.installmentAmt.text = amt.split('.').first;
                                }
                                mfData.orderchangetitle("SIP");
                                mfData.chngOrderType("SIP");
                                mfData.orderpagetite("SDS");
                                
                                // Close the side panel first, then navigate
                                Navigator.of(context, rootNavigator: true).pop();
                                Navigator.of(context, rootNavigator: true).pushNamed(
                                  Routes.mforderScreen,
                                  arguments: widget.mfStockData,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: theme.isDarkMode 
                                    ? colors.primaryDark 
                                    : colors.primaryLight,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: TextWidget.subText(
                                text: "SIP",
                                color: colors.colorWhite,
                                fw: 2,
                                theme: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Divider
                Divider(
                  color: theme.isDarkMode 
                      ? colors.darkColorDivider 
                      : colors.colorDivider,
                  height: 1,
                ),
                
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        MFOverview(mfStockData: widget.mfStockData),
                        MFPerformance(mfStockData: widget.mfStockData),
                        MFAllocation(mfStockData: widget.mfStockData),
                        MFSchemeInfo(mfStockData: widget.mfStockData),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Loading overlay
            if (mfData.singleloader == true)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularLoaderImage(),
                ),
              ),
          ],
        ),
      );
    });
  }

  String _formatFundName(dynamic mfData) {
    if (mfData.factSheetDataModel?.data?.name != null) {
      return mfData.factSheetDataModel!.data!.name!
          .replaceAll(RegExp(r'(Reg \(G\)|\(G\))$'), ' ');
    }
    return widget.mfStockData.schemeName ?? 'Unknown Fund';
  }

  Widget _buildFundMetrics(dynamic theme, MFProvider mfdatapro) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // _buildMetricColumn(
        //     "AUM (CR)", _formatAum(widget.mfStockData.aUM), theme),
        _buildMetricColumn(
            "NAV",
            _formatValue(mfdatapro.factSheetDataModel?.data?.currentNAV),
            theme),
        // _buildMetricColumn("MIN. INV",
        //     _formatValue(widget.mfStockData.minimumPurchaseAmount), theme),
        // _buildMetricColumn("5YR CAGR",
        //     _formatYearData(widget.mfStockData.fIVEYEARDATA), theme),
      ],
    );
  }

  Widget _buildMetricColumn(String title, String value, dynamic theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 7),
        TextWidget.subText(
            align: TextAlign.right,
            text: title,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
            fw: 0),
        const SizedBox(height: 6),
        TextWidget.paraText(
            align: TextAlign.right,
            text: value,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textPrimaryLight,
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
            fw: 0),
      ],
    );
  }

  String _formatAum(String? aum) {
    if (aum == null || aum.isEmpty) return "0.00";
    try {
      return double.parse(aum).toStringAsFixed(2);
    } catch (e) {
      return "0.00";
    }
  }

  String _formatValue(String? value) {
    return value?.isEmpty ?? true ? "0.00" : value!;
  }

  String _formatYearData(String? yearData) {
    if (yearData == null || yearData.isEmpty) return "0.00";
    return "$yearData%";
  }
}
