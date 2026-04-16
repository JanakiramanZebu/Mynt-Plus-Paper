import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../sharedWidget/loader_ui.dart';
import 'tax_pnl_screens/charges_value_screen.dart';
import 'tax_pnl_screens/pnl_value_screen.dart';
import 'tax_pnl_screens/turnover_value_screen.dart';

class TaxPnlScreen extends StatefulWidget {
  const TaxPnlScreen({super.key});

  @override
  _TaxPnlScreenState createState() => _TaxPnlScreenState();
}

class _TaxPnlScreenState extends State<TaxPnlScreen>
    with SingleTickerProviderStateMixin {
  final tablistitems = [
    {
      "title": "Profit & Loss",
      "index": 0,
    },
    {
      "title": "Turnover",
      "index": 1,
    },
    {
      "title": "Charges",
      "index": 2,
    }
  ];
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 4 Tabs
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
                  text: "Tax P&L",
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
          isLoading: ledgerprovider.taxderloading,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.only(left : 16.0, top : 24.0),
                  //   child: BarChartWidget(),
                  // ),
                  SizedBox(
                      width: screenWidth,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 16.0, right: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             TextWidget.subText(
                  text: "Financial Year",
                  textOverflow: TextOverflow.ellipsis,
                  theme: theme.isDarkMode,
                   color: theme.isDarkMode
                                                        ? colors.textPrimaryDark
                                                        : colors.textPrimaryLight,
                  fw: 0),
                           
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_left,
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack),
                                  onPressed: () => {
                                    ledgerprovider.fetchtaxpnleqdata(
                                        context,
                                        ledgerprovider.yearforTaxpnl - 1)
                                  },
                                ),
                                // Center(
                                //   child: Container(
                                //     width: screenWidth * 0.5,
                                //     alignment: Alignment.centerLeft,
                                //     padding: const EdgeInsets.symmetric(
                                //         vertical: 10, horizontal: 10),
                                //     decoration: BoxDecoration(
                                //         borderRadius: BorderRadius.circular(30),
                                //         color: theme.isDarkMode
                                //             ? const Color(0xffB5C0CF).withOpacity(.15)
                                //             : const Color(0xffF1F3F8)),
                                //     child: Center(
                                //       child:
                                 TextWidget.paraText(
                  text: "${ledgerprovider.yearforTaxpnl}",
                  textOverflow: TextOverflow.ellipsis,
                  theme: theme.isDarkMode,
                   color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  fw: 3),
                                
                      
                                //     ),
                                //   ),
                                // ),
                                IconButton(
                                  icon: Icon(Icons.arrow_right,
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack),
                                  onPressed: () => {
                                    ledgerprovider.fetchtaxpnleqdata(
                                        context,
                                        ledgerprovider.yearforTaxpnl + 1)
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),

                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding:
                            const EdgeInsets.only(bottom: 0, left: 15, top: 2),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.darkColorDivider
                                        : colors.colorDivider,
                                    width: 0.4))),
                        // height: 60,
                        child: 
                         TabBar(
              onTap: (index) {
                setState(() {});
              },
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
                fw: 3,
              ),
              labelColor: theme.isDarkMode
                  ? colors.secondaryDark
                  : colors.secondaryLight,
              labelStyle:
                  TextWidget.textStyle(fontSize: 14, theme: false, fw: 3),
              controller: _tabController,
              tabs: List.generate(tablistitems.length, (index) {
                final isSelected = _tabController.index == index;

                final color = isSelected
                    ? (theme.isDarkMode
                        ? colors.secondaryDark
                        : colors.secondaryLight)
                    : (theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight);

                return Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextWidget.subText(
                        text: tablistitems[index]['title'].toString(),
                        theme: false,
                        color: color,
                        fw: isSelected ? 2 : null,
                      ),
                      const SizedBox(width: 5),
                       
                    ],
                  ),
                );
              }),
            ),
                      
                                    ),  
                  ),

                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: const [
                        TaxpnlvalueScreen(),
                        TaxTurnOver(),
                        TaxCharges(),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                    height: 40,
                    width: 65,
                    margin: const EdgeInsets.only(right: 12, top: 15),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            backgroundColor: theme.isDarkMode
                                ? colors.primaryDark
                                : colors.primaryLight,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        onPressed: () async {
                          ledgerprovider.pdfdownloadfortaxpnl(
                              context,
                              ledgerprovider.taxpnleq?.data?.toJson() ?? {},
                              ledgerprovider.taxpnldercomcur?.data?.toJson() ??
                                  {},
                              ledgerprovider.taxpnleqCharge?.toJson() ?? {},
                              ledgerprovider.yearforTaxpnl);
                        },
                        child: Text("Download",
                            textAlign: TextAlign.center,
                            style: textStyle(
                                !theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                12,
                                FontWeight.w500)))),
              ),
              const SizedBox(
                height: 20.0,
              )
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
