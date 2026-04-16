import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/models/explore_model/basketcollection_model.dart';
import 'package:mynt_plus/provider/dashboard_provider.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/mynt_loader.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';

import '../../../../sharedWidget/list_divider.dart';

class FundSelectionScreenWeb extends ConsumerStatefulWidget {
  const FundSelectionScreenWeb({super.key});

  @override
  ConsumerState<FundSelectionScreenWeb> createState() =>
      _FundSelectionScreenState();
}

class _FundSelectionScreenState extends ConsumerState<FundSelectionScreenWeb> {
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
  }

  List<FundListModel> getFilteredFunds(DashboardProvider strategy) {
    List<FundListModel> funds = (strategy.basketSearchItems ?? [])
        .map((item) => FundListModel(
              name: item.name ?? "Unknown Scheme",
              schemeName: item.schemeName ?? "Unknown Scheme",
              type: _getFundTypeFromScheme(item.schemeType),
              fiveYearCAGR: 0.0,
              threeYearCAGR: 0.0,
              aum: double.tryParse(item.aUM ?? "0") ?? 0.0,
              sharpe: 0.0,
              aMCCode: item.aMCCode,
              isin: item.iSIN,
              schemeCode: item.schemeCode,
              nav: double.tryParse(item.nETASSETVALUE ?? "0") ?? 0.0,
            ))
        .toList();

    if (selectedFilter != 'All') {
      funds = funds.where((fund) => fund.type == selectedFilter).toList();
    }

    if (strategy.searchController.text.isNotEmpty) {
      funds = funds
          .where((fund) => fund.name
              .toLowerCase()
              .contains(strategy.searchController.text.toLowerCase()))
          .toList();
    }

    return funds.toList();
  }

  @override
  Widget build(BuildContext context) {
    final strategy = ref.watch(dashboardProvider);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        setState(() {
          strategy.searchController.clear();
          strategy.Basketsearch("");
        });
        if (!didPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: resolveThemeColor(context,
            dark: MyntColors.backgroundColorDark,
            light: MyntColors.backgroundColor),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: resolveThemeColor(context,
                            dark: colors.searchBgDark,
                            light: colors.searchBg),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          SvgPicture.asset(
                            assets.searchIcon,
                            color: resolveThemeColor(context,
                                dark: MyntColors.textSecondaryDark,
                                light: MyntColors.textSecondary),
                            width: 18,
                            height: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: strategy.searchController,
                              style: MyntWebTextStyles.body(context,
                                  fontWeight: MyntFonts.regular,
                                  darkColor: MyntColors.textPrimaryDark,
                                  lightColor: MyntColors.textPrimary),
                              decoration: InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                hintText: "Search funds...",
                                hintStyle: MyntWebTextStyles.body(context,
                                    fontWeight: MyntFonts.regular,
                                    darkColor: MyntColors.textSecondaryDark
                                        .withOpacity(0.4),
                                    lightColor: MyntColors.textSecondary
                                        .withOpacity(0.4)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 12),
                              ),
                              onChanged: (value) {
                                strategy.searchController.text = value;
                                strategy.Basketsearch(value);
                              },
                            ),
                          ),
                          if (strategy.searchController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () {
                                    strategy.searchController.clear();
                                    strategy.Basketsearch("");
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      assets.removeIcon,
                                      width: 20,
                                      height: 20,
                                      color: resolveThemeColor(context,
                                          dark: MyntColors.textSecondaryDark,
                                          light: MyntColors.textSecondary),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (strategy.selectedFunds.isNotEmpty) ...[
                    const SizedBox(width: 5),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () {
                          strategy.searchController.clear();
                          strategy.Basketsearch("");
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: Text(
                            'Done',
                            style: MyntWebTextStyles.body(context,
                                fontWeight: MyntFonts.semiBold,
                                color: MyntColors.primary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Search Results Section
            if (strategy.searchController.text.isNotEmpty)
              if (strategy.basketSearchItems?.isNotEmpty ?? false)
                Expanded(
                    child: _buildSearchResultsList(context, strategy))
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 250),
                    child: NoDataFound(),
                  ),
                ),

            // Fund List
            if (strategy.searchController.text.isEmpty)
              Expanded(
                child: ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  separatorBuilder: (context, index) => const ListDivider(),
                  itemCount: getFilteredFunds(strategy).length,
                  itemBuilder: (context, index) {
                    final fund = getFilteredFunds(strategy)[index];
                    final isSelected =
                        strategy.selectedFunds.any((f) => f.name == fund.name);

                    return _buildFundItem(fund, isSelected, context);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    final filterList = ['All', 'Equity', 'Debt', 'Hybrid', 'Commodities'];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemCount: filterList.length,
      itemBuilder: (context, index) {
        final filter = filterList[index];
        final isSelected = selectedFilter == filter;

        return Container(
          width: 75.0,
          margin: const EdgeInsets.only(right: 0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: isDarkMode(context)
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              highlightColor: isDarkMode(context)
                  ? Colors.white.withOpacity(0.01)
                  : Colors.black.withOpacity(0.01),
              onTap: () {
                setState(() {
                  selectedFilter = filter;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(
                      filter,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: MyntWebTextStyles.body(context,
                          fontWeight: MyntFonts.semiBold,
                          color: isSelected
                              ? resolveThemeColor(context,
                                  dark: MyntColors.secondaryDark,
                                  light: MyntColors.secondary)
                              : resolveThemeColor(context,
                                  dark: MyntColors.textSecondaryDark,
                                  light: MyntColors.textSecondary)),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    height: 2,
                    width: isSelected ? 57 : 0,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: MyntColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFundItem(
      FundListModel fund, bool isSelected, BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isSelected) {
            ref.read(dashboardProvider).removeFundFromStrategy(fund);
          } else {
            ref.read(dashboardProvider).addFundToStrategy(fund);
          }
          ref.read(dashboardProvider).autoSaveFundChange(context);
        },
        splashColor: isDarkMode(context)
            ? Colors.white.withOpacity(0.15)
            : Colors.black.withOpacity(0.15),
        highlightColor: isDarkMode(context)
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.08),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          dense: false,
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: resolveThemeColor(context,
                dark: MyntColors.backgroundColorDark,
                light: MyntColors.backgroundColor),
            child: ClipOval(
              child: Image.network(
                "https://v3.mynt.in/mfapi/static/images/mf/${fund.aMCCode ?? ""}.png",
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    _getFundTypeIcon(fund.type),
                    color: _getFundTypeColor(fund.type),
                    size: 24,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    width: 24,
                    height: 24,
                    child: MyntLoader.inline(strokeWidth: 2),
                  );
                },
              ),
            ),
          ),
          title: Container(
            margin: EdgeInsets.only(
              right: MediaQuery.of(context).size.width * 0.1,
            ),
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              _capitalizeEachWord(fund.name),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: MyntWebTextStyles.body(context,
                  fontWeight: MyntFonts.regular,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Text(
                  fund.type.toUpperCase(),
                  style: MyntWebTextStyles.para(context,
                      fontWeight: MyntFonts.regular,
                      darkColor: MyntColors.textSecondaryDark,
                      lightColor: MyntColors.textSecondary),
                ),
              ],
            ),
          ),
          trailing: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: Colors.grey.withOpacity(0.3),
              highlightColor: Colors.grey.withOpacity(0.2),
              onTap: () {
                if (isSelected) {
                  ref.read(dashboardProvider).removeFundFromStrategy(fund);
                } else {
                  ref.read(dashboardProvider).addFundToStrategy(fund);
                }
                ref.read(dashboardProvider).autoSaveFundChange(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  color: isSelected ? MyntColors.primary : colors.colorGrey,
                  isSelected ? assets.bookmarkIcon : assets.bookmarkedIcon,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getFundTypeColor(String type) {
    final dark = isDarkMode(context);
    switch (type.toLowerCase()) {
      case 'equity':
        return dark ? MyntColors.profitDark : MyntColors.profit;
      case 'debt':
        return MyntColors.lossDark;
      case 'hybrid':
        return dark ? MyntColors.lossDark : MyntColors.loss;
      case 'commodities':
        return MyntColors.pending;
      default:
        return dark ? MyntColors.textSecondaryDark : MyntColors.textSecondary;
    }
  }

  IconData _getFundTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'equity':
        return Icons.trending_up;
      case 'debt':
        return Icons.account_balance;
      case 'hybrid':
        return Icons.pie_chart;
      case 'commodities':
        return Icons.landscape;
      default:
        return Icons.monetization_on;
    }
  }

  String _formatAumValue(double aum) {
    if (aum >= 10000000) {
      return '${(aum / 10000000).toStringAsFixed(1)}Cr';
    } else if (aum >= 100000) {
      return '${(aum / 100000).toStringAsFixed(1)}L';
    } else if (aum >= 1000) {
      return '${(aum / 1000).toStringAsFixed(1)}K';
    } else {
      return aum.toStringAsFixed(0);
    }
  }

  String _capitalizeEachWord(String text) {
    if (text.isEmpty) return text;

    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildSearchResultsList(
      BuildContext context, DashboardProvider strategy) {
    return ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (context, index) => const ListDivider(),
        physics: const ClampingScrollPhysics(),
        itemCount: strategy.basketSearchItems?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          final item = strategy.basketSearchItems?[index];
          if (item == null) return const SizedBox.shrink();

          final fund = FundListModel(
            name: item.name ?? "Unknown Scheme",
            schemeName: item.schemeName ?? "Unknown Scheme",
            type: _getFundTypeFromScheme(item.schemeType),
            fiveYearCAGR: 0.0,
            threeYearCAGR: 0.0,
            aum: double.tryParse(item.aUM ?? "0") ?? 0.0,
            sharpe: 0.0,
            aMCCode: item.aMCCode,
            isin: item.iSIN,
            schemeCode: item.schemeCode,
            nav: double.tryParse(item.nETASSETVALUE ?? "0") ?? 0.0,
          );

          final isSelected = strategy.isFundSelected(fund);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (isSelected) {
                  strategy.removeFundFromStrategy(fund);
                } else {
                  strategy.addFundToStrategy(fund);
                }
                strategy.autoSaveFundChange(context);
              },
              splashColor: isDarkMode(context)
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.15),
              highlightColor: isDarkMode(context)
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                dense: false,
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: resolveThemeColor(context,
                      dark: MyntColors.backgroundColorDark,
                      light: MyntColors.backgroundColor),
                  child: ClipOval(
                    child: Image.network(
                      "https://v3.mynt.in/mfapi/static/images/mf/${item.aMCCode ?? ""}.png",
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          _getFundTypeIcon(fund.type),
                          color: _getFundTypeColor(fund.type),
                          size: 24,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          width: 24,
                          height: 24,
                          child: MyntLoader.inline(strokeWidth: 2),
                        );
                      },
                    ),
                  ),
                ),
                title: Container(
                  margin: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.1,
                  ),
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    _capitalizeEachWord(item.name ?? "Unknown Scheme"),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: MyntWebTextStyles.body(context,
                        fontWeight: MyntFonts.regular,
                        darkColor: MyntColors.textPrimaryDark,
                        lightColor: MyntColors.textPrimary),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Text(
                        fund.type.toUpperCase(),
                        style: MyntWebTextStyles.para(context,
                            fontWeight: MyntFonts.regular,
                            darkColor: MyntColors.textSecondaryDark,
                            lightColor: MyntColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                trailing: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    splashColor: Colors.grey.withOpacity(0.3),
                    highlightColor: Colors.grey.withOpacity(0.2),
                    onTap: () {
                      if (isSelected) {
                        ref
                            .read(dashboardProvider)
                            .removeFundFromStrategy(fund);
                        successMessage(context, 'Fund removed from strategy');
                      } else {
                        ref.read(dashboardProvider).addFundToStrategy(fund);
                        successMessage(context, 'Fund added to strategy');
                      }
                      ref.read(dashboardProvider).autoSaveFundChange(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SvgPicture.asset(
                        color:
                            isSelected ? MyntColors.primary : colors.colorGrey,
                        isSelected
                            ? assets.bookmarkIcon
                            : assets.bookmarkedIcon,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  String _getFundTypeFromScheme(String? schemeType) {
    if (schemeType == null) return "Equity";
    final type = schemeType.toLowerCase();
    if (type.contains("debt")) return "Debt";
    if (type.contains("hybrid")) return "Hybrid";
    if (type.contains("commodity")) return "Commodities";
    return "Equity";
  }
}
