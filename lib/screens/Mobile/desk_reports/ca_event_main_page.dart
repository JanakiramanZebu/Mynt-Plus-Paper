import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';

import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../sharedWidget/loader_ui.dart';
import 'ca_events/ca_event_agmandegm.dart';
import 'ca_events/ca_event_boardmeeting.dart';
import 'ca_events/ca_event_bonus.dart';
import 'ca_events/ca_event_dividend.dart';
import 'ca_events/ca_event_rights.dart';
import 'ca_events/ca_event_split.dart';

class CAEventMainPage extends StatefulWidget {
  const CAEventMainPage({super.key});

  @override
  _CAEventMainPage createState() => _CAEventMainPage();
}

class _CAEventMainPage extends State<CAEventMainPage>
    with SingleTickerProviderStateMixin {
  final tablistitems = [
    {
      "title": "Board Meeting",
      "index": 0,
    },
    {
      "title": "AGM / EGMs",
      "index": 1,
    },
    {
      "title": "Bonus",
      "index": 2,
    },
    {
      "title": "Dividend",
      "index": 3,
    },
    {
      "title": "Rights",
      "index": 4,
    },
    {
      "title": "Split",
      "index": 5,
    },
  ];
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this); // 4 Tabs
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      double screenWidth = MediaQuery.of(context).size.width;

      final ledgerprovider = ref.watch(ledgerProvider);

      return Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          elevation: 0.2,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.heroText(
                  text: "CA Events",
                  textOverflow: TextOverflow.ellipsis,
                  theme: theme.isDarkMode,
                  fw: 1),

              // DropdownButtonHideUnderline(
              //     child: DropdownButton2(
              //         menuItemStyleData: MenuItemStyleData(
              //             customHeights: ledgerprovider.getCustItemsHeight()),
              //         buttonStyleData: ButtonStyleData(
              //             height: 36,
              //             width: MediaQuery.of(context).size.width,
              //             decoration: const BoxDecoration(
              //                 color: Color(0xffF1F3F8),
              //                 borderRadius:
              //                     BorderRadius.all(Radius.circular(32)))),
              //         dropdownStyleData: DropdownStyleData(
              //           padding: const EdgeInsets.symmetric(vertical: 6),
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(4),
              //           ),
              //           offset: const Offset(0, 8),
              //         ),
              //         isExpanded: true,
              //         style:
              //             textStyle(const Color(0XFF000000), 13, FontWeight.w500),
              //         hint: Text(mfOrder.paymentName,
              //             style: textStyle(
              //                 const Color(0XFF000000), 13, FontWeight.w500)),
              //         items: mfOrder.addDividers(),
              //         value: mfOrder.paymentName,
              //         onChanged: (value) async {
              //           mfOrder.chngPayName("$value");
              //         })),
            ],
          ),
          // leading: InkWell(
          //   onTap: () {

          //   },
          //   child: Icon(Icons.ios_share)),
        ),
        body: TransparentLoaderScreen(
          isLoading: ledgerprovider.caeventloading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Padding(
              //   padding: const EdgeInsets.only(left : 16.0, top : 24.0),
              //   child: BarChartWidget(),
              // ),
              SizedBox(
                width: screenWidth,
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 16.0, left: 16.0, top: 16.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            ledgerprovider.datePickerStart(context, theme);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget.paraText(
                                  text: "Start Date",
                                  textOverflow: TextOverflow.ellipsis,
                                  theme: theme.isDarkMode,
                                  fw: 1),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: theme.isDarkMode
                                        ? const Color(0xffB5C0CF)
                                            .withOpacity(.15)
                                        : const Color(0xffF1F3F8)),
                                child: Text(ledgerprovider.startDate,
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        11,
                                        FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            ledgerprovider.datePickerEnd(context, theme);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget.paraText(
                                  text: "End Date",
                                  textOverflow: TextOverflow.ellipsis,
                                  theme: theme.isDarkMode,
                                  fw: 1),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: theme.isDarkMode
                                        ? const Color(0xffB5C0CF)
                                            .withOpacity(.15)
                                        : const Color(0xffF1F3F8)),
                                child: Text(ledgerprovider.endDate,
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        11,
                                        FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0, top: 16.0),
                        child: SizedBox(
                            height: 27,
                            child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: !theme.isDarkMode
                                          ? colors.colorBlack
                                          : colors.colorWhite,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(32)))),
                                onPressed: () async {
                                  ledgerprovider.fetchcaeventsdata(
                                      context,
                                      ledgerprovider.startDate,
                                      ledgerprovider.endDate);
                                },
                                child: Text("Get",
                                    style: textStyle(
                                        !theme.isDarkMode
                                            ? colors.colorBlack
                                            : colors.colorWhite,
                                        12,
                                        FontWeight.w600)))),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(bottom: 0, left: 15, top: 2),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                              width: 0.4))),
                  // height: 60,
                  child: TabBar(
                      labelPadding:
                          const EdgeInsets.only(right: 16, bottom: 8.0),
                      tabAlignment: TabAlignment.start,
                      indicatorColor: Colors.transparent,
                      controller: _tabController,
                      isScrollable: true,
                      tabs: List.generate(
                          tablistitems.length,
                          (tab) => tabConstruce(
                              tablistitems[tab]['title'].toString(),
                              theme,
                              tab,
                              () {},
                              ledgerprovider)))),

              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: const [
                    CAEventBoardMeeting(),
                    CAEventAgmandEgm(),
                    CAEventBonus(),
                    CAEventDividend(),
                    CAEventRights(),
                    CAEventSplit(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showBottomSheet(BuildContext context, Widget bottomSheet) {
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

  Widget tabConstruce(String title, ThemesProvider theme, int tab,
      VoidCallback onPressed, ledgerprovider) {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            ledgerprovider.taxpnlExTabchange(tab);
          });
          _tabController.animateTo(tab);
          print("object act tab $tab");
        },
        style: ElevatedButton.styleFrom(
            elevation: 0,
            side: const BorderSide(
                color: Color.fromARGB(255, 0, 0, 0),
                width: 1), // Border color & width
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            backgroundColor: theme.isDarkMode
                ? tab == ledgerprovider.activeTabTaxPnl
                    ? colors.colorbluegrey
                    : const Color(0xffB5C0CF).withOpacity(.15)
                : tab == ledgerprovider.activeTabTaxPnl
                    ? const Color(0xff000000)
                    : const Color.fromARGB(0, 241, 243, 248),
            shape: const StadiumBorder()),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title,
                  style: textStyle(
                      theme.isDarkMode
                          ? Color(tab == ledgerprovider.activeTabTaxPnl
                              ? 0xff000000
                              : 0xffffffff)
                          : Color(tab == ledgerprovider.activeTabTaxPnl
                              ? 0xffffffff
                              : 0xff000000),
                      12,
                      FontWeight.w500))
            ]));
  }
}
