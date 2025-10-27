import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../locator/preference.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/list_divider.dart';

class MFFilterBottomSheet extends ConsumerStatefulWidget {
  const MFFilterBottomSheet({
    super.key,
  });

  @override
  ConsumerState<MFFilterBottomSheet> createState() => _MFFilterBottomSheetState();
}

class _MFFilterBottomSheetState extends ConsumerState<MFFilterBottomSheet> {
  Preferences pref = Preferences();
  bool nameIsAscending = true;
  bool navIsAscending = true;
  bool unitIsAscending = true;
  bool returnPercChangeIsAscending = true;
  bool investedPriceIsAscending = true;
  String currentSortType = ""; // Track current sort type

  @override
  void initState() {
    _initCurrentSort();
    super.initState();
  }

  void _initCurrentSort() {
    try {
      // Get the current sort from provider
      final currentMFSortOption = ref.read(mfProvider).currentMFSortOption;

      // Initialize with default values from preferences
      nameIsAscending = pref.isMFName ?? true;
      navIsAscending = pref.isMFNav ?? true;
      unitIsAscending = pref.isMFUnit ?? true;
      returnPercChangeIsAscending = pref.isMFReturnPercChange ?? true;
      investedPriceIsAscending = pref.isMFInvestedPrice ?? true;

      // Reset all sort states to default when no sorting is active
      if (currentMFSortOption.isEmpty) {
        currentSortType = "";
        return;
      }

      // Determine current sort type and direction based on the sort option
      if (currentMFSortOption == "NAMEASC" || currentMFSortOption == "NAMEDSC") {
        currentSortType = "name";
        nameIsAscending = currentMFSortOption == "NAMEASC";
      } else if (currentMFSortOption == "NAVASC" || currentMFSortOption == "NAVDSC") {
        currentSortType = "nav";
        navIsAscending = currentMFSortOption == "NAVASC";
      } else if (currentMFSortOption == "UNITASC" || currentMFSortOption == "UNITDSC") {
        currentSortType = "unit";
        unitIsAscending = currentMFSortOption == "UNITASC";
      } else if (currentMFSortOption == "RETURNPERCASC" || currentMFSortOption == "RETURNPERCDSC") {
        currentSortType = "returnPercChange";
        returnPercChangeIsAscending = currentMFSortOption == "RETURNPERCASC";
      } else if (currentMFSortOption == "INVESTEDASC" || currentMFSortOption == "INVESTEDDSC") {
        currentSortType = "investedPrice";
        investedPriceIsAscending = currentMFSortOption == "INVESTEDASC";
      }
    } catch (e) {
      print("Error initializing MF sort state: $e");
      // Fallback to default values
      currentSortType = "";
      // Variables are already initialized with default values above
    }
  }

  void _applySortForType(String type) {
    String sortingValue = "";

    setState(() {
      // If already using this type, toggle direction
      if (currentSortType == type) {
        if (type == "name") {
          nameIsAscending = !nameIsAscending;
        } else if (type == "nav") {
          navIsAscending = !navIsAscending;
        } else if (type == "unit") {
          unitIsAscending = !unitIsAscending;
        } else if (type == "returnPercChange") {
          returnPercChangeIsAscending = !returnPercChangeIsAscending;
        } else if (type == "investedPrice") {
          investedPriceIsAscending = !investedPriceIsAscending;
        }
      } else {
        // Set new sort type
        currentSortType = type;
      }

      // Determine the sort string to apply
      if (type == "name") {
        sortingValue = nameIsAscending ? "NAMEASC" : "NAMEDSC";
      } else if (type == "nav") {
        sortingValue = navIsAscending ? "NAVASC" : "NAVDSC";
      } else if (type == "unit") {
        sortingValue = unitIsAscending ? "UNITASC" : "UNITDSC";
      } else if (type == "returnPercChange") {
        sortingValue = returnPercChangeIsAscending ? "RETURNPERCASC" : "RETURNPERCDSC";
      } else if (type == "investedPrice") {
        sortingValue = investedPriceIsAscending ? "INVESTEDASC" : "INVESTEDDSC";
      }
    });

    // Apply the sort
    ref.read(mfProvider).filterMFHoldings(sorting: sortingValue, context: context);

    // Close the sheet
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.read(themeProvider);
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
                        text: "Sort by", color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight, theme: theme.isDarkMode, fw: 1),
                  ],
                ),
              ),
              Divider(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider),

              // Name Filter
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
                            nameIsAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                            color: currentSortType == "name"
                                ? theme.isDarkMode
                                    ? colors.primaryDark
                                    : colors.primaryLight
                                : colors.colorGrey,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            "Name",
                            style: TextWidget.textStyle(
                                fontSize: 14,
                                color: currentSortType == "name"
                                    ? theme.isDarkMode
                                        ? colors.primaryDark
                                        : colors.primaryLight
                                    : colors.colorGrey,
                                theme: theme.isDarkMode,
                                fw: currentSortType == "name" ? 2 : null),
                          ),
                        ],
                      ),
                    ),
                    const ListDivider(),
                  ],
                ),
              ),

              // NAV Filter
              InkWell(
                onTap: () => _applySortForType("nav"),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Icon(
                            navIsAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                            color: currentSortType == "nav"
                                ? theme.isDarkMode
                                    ? colors.primaryDark
                                    : colors.primaryLight
                                : colors.colorGrey,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            "NAV",
                            style: TextWidget.textStyle(
                                fontSize: 14,
                                color: currentSortType == "nav"
                                    ? theme.isDarkMode
                                        ? colors.primaryDark
                                        : colors.primaryLight
                                    : colors.colorGrey,
                                theme: theme.isDarkMode,
                                fw: currentSortType == "nav" ? 2 : null),
                          ),
                        ],
                      ),
                    ),
                    const ListDivider(),
                  ],
                ),
              ),

              // Unit Filter
              InkWell(
                onTap: () => _applySortForType("unit"),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Icon(
                            unitIsAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                            color: currentSortType == "unit"
                                ? theme.isDarkMode
                                    ? colors.primaryDark
                                    : colors.primaryLight
                                : colors.colorGrey,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            "Unit",
                            style: TextWidget.textStyle(
                                fontSize: 14,
                                color: currentSortType == "unit"
                                    ? theme.isDarkMode
                                        ? colors.primaryDark
                                        : colors.primaryLight
                                    : colors.colorGrey,
                                theme: theme.isDarkMode,
                                fw: currentSortType == "unit" ? 2 : null),
                          ),
                        ],
                      ),
                    ),
                    const ListDivider(),
                  ],
                ),
              ),

              // Return Percentage Change Filter
              InkWell(
                onTap: () => _applySortForType("returnPercChange"),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Icon(
                            returnPercChangeIsAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                            color: currentSortType == "returnPercChange"
                                ? theme.isDarkMode
                                    ? colors.primaryDark
                                    : colors.primaryLight
                                : colors.colorGrey,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            "Return % Change",
                            style: TextWidget.textStyle(
                                fontSize: 14,
                                color: currentSortType == "returnPercChange"
                                    ? theme.isDarkMode
                                        ? colors.primaryDark
                                        : colors.primaryLight
                                    : colors.colorGrey,
                                theme: theme.isDarkMode,
                                fw: currentSortType == "returnPercChange" ? 2 : null),
                          ),
                        ],
                      ),
                    ),
                    const ListDivider(),
                  ],
                ),
              ),

              // Invested Price Filter
              InkWell(
                onTap: () => _applySortForType("investedPrice"),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Icon(
                            investedPriceIsAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                            color: currentSortType == "investedPrice"
                                ? theme.isDarkMode
                                    ? colors.primaryDark
                                    : colors.primaryLight
                                : colors.colorGrey,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            "Invested Price",
                            style: TextWidget.textStyle(
                                fontSize: 14,
                                color: currentSortType == "investedPrice"
                                    ? theme.isDarkMode
                                        ? colors.primaryDark
                                        : colors.primaryLight
                                    : colors.colorGrey,
                                theme: theme.isDarkMode,
                                fw: currentSortType == "investedPrice" ? 2 : null),
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
    });
  }
}
