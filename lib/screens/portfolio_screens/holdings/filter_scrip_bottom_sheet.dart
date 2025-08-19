import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../locator/preference.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/list_divider.dart';

class HoldingsScripFilterBottomSheet extends ConsumerStatefulWidget {
  const HoldingsScripFilterBottomSheet({
    super.key,
  });

  @override
  ConsumerState<HoldingsScripFilterBottomSheet> createState() =>
      _WatchlistsBottomSheetState();
}

class _WatchlistsBottomSheetState
    extends ConsumerState<HoldingsScripFilterBottomSheet> {
  Preferences pref = Preferences();
  bool scripisAscending = true;
  bool pricepisAscending = true;
  bool qtyisAscending = true;
  bool perchangisAscending = true;
  bool ltppcisAscending = true;
  bool investbyisAscending = true;
  String currentSortType = ""; // Track current sort type

  @override
  void initState() {
    super.initState();
    _initCurrentSort();
  }

  void _initCurrentSort() {
    try {
      // Get the current sort from provider
      final currentHoldingSortOption = ref.read(portfolioProvider).currentHoldingSortOption;

      // Reset all sort states to default when no sorting is active
      if (currentHoldingSortOption.isEmpty) {
        currentSortType = "";
        scripisAscending = pref.isScripname ?? true;
        pricepisAscending = pref.isPrice ?? true;
        qtyisAscending = pref.isQuantity ?? true;
        perchangisAscending = pref.isPerchang ?? true;
        ltppcisAscending = pref.isLtppc ?? true;
        investbyisAscending = pref.isInvestby ?? true;
        return;
      }

      // Determine current sort type and direction based on the sort option
      if (currentHoldingSortOption == "ASC" || currentHoldingSortOption == "DSC") {
        currentSortType = "scrip";
        scripisAscending = currentHoldingSortOption == "ASC";
      } else if (currentHoldingSortOption == "LTPASC" || currentHoldingSortOption == "LTPDSC") {
        currentSortType = "price";
        pricepisAscending = currentHoldingSortOption == "LTPASC";
      } else if (currentHoldingSortOption == "QTYASC" || currentHoldingSortOption == "QTYDSC") {
        currentSortType = "qty";
        qtyisAscending = currentHoldingSortOption == "QTYASC";
      } else if (currentHoldingSortOption == "PCASC" || currentHoldingSortOption == "PCDESC") {
        currentSortType = "perchng";
        perchangisAscending = currentHoldingSortOption == "PCASC";
      } else if (currentHoldingSortOption == "LTPPCASC" || currentHoldingSortOption == "LTPPCDESC") {
        currentSortType = "ltppc";
        ltppcisAscending = currentHoldingSortOption == "LTPPCASC";
      } else if (currentHoldingSortOption == "INVASC" || currentHoldingSortOption == "INVDESC") {
        currentSortType = "investby";
        investbyisAscending = currentHoldingSortOption == "INVASC";
      }
    } catch (e) {
      print("Error initializing sort state: $e");
      // Fallback to default values
      currentSortType = "";
      scripisAscending = pref.isScripname ?? true;
      pricepisAscending = pref.isPrice ?? true;
      qtyisAscending = pref.isQuantity ?? true;
      perchangisAscending = pref.isPerchang ?? true;
      ltppcisAscending = pref.isLtppc ?? true;
      investbyisAscending = pref.isInvestby ?? true;
    }
  }

  // Apply sort directly and force UI update
  void _applySortForType(String type) {
    String sortingValue = "";

    // Debug current values
    print("Before sort - Current type: $currentSortType");
    print("Before sort - Sort state: Scrip: $scripisAscending, Price: $pricepisAscending, Qty: $qtyisAscending, PerChng: $perchangisAscending, Ltppc: $ltppcisAscending, Investby: $investbyisAscending");

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
        } else if (type == "ltppc") {
          ltppcisAscending = !ltppcisAscending;
        } else if (type == "investby") {
          investbyisAscending = !investbyisAscending;
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
      } else if (type == "ltppc") {
        sortingValue = ltppcisAscending ? "LTPPCASC" : "LTPPCDESC";
      } else if (type == "investby") {
        sortingValue = investbyisAscending ? "INVASC" : "INVDESC";
      }
    });

    // Debug the resulting sort value
    print("Applying sort value: $sortingValue");

    // Apply the sort directly
    ref.read(portfolioProvider).filterHoldings(sorting: sortingValue, context: context);

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
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
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
                      text: "Sort by", theme: theme.isDarkMode, color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight, fw: 1),
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
                          "LTP Perc.Change",
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
              onTap: () => _applySortForType("ltppc"),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Icon(
                          ltppcisAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 20,
                          color: currentSortType == "ltppc"
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
                          "Return Perc.Change",
                          style: TextWidget.textStyle(
                              fontSize: 14,
                              color: currentSortType == "ltppc"
                                  ? theme.isDarkMode
                                      ? colors.primaryDark
                                      : colors.primaryLight
                                  : theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                              theme: theme.isDarkMode,
                              fw: currentSortType == "ltppc" ? 2 : null),
                        ),
                      ],
                    ),
                  ),
                  const ListDivider(),
                ],
              ),
            ),
            InkWell(
              onTap: () => _applySortForType("investby"),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Icon(
                          investbyisAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 20,
                          color: currentSortType == "investby"
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
                          "Invested Price",
                          style: TextWidget.textStyle(
                              fontSize: 14,
                              color: currentSortType == "investby"
                                  ? theme.isDarkMode
                                      ? colors.primaryDark
                                      : colors.primaryLight
                                  : theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                              theme: theme.isDarkMode,
                              fw: currentSortType == "investby" ? 2 : null),
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
