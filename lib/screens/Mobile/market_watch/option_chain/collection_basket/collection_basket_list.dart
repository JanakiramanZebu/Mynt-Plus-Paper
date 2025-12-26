import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/models/explore_model/basketcollection_model.dart';
import 'package:mynt_plus/provider/dashboard_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';

import '../../../../../sharedWidget/list_divider.dart';

class FundSelectionScreen extends ConsumerStatefulWidget {
  const FundSelectionScreen({super.key});

  @override
  ConsumerState<FundSelectionScreen> createState() =>
      _FundSelectionScreenState();
}

class _FundSelectionScreenState extends ConsumerState<FundSelectionScreen> {
  // final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
   
  }

  List<FundListModel> getFilteredFunds(DashboardProvider strategy) {
    // Convert API data to FundModel
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
            ))
        .toList();

    // Apply filter
    if (selectedFilter != 'All') {
      funds = funds.where((fund) => fund.type == selectedFilter).toList();
    }

    // Apply search
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
    final theme = ref.watch(themeProvider);
    final strategy = ref.watch(dashboardProvider);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        // Clear search when going back
      setState(() {
         strategy.searchController.clear();
         strategy.Basketsearch("");
      });
        // strategy.clearBasketSearchResults();
        if (!didPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 48,
        titleSpacing: 0,
        leading: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            customBorder: const CircleBorder(),
            splashColor: Colors.black.withOpacity(0.15),
            highlightColor: Colors.black.withOpacity(0.08),
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios_outlined,
                size: 18,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
              ),
            ),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.only(right: 12, top: 8, bottom: 7),
          child: Row(
            children: [
              // Search container
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      // Search icon
                      const SizedBox(width: 12),
                      SvgPicture.asset(
                        assets.searchIcon,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        width: 18,
                        height: 18,
                      ),
                      const SizedBox(width: 8),
                      // Text input
                      Expanded(
                        child: TextFormField(
                          controller: strategy.searchController,
                          style: TextWidget.textStyle(
                            fontSize: 16,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            theme: theme.isDarkMode,
                            fw: 0,
                          ),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: "Search funds...",
                            hintStyle: TextWidget.textStyle(
                              fontSize: 14,
                              theme: theme.isDarkMode,
                              fw: 0,
                              color: (theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight)
                                  .withOpacity(0.4),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 12),
                          ),
                          onChanged: (value) {
                            strategy.searchController.text = value;
                            strategy.Basketsearch(value);
                          },
                        ),
                      ),
                      // Clear button
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
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // DONE button (only when funds are selected)
              if (strategy.selectedFunds.isNotEmpty) ...[
                const SizedBox(width: 5),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    splashColor: theme.isDarkMode
                        ? colors.splashColorDark
                        : colors.splashColorLight,
                    highlightColor: theme.isDarkMode
                        ? colors.highlightDark
                        : colors.highlightLight,
                    onTap: () {
                      // Clear search and navigate back
                      strategy.searchController.clear();
                      strategy.Basketsearch("");
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: TextWidget.subText(
                        text: 'Done',
                        theme: theme.isDarkMode,
                        color: colors.colorBlue,
                        fw: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Results Section
            if (strategy.searchController.text.isNotEmpty)
              if (strategy.basketSearchItems?.isNotEmpty ?? false)
                Expanded(
                    child: _buildSearchResultsList(context, strategy, theme))
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

                    return _buildFundItem(fund, isSelected, theme);
                  },
                ),
              ),

          ],
        ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(ThemesProvider theme) {
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
          width: 75.0, // Fixed width like search screen
          margin: const EdgeInsets.only(right: 0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: theme.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              highlightColor: theme.isDarkMode
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
                    child: TextWidget.subText(
                      text: filter,
                      color: isSelected
                          ? theme.isDarkMode
                              ? colors.secondaryDark
                              : colors.secondaryLight
                          : theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                      textOverflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      theme: theme.isDarkMode,
                      fw: isSelected ? 2 : 2,
                    ),
                  ),
                  // Animated underline indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    height: 2,
                    width: isSelected ? 57 : 0, // 75 - 18 for padding
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: colors.colorBlue,
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
      FundListModel fund, bool isSelected, ThemesProvider theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isSelected) {
            ref.read(dashboardProvider).removeFundFromStrategy(fund);
          } else {
            ref.read(dashboardProvider).addFundToStrategy(fund);
          }
        },
        splashColor: theme.isDarkMode
            ? Colors.white.withOpacity(0.15)
            : Colors.black.withOpacity(0.15),
        highlightColor: theme.isDarkMode
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.08),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          dense: false,
          leading: CircleAvatar(
            radius: 22,
            backgroundColor:
                theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
          title: Container(
            margin: EdgeInsets.only(
              right: MediaQuery.of(context).size.width * 0.1,
            ),
            padding: const EdgeInsets.only(
              bottom: 4,
            ),
            child: TextWidget.subText(
              text: _capitalizeEachWord(fund.name),
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 0,
              maxLines: 2,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                TextWidget.paraText(
                  text: fund.type.toUpperCase(),
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 0,
                ),
                // if (fund.aum > 0) ...[
                //   const SizedBox(width: 8),
                //   TextWidget.paraText(
                //     text: 'AUM ${_formatAumValue(fund.aum)}',
                //     theme: theme.isDarkMode,
                //     color: theme.isDarkMode
                //         ? colors.textSecondaryDark
                //         : colors.textSecondaryLight,
                //     fw: 0,
                //   ),
                // ],
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
                        // successMessage(context, 'Fund removed from strategy');
                      } else {
                        ref.read(dashboardProvider).addFundToStrategy(fund);
                        // successMessage(context, 'Fund added to strategy');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SvgPicture.asset(
                        color: isSelected
                            ? colors.colorBlue
                            : colors.colorGrey,
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
  }

  Color _getFundTypeColor(String type) {
    final theme = ref.watch(themeProvider);
    switch (type.toLowerCase()) {
      case 'equity':
        return theme.isDarkMode ? colors.profitDark : colors.profitLight;
      case 'debt':
        return theme.isDarkMode
            ? colors.kColorRedDarkTheme
            : colors.kColorRedDarkTheme;
      case 'hybrid':
        return theme.isDarkMode ? colors.lossDark : colors.lossLight;
      case 'commodities':
        return theme.isDarkMode ? colors.pending : colors.pending;
      default:
        return theme.isDarkMode
            ? colors.textSecondaryDark
            : colors.textSecondaryLight;
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
      // 1 crore
      return '${(aum / 10000000).toStringAsFixed(1)}Cr';
    } else if (aum >= 100000) {
      // 1 lakh
      return '${(aum / 100000).toStringAsFixed(1)}L';
    } else if (aum >= 1000) {
      // 1 thousand
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
      BuildContext context, DashboardProvider strategy, ThemesProvider theme) {
    return ListView.separated(
        shrinkWrap: true,
        // padding: const EdgeInsets.symmetric(horizontal: 16),
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
              },
              splashColor: theme.isDarkMode
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.15),
              highlightColor: theme.isDarkMode
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                dense: false,
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                title: Container(
                  margin: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.1,
                  ),
                  padding: const EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: TextWidget.subText(
                    text: _capitalizeEachWord(item.name ?? "Unknown Scheme"),
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 0,
                    maxLines: 2,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      TextWidget.paraText(
                        text: fund.type.toUpperCase(),
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 0,
                      ),
                      // if (fund.aum > 0) ...[
                      //   const SizedBox(width: 8),
                      //   TextWidget.paraText(
                      //     text: 'AUM ${_formatAumValue(fund.aum)}',
                      //     theme: theme.isDarkMode,
                      //     color: theme.isDarkMode
                      //         ? colors.textSecondaryDark
                      //         : colors.textSecondaryLight,
                      //     fw: 0,
                      //   ),
                      // ],
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
                        successMessage(context, 'Fund removed from strategy');
                      } else {
                        ref.read(dashboardProvider).addFundToStrategy(fund);
                        successMessage(context, 'Fund added to strategy');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SvgPicture.asset(
                        color: isSelected
                            ? colors.colorBlue
                            : colors.colorGrey,
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

  // @override
  // void dispose() {
  //   _searchController.dispose();
  //   super.dispose();
  // }
}
