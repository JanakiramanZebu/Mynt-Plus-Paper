import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../locator/preference.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/list_divider.dart';

class MFFilterBottomSheet extends StatefulWidget {
  const MFFilterBottomSheet({
    super.key,
  });

  @override
  State<MFFilterBottomSheet> createState() => _MFFilterBottomSheetState();
}

class _MFFilterBottomSheetState extends State<MFFilterBottomSheet> {
  Preferences pref = Preferences();
  late bool nameIsAscending;
  late bool navIsAscending;
  late bool unitIsAscending;
  late bool returnPercChangeIsAscending;
  late bool investedPriceIsAscending;

  @override
  void initState() {
    setState(() {
      nameIsAscending = pref.isMFName ?? true;
      navIsAscending = pref.isMFNav ?? true;
      unitIsAscending = pref.isMFUnit ?? true;
      returnPercChangeIsAscending = pref.isMFReturnPercChange ?? true;
      investedPriceIsAscending = pref.isMFInvestedPrice ?? true;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.read(themeProvider);
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
                        text: "Sort by", theme: theme.isDarkMode, fw: 1),
                  ],
                ),
              ),
              Divider(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider),
              
              // Name Filter
              InkWell(
                onTap: () {
                  setState(() {
                    if (nameIsAscending == true) {
                      ref.read(mfProvider).filterMFHoldings(sorting: "NAMEASC", context: context);
                    } else if (nameIsAscending == false) {
                      ref.read(mfProvider).filterMFHoldings(sorting: "NAMEDSC", context: context);
                    }

                    nameIsAscending = !nameIsAscending;
                    pref.setMFName(nameIsAscending);
                    Navigator.pop(context);
                  });
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Icon(
                            pref.isMFName == true
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                            color: colors.colorGrey,
                          ),
                          const SizedBox(width: 15),
                          TextWidget.subText(
                              text: "Name",
                              theme: false,
                              color: colors.colorGrey,
                              fw: 0),
                        ],
                      ),
                    ),
                    const ListDivider(),
                  ],
                ),
              ),

              // NAV Filter
              InkWell(
                onTap: () {
                  setState(() {
                    if (navIsAscending == true) {
                      ref.read(mfProvider).filterMFHoldings(sorting: "NAVASC", context: context);
                    } else if (navIsAscending == false) {
                      ref.read(mfProvider).filterMFHoldings(sorting: "NAVDSC", context: context);
                    }

                    navIsAscending = !navIsAscending;
                    pref.setMFNav(navIsAscending);
                    Navigator.pop(context);
                  });
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Icon(
                            pref.isMFNav == true
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                            color: colors.colorGrey,
                          ),
                          const SizedBox(width: 15),
                          TextWidget.subText(
                              text: "NAV",
                              theme: false,
                              color: colors.colorGrey,
                              fw: 0),
                        ],
                      ),
                    ),
                    const ListDivider(),
                  ],
                ),
              ),

              // Unit Filter
              InkWell(
                onTap: () {
                  setState(() {
                    if (unitIsAscending == true) {
                      ref.read(mfProvider).filterMFHoldings(sorting: "UNITASC", context: context);
                    } else if (unitIsAscending == false) {
                      ref.read(mfProvider).filterMFHoldings(sorting: "UNITDSC", context: context);
                    }

                    unitIsAscending = !unitIsAscending;
                    pref.setMFUnit(unitIsAscending);
                    Navigator.pop(context);
                  });
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Icon(
                            pref.isMFUnit == true
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                            color: colors.colorGrey,
                          ),
                          const SizedBox(width: 15),
                          TextWidget.subText(
                              text: "Unit",
                              theme: false,
                              color: colors.colorGrey,
                              fw: 0),
                        ],
                      ),
                    ),
                    const ListDivider(),
                  ],
                ),
              ),

              // Return Percentage Change Filter
              InkWell(
                onTap: () {
                  setState(() {
                    if (returnPercChangeIsAscending == true) {
                      ref.read(mfProvider).filterMFHoldings(sorting: "RETURNPERCASC", context: context);
                    } else if (returnPercChangeIsAscending == false) {
                      ref.read(mfProvider).filterMFHoldings(sorting: "RETURNPERCDSC", context: context);
                    }

                    returnPercChangeIsAscending = !returnPercChangeIsAscending;
                    pref.setMFReturnPercChange(returnPercChangeIsAscending);
                    Navigator.pop(context);
                  });
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Icon(
                            pref.isMFReturnPercChange == true
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                            color: colors.colorGrey,
                          ),
                          const SizedBox(width: 15),
                          TextWidget.subText(
                              text: "Return % Change",
                              theme: false,
                              color: colors.colorGrey,
                              fw: 0),
                        ],
                      ),
                    ),
                    const ListDivider(),
                  ],
                ),
              ),

              // Invested Price Filter
              InkWell(
                onTap: () {
                  setState(() {
                    if (investedPriceIsAscending == true) {
                      ref.read(mfProvider).filterMFHoldings(sorting: "INVESTEDASC", context: context);
                    } else if (investedPriceIsAscending == false) {
                      ref.read(mfProvider).filterMFHoldings(sorting: "INVESTEDDSC", context: context);
                    }

                    investedPriceIsAscending = !investedPriceIsAscending;
                    pref.setMFInvestedPrice(investedPriceIsAscending);
                    Navigator.pop(context);
                  });
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Icon(
                            pref.isMFInvestedPrice == true
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                            color: colors.colorGrey,
                          ),
                          const SizedBox(width: 15),
                          TextWidget.subText(
                              text: "Invested Price",
                              theme: false,
                              color: colors.colorGrey,
                              fw: 0),
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