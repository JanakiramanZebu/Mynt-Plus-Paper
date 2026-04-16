import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../../../../provider/stocks_provider.dart';
import '../../../../../../provider/thems.dart';
import '../../../../../../res/res.dart';
import '../../../../../../routes/route_names.dart';
import 'sector_themeatic_list.dart';

class SectorThematicWidget extends ConsumerStatefulWidget {
  const SectorThematicWidget({super.key});

  @override
  ConsumerState<SectorThematicWidget> createState() => _SectorThematicWidgetState();
}

class _SectorThematicWidgetState extends ConsumerState<SectorThematicWidget>
    with TickerProviderStateMixin {
  late TabController tabCtrl;

  List<Tab> tabList = [
    Tab(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          SvgPicture.asset("assets/explore/sector.svg", width: 30, height: 30),
          const SizedBox(width: 10),
          const Text("Sectoral")
        ])),
    Tab(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          SvgPicture.asset("assets/explore/thematic.svg",
              width: 30, height: 30),
          const SizedBox(width: 10),
          const Text("Thematic")
        ]))
  ];

  int selectedTabIndex = 0;

  @override
  void initState() {
    tabCtrl = TabController(
        length: tabList.length, vsync: this, initialIndex: selectedTabIndex);

    tabCtrl.addListener(() {
      setState(() {
        selectedTabIndex = tabCtrl.index;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final theme = ref.read(themeProvider);
    final tradeAcrion = ref.read(stocksProvide);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
            height: 50,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: theme.isDarkMode
                            ? colors.darkColorDivider
                            : colors.colorDivider,
                        width: 0),
                    top: BorderSide(
                        color: theme.isDarkMode
                            ? colors.darkColorDivider
                            : colors.colorDivider,
                        width: 0))),
            child: TabBar(
                indicatorColor: const Color(0xff0037B7),
                indicatorSize: TabBarIndicatorSize.tab,
                unselectedLabelColor: const Color(0XFF666666),
                unselectedLabelStyle:
                    textStyle(const Color(0XFF666666), 14, FontWeight.w500),
                labelColor: const Color(0XFF0037B7),
                labelStyle:
                    textStyle(const Color(0XFF0037B7), 14, FontWeight.w600),
                controller: tabCtrl,
                tabs: tabList)),
        SizedBox(
         
          height: 314,
          child: TabBarView(
              controller: tabCtrl, children: [ SectorThematicList(data:tradeAcrion.sectorsData ,isscollable:false ),  SectorThematicList(data:tradeAcrion.thematicDat ,isscollable:false )]),
        ),

       Center(
         child: TextButton(
                  onPressed: () async {
                await   tradeAcrion . fetchALLAdindices();
                     Navigator.pushNamed(context, Routes.allTrade);
                  },
                  child: Text('See all',
                      style: GoogleFonts.inter(
                          color: const Color(0xff0037B7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600))),
       )
      ],
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
