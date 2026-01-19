import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/global_font_web.dart';
// COMMENTED OUT: No longer using dialog screens, redirecting to external URLs instead
// import 'fund_screen_web.dart';
// import 'withdraw_screen_web.dart';

import '../../../locator/locator.dart';
import '../../../locator/preference.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart' hide WebTextStyles;
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
      backgroundColor: theme.isDarkMode ? WebDarkColors.background : WebColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Section
              // _buildHeaderSection(funds, theme),
              // const SizedBox(height: 32),
              
              // Available Margin Card
              _buildAvailableMarginCard(funds, theme, trancation),
              const SizedBox(height: 24),
              
              // Financial Information Cards
              _buildFinancialInfoCards(funds, theme),
            ],
          ),
        ),
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
            color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          ),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildAvailableMarginCard(funds, ThemesProvider theme, trancation) {
    return Container(     
      padding: const EdgeInsets.all(20),     
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Available Margin Title and Value
          Text(
            "Available Margin",
            style: WebTextStyles.title(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textSecondary
                  : WebColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            getFormatter(
              value: double.parse("${funds.fundDetailModel?.avlMrg ?? 0.00}"),
              v4d: false,
              noDecimal: false,
            ),
            style: WebTextStyles.custom(
              fontSize: 35,
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
              fontWeight: WebFonts.semiBold,
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                "Add Money",
                true,
                theme,
                () {
                  // Redirect to external fund page for add money
                  openFunds('fund', context);
                  
                  // COMMENTED OUT: Original dialog-based add money flow
                  // showDialog(context: context, builder: (context) => FundScreenWeb(dd: trancation));
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                "Withdraw",
                false,
                theme,
                () {
                  // Redirect to external fund page for withdraw
                  openFunds('withdraw', context);
                  
                  // COMMENTED OUT: Original dialog-based withdraw flow
                  // await trancation.fetchValidateToken(context);
                  // Future.delayed(
                  //   const Duration(milliseconds: 100),
                  //   () async {
                  //     await trancation.ip();
                  //     await trancation.fetchupiIdView(
                  //       trancation.bankdetails!.dATA![trancation.indexss][1],
                  //       trancation.bankdetails!.dATA![trancation.indexss][2],
                  //     );
                  //     await trancation.fetchcwithdraw(context);
                  //   },
                  // );
                  // trancation.changebool(false);
                  // showDialog(context: context, builder: (context) => WithdrawScreenWeb(withdarw: trancation, foucs: FocusNode(), theme: theme, segment: ""));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, bool isPrimary, ThemesProvider theme, VoidCallback onPressed) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? (theme.isDarkMode ? WebDarkColors.primaryDark : WebColors.primaryLight)
              : (theme.isDarkMode 
                  ? WebDarkColors.textSecondary.withOpacity(0.6) 
                  : WebColors.buttonSecondary),
          foregroundColor: isPrimary
              ? Colors.white
              : (theme.isDarkMode ? Colors.white : WebColors.primaryLight),
          side: isPrimary
              ? null
              : BorderSide(
                  color: theme.isDarkMode ? WebDarkColors.primaryLight : WebColors.primaryDark,
                  width: 1,
                ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: WebTextStyles.buttonMd(
            isDarkTheme: theme.isDarkMode,
            color: isPrimary
                ? Colors.white
                : (theme.isDarkMode ? Colors.white : WebColors.primaryLight),
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialInfoCards(funds, ThemesProvider theme) {
    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          color: theme.isDarkMode ? WebDarkColors.background : WebColors.background,
          borderRadius: BorderRadius.circular(0),
          border: Border.all(
            color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left column - Available Capital
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      // color: theme.isDarkMode ? WebDarkColors.background : WebColors.background,
                      
                      border: Border(
                        bottom: BorderSide(
                          color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Available Capital",
                          style: WebTextStyles.sub(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textSecondary
                                : WebColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          getFormatter(
                            value: _safeParseDouble("${funds.fundDetailModel?.totCredit ?? 0.00}"),
                            v4d: false,
                            noDecimal: false,
                          ),
                          style: WebTextStyles.title(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textPrimary
                                : WebColors.textPrimary,
                            fontWeight: WebFonts.semiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildAvailableCashContent(funds, theme),
                    ),
                  ),
                ],
              ),
            ),
            // Vertical divider
            Container(
              width: 0.5,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: theme.isDarkMode
                  ? WebDarkColors.divider
                  : WebColors.divider,
            ),
            // Right column - Margin Used
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Margin Used",
                          style: WebTextStyles.sub(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textSecondary
                                : WebColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          getFormatter(
                            value: double.parse("${funds.fundDetailModel?.utilizedMrgn ?? 0.00}"),
                            v4d: false,
                            noDecimal: false,
                          ),
                          style: WebTextStyles.title(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textPrimary
                                : WebColors.textPrimary,
                            fontWeight: WebFonts.semiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildMarginUsedContent(funds, theme),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildInfoRow(String label, String value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: WebTextStyles.dialogContent(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: WebTextStyles.dialogContent(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
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
