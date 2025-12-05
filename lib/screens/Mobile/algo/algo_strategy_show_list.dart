import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/res/res.dart';

import '../../../models/profile_model/algo_strategy_model.dart';
import '../../../provider/user_profile_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../sharedWidget/no_data_found.dart';
import '../../../sharedWidget/snack_bar.dart';
import '../../../routes/route_names.dart';

class AlgoStrategyShowList extends ConsumerStatefulWidget {
  const AlgoStrategyShowList({super.key});

  @override
  ConsumerState<AlgoStrategyShowList> createState() => _AlgoStrategyShowListState();
}

class _AlgoStrategyShowListState extends ConsumerState<AlgoStrategyShowList> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final userProfile = ref.watch(userProfileProvider);
    
    return Scaffold(
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
            splashColor:
                theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
            highlightColor:
                theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
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
            text: "Algo Approval",
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 1),
        actions: [
          Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor:
                    theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
                highlightColor:
                    theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
                borderRadius: BorderRadius.circular(6),
                      onTap: () => Navigator.pushNamed(context, Routes.createAlgoStrategy),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    
                      TextWidget.subText(
                        text: 'Create',
                        theme: theme.isDarkMode,
                        color:
                            theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                        fw: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (_) {
            if (userProfile.userloader) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            final algoStrategies = userProfile.algoStrategies;
            final filteredStrategies = _getFilteredStrategies(algoStrategies);
            
            if (algoStrategies.isEmpty) {
              return _buildEmptyState(theme.isDarkMode);
            }
            
                    return Column(
                      children: [
                        // Filter tabs
                        _buildFilterTabs(theme.isDarkMode),
                        // Strategies list
                        Expanded(
                          child: filteredStrategies.isEmpty
                              ? _buildNoResultsState(theme.isDarkMode)
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: filteredStrategies.length,
                                  itemBuilder: (context, index) {
                                    return _buildStrategyTile(filteredStrategies[index], theme.isDarkMode);
                                  },
                                ),
                        ),
                      ],
                    );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          SvgPicture.asset(assets.noDatafound,
          color:   Color(0xff777777)
          ),
          const SizedBox(height: 2),
          TextWidget.subText(
              text: "No Algo Strategies Found",
              color: isDark
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
                  fw:0,
              theme: isDark),
          
         
        ],
      ),
    );
  }

  Widget _buildStrategyTile(AlgoStrategyModel strategy, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // color: isDark ? colors.searchBgDark : colors.searchBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? colors.dividerDark : colors.dividerLight,
        ),
       
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          splashColor: isDark ? colors.splashColorDark : colors.splashColorLight,
          highlightColor: isDark ? colors.highlightDark : colors.highlightLight,
          onTap: () => _handleCardTap(strategy),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Title and Status badge
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          TextWidget.titleText(
                            text: strategy.algorithmName,
                            theme: isDark,
                            color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                            fw: 1,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                          // const SizedBox(width: 8),
                        ],
                      ),
                    ),
                          //  _buildTypeChip(strategy.type, isDark),
                          //  const SizedBox(width: 8),

                    _buildStatusChip(strategy.status, isDark),
                  ],
                ),
                const SizedBox(height: 8),
                // Algorithm ID
                TextWidget.subText(
                  text: strategy.algoId,
                  theme: isDark,
                  color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                  fw: 0,
                ),
                const SizedBox(height: 8),
                // Description
                TextWidget.paraText(
                  text: strategy.description,
                  theme: isDark,
                  color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                  maxLines: 3,
                  textOverflow: TextOverflow.ellipsis,
                ),
                // Bottom row: Type badge aligned to right                
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isDark) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    
    switch (status.toLowerCase()) {
      case 'pending':
        // Pending color scheme
        backgroundColor = isDark ? colors.pending.withOpacity(0.1) : colors.pending.withOpacity(0.1);
        textColor = isDark ? colors.pending : colors.pending;
        borderColor = isDark ? colors.pending.withOpacity(0.3) : colors.pending.withOpacity(0.3);
        break;
      case 'approved':
        // Green scheme for Approved
        backgroundColor = isDark ? Colors.green.withOpacity(0.1) : Colors.green.withOpacity(0.1);
        textColor = isDark ? Colors.green : Colors.green;
        borderColor = isDark ? Colors.green.withOpacity(0.3) : Colors.green.withOpacity(0.3);
        break;
      case 'rejected':
        // Red scheme for Rejected
        backgroundColor = isDark ? Colors.red.withOpacity(0.1) : Colors.red.withOpacity(0.1);
        textColor = isDark ? Colors.red : Colors.red;
        borderColor = isDark ? Colors.red.withOpacity(0.3) : Colors.red.withOpacity(0.3);
        break;
      default:
        // Default grey scheme for any other status
        backgroundColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F8F8);
        textColor = isDark ? const Color(0xFFCCCCCC) : const Color(0xFF666666);
        borderColor = isDark ? const Color(0xFF404040) : const Color(0xFFE0E0E0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: TextWidget.captionText(
        text: status,
        theme: isDark,
        color: textColor,
        fw: 1,
      ),
    );
  }

  Widget _buildTypeChip(String type, bool isDark) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    
    switch (type.toLowerCase()) {
      case 'api-based':
        // Teal scheme for API-based
        backgroundColor = isDark ? const Color(0xFF1A2A2A) : const Color(0xFFE0F2F1);
        textColor = isDark ? const Color(0xFF00BCD4) : const Color(0xFF00695C);
        borderColor = isDark ? const Color(0xFF00BCD4).withOpacity(0.3) : const Color(0xFF00BCD4).withOpacity(0.3);
        break;
      case 'pine script':
        // Blue scheme for Pinescript
        backgroundColor = isDark ? const Color(0xFF1A2A3A) : const Color(0xFFE3F2FD);
        textColor = isDark ? const Color(0xFF2196F3) : const Color(0xFF1976D2);
        borderColor = isDark ? const Color(0xFF2196F3).withOpacity(0.3) : const Color(0xFF2196F3).withOpacity(0.3);
        break;
      case 'python':
        // Purple scheme for Python
        backgroundColor = isDark ? const Color(0xFF2A1A3A) : const Color(0xFFF3E5F5);
        textColor = isDark ? const Color(0xFF9C27B0) : const Color(0xFF7B1FA2);
        borderColor = isDark ? const Color(0xFF9C27B0).withOpacity(0.3) : const Color(0xFF9C27B0).withOpacity(0.3);
        break;
      default:
        // Default grey scheme for any other types
        backgroundColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F8F8);
        textColor = isDark ? const Color(0xFFCCCCCC) : const Color(0xFF666666);
        borderColor = isDark ? const Color(0xFF404040) : const Color(0xFFE0E0E0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: TextWidget.captionText(
        text: type,
        theme: isDark,
        color: textColor,
        fw: 1,
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  List<AlgoStrategyModel> _getFilteredStrategies(List<AlgoStrategyModel> strategies) {
    if (_selectedFilter == 'All') {
      return strategies;
    }
    return strategies.where((strategy) => 
      strategy.status.toLowerCase() == _selectedFilter.toLowerCase()
    ).toList();
  }

  void _handleCardTap(AlgoStrategyModel strategy) {
    final status = strategy.status.toLowerCase();
    
    if (status == 'approved') {
      // Show message for approved strategies
      error(context, 'Strategy is already approved and cannot be edited');
    } else if (status == 'pending' || status == 'rejected') {
      // Allow editing for pending and rejected strategies
      _navigateToEdit(strategy);
    }
  }

  void _navigateToEdit(AlgoStrategyModel strategy) {
    Navigator.pushNamed(
      context,
      Routes.createAlgoStrategy,
      arguments: strategy,
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    final filterOptions = ['All', 'Pending', 'Approved', 'Rejected'];
    
    return Container(
      height: 45,
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filterOptions.length,
        itemBuilder: (context, index) {
          final filter = filterOptions[index];
          final isSelected = _selectedFilter == filter;

          return Container(
            margin: const EdgeInsets.only(right: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                splashColor: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.15),
                highlightColor: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.08),
                onTap: () {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? isDark ? colors.searchBgDark : const Color(0xffF1F3F8)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.only(left: 14, right: 14, top: 0, bottom: 0),
                  child: Center(
                    child: TextWidget.subText(
                      text: filter,
                      color: isSelected
                          ? isDark ? colors.textPrimaryDark : colors.textPrimaryLight
                          : isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                      fw: isSelected ? 2 : 2,
                      theme: !isDark,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoResultsState(bool isDark) {
    return const Center(
      child: NoDataFound(),
    );
  }


}
