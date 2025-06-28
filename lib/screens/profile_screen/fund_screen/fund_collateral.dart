import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/functions.dart';

class FundCollateral extends ConsumerStatefulWidget {
  const FundCollateral({super.key});

  @override
  ConsumerState<FundCollateral> createState() => _FundCollateralState();
}

class _FundCollateralState extends ConsumerState<FundCollateral> {
  @override
  void initState() {
    super.initState();
    // Fetch pledge details when the bottom sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fundProvider).fetchPledgeDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final fund = ref.watch(fundProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        boxShadow: const [
          BoxShadow(
            color: Color(0xff999999),
            blurRadius: 4.0,
            offset: Offset(2.0, 0.0)
          )
        ]
      ),
      child: fund.isLoadingPledgeDetails
        ? _buildLoadingState(theme)
        : _buildContent(theme, fund),
    );
  }
  
  Widget _buildLoadingState(theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const CustomDragHandler(),
        const SizedBox(height: 40),
        CircularProgressIndicator(
          color: colors.colorBlue,
        ),
        const SizedBox(height: 16),
        Text(
          "Loading Collateral Details...",
          style: TextWidget.textStyle(
            fontSize: 14,
            theme: false,
            color: colors.colorGrey,
            fw: 0
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
  
  Widget _buildContent(theme, fund) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const CustomDragHandler(),
        const SizedBox(height: 10),
        
        // Header Section
        Center(
          child: Column(
            children: [
              Text(
                "Collateral Details",
                style: TextWidget.textStyle(
                  fontSize: 18,
                  theme: false,
                  color: colors.colorGrey,
                  fw: 0
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Data Grid
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // CASH EQUIVALENT
              _buildDataRow(
                "CASH EQUIVALENT",
                getFormatter(
                  value: double.parse("${fund.pledgeAndUnpledgeModel?.cashEquivalent ?? 0.00}"),
                  v4d: false,
                  noDecimal: false
                ),
              ),
              
              // NON CASH
              _buildDataRow(
                "NON CASH",
                getFormatter(
                  value: double.parse("${fund.pledgeAndUnpledgeModel?.noncashEquivalent ?? 0.00}"),
                  v4d: false,
                  noDecimal: false
                ),
                isLast: true,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Available Estimated Margin Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.colorWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.colorDivider.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Available Estimated Margin",
                style: TextWidget.textStyle(
                  fontSize: 14,
                  theme: false,
                  color: colors.colorGrey,
                  fw: 0
                ),
              ),
              const SizedBox(height: 8),
              Text(
                getFormatter(
                  value: double.parse("${fund.pledgeAndUnpledgeModel?.estTotalAvailable ?? 0.00}"),
                  v4d: false,
                  noDecimal: false
                ),
                style: TextWidget.textStyle(
                  fontSize: 24,
                  theme: false,
                  color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  fw: 1
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Do you want to get margin to trade?",
                style: TextWidget.textStyle(
                  fontSize: 14,
                  theme: false,
                  color: colors.colorGrey,
                  fw: 0
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: colors.colorBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context); // Close current bottom sheet first
                    await fund.fetchHstoken(context);
                    Navigator.pushNamed(
                      context,
                      Routes.reportWebViewApp,
                      arguments: "pledge"
                    );
                  },
                  child: Text(
                    "Get Margin",
                    style: TextWidget.textStyle(
                      fontSize: 16,
                      theme: false,
                      color: colors.colorWhite,
                      fw: 0
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 10),
      ]
    );
  }
  
  Widget _buildDataRow(String title, String value, {bool isFirst = false, bool isLast = false}) {
    final theme = ref.read(themeProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : colors.colorDivider.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: TextWidget.textStyle(
                fontSize: 13,
                theme: false,
                color: colors.colorGrey,
                fw: 0
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextWidget.textStyle(
                fontSize: 14,
                theme: false,
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                fw: 0
              ),
            ),
          ),
        ],
      ),
    );
  }
}
