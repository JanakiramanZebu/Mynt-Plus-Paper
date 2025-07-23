import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/market_watch_provider.dart';
import '../../locator/preference.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/list_divider.dart';

class ScripFilterBottomSheet extends ConsumerStatefulWidget {
  const ScripFilterBottomSheet({
    super.key,
  });

  @override
  ConsumerState<ScripFilterBottomSheet> createState() =>
      _WatchlistsBottomSheetState();
}

class _WatchlistsBottomSheetState
    extends ConsumerState<ScripFilterBottomSheet> {
  Preferences pref = Preferences();
  bool scripisAscending = true;
  bool pricepisAscending = true;
  bool perchangisAscending = true;
  String currentSortType = ""; // Track current sort type

  @override
  void initState() {
    super.initState();
    _initCurrentSort();
  }

  void _initCurrentSort() {
    // Get the current sort from provider
    final sortByWL = ref.read(marketWatchProvider).sortByWL;

    // Reset all sort states to default when no sorting is active
    if (sortByWL.isEmpty) {
      currentSortType = "";
      scripisAscending = true;
      pricepisAscending = true;
      perchangisAscending = true;
      return;
    }

    // Determine current sort type and direction
    if (sortByWL.startsWith("Scrip")) {
      currentSortType = "scrip";
      scripisAscending = sortByWL.contains("A to Z");
    } else if (sortByWL.startsWith("Price")) {
      currentSortType = "price";
      pricepisAscending = sortByWL.contains("Low to High");
    } else if (sortByWL.startsWith("Per.Chng")) {
      currentSortType = "perchng";
      perchangisAscending = sortByWL.contains("Low to High");
    }
  }

  // Apply sort directly and force UI update
  void _applySortForType(String type) {
    final watchlist = ref.read(marketWatchProvider);
    String sortingValue = "";

    // Debug current values
    print("Before sort - Current type: $currentSortType");
    print(
        "Before sort - Sort state: Scrip: $scripisAscending, Price: $pricepisAscending, PerChng: $perchangisAscending");

    // Update current sort type
    setState(() {
      // If already using this type, toggle direction
      if (currentSortType == type) {
        if (type == "scrip") {
          scripisAscending = !scripisAscending;
        } else if (type == "price") {
          pricepisAscending = !pricepisAscending;
        } else if (type == "perchng") {
          perchangisAscending = !perchangisAscending;
        }
      } else {
        // Set new sort type
        currentSortType = type;
      }

      // Determine the sort string to apply
      if (type == "scrip") {
        sortingValue = scripisAscending ? "Scrip - A to Z" : "Scrip - Z to A";
      } else if (type == "price") {
        sortingValue =
            pricepisAscending ? "Price - Low to High" : "Price - High to Low";
      } else if (type == "perchng") {
        sortingValue = perchangisAscending
            ? "Per.Chng - Low to High"
            : "Per.Chng - High to Low";
      }
    });

    // Debug the resulting sort value
    print("Applying sort value: $sortingValue");

    // Apply the sort directly with force flag
    ref.read(marketWatchProvider).getSortByWL(sortingValue);

    // Force UI update by using the provider method
    ref.read(marketWatchProvider).filterMWScrip(
        sorting: sortingValue, wlName: watchlist.wlName, context: context);

    // Close the sheet
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.isDarkMode ? Colors.black : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomDragHandler(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.titleText(
                      text: "Sort by",
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
            // Scrip name sorting option with indicator
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

                        // TextWidget.subText(
                        // text:"Scrip Name" ,
                        // color: colors.colorGrey,
                        // theme: theme.isDarkMode,
                        // fw:  currentSortType == "scrip"
                        //         ? 1
                        //         : null),

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
                              fw: currentSortType == "scrip" ? 0 : null),
                        )
                      ],
                    ),
                  ),
                  const ListDivider(),
                ],
              ),
            ),
            // LTP sorting option with indicator
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

                        //  TextWidget.subText(
                        // text:"LTP",
                        // color: colors.colorGrey,
                        // theme: theme.isDarkMode,
                        // fw:  currentSortType == "price"
                        //         ? 1
                        //         : null),

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
                              fw: currentSortType == "price" ? 0 : null),
                        )
                      ],
                    ),
                  ),
                  const ListDivider(),
                ],
              ),
            ),
            // Percentage change sorting option with indicator
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
                                    : colors.textSecondaryLight),
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
                              fw: currentSortType == "perchng" ? 0 : null),
                        )
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
