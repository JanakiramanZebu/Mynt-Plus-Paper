import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../provider/ledger_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/list_divider.dart';

class PledgeApproveFilterBottomSheet extends ConsumerStatefulWidget {
  final Function(String sortType, bool isAscending) onSortApplied;
  final String currentSortType;
  final bool nameAscending;
  final bool priceAscending;
  final bool haircutAscending;
  final bool isPledgeFilter;

  const PledgeApproveFilterBottomSheet({
    super.key,
    required this.onSortApplied,
    this.currentSortType = "",
    this.nameAscending = true,
    this.priceAscending = true,
    this.haircutAscending = true,
    this.isPledgeFilter = false,
  });

  @override
  ConsumerState<PledgeApproveFilterBottomSheet> createState() =>
      _PledgeApproveFilterBottomSheetState();
}

class _PledgeApproveFilterBottomSheetState
    extends ConsumerState<PledgeApproveFilterBottomSheet> {
  late bool scripisAscending;
  late bool pricepisAscending;
  late bool haircutisAscending;
  late String currentSortType;

  @override
  void initState() {
    super.initState();
    currentSortType = widget.currentSortType;
    scripisAscending = widget.nameAscending;
    pricepisAscending = widget.priceAscending;
    haircutisAscending = widget.haircutAscending;
  }

  void _applySortForType(String type) {
    setState(() {
      // If already using this type, toggle direction
      if (currentSortType == type) {
        if (type == "name") {
          scripisAscending = !scripisAscending;
        } else if (type == "price") {
          pricepisAscending = !pricepisAscending;
        } else if (type == "haircut") {
          haircutisAscending = !haircutisAscending;
        }
      } else {
        // Set new sort type
        currentSortType = type;
      }
    });

    // Determine the sort direction
    bool isAscending = true;
    if (type == "name") {
      isAscending = scripisAscending;
    } else if (type == "price") {
      isAscending = pricepisAscending;
    } else if (type == "haircut") {
      isAscending = haircutisAscending;
    }

    // Apply the sort via callback
    widget.onSortApplied(type, isAscending);

    // Close the sheet
    Navigator.pop(context);
  }

  Widget _buildPledgeFilterItem({
    required BuildContext context,
    required ThemesProvider theme,
    required String label,
    required String filterValue,
    required String currentFilter,
  }) {
    final isSelected = currentFilter == filterValue;
    return InkWell(
      onTap: () {
        ref.read(ledgerProvider).setPledgeCashFilter(filterValue);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.asset(
              theme.isDarkMode
                  ? isSelected
                      ? assets.darkCheckedboxIcon
                      : assets.darkCheckboxIcon
                  : isSelected
                      ? assets.ckeckedboxIcon
                      : assets.ckeckboxIcon,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
                // Icon(
                //    ? Icons.check_circle : Icons.circle_outlined,
                //   size: 20,
                //   color: isSelected
                //       ? theme.isDarkMode
                //           ? colors.primaryDark
                //           : colors.primaryLight
                //       : theme.isDarkMode
                //           ? colors.textSecondaryDark
                //           : colors.textSecondaryLight,
                // ),
                const SizedBox(width: 15),
                Text(
                  label,
                  style: TextWidget.textStyle(
                      fontSize: 14,
                      color: isSelected
                          ? theme.isDarkMode
                              ? colors.primaryDark
                              : colors.primaryLight
                          : theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                      theme: theme.isDarkMode,
                      fw: isSelected ? 2 : 0),
                ),
              ],
            ),
          ),
          const ListDivider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final currentCashFilter = widget.isPledgeFilter
        ? ref.watch(ledgerProvider).pledgeCashFilter
        : '';
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          color: theme.isDarkMode ? Colors.black : Colors.white,
          border: Border(
            top: BorderSide(
              color: theme.isDarkMode
                  ? colors.textSecondaryDark.withOpacity(0.5)
                  : colors.colorWhite,
            ),
            left: BorderSide(
              color: theme.isDarkMode
                  ? colors.textSecondaryDark.withOpacity(0.5)
                  : colors.colorWhite,
            ),
            right: BorderSide(
              color: theme.isDarkMode
                  ? colors.textSecondaryDark.withOpacity(0.5)
                  : colors.colorWhite,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomDragHandler(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.titleText(
                      text: widget.isPledgeFilter ? "Filter by" : "Sort by",
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                      fw: 1),
                ],
              ),
            ),
            Divider(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider),
            if (widget.isPledgeFilter) ...[
              _buildPledgeFilterItem(
                context: context,
                theme: theme,
                label: "All",
                filterValue: "all",
                currentFilter: currentCashFilter,
              ),
              _buildPledgeFilterItem(
                context: context,
                theme: theme,
                label: "Cash",
                filterValue: "cash",
                currentFilter: currentCashFilter,
              ),
              _buildPledgeFilterItem(
                context: context,
                theme: theme,
                label: "Non-Cash",
                filterValue: "noncash",
                currentFilter: currentCashFilter,
              ),
              const SizedBox(height: 8),
            ] else ...[
            // Name (A to Z) sorting option
            InkWell(
              onTap: () => _applySortForType("name"),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Icon(
                          scripisAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 20,
                          color: currentSortType == "name"
                              ? theme.isDarkMode
                                  ? colors.primaryDark
                                  : colors.primaryLight
                              : theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                        ),
                        const SizedBox(width: 15),
                        Text(
                          "A to Z",
                          style: TextWidget.textStyle(
                              fontSize: 14,
                              color: currentSortType == "name"
                                  ? theme.isDarkMode
                                      ? colors.primaryDark
                                      : colors.primaryLight
                                  : theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                              theme: theme.isDarkMode,
                              fw: currentSortType == "name" ? 2 : 0),
                        )
                      ],
                    ),
                  ),
                  const ListDivider(),
                ],
              ),
            ),
            // Price sorting option
            InkWell(
              onTap: () => _applySortForType("price"),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Icon(
                          pricepisAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 20,
                          color: currentSortType == "price"
                              ? theme.isDarkMode
                                  ? colors.primaryDark
                                  : colors.primaryLight
                              : theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                        ),
                        const SizedBox(width: 15),
                        Text(
                          "Price",
                          style: TextWidget.textStyle(
                              fontSize: 14,
                              color: currentSortType == "price"
                                  ? theme.isDarkMode
                                      ? colors.primaryDark
                                      : colors.primaryLight
                                  : theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                              theme: theme.isDarkMode,
                              fw: currentSortType == "price" ? 2 : 0),
                        )
                      ],
                    ),
                  ),
                  const ListDivider(),
                ],
              ),
            ),
            // Haircut sorting option
            InkWell(
              onTap: () => _applySortForType("haircut"),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Icon(
                          haircutisAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 20,
                          color: currentSortType == "haircut"
                              ? theme.isDarkMode
                                  ? colors.primaryDark
                                  : colors.primaryLight
                              : theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                        ),
                        const SizedBox(width: 15),
                        Text(
                          "Haircut",
                          style: TextWidget.textStyle(
                              fontSize: 14,
                              color: currentSortType == "haircut"
                                  ? theme.isDarkMode
                                      ? colors.primaryDark
                                      : colors.primaryLight
                                  : theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                              theme: theme.isDarkMode,
                              fw: currentSortType == "haircut" ? 2 : 0),
                        )
                      ],
                    ),
                  ),
                  const ListDivider(),
                ],
              ),
            ),
            ],
          ],
        ),
      ),
    );
  }
}

