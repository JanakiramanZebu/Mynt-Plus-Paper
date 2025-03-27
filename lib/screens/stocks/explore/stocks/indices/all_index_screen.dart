import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../provider/stocks_provider.dart';
import '../../../../../provider/index_list_provider.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/custom_back_btn.dart';
import 'global_index.dart';
import 'index_screen.dart';

class AllIndicesScreen extends StatefulWidget {
  const AllIndicesScreen({super.key});

  @override
  State<AllIndicesScreen> createState() => _AllIndicesScreenState();
}

class _AllIndicesScreenState extends State<AllIndicesScreen>
    with TickerProviderStateMixin {
  late TabController tabCtrl;

  List<Tab> tabList = [
    Tab(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          SvgPicture.asset("assets/icon/india.svg"),
          const SizedBox(width: 10),
          const Text("Indian Index")
        ])),
    Tab(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          SvgPicture.asset("assets/icon/world.svg"),
          const SizedBox(width: 10),
          const Text("Global Index")
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
    return PopScope(
        canPop: true, // Allows default back navigation
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return; // If system handled back, do nothing
        },
        child: Consumer(builder: (context, ScopedReader watch, _) {
          final allIndices = watch(stocksProvide);
          final indexData = watch(indexListProvider);

          return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
              child: Scaffold(
                  appBar: AppBar(
                      elevation: .2,
                      leadingWidth: 41,
                      centerTitle: false,
                      titleSpacing: 6,
                      leading: const CustomBackBtn(),
                      shadowColor: const Color(0xffECEFF3),
                      title: InkWell(
                        onTap: selectedTabIndex != 0
                            ? null
                            : () {
                                showModalBottomSheet(
                                    showDragHandle: true,
                                    useSafeArea: true,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16))),
                                    backgroundColor: const Color(0xffffffff),
                                    context: context,
                                    builder: (context) => Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16.0),
                                                  child: Text("Indian index",
                                                      style: textStyles
                                                          .appBarTitleTxt)),
                                              const SizedBox(height: 6),
                                              Flexible(
                                                  child: ListView.separated(
                                                      physics:
                                                          const ClampingScrollPhysics(),
                                                      itemBuilder:
                                                          (context, index) {
                                                        return ListTile(
                                                            onTap: () async {
                                                              indexData.getchngIndexData(
                                                                  indexData
                                                                          .indexExch[
                                                                      index]);
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16),
                                                            dense: true,
                                                            title: Text(
                                                                indexData.indexExch[
                                                                    index],
                                                                style: indexData.indexExch[index] ==
                                                                        indexData
                                                                            .selectedIndExch
                                                                    ? textStyles
                                                                        .actPrdText
                                                                    : textStyles
                                                                        .prdText),
                                                            trailing: SvgPicture.asset(indexData.indexExch[index] ==
                                                                    indexData
                                                                        .selectedIndExch
                                                                ? assets
                                                                    .actProductIcon
                                                                : assets.productIcon));
                                                      },
                                                      separatorBuilder:
                                                          (context, index) {
                                                        return Divider(
                                                            height: 0.5,
                                                            color: colors
                                                                .colorDivider);
                                                      },
                                                      shrinkWrap: true,
                                                      itemCount: indexData
                                                          .indexExch.length))
                                            ]));
                              },
                        child: Container(
                          width: 120,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 3),
                          child: selectedTabIndex == 0
                              ? Row(
                                  children: [
                                    Text(
                                        "${selectedTabIndex == 0 ? indexData.selectedIndExch : "Global"} index",
                                        style: textStyle(
                                            const Color(0xff000000),
                                            14,
                                            FontWeight.w600)),
                                    const SizedBox(width: 6),
                                    SvgPicture.asset(assets.downArrow,
                                        color: colors.colorBlue, width: 14)
                                  ],
                                )
                              : Text("Global index",
                                  style: textStyle(const Color(0xff000000), 14,
                                      FontWeight.w600)),
                        ),
                      ),
                      bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(50),
                          child: Container(
                              decoration: const BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: Color(0xffDDDDDD)))),
                              child: TabBar(
                                  indicatorColor: const Color(0xff0037B7),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  unselectedLabelColor: const Color(0XFF666666),
                                  unselectedLabelStyle: textStyle(
                                      const Color(0XFF666666),
                                      14,
                                      FontWeight.w500),
                                  labelColor: const Color(0XFF0037B7),
                                  labelStyle: textStyle(const Color(0XFF0037B7),
                                      14, FontWeight.w600),
                                  controller: tabCtrl,
                                  tabs: tabList)))),
                  body: TabBarView(controller: tabCtrl, children: [
                    IndexScreen(indexData: indexData.indIndex),
                    GlobalIndices(globalIndices: allIndices.globalIndicesModel)
                  ])));
        }));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
