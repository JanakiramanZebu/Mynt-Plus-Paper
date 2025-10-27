import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../locator/preference.dart';
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/list_divider.dart';

class PositionScripFilterBottomSheet extends ConsumerStatefulWidget {
  const PositionScripFilterBottomSheet({
    super.key,
  });

  @override
  ConsumerState<PositionScripFilterBottomSheet> createState() =>
      _PositionScripBottomSheetState();
}

class _PositionScripBottomSheetState
    extends ConsumerState<PositionScripFilterBottomSheet> {
  Preferences pref = Preferences();
  bool scripisAscending = true;
  bool pricepisAscending = true;
  bool qtyisAscending = true;
  bool perchangisAscending = true;
  bool postion = true;
  String currentSortType = ""; // Track current sort type

  @override
  void initState() {
    super.initState();
    _initCurrentSort();
  }

  void _initCurrentSort() {
    try {
      // Get the current sort from provider
      final currentPositionSortOption = ref.read(portfolioProvider).currentPositionSortOption;

      // Reset all sort states to default when no sorting is active
      if (currentPositionSortOption.isEmpty) {
        currentSortType = "";
        scripisAscending = pref.isPosScripname ?? true;
        pricepisAscending = pref.isPosPrice ?? true;
        qtyisAscending = pref.isPosQuantity ?? true;
        perchangisAscending = pref.isPosPerchang ?? true;
        postion = pref.isPostion ?? true;
        return;
      }

      // Determine current sort type and direction based on the sort option
      if (currentPositionSortOption == "ASC" || currentPositionSortOption == "DSC") {
        currentSortType = "scrip";
        scripisAscending = currentPositionSortOption == "ASC";
      } else if (currentPositionSortOption == "LTPASC" || currentPositionSortOption == "LTPDSC") {
        currentSortType = "price";
        pricepisAscending = currentPositionSortOption == "LTPASC";
      } else if (currentPositionSortOption == "QTYASC" || currentPositionSortOption == "QTYDSC") {
        currentSortType = "qty";
        qtyisAscending = currentPositionSortOption == "QTYASC";
      } else if (currentPositionSortOption == "PCASC" || currentPositionSortOption == "PCDESC") {
        currentSortType = "perchng";
        perchangisAscending = currentPositionSortOption == "PCASC";
      } else if (currentPositionSortOption == "Open") {
        currentSortType = "position";
        postion = true; // 0 qty at top
      } else if (currentPositionSortOption == "OpenDSC") {
        currentSortType = "position";
        postion = false; // 0 qty at bottom
      } else if (currentPositionSortOption == "Close") {
        currentSortType = "position";
        postion = true; // Default to Open position
      }
    } catch (e) {
      print("Error initializing sort state: $e");
      // Fallback to default values
      currentSortType = "";
      scripisAscending = pref.isPosScripname ?? true;
      pricepisAscending = pref.isPosPrice ?? true;
      qtyisAscending = pref.isPosQuantity ?? true;
      perchangisAscending = pref.isPosPerchang ?? true;
      postion = pref.isPostion ?? true;
    }
  }

  // Apply sort directly and force UI update
  void _applySortForType(String type) {
    String sortingValue = "";

    // Debug current values
    print("Before sort - Current type: $currentSortType");
    print("Before sort - Sort state: Scrip: $scripisAscending, Price: $pricepisAscending, Qty: $qtyisAscending, PerChng: $perchangisAscending, Position: $postion");

    // Update current sort type
    setState(() {
      // If already using this type, toggle direction
      if (currentSortType == type) {
        if (type == "scrip") {
          scripisAscending = !scripisAscending;
        } else if (type == "price") {
          pricepisAscending = !pricepisAscending;
        } else if (type == "qty") {
          qtyisAscending = !qtyisAscending;
        } else if (type == "perchng") {
          perchangisAscending = !perchangisAscending;
        } else if (type == "position") {
          postion = !postion;
        }
      } else {
        // Set new sort type
        currentSortType = type;
      }

      // Determine the sort string to apply
      if (type == "scrip") {
        sortingValue = scripisAscending ? "ASC" : "DSC";
      } else if (type == "price") {
        sortingValue = pricepisAscending ? "LTPASC" : "LTPDSC";
      } else if (type == "qty") {
        sortingValue = qtyisAscending ? "QTYASC" : "QTYDSC";
      } else if (type == "perchng") {
        sortingValue = perchangisAscending ? "PCASC" : "PCDESC";
      } else if (type == "position") {
        sortingValue = postion ? "Open" : "OpenDSC";
      }
    });

    // Debug the resulting sort value
    print("Applying sort value: $sortingValue");

    // Apply the sort directly
    ref.read(portfolioProvider).sortPositions(sorting: sortingValue);

    // Close the sheet
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),

                                border: Border(
                                  top: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  left: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  right: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                ),
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            ),

        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomDragHandler(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.titleText(
                      text: "Sort by",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      fw: 1),
                ],
              ),
            ),
            Divider(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider),
            InkWell(
              onTap: () => _applySortForType("scrip"),
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
                          color: currentSortType == "scrip"
                              ? theme.isDarkMode
                                  ? colors.primaryDark
                                  : colors.primaryLight
                              : theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Scrip Name",
                          style: TextWidget.textStyle(
                              fontSize: 14,
                              color: currentSortType == "scrip"
                                  ? theme.isDarkMode
                                      ? colors.primaryDark
                                      : colors.primaryLight
                                  : theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                              theme: theme.isDarkMode,
                              fw: currentSortType == "scrip" ? 2 : null),
                        ),
                      ],
                    ),
                  ),
                  const ListDivider(),
                ],
              ),
            ),
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
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          "LTP",
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
                              fw: currentSortType == "price" ? 2 : null),
                        ),
                      ],
                    ),
                  ),
                  const ListDivider(),
                ],
              ),
            ),
            InkWell(
              onTap: () => _applySortForType("qty"),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Icon(
                          qtyisAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 20,
                          color: currentSortType == "qty"
                              ? theme.isDarkMode
                                  ? colors.primaryDark
                                  : colors.primaryLight
                              : theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Qty",
                          style: TextWidget.textStyle(
                              fontSize: 14,
                              color: currentSortType == "qty"
                                  ? theme.isDarkMode
                                      ? colors.primaryDark
                                      : colors.primaryLight
                                  : theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                              theme: theme.isDarkMode,
                              fw: currentSortType == "qty" ? 2 : null),
                        ),
                      ],
                    ),
                  ),
                  const ListDivider(),
                ],
              ),
            ),
            InkWell(
              onTap: () => _applySortForType("perchng"),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Icon(
                          perchangisAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 20,
                          color: currentSortType == "perchng"
                              ? theme.isDarkMode
                                  ? colors.primaryDark
                                  : colors.primaryLight
                              : theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Perc.Change",
                          style: TextWidget.textStyle(
                              fontSize: 14,
                              color: currentSortType == "perchng"
                                  ? theme.isDarkMode
                                      ? colors.primaryDark
                                      : colors.primaryLight
                                  : theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                              theme: theme.isDarkMode,
                              fw: currentSortType == "perchng" ? 2 : null),
                        ),
                      ],
                    ),
                  ),
                  const ListDivider(),
                ],
              ),
            ),
            InkWell(
              onTap: () => _applySortForType("position"),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Icon(
                          postion
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 20,
                          color: currentSortType == "position"
                              ? theme.isDarkMode
                                  ? colors.primaryDark
                                  : colors.primaryLight
                              : theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          postion ? "Open Position" : "Close Position",
                          style: TextWidget.textStyle(
                              fontSize: 14,
                              color: currentSortType == "position"
                                  ? theme.isDarkMode
                                      ? colors.primaryDark
                                      : colors.primaryLight
                                  : theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                              theme: theme.isDarkMode,
                              fw: currentSortType == "position" ? 2 : null),
                        ),
                      ],
                    ),
                  ),
                  const ListDivider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
