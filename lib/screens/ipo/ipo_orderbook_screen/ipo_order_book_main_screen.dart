import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/iop_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';
import 'ipo_order_book_tab/close_ipo_tab.dart';
import 'ipo_order_book_tab/open_ipo_tab.dart';

class IpoOrderbookMainScreen extends StatefulWidget {
  const IpoOrderbookMainScreen({super.key});

  @override
  State<IpoOrderbookMainScreen> createState() => _IpoOrderbookMainScreenState();
}

class _IpoOrderbookMainScreenState extends State<IpoOrderbookMainScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final ipo = watch(ipoProvide);
      final theme = watch(themeProvider);

      return Scaffold(
        appBar: AppBar(
          elevation: .2,
          centerTitle: false,
          leadingWidth: 41,
          titleSpacing: 6,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
              // Navigator.pushReplacement(context, 
              //   PageRouteBuilder(
              //     pageBuilder: (context, animation, secondaryAnimation) =>
              //         const IPOScreen(),
              //     transitionsBuilder:
              //         (context, animation, secondaryAnimation, child) {
              //       final tween = Tween<Offset>(
              //           begin: const Offset(0, 1), end: const Offset(.0, .0));
              //       return SlideTransition(
              //           position: animation.drive(tween), child: child);
              //     })
              //   );


            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: SvgPicture.asset(assets.backArrow,
                  color:
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
            ),
          ),
          backgroundColor:
              theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          shadowColor: const Color(0xffECEFF3),
          title: Text(
            "Order Book",
            style: textStyles.appBarTitleTxt.copyWith(
              color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              //   ListView(padding: EdgeInsets.zero, shrinkWrap: true, children: [
              //     Container(
              //         padding:
              //             const EdgeInsets.only(left: 14, top: 8, bottom: 8),
              //         height: 52,
              //         decoration: BoxDecoration(
              //             border: Border(
              //                 bottom: BorderSide(
              //                     color: theme.isDarkMode
              //                         ? colors.darkColorDivider
              //                         : colors.colorDivider,
              //                     width: 0),
              //                 top: BorderSide(
              //                     color: theme.isDarkMode
              //                         ? colors.darkColorDivider
              //                         : colors.colorDivider,
              //                     width: 0))),
              //         child: ListView.separated(
              //             scrollDirection: Axis.horizontal,
              //             itemCount: ipo.ipoOrderBookTabNameBtns.length,
              //             itemBuilder: (BuildContext context, int index) {
              //               return ElevatedButton(
              //                   onPressed: () async {
              //                     ipo.chngOrderBookTabNameBtn(
              //                         ipo.ipoOrderBookTabNameBtns[index]['btnName']);
              //                   },
              //                   style: ElevatedButton.styleFrom(
              //                       elevation: 0,
              //                       padding: const EdgeInsets.symmetric(
              //                           horizontal: 12, vertical: 0),
              //                       backgroundColor: theme.isDarkMode
              //                           ? ipo.ipoOrderBookTabNameAct ==
              //                                   ipo.ipoOrderBookTabNameBtns[index]
              //                                       ['btnName']
              //                               ? colors.colorbluegrey
              //                               : const Color(0xffB5C0CF)
              //                                   .withOpacity(.15)
              //                           : ipo.ipoOrderBookTabNameAct ==
              //                                   ipo.ipoOrderBookTabNameBtns[index]
              //                                       ['btnName']
              //                               ? const Color(0xff000000)
              //                               : const Color(0xffF1F3F8),
              //                       shape: const StadiumBorder()),
              //                   child: Row(children: [
              //                     SvgPicture.asset(
              //                       "${ipo.ipoOrderBookTabNameBtns[index]['imgPath']}",
              //                       color: theme.isDarkMode
              //                           ? Color(ipo.ipoOrderBookTabNameAct ==
              //                                   ipo.ipoOrderBookTabNameBtns[index]
              //                                       ['btnName']
              //                               ? 0xff000000
              //                               : 0xffffffff)
              //                           : Color(ipo.ipoOrderBookTabNameAct ==
              //                                   ipo.ipoOrderBookTabNameBtns[index]
              //                                       ['btnName']
              //                               ? 0xffffffff
              //                               : 0xff000000),
              //                     ),
              //                     const SizedBox(width: 8),
              //                     Text(
              //                         "${ipo.ipoOrderBookTabNameBtns[index]['btnName']}",
              //                         style: textStyle(
              //                             theme.isDarkMode
              //                                 ? Color(ipo.ipoOrderBookTabNameAct ==
              //                                         ipo.ipoOrderBookTabNameBtns[
              //                                             index]['btnName']
              //                                     ? 0xff000000
              //                                     : 0xffffffff)
              //                                 : Color(ipo.ipoOrderBookTabNameAct ==
              //                                         ipo.ipoOrderBookTabNameBtns[
              //                                             index]['btnName']
              //                                     ? 0xffffffff
              //                                     : 0xff000000),
              //                             12.5,
              //                             FontWeight.w500))
              //                   ]));
              //             },
              //             separatorBuilder: (BuildContext context, int index) {
              //               return const SizedBox(width: 10);
              //             })),
              //   ]),
              // if (ipo.ipoOrderBookTabNameAct == "Open Order") ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  "Open Orders",
                  style: textStyle(
                      theme.isDarkMode
                          ? colors.colorWhite.withOpacity(0.3)
                          : colors.colorBlack.withOpacity(0.3),
                      15,
                      FontWeight.w600),
                ),
              ),
               ipo.openorder!.isNotEmpty? const IpoOpenOrder():
               const Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: NoDataFound(),
                  ),
                ),
              // ] else if (ipo.ipoOrderBookTabNameAct == "Closed Order") ...[
              // Divider(
              //   height: 10,
              //     color: theme.isDarkMode
              //         ? colors.darkColorDivider
              //         : colors.colorDivider),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Text(
                    "Closed Orders",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite.withOpacity(0.3)
                            : colors.colorBlack.withOpacity(0.3),
                        15,
                        FontWeight.w600),
                  )),
              ipo.closeorder!.isNotEmpty? const IpoCloseOrder()
              :const Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: NoDataFound(),
                  ),
                ),
              // ]
            ],
          ),
        ),
      );

      // return SingleChildScrollView(
      //   child: Container(
      //     child: ipo.fundisLoad
      //         ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      //             const ProgressiveDotsLoader(),
      //             const SizedBox(height: 3),
      //             Text('This will take a few seconds.',
      //                 style: textStyle(colors.colorGrey, 13, FontWeight.w500)),
      //           ])
      //         : TabBarView(controller: ipo.ipoOrderBookScreenTab, children:[
      //                 IpoOpenOrder(open: ipo),
      //                 IpoCloseOrder(close: ipo)

      //             ],
      //           ),
      //   ),
      // );
    });
  }
}
