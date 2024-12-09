import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/thems.dart';
import '../../../provider/iop_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/payment_loader.dart';
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
    context.read(ipoProvide).ipoTab = TabController(
        length: context.read(ipoProvide).ipotabs.length,
        vsync: this,
        initialIndex: context.read(ipoProvide).selectedTab);

    context.read(ipoProvide).ipoTab.addListener(() {
      context
          .read(ipoProvide)
          .changeTabIndex(context.read(ipoProvide).ipoTab.index);
      context.read(ipoProvide).ipotab();
    });

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
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: SvgPicture.asset(
                assets.backArrow,
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              ),
            ),
          ),
          backgroundColor:
              theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          shadowColor: const Color(0xffECEFF3),
          title: Text("IPOs",
              style: textStyles.appBarTitleTxt.copyWith(
                  color: theme.isDarkMode
                      ? colors.colorWhite
                      : colors.colorBlack)),
        ),
        body: ipo.fundisLoad
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const ProgressiveDotsLoader(),
                const SizedBox(height: 3),
                Text('This will take a few seconds.',
                    style: textStyle(colors.colorGrey, 13, FontWeight.w500)),
              ])
            : Column(
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: theme.isDarkMode
                              ? colors.colorBlack
                              : colors.colorWhite,
                          border: Border(
                              bottom: BorderSide(
                                  color: theme.isDarkMode
                                      ? colors.darkGrey
                                      : const Color(0xffF1F3F8),
                                  width: 0))),
                      height: 46,
                      child: TabBar(
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorColor: const Color(0xff0037B7),
                          unselectedLabelColor: const Color(0XFF777777),
                          unselectedLabelStyle: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.28)),
                          labelColor: const Color(0XFF0037B7),
                          labelStyle: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          controller: ipo.ipoTab,
                          tabs: ipo.ipotabs)),
                  Expanded(
                      child: TabBarView(
                    controller: ipo.ipoTab,
                    children: [
                      IpoOpenOrder(open: ipo),
                      IpoCloseOrder(close: ipo)
                    ],
                  ))
                ],
              ),
      );
    });
  }
}
