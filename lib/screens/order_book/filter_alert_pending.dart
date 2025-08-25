import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../res/res.dart';
import '../../locator/preference.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/list_divider.dart';

class OrderbookPendingAlertkFilterBottomSheet extends ConsumerStatefulWidget {
  const OrderbookPendingAlertkFilterBottomSheet({super.key});

  @override
  ConsumerState<OrderbookPendingAlertkFilterBottomSheet> createState() =>
      _OrderbookPendingAlertkFilterBottomSheetState();
}

class _OrderbookPendingAlertkFilterBottomSheetState
    extends ConsumerState<OrderbookPendingAlertkFilterBottomSheet> {
  Preferences pref = Preferences();
  bool scripisAscending = true;
  bool pricepisAscending = true;
  bool alertvalueisAscending = true;
  bool changeisAscending = true;
  String currentSortType = ""; // Track current sort type
  
  // Static variable to track the last selected sort type across instances
  static String _lastSelectedSortType = "";

  @override
  void initState() {
    super.initState();
    _initCurrentSort();
  }

  void _initCurrentSort() {
    try {
      // Initialize sort states from preferences
      scripisAscending = pref.isPAScripname ?? true;
      pricepisAscending = pref.isPAPrice ?? true;
      alertvalueisAscending = pref.isPAPricealert ?? true;
      changeisAscending = pref.isPAChange ?? true;
      
      // Try to restore the last selected sort type from static variable
      if (_lastSelectedSortType.isNotEmpty) {
        currentSortType = _lastSelectedSortType;
        // Set the corresponding boolean to the correct state
        if (_lastSelectedSortType == "scrip") {
          scripisAscending = pref.isPAScripname ?? true;
        } else if (_lastSelectedSortType == "price") {
          pricepisAscending = pref.isPAPrice ?? true;
        } else if (_lastSelectedSortType == "alertvalue") {
          alertvalueisAscending = pref.isPAPricealert ?? true;
        } else if (_lastSelectedSortType == "change") {
          changeisAscending = pref.isPAChange ?? true;
        }
      } else {
        // If no last selected type, default to no sorting
        currentSortType = "";
      }
    } catch (e) {
      // Fallback to default values
      currentSortType = "";
      scripisAscending = pref.isPAScripname ?? true;
      pricepisAscending = pref.isPAPrice ?? true;
      alertvalueisAscending = pref.isPAPricealert ?? true;
      changeisAscending = pref.isPAChange ?? true;
    }
  }

  // Apply sort directly and force UI update
  void _applySortForType(String type) {
    String sortingValue = "";

   
    setState(() {
      // If already using this type, toggle direction
      if (currentSortType == type) {
        if (type == "scrip") {
          scripisAscending = !scripisAscending;
        } else if (type == "price") {
          pricepisAscending = !pricepisAscending;
        } else if (type == "alertvalue") {
          alertvalueisAscending = !alertvalueisAscending;
        } else if (type == "change") {
          changeisAscending = !changeisAscending;
        }
      } else {
        // Set new sort type and start with ascending
        currentSortType = type;
        scripisAscending = type == "scrip" ? true : pref.isPAScripname ?? true;
        pricepisAscending = type == "price" ? true : pref.isPAPrice ?? true;
        alertvalueisAscending = type == "alertvalue" ? true : pref.isPAPricealert ?? true;
        changeisAscending = type == "change" ? true : pref.isPAChange ?? true;
      }

      // Determine the sort string to apply
      if (type == "scrip") {
        sortingValue = scripisAscending ? "ASC" : "DSC";
      } else if (type == "price") {
        sortingValue = pricepisAscending ? "LTPASC" : "LTPDSC";
      } else if (type == "alertvalue") {
        sortingValue = alertvalueisAscending ? "ALERTVALUEASC" : "ALERTVALUEDSC";
      } else if (type == "change") {
        sortingValue = changeisAscending ? "CHANGEASC" : "CHANGEDSC";
      }
    });

   

    // Apply the sort directly
    ref.read(marketWatchProvider).filterPendingAlert(sortingValue);

    // Update preferences
    if (type == "scrip") {
      pref.setPAScrip(scripisAscending);
    } else if (type == "price") {
      pref.setPAPrice(pricepisAscending);
    } else if (type == "alertvalue") {
      pref.setPAPriceAlert(alertvalueisAscending);
    } else if (type == "change") {
      pref.setPAChange(changeisAscending);
    }

    // Store the last selected sort type in static variable for persistence
    _lastSelectedSortType = type;

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
                          color: !theme.isDarkMode
                              ? colors.textPrimaryLight
                              : colors.textPrimaryDark,
                          fw: 1),
                    ])),
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
              onTap: () => _applySortForType("alertvalue"),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Icon(
                          alertvalueisAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 20,
                          color: currentSortType == "alertvalue"
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
                          "Alert Price",
                          style: TextWidget.textStyle(
                              fontSize: 14,
                              color: currentSortType == "alertvalue"
                                  ? theme.isDarkMode
                                      ? colors.primaryDark
                                      : colors.primaryLight
                                  : theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                              theme: theme.isDarkMode,
                              fw: currentSortType == "alertvalue" ? 2 : null),
                        ),
                      ],
                    ),
                  ),
                  const ListDivider(),
                ],
              ),
            ),
            InkWell(
              onTap: () => _applySortForType("change"),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Icon(
                          changeisAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 20,
                          color: currentSortType == "change"
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
                          "Change",
                          style: TextWidget.textStyle(
                              fontSize: 14,
                              color: currentSortType == "change"
                                  ? theme.isDarkMode
                                      ? colors.primaryDark
                                      : colors.primaryLight
                                  : theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                              theme: theme.isDarkMode,
                              fw: currentSortType == "change" ? 2 : null),
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
