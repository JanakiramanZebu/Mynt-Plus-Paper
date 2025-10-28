import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'fund_screen_web.dart';
import 'withdraw_screen_web.dart';

import '../../../provider/fund_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';

class SecureFundWeb extends ConsumerStatefulWidget {
  const SecureFundWeb({super.key});

  @override
  ConsumerState<SecureFundWeb> createState() => _SecureFundWebState();
}

class _SecureFundWebState extends ConsumerState<SecureFundWeb> {

  @override
  Widget build(BuildContext context) {
    final funds = ref.watch(fundProvider);
    final theme = ref.watch(themeProvider);
    final trancation = ref.watch(transcationProvider);

    return Scaffold(
      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(funds, theme),
              const SizedBox(height: 32),
              
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
        Text(
          'Funds & Margin',
          style: TextWidget.textStyle(
            fontSize: 28,
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            fw: 3,
          ),
        ),
        IconButton(
          onPressed: () {
            ref.read(fundProvider).fetchFunds(context);
          },
          icon: Icon(
            Icons.refresh,
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          ),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildAvailableMarginCard(funds, ThemesProvider theme, trancation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Available Margin Title and Value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget.subText(
                    text: "Available Margin",
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 0,
                    theme: false,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getFormatter(
                      value: double.parse("${funds.fundDetailModel?.avlMrg ?? 0.00}"),
                      v4d: false,
                      noDecimal: false,
                    ),
                    style: TextWidget.textStyle(
                      fontSize: 24,
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 3,
                    ),
                  ),
                ],
              ),
              // Action Buttons
              Row(
                children: [
                  _buildActionButton(
                    "Add Money",
                    true,
                    theme,
                    () {
                      showDialog(context: context, builder: (context) => FundScreenWeb(dd: trancation));
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    "Withdraw",
                    false,
                    theme,
                    () async {
                      await trancation.fetchValidateToken(context);
                      Future.delayed(
                        const Duration(milliseconds: 100),
                        () async {
                          await trancation.ip();
                          await trancation.fetchupiIdView(
                            trancation.bankdetails!.dATA![trancation.indexss][1],
                            trancation.bankdetails!.dATA![trancation.indexss][2],
                          );
                          await trancation.fetchcwithdraw(context);
                        },
                      );
                      trancation.changebool(false);
                      showDialog(context: context, builder: (context) => WithdrawScreenWeb(withdarw: trancation, foucs: FocusNode(), theme: theme, segment: ""));
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, bool isPrimary, ThemesProvider theme, VoidCallback onPressed) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? (theme.isDarkMode ? colors.primaryDark : colors.primaryLight)
              : (theme.isDarkMode 
                  ? colors.textSecondaryDark.withOpacity(0.6) 
                  : colors.fundbuttonBg),
          foregroundColor: isPrimary
              ? colors.colorWhite
              : (theme.isDarkMode ? colors.colorWhite : colors.primaryLight),
          side: isPrimary
              ? null
              : BorderSide(
                  color: theme.isDarkMode ? colors.primaryLight : colors.primaryDark,
                  width: 1,
                ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextWidget.textStyle(
            fontSize: 14,
            theme: false,
            color: isPrimary
                ? colors.colorWhite
                : (theme.isDarkMode ? colors.colorWhite : colors.primaryLight),
            fw: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialInfoCards(funds, ThemesProvider theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Available Capital Card
        Expanded(
          child: SizedBox(
            height: 400,
            child: _buildInfoCard(
              "Available Capital",
              getFormatter(
                value: _safeParseDouble("${funds.fundDetailModel?.totCredit ?? 0.00}"),
                v4d: false,
                noDecimal: false,
              ),
              theme,
              expandedContent: SingleChildScrollView(
                child: _buildAvailableCashContent(funds, theme),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Margin Used Card
        Expanded(
          child: SizedBox(
            height: 400,
            child: _buildInfoCard(
              "Margin Used",
              getFormatter(
                value: double.parse("${funds.fundDetailModel?.utilizedMrgn ?? 0.00}"),
                v4d: false,
                noDecimal: false,
              ),
              theme,
              expandedContent: SingleChildScrollView(
                child: _buildMarginUsedContent(funds, theme),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    ThemesProvider theme, {
    Widget? expandedContent,
  }) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: Column(
        children: [
          // Card Header
          InkWell(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.subText(
                    text: title,
                    theme: false,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 0,
                  ),
                  Row(
                    children: [
                      TextWidget.subText(
                        text: value,
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fw: 3,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expanded Content with constrained height for scrolling
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.isDarkMode 
                    ? colors.kColorLightGreyDarkTheme.withOpacity(0.5)
                    : colors.kColorLightGrey.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: expandedContent,
            ),
          ),
        ],
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

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
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
      ),
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

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
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
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.subText(
            text: label,
            theme: false,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            fw: 0,
          ),
          TextWidget.subText(
            text: value,
            theme: false,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 0,
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
