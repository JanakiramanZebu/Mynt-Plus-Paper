import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../res/res.dart';
import '../../locator/preference.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/list_divider.dart';

class OrderbookFilterBottomSheet extends ConsumerStatefulWidget {
  const OrderbookFilterBottomSheet({super.key});

  @override
  ConsumerState<OrderbookFilterBottomSheet> createState() =>
      _OrderbookFilterBottomSheetState();
}

class _OrderbookFilterBottomSheetState
    extends ConsumerState<OrderbookFilterBottomSheet> {
  Preferences pref = Preferences();
  bool scripisAscending = true;
  bool pricepisAscending = true;
  bool qtyisAscending = true;
  bool productisAscending = true;
  bool timeisAscending = true;
  String currentSortType = ""; // Track current sort type

  @override
  void initState() {
    super.initState();
    _initCurrentSort();
  }

  void _initCurrentSort() {
    try {
      // Get the current sort from provider
      final lastOrderSortMethod = ref.read(orderProvider).lastOrderSortMethod;

      // Reset all sort states to default when no sorting is active
      if (lastOrderSortMethod.isEmpty) {
        currentSortType = "";
        scripisAscending = pref.isObScripname ?? true;
        pricepisAscending = pref.isObPrice ?? true;
        qtyisAscending = pref.isObqty ?? true;
        productisAscending = pref.isObProduct ?? true;
        timeisAscending = pref.isObtime ?? true;
        return;
      }

      // Determine current sort type and direction based on the sort option
      if (lastOrderSortMethod == "ASC" || lastOrderSortMethod == "DSC") {
        currentSortType = "scrip";
        scripisAscending = lastOrderSortMethod == "ASC";
      } else if (lastOrderSortMethod == "LTPASC" || lastOrderSortMethod == "LTPDSC") {
        currentSortType = "price";
        pricepisAscending = lastOrderSortMethod == "LTPASC";
      } else if (lastOrderSortMethod == "QTYASC" || lastOrderSortMethod == "QTYDSC") {
        currentSortType = "qty";
        qtyisAscending = lastOrderSortMethod == "QTYASC";
      } else if (lastOrderSortMethod == "PRODUCTASC" || lastOrderSortMethod == "PRODUCTDSC") {
        currentSortType = "product";
        productisAscending = lastOrderSortMethod == "PRODUCTASC";
      } else if (lastOrderSortMethod == "TIMEASC" || lastOrderSortMethod == "TIMEDSC") {
        currentSortType = "time";
        timeisAscending = lastOrderSortMethod == "TIMEASC";
      }
    } catch (e) {
      print("Error initializing sort state: $e");
      // Fallback to default values
      currentSortType = "";
      scripisAscending = pref.isObScripname ?? true;
      pricepisAscending = pref.isObPrice ?? true;
      qtyisAscending = pref.isObqty ?? true;
      productisAscending = pref.isObProduct ?? true;
      timeisAscending = pref.isObtime ?? true;
    }
  }

  // Apply sort directly and force UI update
  void _applySortForType(String type) {
    String sortingValue = "";

    // Debug current values
    print("Before sort - Current type: $currentSortType");
    print("Before sort - Sort state: Scrip: $scripisAscending, Price: $pricepisAscending, Qty: $qtyisAscending, Product: $productisAscending, Time: $timeisAscending");

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
        } else if (type == "product") {
          productisAscending = !productisAscending;
        } else if (type == "time") {
          timeisAscending = !timeisAscending;
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
      } else if (type == "product") {
        sortingValue = productisAscending ? "PRODUCTASC" : "PRODUCTDSC";
      } else if (type == "time") {
        sortingValue = timeisAscending ? "TIMEASC" : "TIMEDSC";
      }
    });

    // Debug the resulting sort value
    print("Applying sort value: $sortingValue");

    // Apply the sort directly
    ref.read(orderProvider).filterOrders(sorting: sortingValue);

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
                              ? colors.colorBlack
                              : colors.colorWhite,
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
              onTap: () => _applySortForType("product"),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Icon(
                          productisAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 20,
                          color: currentSortType == "product"
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
                          "Product",
                          style: TextWidget.textStyle(
                              fontSize: 14,
                              color: currentSortType == "product"
                                  ? theme.isDarkMode
                                      ? colors.primaryDark
                                      : colors.primaryLight
                                  : theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                              theme: theme.isDarkMode,
                              fw: currentSortType == "product" ? 2 : null),
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
              onTap: () => _applySortForType("time"),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Icon(
                          timeisAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 20,
                          color: currentSortType == "time"
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
                          "Time",
                          style: TextWidget.textStyle(
                              fontSize: 14,
                              color: currentSortType == "time"
                                  ? theme.isDarkMode
                                      ? colors.primaryDark
                                      : colors.primaryLight
                                  : theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                              theme: theme.isDarkMode,
                              fw: currentSortType == "time" ? 2 : null),
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
