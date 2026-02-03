import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../provider/portfolio_provider.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/assets.dart';
import '../../../../sharedWidget/no_data_found.dart';
import 'position_group_symbol_web.dart';

final _assets = Assets();

class PositionGroupScreen extends ConsumerStatefulWidget {
  const PositionGroupScreen({super.key});

  @override
  ConsumerState<PositionGroupScreen> createState() => _PositionGroupScreenState();
}

class _PositionGroupScreenState extends ConsumerState<PositionGroupScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch for provider changes to rebuild when P&L/MTM values change
    final positionBook = ref.watch(portfolioProvider);

    // Web version without Scaffold/AppBar - embeds directly in position screen
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: resolveThemeColor(context,
              dark: MyntColors.backgroundColorDark,
              light: MyntColors.backgroundColor),
          child: _hasAnyGroups(positionBook)
              ? SizedBox(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      primary: false,
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: _buildGroupsContent(context, positionBook),
                    ),
                  ),
                )
              : Center(
                  child: _buildGroupsContent(context, positionBook),
                ),
        );
      },
    );
  }

  // Check if any groups exist (default or custom)
  bool _hasAnyGroups(PortfolioProvider positionBook) {
    return _hasGroups(positionBook, 'default');
  }

  // Build groups content - show single "No Groups" if both are empty, otherwise show sections
  Widget _buildGroupsContent(BuildContext context, PortfolioProvider positionBook) {
    try {
      debugPrint('>>> _buildGroupsContent START');
      debugPrint('groupPositionSym count: ${positionBook.groupPositionSym.length}');
      debugPrint('groupedBySymbol keys: ${positionBook.groupedBySymbol.keys.toList()}');

      // Check if both default and custom groups are empty
      final hasDefaultGroups = _hasGroups(positionBook, 'default');
      final hasCustomGroups = _hasGroups(positionBook, 'custom');

      debugPrint('hasDefaultGroups: $hasDefaultGroups');
      debugPrint('hasCustomGroups: $hasCustomGroups');

      // If both are empty, show single "No Groups" message
      if (!hasDefaultGroups && !hasCustomGroups) {
        debugPrint('>>> Showing NoDataFound - no groups');
        return const NoDataFound(
          title: "No Groups Available",
          subtitle: "There are no position groups available at the moment.",
          primaryEnabled: false,
          secondaryEnabled: false,
        );
      }

      // Otherwise, show sections
      debugPrint('>>> Building group sections');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Default Groups Section (only show if has default groups)
          if (hasDefaultGroups) ...[
            _buildSectionHeader(context, "Default"),
            const PositionGroupSymbol(filterType: 'default'),
            const SizedBox(height: 16),
          ],

          // Custom Groups Section (only show if has custom groups)
          if (hasCustomGroups) ...[
            _buildSectionHeader(context, "Custom"),
            const PositionGroupSymbol(filterType: 'custom'),
          ],
        ],
      );
    } catch (e, stackTrace) {
      debugPrint('>>> _buildGroupsContent EXCEPTION');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: resolveThemeColor(context,
                    dark: MyntColors.lossDark, light: MyntColors.loss),
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading groups',
                style: MyntWebTextStyles.head(
                  context,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary,
                  fontWeight: MyntFonts.semiBold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check console for details',
                style: MyntWebTextStyles.body(
                  context,
                  darkColor: MyntColors.textSecondaryDark,
                  lightColor: MyntColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Check if groups exist for a given filter type
  bool _hasGroups(PortfolioProvider positionBook, String filterType) {
    try {
      debugPrint('>>> _hasGroups START (filterType: $filterType)');

      if (positionBook.groupPositionSym.isEmpty ||
          positionBook.groupedBySymbol.isEmpty) {
        debugPrint('>>> No groups found - empty data');
        return false;
      }

      final groupSymbolsSnapshot = List<String>.from(positionBook.groupPositionSym);
      final groupedBySymbolSnapshot = Map<String, dynamic>.from(positionBook.groupedBySymbol);

      debugPrint('Total groups in snapshot: ${groupSymbolsSnapshot.length}');

      // Filter groups based on type
      final filteredGroups = groupSymbolsSnapshot.where((groupSymbol) {
        final groupData = groupedBySymbolSnapshot[groupSymbol];
        if (groupData == null) {
          debugPrint('Group $groupSymbol has null data');
          return false;
        }

        final isCustomGrp = groupData["isCustomGrp"] ?? false;
        final groupList = (groupData['groupList'] as List?) ?? [];

        debugPrint('Group: $groupSymbol, isCustom: $isCustomGrp, positions: ${groupList.length}');

        // For custom groups, show even if empty (user just created it)
        // For default groups, only show if it has F&O positions
        if (!isCustomGrp) {
          // Default group - must have F&O positions
          final hasFnoPositions = groupList.any((pos) =>
            pos != null && _isFutureOrOption(pos)
          );
          if (!hasFnoPositions) {
            debugPrint('Skipping default group $groupSymbol - no F&O positions');
            return false;
          }
        }

        if (filterType == 'default') {
          return !isCustomGrp;
        } else if (filterType == 'custom') {
          return isCustomGrp;
        }
        return true;
      }).toList();

      debugPrint('Filtered groups ($filterType): ${filteredGroups.length}');
      return filteredGroups.isNotEmpty;
    } catch (e, stackTrace) {
      debugPrint('>>> _hasGroups EXCEPTION (filterType: $filterType)');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      return false;
    }
  }

  // Helper to check if position is F&O
  bool _isFutureOrOption(dynamic position) {
    final expDate = position['expDate']?.toString() ?? '';
    return expDate.isNotEmpty && expDate != '' && expDate != '-';
  }

  // Section header for Default/Custom groups
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: resolveThemeColor(context,
            dark: MyntColors.backgroundColorDark,
            light: MyntColors.backgroundColor),
        border: Border(
          bottom: BorderSide(
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: MyntWebTextStyles.caption(
          context,
          darkColor: MyntColors.textSecondaryDark,
          lightColor: MyntColors.textSecondary,
          fontWeight: MyntFonts.medium,
        ),
      ),
    );
  }
}

// Total P&L/MTM Display Widget (same as position screen)
class _PnLDisplay extends StatelessWidget {
  final bool isNetPnl;
  final bool isDay;
  final String totUnRealMtm;
  final String totMtM;
  final String totBookedPnL;
  final String totPnL;
  final PortfolioProvider positionBook;

  const _PnLDisplay({
    required this.isNetPnl,
    required this.isDay,
    required this.totUnRealMtm,
    required this.totMtM,
    required this.totBookedPnL,
    required this.totPnL,
    required this.positionBook,
  });

  Color _getValueColor(String value, BuildContext context) {
    if (value.startsWith("-")) {
      return resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
    } else if (value == "0.00") {
      return resolveThemeColor(context,
          dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    }
    return resolveThemeColor(context,
        dark: MyntColors.profitDark, light: MyntColors.profit);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 10.0, left: 8.0, right: 8.0, bottom: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                !isNetPnl ? "Total MTM" : "Total P&L",
                style: MyntWebTextStyles.body(
                  context,
                  darkColor: MyntColors.textSecondaryDark,
                  lightColor: MyntColors.textSecondary,
                  fontWeight: MyntFonts.medium,
                ),
              ),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: isDarkMode(context)
                      ? MyntColors.rippleDark
                      : MyntColors.rippleLight,
                  highlightColor: isDarkMode(context)
                      ? MyntColors.highlightDark
                      : MyntColors.highlightLight,
                  onTap: () {
                    positionBook.chngPositionPnl(!positionBook.isNetPnl);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      _assets.switchIcon,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          !isNetPnl
              ? _buildValueText(context, isDay ? totUnRealMtm : totMtM,
                  isDay ? _getValueColor(totUnRealMtm, context) : _getValueColor(totMtM, context))
              : _buildValueText(context, isDay ? totBookedPnL : totPnL,
                  isDay ? _getValueColor(totBookedPnL, context) : _getValueColor(totPnL, context))
        ],
      ),
    );
  }

  Widget _buildValueText(BuildContext context, String value, Color color) {
    return Text(
      value,
      style: MyntWebTextStyles.head(
        context,
        color: color,
        fontWeight: MyntFonts.medium,
      ),
    );
  }
}
