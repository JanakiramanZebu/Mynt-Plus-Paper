import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/iop_provider.dart';
import '../../../res/res.dart';
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
                child: SvgPicture.asset(assets.backArrow),
              ),
            ),
            backgroundColor: colors.colorWhite,
            shadowColor: const Color(0xffECEFF3),
            title: Text("IPOs", style: textStyles.appBarTitleTxt)),
        body: Column(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Color(0xffD7DCE4)))),
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
                    children: [IpoOpenOrder(open:ipo), IpoCloseOrder(close:ipo)],))
          ],
        ),
      );
    });
  }
}
