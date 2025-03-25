import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read(ipoProvide).getipoorderbookmodel(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final ipo = watch(ipoProvide);
      final theme = watch(themeProvider);
      final dev_height = MediaQuery.of(context).size.height;

      return Scaffold(
        // appBar: AppBar(
        //   elevation: .2,
        //   centerTitle: false,
        //   leadingWidth: 41,
        //   titleSpacing: 6,
        //   leading: InkWell(
        //     onTap: () {
        //       Navigator.pop(context);
        //       // Navigator.pushReplacement(context,
        //       //   PageRouteBuilder(
        //       //     pageBuilder: (context, animation, secondaryAnimation) =>
        //       //         const IPOScreen(),
        //       //     transitionsBuilder:
        //       //         (context, animation, secondaryAnimation, child) {
        //       //       final tween = Tween<Offset>(
        //       //           begin: const Offset(0, 1), end: const Offset(.0, .0));
        //       //       return SlideTransition(
        //       //           position: animation.drive(tween), child: child);
        //       //     })
        //       //   );

        //     },
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 9),
        //       child: SvgPicture.asset(assets.backArrow,
        //           color:
        //               theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
        //     ),
        //   ),
        //   backgroundColor:
        //       theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        //   shadowColor: const Color(0xffECEFF3),
        //   title: Text(
        //     "Order Book",
        //     style: textStyles.appBarTitleTxt.copyWith(
        //       color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
        //     ),
        //   ),
        // ),
        body: TransparentLoaderScreen(
          isLoading: ipo.myBidsload!,
          child: (ipo.openorder?.isEmpty ?? true) &&
                      (ipo.closeorder?.isEmpty ?? true)
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 225),
                        child: Container(
                          height: dev_height - 140,
                          child: Column(
                            children: [
                              NoDataFound(),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (ipo.openorder!.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8),
                                child: Text(
                                  "Open Orders",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite.withOpacity(0.3)
                                          : colors.colorBlack.withOpacity(0.3),
                                      16,
                                      FontWeight.w600),
                                ),
                              ),
                              const IpoOpenOrder(),
                            ],
                            if (ipo.closeorder!.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8),
                                child: Text(
                                  "Closed Orders",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite.withOpacity(0.3)
                                          : colors.colorBlack.withOpacity(0.3),
                                      16,
                                      FontWeight.w600),
                                ),
                              ),
                              const IpoCloseOrder(),
                            ],
                          ]),
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
