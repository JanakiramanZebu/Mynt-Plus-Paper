import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';

import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../sharedWidget/loader_ui.dart';
import 'pledge_history_screen.dart';
import 'tax_pnl_screens/pnl_value_screen.dart';
import 'unpledge_history_screen.dart';

class PledgeHistoryMainScreen extends StatefulWidget {
  const PledgeHistoryMainScreen({super.key});

  @override
  _PledgeMainScreen createState() => _PledgeMainScreen();
}

class _PledgeMainScreen extends State<PledgeHistoryMainScreen>
    with SingleTickerProviderStateMixin {
  final tablistitems = [
    {
      "title": "Pledge",
      "index": 0,
    },
    {
      "title": "Unpledge",
      "index": 1,
    },
     
  ];
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 4 Tabs
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = watch(themeProvider);
      double screenWidth = MediaQuery.of(context).size.width;

      final ledgerprovider = watch(ledgerProvider);

      return Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
           elevation: 0.2,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.heroText(
                  text: "Pledge History",
                  
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
          isLoading: ledgerprovider.pledgehistory,
          child:  
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.only(left : 16.0, top : 24.0),
                  //   child: BarChartWidget(),
                  // ),
                   

                  Padding(
                    padding: const EdgeInsets.only(top :8.0),
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
                        child: TabBar(
                            labelPadding:
                                const EdgeInsets.only(right: 16, bottom: 0),
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
                  ),
                  
              
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: [ 
                        PledgeHistoryScreen(),
                        UnpledgeHistoryScreen(),
                        
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
                    : Color.fromARGB(0, 241, 243, 248),
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
