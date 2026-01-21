import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// COMMENTED OUT: No longer using dialog screens, redirecting to external URLs instead
// import 'fund_screen_web.dart';
// import 'withdraw_screen_web.dart';

import '../../../locator/locator.dart';
import '../../../locator/preference.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../sharedWidget/common_buttons_web.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/snack_bar.dart';

class SecureFundWeb extends ConsumerStatefulWidget {
  const SecureFundWeb({super.key});

  @override
  ConsumerState<SecureFundWeb> createState() => _SecureFundWebState();
}

class _SecureFundWebState extends ConsumerState<SecureFundWeb> {
  /// Opens the fund management page in a new window
  /// Similar to Vue.js function: openFunds(pageis)
  /// 
  /// @param pageis - 'fund' for add money, or 'withdraw' for withdraw page
  void openFunds(String pageis, BuildContext context) {
    if (!kIsWeb) {
      showResponsiveWarningMessage(context, "This feature is only available on web");
      return;
    }
    
    try {
      final pref = locator<Preferences>();
      String? uid = pref.clientId;
      String? stoken = pref.token; 

      // Check if credentials are missing
      if (uid == null || uid.isEmpty || stoken == null || stoken.isEmpty) {
        showResponsiveWarningMessage(context, "Please login to continue");
        return;
      }
      
      // Construct URL based on page type
      String url;
      if (pageis == 'fund') {
        url = 'https://fund.zebuetrade.com?uid=$uid&token=$stoken';
      } else {
        url = 'https://fund.zebuetrade.com/withdrawal?uid=$uid&token=$stoken';
      }
      html.window.open(url, '_blank');
    } catch (e) {
      print("Error opening fund page: $e");
      showResponsiveWarningMessage(context, "Error opening fund page. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final funds = ref.watch(fundProvider);
    final theme = ref.watch(themeProvider);
    final trancation = ref.watch(transcationProvider);

    return Scaffold(
      backgroundColor: resolveThemeColor(
        context,
        dark: MyntColors.backgroundColorDark,
        light: MyntColors.backgroundColor,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 800;
          final hPadding = isSmallScreen ? 16.0 : 24.0;
          
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Available Margin Card
                  _buildAvailableMarginCard(funds, theme, trancation, isSmallScreen),
                  const SizedBox(height: 24),
                  
                  // Financial Information Cards
                  _buildFinancialInfoCards(funds, theme, isSmallScreen),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(funds, ThemesProvider theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
       
        IconButton(
          onPressed: () {
            ref.read(fundProvider).fetchFunds(context);
          },
          icon: Icon(
            Icons.refresh,
            color: resolveThemeColor(
              context,
              dark: MyntColors.textPrimaryDark,
              light: MyntColors.textPrimary,
            ),
          ),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildAvailableMarginCard(funds, ThemesProvider theme, trancation, bool isSmallScreen) {
    return Container(     
      padding: const EdgeInsets.all(20),     
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Available Margin Title and Value
          Text(
            "Available Margin",
            style: MyntWebTextStyles.title(
              context,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            getFormatter(
              value: double.parse("${funds.fundDetailModel?.avlMrg ?? 0.00}"),
              v4d: false,
              noDecimal: false,
            ),
            style: webText(
              context,
              size: isSmallScreen ? 28 : 35,
              weight: MyntFonts.semiBold,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              MyntPrimaryButton(
                label: "Add Money",
                isFullWidth: isSmallScreen,
                padding: const EdgeInsets.symmetric(horizontal: 35),
                onPressed: () {
                  openFunds('fund', context);
                },
              ),
              MyntOutlinedButton(
                label: "Withdraw",
                isFullWidth: isSmallScreen,
                padding: const EdgeInsets.symmetric(horizontal: 35),
                onPressed: () {
                  openFunds('withdraw', context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Action button helper has been replaced by MyntPrimaryButton and MyntOutlinedButton from common_buttons_web.dart


  Widget _buildFinancialInfoCards(funds, ThemesProvider theme, bool isSmallScreen) {
    final content = isSmallScreen
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: "Available Capital",
                value: "${funds.fundDetailModel?.totCredit ?? 0.00}",
                content: _buildAvailableCashContent(funds, theme),
                context: context,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.dividerDark,
                    light: MyntColors.divider,
                  ),
                  height: 1,
                ),
              ),
              _buildSection(
                title: "Margin Used",
                value: "${funds.fundDetailModel?.utilizedMrgn ?? 0.00}",
                content: _buildMarginUsedContent(funds, theme),
                context: context,
              ),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildSection(
                  title: "Available Capital",
                  value: "${funds.fundDetailModel?.totCredit ?? 0.00}",
                  content: _buildAvailableCashContent(funds, theme),
                  context: context,
                ),
              ),
              Container(
                width: 0.5,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.dividerDark,
                  light: MyntColors.divider,
                ),
              ),
              Expanded(
                child: _buildSection(
                  title: "Margin Used",
                  value: "${funds.fundDetailModel?.utilizedMrgn ?? 0.00}",
                  content: _buildMarginUsedContent(funds, theme),
                  context: context,
                ),
              ),
            ],
          );

    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          color: resolveThemeColor(
            context,
            dark: MyntColors.backgroundColorDark,
            light: MyntColors.backgroundColor,
          ),
          borderRadius: BorderRadius.circular(0),
          border: Border.all(
            color: resolveThemeColor(
              context,
              dark: MyntColors.dividerDark,
              light: MyntColors.divider,
            ),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: content,
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String value,
    required Widget content,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.dividerDark,
                  light: MyntColors.divider,
                ),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: MyntWebTextStyles.body(
                  context,
                  darkColor: MyntColors.textSecondaryDark,
                  lightColor: MyntColors.textSecondary,
                  fontWeight: MyntFonts.medium,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                getFormatter(
                  value: double.tryParse(value) ?? 0.00,
                  v4d: false,
                  noDecimal: false,
                ),
                style: MyntWebTextStyles.title(
                  context,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary,
                  fontWeight: MyntFonts.semiBold,
                ),
              ),
            ],
          ),
        ),
        content,
      ],
    );
  }


  Widget _buildAvailableCashContent(funds, theme) {
    final filteredCredits = funds.listOfCredits.length > 1
        ? funds.listOfCredits
            .sublist(1)
            .where((item) =>
                item["name"] != "Collateral" &&
                item["name"] != "Opening Balance" &&
                item["name"] != "Payin")
            .toList()
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Cash Balance
          _buildInfoRow(
            "Cash Balance",
            getFormatter(
              value: funds.listOfCredits.isNotEmpty
                  ? double.parse("${funds.listOfCredits[0]["value"]}")
                  : 0.00,
              v4d: false,
              noDecimal: false,
            ),
            theme,
          ),
          
          // Payin
          _buildInfoRow(
            "Payin",
            getFormatter(
              value: _safeParseDouble("${funds.fundDetailModel?.payin ?? 0.00}"),
              v4d: false,
              noDecimal: false,
            ),
            theme,
          ),
          
          // Collateral Equity
          _buildInfoRow(
            "Collateral Equity",
            getFormatter(
              value: _safeParseDouble("${funds.pledgeAndUnpledgeModel?.noncashEquivalent ?? 0.00}"),
              v4d: false,
              noDecimal: false,
            ),
            theme,
          ),
          
          // Collateral Liquid
          _buildInfoRow(
            "Collateral Liquid",
            getFormatter(
              value: _safeParseDouble("${funds.pledgeAndUnpledgeModel?.cashEquivalent ?? 0.00}"),
              v4d: false,
              noDecimal: false,
            ),
            theme,
          ),
          
          // Collateral Additional (conditional)
          if (funds.fundDetailModel?.brkcollamt != null &&
              funds.fundDetailModel?.brkcollamt != 0.00)
            _buildInfoRow(
              "Collateral Additional",
              getFormatter(
                value: _safeParseDouble("${funds.fundDetailModel?.brkcollamt ?? 0.00}"),
                v4d: false,
                noDecimal: false,
              ),
              theme,
            ),
          
          // Additional Credits
          if (filteredCredits.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...filteredCredits.map((item) => _buildInfoRow(
              "${item["name"]}",
              getFormatter(
                value: _safeParseDouble("${item["value"]}"),
                v4d: false,
                noDecimal: false,
              ),
              theme,
            )),
          ],
        ],
    );
  }

  Widget _buildMarginUsedContent(funds, theme) {
    final filteredMargin = funds.listOfUsedMrgn.length > 1
        ? funds.listOfUsedMrgn
            .sublist(1)
            .where((item) =>
                item["name"] != "Span" &&
                item["name"] != "Exposure" &&
                item["name"] != "Option Premium" &&
                item["name"] != "Unrealized Expenses")
            .toList()
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Span
          _buildInfoRow(
            "Span",
            getFormatter(
              value: _safeParseDouble("${funds.fundDetailModel?.span ?? 0.00}"),
              v4d: false,
              noDecimal: false,
            ),
            theme,
          ),
          
          // Exposure
          _buildInfoRow(
            "Exposure",
            getFormatter(
              value: _safeParseDouble("${funds.fundDetailModel?.expo ?? 0.00}"),
              v4d: false,
              noDecimal: false,
            ),
            theme,
          ),
          
          // Basket Margin
          _buildInfoRow(
            "Basket Margin",
            getFormatter(
              value: _safeParseDouble("${funds.fundDetailModel?.scripbskmar ?? 0.00}"),
              v4d: false,
              noDecimal: false,
            ),
            theme,
          ),
          
          // CO / BO Margin
          _buildInfoRow(
            "CO / BO Margin",
            getFormatter(
              value: _safeParseDouble("${funds.fundDetailModel?.cobomargin ?? 0.00}"),
              v4d: false,
              noDecimal: false,
            ),
            theme,
          ),
          
          // Option Premium
          _buildInfoRow(
            "Option Premium",
            getFormatter(
              value: _safeParseDouble("${funds.fundDetailModel?.premium ?? 0.00}"),
              v4d: false,
              noDecimal: false,
            ),
            theme,
          ),
          
          // Delivery Sell Benefit
          _buildInfoRow(
            "Delivery Sell Benefit",
            getFormatter(
              value: _safeParseDouble("${funds.fundDetailModel?.deliverySellBenefit ?? 0.00}"),
              v4d: false,
              noDecimal: false,
            ),
            theme,
          ),
          
          // Unrealized Expenses
          _buildInfoRow(
            "Unrealized Expenses",
            getFormatter(
              value: _safeParseDouble("${funds.fundDetailModel?.brokerage ?? 0.00}"),
              v4d: false,
              noDecimal: false,
            ),
            theme,
          ),
          
          // Additional Margin Items
          if (filteredMargin.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...filteredMargin.map((item) => _buildInfoRow(
              "${item["name"]}",
              getFormatter(
                value: _safeParseDouble("${item["value"]}"),
                v4d: false,
                noDecimal: false,
              ),
              theme,
            )),
          ],
        ],
    );
  }

  Widget  _buildInfoRow(String label, String value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: MyntWebTextStyles.body(
              context,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
              fontWeight: MyntFonts.medium,
            ),
          ),
          Text(
            value,
            style: MyntWebTextStyles.body(
              context,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
              fontWeight: MyntFonts.medium,
            ),
          ),
        ],
      ),
    );
  }

  double _safeParseDouble(String value) {
    try {
      if (value.isEmpty || value == "null" || value == "undefined") {
        return 0.0;
      }
      return double.parse(value);
    } catch (e) {
      return 0.0;
    }
  }
}
