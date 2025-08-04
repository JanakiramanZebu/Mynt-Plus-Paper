import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/custom_drag_handler.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/desk_reports_model/calender_pnl_model.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_switch_btn.dart';
import '../../sharedWidget/custom_text_form_field.dart';
import '../../sharedWidget/snack_bar.dart';
import '../../sharedWidget/splash_loader.dart';
import '../../utils/no_emoji_inputformatter.dart';
import '../splash_screen.dart';
import 'bottom_sheets/sharing_screen.dart';

class CalenderpnlScreen extends ConsumerStatefulWidget {
  const CalenderpnlScreen({super.key});

  @override
  ConsumerState<CalenderpnlScreen> createState() => _CalenderpnlScreenState();
}

class _CalenderpnlScreenState extends ConsumerState<CalenderpnlScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.animation!.addListener(_onTabChanged);
    // Fetch data only if not loaded for this year/segment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ledgerprovider = ref.read(ledgerProvider);
      ledgerprovider.loadOrFetchCalendarPnlData(
        context,
        ledgerprovider.startDate,
        ledgerprovider.today,
        ledgerprovider.selectedSegment,
      );
    });
  }

  void _onTabChanged() {
    final newIndex = _tabController.animation!.value.round();
    if (activeTab != newIndex) {
      setState(() {
        activeTab = newIndex;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double netvalue = 0.0;
    return Consumer(
      builder: (context, WidgetRef ref, _) {
        final theme = ref.watch(themeProvider);
        final ledgerprovider = ref.watch(ledgerProvider);
        // Filter sortedDates to only include dates within the selected financial year
        final sortedDates = ledgerprovider.grouped.keys
            .where((date) =>
                !date.isBefore(ledgerprovider.startTaxDate) &&
                !date.isAfter(ledgerprovider.endTaxDate))
            .toList()
          ..sort((a, b) => b.compareTo(a));
        Future<void> _refresh() async {
          await Future.delayed(
              const Duration(seconds: 0)); // simulate refresh delay
          print("refresh ");
          // Always use the currently visible tab for refresh
          final currentTabIndex = _tabController.index;
          final currentSegment =
              ledgerprovider.availableSegments[currentTabIndex];
          ledgerprovider
              .setSegment(currentSegment); // ensure provider is in sync
          await ledgerprovider.getCurrentDate('else');
          ledgerprovider.calendarProvider();
          ledgerprovider.fetchsharingdata(
            ledgerprovider.startDate,
            ledgerprovider.today,
            currentSegment,
            context,
          );
          await ledgerprovider.loadOrFetchCalendarPnlData(
            context,
            ledgerprovider.startDate,
            ledgerprovider.today,
            currentSegment,
            force: true,
          );
        }

        if (ledgerprovider.calenderpnlAllData != null) {
          netvalue = (ledgerprovider.calenderpnlAllData?.realized ?? 0.0) -
              (ledgerprovider.calenderpnlAllData!.totalCharges ?? 0.0);
        }
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              ledgerprovider.falseloader('calpnl');
              ledgerprovider.setSegment("Equity");

              ledgerprovider.showProfiossSearch(false);
            }
          },
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              appBar: AppBar(
                leadingWidth: 41,
                titleSpacing: 6,
                centerTitle: false,
                leading: InkWell(
                    onTap: () {
                      ledgerprovider.falseloader('calpnl');
                      ledgerprovider.setSegment("Equity");
                      ledgerprovider.setFinancialYear("");
                      ledgerprovider.showProfiossSearch(false);
                      Navigator.pop(context);
                    },
                    child: const CustomBackBtn()),
                elevation: 0.2,
                title: TextWidget.titleText(
                    text: "P&L Summary",
                    textOverflow: TextOverflow.ellipsis,
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 1),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TabBar(
                        tabAlignment: TabAlignment.start,
                        indicatorSize: TabBarIndicatorSize.tab,
                        isScrollable: true,
                        indicatorColor: theme.isDarkMode
                            ? colors.secondaryDark
                            : colors.secondaryLight,
                        unselectedLabelColor: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        unselectedLabelStyle: TextWidget.textStyle(
                          fontSize: 14,
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 3,
                        ),
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        indicatorPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        labelColor: theme.isDarkMode
                            ? colors.secondaryDark
                            : colors.secondaryLight,
                        labelStyle: TextWidget.textStyle(
                            fontSize: 14,
                            theme: false,
                            color: theme.isDarkMode
                                ? colors.secondaryDark
                                : colors.secondaryLight,
                            fw: 0),
                        tabs: ledgerprovider.availableSegments
                            .map((e) => Tab(text: e))
                            .toList(),
                        controller: _tabController,
                        onTap: (index) {
                          final selectedSegment =
                              ledgerprovider.availableSegments[index];
                          ledgerprovider.setSegment(selectedSegment);
                          // Check if data is cached for this segment and year
                          final cacheKey = ledgerprovider.calendarPnlCacheKey(
                            ledgerprovider.selectedFinancialYear,
                            selectedSegment,
                          );
                          if (!ledgerprovider.calendarPnlCache
                                  .containsKey(cacheKey) ||
                              ledgerprovider.calendarPnlCache[cacheKey] ==
                                  null) {
                            // Show loader and fetch data
                            ledgerprovider.loadOrFetchCalendarPnlData(
                              context,
                              ledgerprovider.formattedStartDate,
                              ledgerprovider.formattedendDate,
                              selectedSegment,
                              force: true,
                            );
                          } else {
                            // Use cached data
                            ledgerprovider.loadOrFetchCalendarPnlData(
                              context,
                              ledgerprovider.formattedStartDate,
                              ledgerprovider.formattedendDate,
                              selectedSegment,
                              force: false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              body: (ledgerprovider.calendarpnlloading ||
                      ledgerprovider.calenderpnlAllData == null ||
                      (ledgerprovider.selectedSegment == 'FNO' &&
                          ledgerprovider.calenderpnlAllData?.segment != 'FNO'))
                  ? Center(
                      child: Container(
                        color: Colors.white,
                        child: CircularLoaderImage(),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        TextWidget.subText(
                                            text: ledgerprovider
                                                .selectedFinancialYear,
                                            color: theme.isDarkMode
                                                ? colors.textSecondaryDark
                                                : colors.textSecondaryLight,
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            fw: 3),
                                        const SizedBox(height: 4),
                                        TextWidget.subText(
                                            text: "Realised P&L",
                                            color: theme.isDarkMode
                                                ? colors.textSecondaryDark
                                                : colors.textSecondaryLight,
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            fw: 3),
                                        const SizedBox(height: 4),
                                        TextWidget.headText(
                                            text:
                                                "${ledgerprovider.calenderpnlAllData != null ? ledgerprovider.calenderpnlAllData!.realized.toStringAsFixed(2) : 0.0} ",
                                            color: ledgerprovider
                                                        .calenderpnlAllData !=
                                                    null
                                                ? ledgerprovider
                                                            .calenderpnlAllData!
                                                            .realized !=
                                                        0
                                                    ? ledgerprovider
                                                                .calenderpnlAllData!
                                                                .realized <
                                                            0
                                                        ? theme.isDarkMode
                                                            ? colors.lossDark
                                                            : colors.lossLight
                                                        : theme.isDarkMode
                                                            ? colors.profitDark
                                                            : colors.profitLight
                                                    : theme.isDarkMode
                                                        ? colors
                                                            .textSecondaryDark
                                                        : colors
                                                            .textSecondaryLight
                                                : theme.isDarkMode
                                                    ? colors.textSecondaryDark
                                                    : colors.textSecondaryLight,
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            fw: 0),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          ledgerprovider.calenderpnlAllData == null
                              ? const Center(
                                  child: Padding(
                                  padding: EdgeInsets.only(top: 60),
                                  child: NoDataFound(),
                                ))
                              : Expanded(
                                  child: SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CalendarTabs(
                                            theme: theme,
                                            heatmapData:
                                                ledgerprovider.heatmapData,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Divider(
                                              color: theme.isDarkMode
                                                  ? colors.dividerDark
                                                  : colors.dividerLight,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child:
                                                  !ledgerprovider
                                                          .showProfitlossSearch
                                                      ? SizedBox(
                                                          height: 40,
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        5),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: colors
                                                                  .searchBg,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                // Padding(
                                                                //   padding:
                                                                //       const EdgeInsets
                                                                //           .only(
                                                                //           right:
                                                                //               10),
                                                                //   child: Row(
                                                                //     children: [
                                                                //       Material(
                                                                //         color: Colors
                                                                //             .transparent,
                                                                //         shape:
                                                                //             const CircleBorder(),
                                                                //         clipBehavior:
                                                                //             Clip.hardEdge,
                                                                //         child:
                                                                //             InkWell(
                                                                //           customBorder:
                                                                //               const CircleBorder(),
                                                                //           splashColor: theme.isDarkMode
                                                                //               ? colors.splashColorDark
                                                                //               : colors.splashColorLight,
                                                                //           highlightColor: theme.isDarkMode
                                                                //               ? colors.highlightDark
                                                                //               : colors.highlightLight,
                                                                //           onTap:
                                                                //               () {
                                                                //             Future.delayed(const Duration(milliseconds: 150),
                                                                //                 () {
                                                                //               ledgerprovider.showProfiossSearch(true);
                                                                //             });
                                                                //           },
                                                                //           child:
                                                                //               Padding(
                                                                //             padding:
                                                                //                 const EdgeInsets.all(8.0),
                                                                //             child:
                                                                //                 SvgPicture.asset(
                                                                //               assets.searchIcon,
                                                                //               color: colors.textPrimaryLight,
                                                                //               width: 18,
                                                                //             ),
                                                                //           ),
                                                                //         ),
                                                                //       ),
                                                                //     ],
                                                                //   ),
                                                                // ),
                                                                Material(
                                                                  color: Colors
                                                                      .transparent,
                                                                  shape:
                                                                      const RoundedRectangleBorder(),
                                                                  child:
                                                                      InkWell(
                                                                    customBorder:
                                                                        const RoundedRectangleBorder(),
                                                                    splashColor: theme.isDarkMode
                                                                        ? colors
                                                                            .splashColorDark
                                                                        : colors
                                                                            .splashColorLight,
                                                                    highlightColor: theme.isDarkMode
                                                                        ? colors
                                                                            .highlightDark
                                                                        : colors
                                                                            .highlightLight,
                                                                    onTap: () {
                                                                      _showBottomSheetcharges(
                                                                          context,
                                                                          theme,
                                                                          ledgerprovider);
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              8.0,
                                                                          vertical:
                                                                              5),
                                                                      child: TextWidget
                                                                          .subText(
                                                                        text:
                                                                            "Charges",
                                                                        color: theme.isDarkMode
                                                                            ? colors.primaryDark
                                                                            : colors.primaryLight,
                                                                        textOverflow:
                                                                            TextOverflow.ellipsis,
                                                                        theme: theme
                                                                            .isDarkMode,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          height: 40,
                                                          child: TextFormField(
                                                            autofocus: true,
                                                            controller:
                                                                ledgerprovider
                                                                    .profitlossSearchCtrl,
                                                            style: TextWidget
                                                                .textStyle(
                                                              fontSize: 14,
                                                              theme: theme
                                                                  .isDarkMode,
                                                              fw: 1,
                                                            ),
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            textCapitalization:
                                                                TextCapitalization
                                                                    .characters,
                                                            inputFormatters: [
                                                              UpperCaseTextFormatter(),
                                                              NoEmojiInputFormatter(),
                                                              FilteringTextInputFormatter
                                                                  .deny(RegExp(
                                                                      '[π£•₹€℅™∆√¶/.,]'))
                                                            ],
                                                            decoration:
                                                                InputDecoration(
                                                                    hintText:
                                                                        "Search",
                                                                    hintStyle: TextWidget.textStyle(
                                                                        fontSize:
                                                                            14,
                                                                        theme: theme
                                                                            .isDarkMode,
                                                                        fw: 0,
                                                                        color: colors
                                                                            .textSecondaryLight),
                                                                    fillColor: colors
                                                                        .searchBg,
                                                                    filled:
                                                                        true,
                                                                    prefixIcon:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: SvgPicture.asset(
                                                                          assets
                                                                              .searchIcon,
                                                                          color: colors
                                                                              .textPrimaryLight,
                                                                          fit: BoxFit
                                                                              .scaleDown,
                                                                          width:
                                                                              20),
                                                                    ),
                                                                    suffixIcon:
                                                                        Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      shape:
                                                                          const CircleBorder(),
                                                                      clipBehavior:
                                                                          Clip.hardEdge,
                                                                      child:
                                                                          InkWell(
                                                                        customBorder:
                                                                            const CircleBorder(),
                                                                        splashColor: theme.isDarkMode
                                                                            ? colors.splashColorDark
                                                                            : colors.splashColorLight,
                                                                        highlightColor: theme.isDarkMode
                                                                            ? colors.highlightDark
                                                                            : colors.highlightLight,
                                                                        onTap:
                                                                            () async {
                                                                          Future.delayed(
                                                                              const Duration(milliseconds: 150),
                                                                              () {
                                                                            ledgerprovider.clearProfitlossSearch();
                                                                            ledgerprovider.showProfiossSearch(false);
                                                                          });
                                                                        },
                                                                        child: SvgPicture.asset(
                                                                            assets
                                                                                .removeIcon,
                                                                            fit:
                                                                                BoxFit.scaleDown,
                                                                            width: 20),
                                                                      ),
                                                                    ),
                                                                    enabledBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide
                                                                            .none,
                                                                        borderRadius: BorderRadius.circular(
                                                                            20)),
                                                                    disabledBorder:
                                                                        InputBorder
                                                                            .none,
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide
                                                                            .none,
                                                                        borderRadius: BorderRadius.circular(
                                                                            20)),
                                                                    contentPadding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            5,
                                                                        vertical:
                                                                            5),
                                                                    border: OutlineInputBorder(
                                                                        borderSide: BorderSide
                                                                            .none,
                                                                        borderRadius:
                                                                            BorderRadius.circular(20))),
                                                            onChanged: (value) {
                                                              if (value
                                                                  .isNotEmpty) {
                                                                // positionBook.showPositionSearch(false);
                                                              } else {
                                                                // positionBook.showPositionSearch(false);
                                                              }

                                                              ledgerprovider
                                                                  .profitlossSearch(
                                                                      value,
                                                                      context);
                                                            },
                                                          ),
                                                        ),
                                            ),
                                            Divider(
                                              color: theme.isDarkMode
                                                  ? colors.dividerDark
                                                  : colors.dividerLight,
                                            ),
                                            sortedDates.isEmpty
                                                ? Center(
                                                    child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 30),
                                                    child: Column(
                                                      children: [
                                                        const NoDataFound(),
                                                        if (ledgerprovider
                                                            .profitlossSearchCtrl
                                                            .text
                                                            .isNotEmpty)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 16),
                                                            child: TextWidget
                                                                .subText(
                                                              text:
                                                                  "No results found for '${ledgerprovider.profitlossSearchCtrl.text}'",
                                                              color: theme.isDarkMode
                                                                  ? colors
                                                                      .textSecondaryDark
                                                                  : colors
                                                                      .textSecondaryLight,
                                                              textOverflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              theme: theme
                                                                  .isDarkMode,
                                                              fw: 0,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ))
                                                : ListView.separated(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        sortedDates.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final dateKey =
                                                          sortedDates[index];
                                                      final tradesForDate =
                                                          ledgerprovider
                                                                  .grouped[
                                                              dateKey]!;
                                                      // Calculate total realized PnL for this date
                                                      final totalRealisedPnl =
                                                          tradesForDate.fold<
                                                                  double>(
                                                              0.0,
                                                              (sum, item) =>
                                                                  sum +
                                                                  double.parse(item
                                                                      .realisedpnl!));

                                                      // Format the date (e.g. "03 Oct 2024")
                                                      final dateString =
                                                          '${dateKey.day.toString().padLeft(2, '0')} '
                                                          '${_monthName(dateKey.month)} '
                                                          '${dateKey.year}';

                                                      return Theme(
                                                          data: Theme.of(
                                                                  context)
                                                              .copyWith(
                                                                  dividerColor:
                                                                      Colors
                                                                          .transparent),
                                                          child: InkWell(
                                                              onTap: () {
                                                                _showBottomSheet(
                                                                    context,
                                                                    tradesForDate,
                                                                    theme,
                                                                    dateString,
                                                                    screenWidth);
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        16.0,
                                                                    horizontal:
                                                                        16.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    SizedBox(
                                                                      width:
                                                                          screenWidth *
                                                                              0.5,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          TextWidget.subText(
                                                                              text: "${dateString}  ",
                                                                              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                                              textOverflow: TextOverflow.ellipsis,
                                                                              theme: theme.isDarkMode,
                                                                              fw: 0),
                                                                          Container(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: colors.btnBg,
                                                                              borderRadius: BorderRadius.circular(2),
                                                                            ),
                                                                            child:
                                                                                TextWidget.subText(
                                                                              text: "${tradesForDate.length}",
                                                                              textOverflow: TextOverflow.ellipsis,
                                                                              theme: theme.isDarkMode,
                                                                              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                                              fw: 0,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    TextWidget.subText(
                                                                        text: "${(totalRealisedPnl).toStringAsFixed(2)} ",
                                                                        color: totalRealisedPnl != 0
                                                                            ? totalRealisedPnl > 0
                                                                                ? theme.isDarkMode
                                                                                    ? colors.profitDark
                                                                                    : colors.profitLight
                                                                                : totalRealisedPnl < 0
                                                                                    ? theme.isDarkMode
                                                                                        ? colors.lossDark
                                                                                        : colors.lossLight
                                                                                    : theme.isDarkMode
                                                                                        ? colors.textSecondaryDark
                                                                                        : colors.textSecondaryLight
                                                                            : theme.isDarkMode
                                                                                ? colors.textPrimaryDark
                                                                                : colors.textPrimaryLight,
                                                                        textOverflow: TextOverflow.ellipsis,
                                                                        theme: theme.isDarkMode,
                                                                        fw: 0),
                                                                  ],
                                                                ),
                                                              )));
                                                    },
                                                    separatorBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return Divider(
                                                        color: theme.isDarkMode
                                                            ? colors.dividerDark
                                                            : colors
                                                                .dividerLight,
                                                      );
                                                    },
                                                  )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to build the UI for a single trade
  Widget _buildTradeItem(TradeData trade, ThemesProvider theme) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: screenWidth *
                    0.65, // Ensures text takes the available width
                child: InkWell(
                  onTap: () async {
                    // Handle the onTap event here
                  },
                  child: Text(
                    "${trade.sCRIPSYMBOL}",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        13,
                        FontWeight.w600),
                    softWrap: true, // Allows text to wrap
                    overflow: TextOverflow
                        .ellipsis, // Adds "..." if the text is too long
                    maxLines: 2, // Limits text to 2 lines, change as needed
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Divider(
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextWidget.subText(
                      text: "Net Qty :  ",
                      color: const Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${double.tryParse(trade.updatedNETQTY!)!.toInt()}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextWidget.subText(
                      text: "Buy Qty :  ",
                      color: const Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${trade.totalBuyQty}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
              Row(
                children: [
                  TextWidget.subText(
                      text: "Sell Qty :  ",
                      color: const Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${trade.totalSellQty}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextWidget.subText(
                      text: "Buy Rate :  ",
                      color: const Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${trade.totalBuyRate}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
              Row(
                children: [
                  TextWidget.subText(
                      text: "Sell Rate :  ",
                      color: const Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${trade.totalSellRate}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextWidget.subText(
                      text: "Buy Amount :  ",
                      color: const Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${trade.bAMT}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
              Row(
                children: [
                  TextWidget.subText(
                      text: "Sell Amount :  ",
                      color: const Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${trade.sAMT}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextWidget.subText(
                      text: "Realised :  ",
                      color: const Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${trade.realisedpnl}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
              Row(
                children: [
                  TextWidget.subText(
                      text: "Unrealised :  ",
                      color: const Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${trade.unrealisedpnl}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper widget for key-value text
  Widget _keyValueText(String key, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(key, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }

  void _showBottomSheetSharing(BuildContext context, Widget bottomSheet) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        useSafeArea: true,
        isDismissible: true,
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: bottomSheet));
  }

  void _showBottomSheetcharges(
      BuildContext context, ThemesProvider theme, LDProvider ledgerprovider) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.2,
          minChildSize: 0.2,
          maxChildSize: 0.4,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomDragHandler(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget.titleText(
                        text: "Charges and Taxes",
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        theme: theme.isDarkMode,
                        fw: 0,
                      ),
                      TextWidget.titleText(
                        text: ledgerprovider.calenderpnlAllData != null
                            ? ledgerprovider.calenderpnlAllData!.totalCharges !=
                                    null
                                ? ledgerprovider
                                    .calenderpnlAllData!.totalCharges!
                                    .toStringAsFixed(2)
                                : '0.0'
                            : '0.0',
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        theme: theme.isDarkMode,
                        fw: 0,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  _showBottomSheet(BuildContext context, trade, ThemesProvider theme,
      String date, double widthval) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: .4,
          maxChildSize: 0.88,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color:
                      theme.isDarkMode ? colors.colorBlack : colors.colorWhite),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  const CustomDragHandler(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextWidget.titleText(
                        text: "Trades in ${date}",
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fw: 0),
                  ),
                  Divider(
                    color: theme.isDarkMode
                        ? colors.dividerDark
                        : colors.dividerLight,
                  ),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: trade.length,
                      itemBuilder: (context, index) {
                        String symbol = trade[index].sCRIPSYMBOL ?? '';
                        String cleanedSymbol =
                            symbol.replaceFirst(RegExp(r'^\d+\s+'), '');

                        return Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: widthval *
                                              0.80, // Ensures text takes the available width
                                          child: InkWell(
                                            onTap: () async {
                                              // Handle the onTap event here
                                            },
                                            child: TextWidget.subText(
                                              text: cleanedSymbol,
                                              color: theme.isDarkMode
                                                  ? colors.textPrimaryDark
                                                  : colors.textPrimaryLight,
                                              theme: theme.isDarkMode,
                                              fw: 0,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              softWrap: true,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  trade[index].oQTY != "0" &&
                                          trade[index].oRATE != "0"
                                      ? _buildInfoRow(
                                          "Open Qty / Price",
                                          "${double.tryParse(trade[index].oQTY)!.toInt()} / ${double.tryParse(trade[index].oRATE)!.toStringAsFixed(2)}",
                                          theme)
                                      : const SizedBox.shrink(),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                      "Buy Qty / Price",
                                      "${double.tryParse(trade[index].bQTY)!.toInt()} / ${double.tryParse(trade[index].bRATE)!.toStringAsFixed(2)}",
                                      theme),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                      "Sell Qty / Price",
                                      "${double.tryParse(trade[index].sQTY)!.toInt()} / ${double.tryParse(trade[index].sRATE)!.toStringAsFixed(2)}",
                                      theme),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                      "Net Qty",
                                      "${double.tryParse(trade[index].updatedNETQTY)!.toInt()}",
                                      theme),
                                  const SizedBox(height: 8),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextWidget.subText(
                                                text: "Realised",
                                                theme: false,
                                                color: theme.isDarkMode
                                                    ? colors.textSecondaryDark
                                                    : colors.textSecondaryLight,
                                                fw: 3),
                                            TextWidget.subText(
                                                text:
                                                    "${double.parse(trade[index].realisedpnl).toStringAsFixed(2)}",
                                                theme: false,
                                                color: double.parse(trade[index]
                                                                .realisedpnl)
                                                            .toStringAsFixed(
                                                                2) !=
                                                        0
                                                    ? double.parse(trade[index]
                                                                .realisedpnl) >
                                                            0
                                                        ? theme.isDarkMode
                                                            ? colors.profitDark
                                                            : colors.profitLight
                                                        : double.parse(trade[
                                                                        index]
                                                                    .realisedpnl) <
                                                                0
                                                            ? theme.isDarkMode
                                                                ? colors
                                                                    .lossDark
                                                                : colors
                                                                    .lossLight
                                                            : theme.isDarkMode
                                                                ? colors
                                                                    .textSecondaryDark
                                                                : colors
                                                                    .textSecondaryLight
                                                    : theme.isDarkMode
                                                        ? colors.textPrimaryDark
                                                        : colors
                                                            .textPrimaryLight,
                                                fw: 3),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Divider(
                                            color: theme.isDarkMode
                                                ? colors.dividerDark
                                                : colors.dividerLight,
                                            thickness: 0)
                                      ]),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Divider(
                                      color: theme.isDarkMode
                                          ? colors.dividerDark
                                          : colors.dividerLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                          color: theme.isDarkMode
                              ? colors.dividerDark
                              : colors.dividerLight,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Convert month integer to month name
  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

class CalendarTabs extends StatefulWidget {
  final dynamic theme; // Passed from your UI (e.g., watch(themeProvider))
  final Map<DateTime, double> heatmapData; // Data from ledgerprovider

  const CalendarTabs({
    super.key,
    required this.theme,
    required this.heatmapData,
  });

  @override
  State<CalendarTabs> createState() => _CalendarTabsState();
}

class _CalendarTabsState extends State<CalendarTabs> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Consumer(
      builder: (context, WidgetRef ref, _) {
        final ledgerprovider = ref.watch(ledgerProvider);
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          elevation: 0,
          color:
              widget.theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          child: Container(
            width: screenWidth * 0.9, // Adjust as needed

            child: Column(
              children: [
                // Top row: Monthly/Daily tabs + Financial year dropdown
                // Row(
                //   // crossAxisAlignment: CrossAxisAlignment.center,
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     // Monthly tab
                //     GestureDetector(
                //       onTap: () => ledgerprovider.setTab(true),
                //       child: Column(
                //         children: [
                //           Text(
                //             "Monthly",
                //             style: textStyle(
                //               widget.theme.isDarkMode
                //                   ? Colors.white
                //                   : Colors.black,
                //               14,
                //               FontWeight.w600,
                //             ),
                //           ),
                //           if (ledgerprovider.isMonthly)
                //             Container(
                //               margin: const EdgeInsets.only(top: 2),
                //               height: 2,
                //               width: 60,
                //               color: widget.theme.isDarkMode
                //                   ? Colors.white
                //                   : Colors.black,
                //             ),
                //         ],
                //       ),
                //     ),
                //     // Daily tab
                //     GestureDetector(
                //       onTap: () => ledgerprovider.setTab(false),
                //       child: Column(
                //         children: [
                //           Text(
                //             "Daily",
                //             style: textStyle(
                //               widget.theme.isDarkMode
                //                   ? Colors.white
                //                   : Colors.black,
                //               14,
                //               FontWeight.w600,
                //             ),
                //           ),
                //           if (!ledgerprovider.isMonthly)
                //             Container(
                //               margin: const EdgeInsets.only(top: 2),
                //               height: 2,
                //               width: 60,
                //               color: widget.theme.isDarkMode
                //                   ? Colors.white
                //                   : Colors.black,
                //             ),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 8),
                // Content: Either Monthly grid or Daily calendar
                if (ledgerprovider.isMonthly)
                  _MonthlyGrid(
                    theme: widget.theme,
                    monthlyPnL: ledgerprovider.monthlyPnL,
                    onMonthSelected: (DateTime selectedMonth) {
                      ledgerprovider.setSelectedMonth(selectedMonth);
                      ledgerprovider.setTab(false);
                    },
                    startFY: ledgerprovider.startTaxDate,
                    endFY: ledgerprovider.endTaxDate,
                  )
                else
                  _DailyCalendar(
                    key: ValueKey(
                        ledgerprovider.selectedMonth.toIso8601String()),
                    theme: widget.theme,
                    heatmapData: widget.heatmapData,
                    startDate: ledgerprovider.startTaxDate,
                    endDate: ledgerprovider.endTaxDate,
                    currentMonth: ledgerprovider.selectedMonth,
                    onMonthChanged: (DateTime newMonth) {
                      ledgerprovider.setSelectedMonth(newMonth);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// UI-only MonthlyGrid widget that always shows 12 months (Apr–Mar) in a 4×3 grid.
class _MonthlyGrid extends StatelessWidget {
  final dynamic theme;
  final Map<String, double> monthlyPnL;
  final ValueChanged<DateTime> onMonthSelected;
  final DateTime startFY;
  final DateTime endFY;

  const _MonthlyGrid({
    required this.theme,
    required this.monthlyPnL,
    required this.onMonthSelected,
    required this.startFY,
    required this.endFY,
  });

  @override
  Widget build(BuildContext context) {
    // Generate 12 months from startFY to endFY (guaranteed)
    final months = <DateTime>[];
    DateTime current = DateTime(startFY.year, startFY.month, 1);
    while (!current.isAfter(endFY)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1, 1);
    }
    // Chunk into 4 columns (4 items per row)
    final rows = <List<DateTime>>[];
    for (int i = 0; i < months.length; i += 4) {
      final endIndex = (i + 4 > months.length) ? months.length : (i + 4);
      rows.add(months.sublist(i, endIndex));
    }
    return Column(
      children: [
        for (final row in rows)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final monthDate in row) _buildMonthBox(context, monthDate),
            ],
          ),
      ],
    );
  }

  Widget _buildMonthBox(BuildContext context, DateTime monthDate) {
    double screenWidth = MediaQuery.of(context).size.width;
    final key =
        "${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}";
    final double? monthValue = monthlyPnL[key];
    final numval = (monthValue == null || monthValue == 0)
        ? "-"
        : monthValue.toStringAsFixed(2);
    var displayText = numval != "-"
        ? NumberFormat.compactCurrency(
            decimalDigits: 2,
            locale: 'en_IN',
            symbol: '',
          ).format(double.parse(numval))
        : '-';
    if (displayText.contains("T")) {
      displayText = displayText.replaceAll("T", "K");
    }
    final monthAbbrs = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    final monthName = monthAbbrs[monthDate.month - 1];
    Color bgColor;
    if (monthValue == null) {
      bgColor = theme.isDarkMode
          ? colors.textSecondaryDark
          : colors.textSecondaryLight;
    } else {
      bgColor = (monthValue < 0) ? colors.lossLight : colors.profitLight;
    }
    return Container(
      margin: const EdgeInsets.all(6),
      width: screenWidth * 0.19,
      height: screenWidth * 0.19,
      decoration: BoxDecoration(
        color: colors.btnBg.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextWidget.subText(
            text: monthName,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
            fw: 3,
          ),
          const SizedBox(height: 6),
          TextWidget.subText(
            text: displayText,
            color: bgColor,
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
            fw: 0,
          ),
        ],
      ),
    );
  }
}

Widget _buildInfoRow(String title1, String value1, ThemesProvider theme) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget.subText(
            text: title1,
            theme: false,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            fw: 3),
        TextWidget.subText(
            text: value1,
            theme: false,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 3),
      ],
    ),
    const SizedBox(height: 8),
    Divider(
        color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        thickness: 0)
  ]);
}

/// UI-only DailyCalendar widget.
class _DailyCalendar extends StatefulWidget {
  final dynamic theme;
  final Map<DateTime, double> heatmapData;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime currentMonth;
  final ValueChanged<DateTime> onMonthChanged;

  const _DailyCalendar({
    required this.theme,
    required this.heatmapData,
    required this.startDate,
    required this.endDate,
    required this.currentMonth,
    required this.onMonthChanged,
    required ValueKey<String> key,
  });

  @override
  State<_DailyCalendar> createState() => _DailyCalendarState();
}

class _DailyCalendarState extends State<_DailyCalendar> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = widget.currentMonth;
  }

  @override
  void didUpdateWidget(covariant _DailyCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth != widget.currentMonth) {
      setState(() {
        _month = widget.currentMonth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysToDisplay = _buildMonthDays(_month);
    final weeks = _chunkDays(daysToDisplay, 7);
    return Column(
      children: [
        // Month title with left/right arrows
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _goToPreviousMonth,
              ),
              Text(
                _formatMonthYear(_month),
                style: textStyle(
                    widget.theme.isDarkMode ? Colors.white : Colors.black,
                    16,
                    FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _goToNextMonth,
              ),
            ],
          ),
        ),
        // Day headers (Mon–Sun)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Mon",
                  style: textStyle(
                      widget.theme.isDarkMode ? Colors.white : Colors.black,
                      12,
                      FontWeight.w700)),
              Text("Tue",
                  style: textStyle(
                      widget.theme.isDarkMode ? Colors.white : Colors.black,
                      12,
                      FontWeight.w700)),
              Text("Wed",
                  style: textStyle(
                      widget.theme.isDarkMode ? Colors.white : Colors.black,
                      12,
                      FontWeight.w700)),
              Text("Thu",
                  style: textStyle(
                      widget.theme.isDarkMode ? Colors.white : Colors.black,
                      12,
                      FontWeight.w700)),
              Text("Fri",
                  style: textStyle(
                      widget.theme.isDarkMode ? Colors.white : Colors.black,
                      12,
                      FontWeight.w700)),
              Text("Sat",
                  style: textStyle(
                      widget.theme.isDarkMode ? Colors.white : Colors.black,
                      12,
                      FontWeight.w700)),
              Text("Sun",
                  style: textStyle(
                      widget.theme.isDarkMode ? Colors.white : Colors.black,
                      12,
                      FontWeight.w700)),
            ],
          ),
        ),
        // Calendar grid: rows of 7 days
        for (final week in weeks)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final day in week) _buildDayBox(context, day),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDayBox(BuildContext context, DateTime date) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (date.isBefore(widget.startDate) ||
        date.isAfter(widget.endDate) ||
        date.year < 1900) {
      return Container(
        width: screenWidth * 0.09,
        height: screenWidth * 0.09,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: widget.theme.isDarkMode
              ? const Color(0xff3A3A3A)
              : const Color(0xffF1F3F8),
          borderRadius: BorderRadius.circular(8.0),
        ),
      );
    }
    final double? value =
        widget.heatmapData[DateTime(date.year, date.month, date.day)];

    Color bgColor;
    if (value == null) {
      bgColor = widget.theme.isDarkMode
          ? const Color(0xff3A3A3A)
          : const Color(0xffF1F3F8);
    } else {
      bgColor = (value < 0)
          ? Colors.red.withOpacity(0.2)
          : Colors.green.withOpacity(0.2);
    }
    final displayTextVal = value == null ? "-" : value.toStringAsFixed(2);
    var displayText = displayTextVal != "-"
        ? NumberFormat.compactCurrency(
                decimalDigits: 2, locale: 'en_IN', symbol: '')
            .format(double.parse(displayTextVal))
        : '-';
    if (displayText.contains("T")) {
      displayText = displayText.replaceAll("T", "K");
    }
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Selected Date: ${date.toLocal().toIso8601String().split('T').first} => $value",
            ),
          ),
        );
      },
      child: Container(
        width: 40,
        height: 50,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString().padLeft(2, '0'),
              style: textStyle(
                  widget.theme.isDarkMode ? Colors.white : Colors.black,
                  12,
                  FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              displayText,
              style: textStyle(
                  widget.theme.isDarkMode ? Colors.white70 : Colors.grey[800]!,
                  10,
                  FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _goToPreviousMonth() {
    if (_month.year == widget.startDate.year &&
        _month.month == widget.startDate.month) return;
    final prevMonth = DateTime(_month.year, _month.month - 1, 1);
    setState(() {
      _month =
          prevMonth.isBefore(widget.startDate) ? widget.startDate : prevMonth;
    });
    widget.onMonthChanged(_month);
  }

  void _goToNextMonth() {
    if (_month.year == widget.endDate.year &&
        _month.month == widget.endDate.month) return;
    final nextMonth = DateTime(_month.year, _month.month + 1, 1);
    setState(() {
      _month = nextMonth.isAfter(widget.endDate) ? widget.endDate : nextMonth;
    });
    widget.onMonthChanged(_month);
  }

  String _formatMonthYear(DateTime date) {
    const monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return "${monthNames[date.month - 1]} ${date.year}";
  }

  List<DateTime> _buildMonthDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final leading = firstDayOfMonth.weekday - 1;
    final trailing = 7 - lastDayOfMonth.weekday;
    final days = <DateTime>[];
    for (int i = 0; i < leading; i++) {
      days.add(DateTime(1900, 1, 1));
    }
    for (int d = 1; d <= lastDayOfMonth.day; d++) {
      days.add(DateTime(month.year, month.month, d));
    }
    for (int i = 0; i < trailing; i++) {
      days.add(DateTime(1900, 1, 1));
    }
    return days;
  }

  List<List<DateTime>> _chunkDays(List<DateTime> days, int chunkSize) {
    final chunks = <List<DateTime>>[];
    for (int i = 0; i < days.length; i += chunkSize) {
      chunks.add(days.sublist(
          i, (i + chunkSize > days.length) ? days.length : i + chunkSize));
    }
    return chunks;
  }
  // ignore: unused_element
}
