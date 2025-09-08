import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/models/explore_model/basketcollection_model.dart';
import 'package:mynt_plus/provider/dashboard_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

class FundSelectionScreen extends ConsumerStatefulWidget {
  const FundSelectionScreen({super.key});

  @override
  ConsumerState<FundSelectionScreen> createState() => _FundSelectionScreenState();
}

class _FundSelectionScreenState extends ConsumerState<FundSelectionScreen> {
  // final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider).Basketsearch("");
    });
  }


  List<FundListModel> getFilteredFunds(DashboardProvider strategy) {
    // Convert API data to FundModel
    List<FundListModel> funds = (strategy.basketSearchItems ?? []).map((item) => FundListModel(
      name: item.schemeName ?? "Unknown Scheme",
      type: _getFundTypeFromScheme(item.schemeType),
      fiveYearCAGR: 0.0,
      threeYearCAGR: 0.0,
      aum: double.tryParse(item.aUM ?? "0") ?? 0.0,
      sharpe: 0.0,
      aMCCode: item.aMCCode,
      isin: item.iSIN,
    )).toList();
    
    // Apply filter
    if (selectedFilter != 'All') {
      funds = funds.where((fund) => fund.type == selectedFilter).toList();
    }
    
    // Apply search
    if (strategy.searchController.text.isNotEmpty) {
      funds = funds.where((fund) => 
        fund.name.toLowerCase().contains(strategy.searchController.text.toLowerCase())
      ).toList();
    }
    
    return funds.toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final strategy = ref.watch(dashboardProvider);
    
    return Scaffold(
      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      appBar: AppBar(
        leadingWidth: 48,
        titleSpacing: 0,
        centerTitle: false,
        leading: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            customBorder: const CircleBorder(),
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
        elevation: 0.2,
        title: TextWidget.titleText(
          text: "Add Funds to Strategy",
          textOverflow: TextOverflow.ellipsis,
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
        ),
        // actions: [
        //   if (strategy.selectedFunds.isNotEmpty)
        //     TextButton(
        //       onPressed: () {
        //        Navigator.pop(context);
        //       },
        //       child: TextWidget.subText(
        //         text: 'Next',
        //         theme: theme.isDarkMode,
        //         color: colors.colorBlue,
        //         fw: 1,
        //       ),
        //     ),
        // ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      controller: strategy.searchController,
                      style: TextWidget.textStyle(
                        fontSize: 16,
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fw: 0,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search funds",
                        hintStyle: TextWidget.textStyle(
                          fontSize: 14,
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 0,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                        ),
                        suffixIcon: strategy.searchController.text.isNotEmpty ? Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                             strategy.clearsearchcontroller();
                            },
                            child: SvgPicture.asset(
                              assets.removeIcon,
                              width: 18,
                              height: 18,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        ) : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      ),
                      
                      onChanged: (value) {
                        strategy.searchController.text = value;
                        strategy.Basketsearch(value);
                      }
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Filter Chips
                  if(strategy.searchController.text.isEmpty)
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ['All', 'Equity', 'Debt', 'Hybrid', 'Commodities']
                          .map((filter) => _buildFilterChip(filter, theme))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Results Section
            if (strategy.searchController.text.isNotEmpty)
              if (strategy.basketSearchItems?.isNotEmpty ?? false)
                Expanded(child: _buildSearchResultsList(context, strategy, theme))
              else
                const Padding(
                  padding: EdgeInsets.only(top: 250),
                  child: NoDataFound(),
                ),
            // Selected Funds Count
            if (strategy.selectedFunds.isNotEmpty && strategy.searchController.text.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.subText(
                          text: '${strategy.selectedFunds.length} funds selected',
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 0,
                        ),
                        TextButton(
                          onPressed: () => ref.read(dashboardProvider).clearStrategy(),
                          child: TextWidget.subText(
                            text: 'Clear All',
                            theme: theme.isDarkMode,
                            color: colors.colorBlue,
                            fw: 0,
                          ),
                        ),
                      ],
                    ),
                    if (strategy.selectedFunds.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: TextWidget.subText(
                            text: 'Add Funds to Strategy',
                            theme: theme.isDarkMode,
                            color: colors.colorWhite,
                            fw: 1,
                          ),
                        ),
                      ),
                      
                  ],
                ),
              ),
            
            // Fund List
            if (strategy.searchController.text.isEmpty)
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: getFilteredFunds(strategy).length,
                  itemBuilder: (context, index) {
                    final fund = getFilteredFunds(strategy)[index];
                    final isSelected = strategy.selectedFunds.any((f) => f.name == fund.name);
                    
                    return _buildFundItem(fund, isSelected, theme);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter, ThemesProvider theme) {
    final isSelected = selectedFilter == filter;
    
    return Container(
      margin: const EdgeInsets.only(right: 4),
      child: FilterChip(
        label: TextWidget.subText(
          text: filter,
          theme: theme.isDarkMode,
          color: isSelected
              ? colors.colorWhite
              : (theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight),
          fw: isSelected ? 0 : 3,
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedFilter = filter;
          });
        },
        backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        selectedColor: colors.colorBlue,
        side: BorderSide(
          color: isSelected
              ? colors.colorBlue
              : (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight),
        ),
      ),
    );
  }

  Widget _buildFundItem(FundListModel fund, bool isSelected, ThemesProvider theme) {
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.isDarkMode 
                    ? colors.darkColorDivider 
                    : colors.colorDivider,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Fund Image
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.isDarkMode ? colors.darkGrey : colors.colorGrey,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
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
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Fund Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget.subText(
                      text: _capitalizeEachWord(fund.name),
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 0,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getFundTypeColor(fund.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getFundTypeColor(fund.type).withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: TextWidget.captionText(
                            text: fund.type.toUpperCase(),
                            theme: theme.isDarkMode,
                            color: _getFundTypeColor(fund.type),
                            fw: 0,
                          ),
                        ),
                        if (fund.aum > 0) ...[
                          const SizedBox(width: 8),
                          TextWidget.captionText(
                            text: 'AUM: ₹${_formatAumValue(fund.aum)}',
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            fw: 0,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Selection Indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? colors.colorBlue : Colors.transparent,
                  border: Border.all(
                    color: isSelected 
                        ? colors.colorBlue 
                        : (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getFundTypeColor(String type) {
    final theme = ref.watch(themeProvider);
    switch (type.toLowerCase()) {
      case 'equity':
        return theme.isDarkMode ? colors.successDark : colors.successLight;
      case 'debt':
        return theme.isDarkMode ? colors.kColorRedDarkTheme : colors.kColorRedDarkTheme;
      case 'hybrid':
        return theme.isDarkMode ? colors.lossDark : colors.lossLight;
      case 'commodities':
        return theme.isDarkMode ? colors.pending : colors.pending;
      default:
        return theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight;
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
    if (aum >= 10000000) { // 1 crore
      return '${(aum / 10000000).toStringAsFixed(1)}Cr';
    } else if (aum >= 100000) { // 1 lakh
      return '${(aum / 100000).toStringAsFixed(1)}L';
    } else if (aum >= 1000) { // 1 thousand
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
    return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: strategy.basketSearchItems?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          final item = strategy.basketSearchItems?[index];
          if (item == null) return const SizedBox.shrink();

          final fund = FundListModel(
            name: item.schemeName ?? "Unknown Scheme",
            type: _getFundTypeFromScheme(item.schemeType),
            fiveYearCAGR: 0.0,
            threeYearCAGR: 0.0,
            aum: double.tryParse(item.aUM ?? "0") ?? 0.0,
            sharpe: 0.0,
            aMCCode: item.aMCCode,
            isin: item.iSIN,
          );
          
          final isSelected = strategy.isFundSelected(fund);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.darkGrey : colors.colorWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.isDarkMode 
                    ? colors.darkColorDivider 
                    : colors.colorDivider,
                width: 0.5,
              ),
            ),
            child: InkWell(
              onTap: () {
                if (isSelected) {
                  strategy.removeFundFromStrategy(fund);
                } else {
                  strategy.addFundToStrategy(fund);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Fund Image
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorGrey,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
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
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Fund Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget.subText(
                            text: _capitalizeEachWord(item.schemeName ?? "Unknown Scheme"),
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            fw: 0,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getFundTypeColor(fund.type).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getFundTypeColor(fund.type).withOpacity(0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: TextWidget.captionText(
                                  text: fund.type.toUpperCase(),
                                  theme: theme.isDarkMode,
                                  color: _getFundTypeColor(fund.type),
                                  fw: 0,
                                ),
                              ),
                              if (fund.aum > 0) ...[
                                const SizedBox(width: 8),
                                TextWidget.captionText(
                                  text: 'AUM: ₹${_formatAumValue(fund.aum)}',
                                  theme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                  fw: 0,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Selection Indicator
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? colors.colorBlue : Colors.transparent,
                        border: Border.all(
                          color: isSelected 
                              ? colors.colorBlue 
                              : (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
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

