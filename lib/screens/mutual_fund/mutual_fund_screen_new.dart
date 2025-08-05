import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/thems.dart';
import '../../provider/mf_provider.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/functions.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../sharedWidget/list_divider.dart';

class MutualFundNewScreen extends ConsumerStatefulWidget {
  final TabController tabController;
  const MutualFundNewScreen({super.key, required this.tabController});

  @override
  ConsumerState<MutualFundNewScreen> createState() =>
      _MutualFundNewScreenState();
}

class _MutualFundNewScreenState extends ConsumerState<MutualFundNewScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Add listener to update state when tab changes
    _tabController.addListener(() {
      setState(() {
        // This will trigger rebuild when tab changes
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final mfData = ref.watch(mfProvider);
    final theme = ref.watch(themeProvider);
  final isSelected = _tabController.index;
    


    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: SizedBox(
          //     child: Skeletonizer(
          //       enabled: mfData.holdstatload ?? false,
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             children: [
          //               Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   TextWidget.paraText(
          //                     text: "Invested",
          //                     color: theme.isDarkMode
          //                         ? colors.textPrimaryDark
          //                         : colors.textPrimaryLight,
          //                     textOverflow: TextOverflow.ellipsis,
          //                     theme: theme.isDarkMode,
          //                   ),
          //                   const SizedBox(height: 6),
          //                   TextWidget.titleText(
          //                       text:
          //                           "${(mfData.mfholdingnew?.summary?.invested == "" || mfData.mfholdingnew?.summary?.invested == null) ? "0.00" : mfData.mfholdingnew?.summary?.invested}",
          //                       color: theme.isDarkMode
          //                           ? colors.textSecondaryDark
          //                           : colors.textSecondaryLight,
          //                       textOverflow: TextOverflow.ellipsis,
          //                       theme: theme.isDarkMode,
          //                       fw: 0),
          //                 ],
          //               ),
          //               Column(
          //                 crossAxisAlignment: CrossAxisAlignment.end,
          //                 children: [
          //                   TextWidget.paraText(
          //                     text: "Profit / Loss",
          //                     color: theme.isDarkMode
          //                         ? colors.textPrimaryDark
          //                         : colors.textPrimaryLight,
          //                     textOverflow: TextOverflow.ellipsis,
          //                     theme: theme.isDarkMode,
          //                   ),
          //                   const SizedBox(height: 6),
          //                   TextWidget.titleText(
          //                       text:
          //                           "${(mfData.mfholdingnew?.summary?.absReturnValue == "" || mfData.mfholdingnew?.summary?.absReturnValue == null) ? "0.00" : mfData.mfholdingnew?.summary?.absReturnValue}",
          //                       color: theme.isDarkMode
          //                           ? colors.textSecondaryDark
          //                           : colors.textSecondaryLight,
          //                       textOverflow: TextOverflow.ellipsis,
          //                       theme: theme.isDarkMode,
          //                       fw: 0),
          //                 ],
          //               ),
          //             ],
          //           ),
          //           const SizedBox(height: 16),
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             children: [
          //               Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   TextWidget.paraText(
          //                     text: "Current",
          //                     color: theme.isDarkMode
          //                         ? colors.textPrimaryDark
          //                         : colors.textPrimaryLight,
          //                     textOverflow: TextOverflow.ellipsis,
          //                     theme: theme.isDarkMode,
          //                   ),
          //                   const SizedBox(height: 6),
          //                   TextWidget.titleText(
          //                     text:
          //                         "${(mfData.mfholdingnew?.summary?.currentValue == "" || mfData.mfholdingnew?.summary?.currentValue == null) ? "0.00" : mfData.mfholdingnew?.summary?.currentValue}",
          //                     color: theme.isDarkMode
          //                         ? colors.textSecondaryDark
          //                         : colors.textSecondaryLight,
          //                     textOverflow: TextOverflow.ellipsis,
          //                     theme: theme.isDarkMode,
          //                     fw: 0,
          //                   ),
          //                 ],
          //               ),
          //               Column(
          //                 crossAxisAlignment: CrossAxisAlignment.end,
          //                 children: [
          //                   TextWidget.paraText(
          //                     text: "Abs Returns %",
          //                     color: theme.isDarkMode
          //                         ? colors.textPrimaryDark
          //                         : colors.textPrimaryLight,
          //                     textOverflow: TextOverflow.ellipsis,
          //                     theme: theme.isDarkMode,
          //                   ),
          //                   const SizedBox(height: 6),
          //                   TextWidget.titleText(
          //                       text:
          //                           "${mfData.mfholdingnew?.summary?.absReturnPercent?.toString() ?? "0"}%", // Ensures percentage is always a valid string
          //                       color: theme.isDarkMode
          //                           ? colors.textSecondaryDark
          //                           : colors.textSecondaryLight,
          //                       textOverflow: TextOverflow.ellipsis,
          //                       theme: theme.isDarkMode,
          //                       fw: 0),

          //                   //     Text(
          //                   //   _formatValue(mfData.mfholdingnew?.summary?.absReturnValue),
          //                   //   style: TextStyle(
          //                   //     fontSize: 14,
          //                   //     fontWeight: FontWeight.w500,
          //                   //     color: _getColorBasedOnValue(
          //                   //       mfData.mfholdingnew?.summary?.absReturnValue,
          //                   //     ),
          //                   //   ),
          //                   // ),
          //                 ],
          //               ),
          //             ],
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

          nfoCard(context, mfData, theme),
          // buildSlidingPanelContent(mfData.bestMFListStaticnew, mfData, theme),
          // const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.only(left: 8, right: 8,  bottom: 8),
            height: 35,
            child: TabBar(
              controller: _tabController, 
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: colors.colorWhite,
              indicator: BoxDecoration(
                color: const Color(0xffF1F3F8),
                borderRadius: BorderRadius.circular(6),
              ),
              unselectedLabelColor:  colors.textSecondaryLight,
              labelStyle:
                  TextWidget.textStyle(fontSize: 14, theme: false, fw: 2),
              unselectedLabelStyle: TextWidget.textStyle(
                  fontSize: 14, theme: false, fw: 3, letterSpacing: -0.28, color: colors.textSecondaryLight),
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            tabs: const [
                Tab(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 10, right: 10, top: 0, bottom: 0),
                    child: Text("Collections"),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 10, right: 10, top: 0, bottom: 0),
                    child: Text("Categories"),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar View
          SizedBox(
            height: 450 ,
            child: TabBarView(
              controller: _tabController,
              children: [
                buildCollectionsTab(mfData, theme),
                buildCategoriesTab(mfData, theme),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget.titleText(
                    // align: TextAlign.right,
                    text: 'Calculator',
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    textOverflow: TextOverflow.ellipsis,
                    theme: theme.isDarkMode,
                    fw: 1),
                const SizedBox(height: 10),
                sipcaltor(context, mfData, theme),
                ListDivider(),
                cargrcalss(context, mfData, theme),
                ListDivider(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget tabButton(IconData icon, String title) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSlidingPanelContent(
      bestMFList, MFProvider mfData, ThemesProvider theme) {
    return Container(
      // padding: const EdgeInsets.all(16.0),
      // color:
      // const Color(0xFFF9F9F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: 9),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget.titleText(
                    align: TextAlign.right,
                    text: "Collections",
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    textOverflow: TextOverflow.ellipsis,
                    theme: theme.isDarkMode,
                    fw: 1),
                const SizedBox(height: 10),
                TextWidget.paraText(
                    align: TextAlign.right,
                    text:
                        "Find the right mutual fund across these asset classes",
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    textOverflow: TextOverflow.ellipsis,
                    theme: theme.isDarkMode,
                    fw: 3),
              ],
            ),
          ),

          // const SizedBox(height: 24),
          SingleChildScrollView(
            child: Column(
              children: [
                Builder(
                  builder: (context) {
                    double screenWidth = MediaQuery.of(context).size.width;
                    double screenHeight = MediaQuery.of(context).size.height;

                    int crossAxisCount = screenWidth > 600 ? 3 : 2;
                    double childAspectRatio = 1.2;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return ListView.separated(
                          shrinkWrap:
                              true, // Allow GridView to take only required space
                          physics:
                              const NeverScrollableScrollPhysics(), // Disable GridView's scrolling
                          separatorBuilder: (_, __) => const ListDivider(),
                          itemCount: bestMFList?.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            if (bestMFList == null ||
                                index >= bestMFList.length) {
                              return const SizedBox.shrink();
                            }

                            return InkWell(
                              onTap: () async {
                                mfData.changetitle(bestMFList[index]['title']);
                                Navigator.pushNamed(
                                  context,
                                  Routes.bestMfScreen,
                                  arguments: bestMFList[index]['title'],
                                );
                              },
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                dense: false,
                                leading: SvgPicture.asset(
                                  bestMFList[index]['image'] ??
                                      'assets/explore/default.svg',
                                  height: 40,
                                  width: 40,
                                ),
                                title: TextWidget.subText(
                                  text: bestMFList[index]['title'] ?? '',
                                  color: theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                  textOverflow: TextOverflow.ellipsis,
                                  theme: theme.isDarkMode,
                                ),
                                subtitle: TextWidget.paraText(
                                  text:
                                      "${bestMFList[index]['subtitle'] ?? ''}",
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                  maxLines: 2,
                                  textOverflow: TextOverflow.ellipsis,
                                  theme: theme.isDarkMode,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildCategoryCard(
      {required String? dataIcon,
      required BuildContext context,
      required String? title,
      required String? description,
      required List<dynamic>? chips,
      required MFProvider mfData,
      required ThemesProvider theme}) {
    if (dataIcon == null || title == null
        // ||
        // description == null
        //  ||
        // chips == null

        ) {
      return const SizedBox.shrink();
    }

    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: () async {
        if (chips?.isNotEmpty ?? false) {
          final firstChip = chips?[0]?.toString() ?? "";
          mfData.fetchcatdatanew(title, firstChip);
          mfData.changetitle(firstChip);
          Navigator.pushNamed(context, Routes.mfCategoryList, arguments: title);
        }
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minLeadingWidth: 25,
        dense: false,
        leading: Image.asset(
          dataIcon,
          width: 30,
          height: 30,
        ),
        title: TextWidget.subText(
          // align: TextAlign.right,
          text: title,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          textOverflow: TextOverflow.ellipsis,
          theme: theme.isDarkMode,
        ),
        subtitle: Container(
          margin: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.1,
          ),
          child: TextWidget.paraText(
              // align: TextAlign.right,
              text: description ?? '',
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              fw: 3),
        ),
      ),
    );
  }

  Widget nfoCard(BuildContext context, MFProvider mf, ThemesProvider theme) {
    return GestureDetector(
      onTap: () async {
        Navigator.pushNamed(context, Routes.mfnfoscreen);
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.isDarkMode
              ? const Color.fromARGB(255, 0, 0, 0)
              : Colors.white,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
            color: const Color(0xFFECEDEE),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 0),
                      child: TextWidget.paraText(
                          align: TextAlign.left,
                          text: "INVEST IN",
                          color: theme.isDarkMode
                              ? colors.primaryDark
                              : colors.primaryLight,
                          textOverflow: TextOverflow.ellipsis,
                          theme: theme.isDarkMode,
                          fw: 3),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextWidget.subText(
                            align: TextAlign.left,
                            text: "New Fund Offerings",
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            fw: 3),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          color: theme.isDarkMode
                              ? colors.primaryDark
                              : colors.primaryLight,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
                SvgPicture.asset(
                  'assets/explore/gift.svg',
                  width: 38,
                  height: 34,
                ),
              ],
            ),
            // const SizedBox(height: 10),
            // TextWidget.paraText(
            //     align: TextAlign.left,
            //     text:
            //         "A new fund offer (NFO) is the first subscription for any new fund by an investment company.",
            //     color: theme.isDarkMode
            //         ? colors.textSecondaryDark
            //         : colors.textSecondaryLight,
            //     maxLines: 2,
            //     textOverflow: TextOverflow.ellipsis,
            //     theme: theme.isDarkMode,
            //     fw: 3),
            // const SizedBox(height: 12),
            // Row(
            //   children: [
            //     TextWidget.paraText(
            //         align: TextAlign.left,
            //         text: "See all NFOs",
            //         color: theme.isDarkMode
            //             ? colors.primaryDark
            //             : colors.primaryLight,
            //         textOverflow: TextOverflow.ellipsis,
            //         theme: theme.isDarkMode,
            //         fw: 3),
            //     SizedBox(width: 4),
            //     Icon(
            //       Icons.arrow_forward,
            //       color: theme.isDarkMode
            //           ? colors.primaryDark
            //           : colors.primaryLight,
            //       size: 16,
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget sipcaltor(BuildContext context, MFProvider mf, ThemesProvider theme) {
    return InkWell(
      onTap: () async {
        Navigator.pushNamed(context, Routes.mfsipcalscreen);
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minLeadingWidth: 25,
        dense: false,
        leading: SvgPicture.asset(
          'assets/icon/watchlistIcon/calc.svg',
          width: 25,
          height: 25,
        ),
        title: TextWidget.subText(
          // align: TextAlign.right,
          text: "SIP Calculator",
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          textOverflow: TextOverflow.ellipsis,
          theme: theme.isDarkMode,
        ),
      ),
    );
  }

  Widget cargrcalss(BuildContext context, MFProvider mf, ThemesProvider theme) {
    return InkWell(
      onTap: () async {
        Navigator.pushNamed(context, Routes.mfcagrcalss);
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minLeadingWidth: 25,
        dense: false,
        leading: SvgPicture.asset(
          'assets/icon/watchlistIcon/calc.svg',
          width: 25,
          height: 25,
        ),
        title: TextWidget.subText(
          // align: TextAlign.right,
          text: "CAGR Calculator",
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          textOverflow: TextOverflow.ellipsis,
          theme: theme.isDarkMode,
        ),
      ),
    );
  }

  Widget buildCollectionsTab(MFProvider mfData, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       TextWidget.titleText(
        //           align: TextAlign.right,
        //           text: "Collections",
        //           color: theme.isDarkMode
        //               ? colors.textPrimaryDark
        //               : colors.textPrimaryLight,
        //           textOverflow: TextOverflow.ellipsis,
        //           theme: theme.isDarkMode,
        //           fw: 1),
        //       const SizedBox(height: 10),
        //       TextWidget.paraText(
        //           align: TextAlign.right,
        //           text: "Find the right mutual fund across these asset classes",
        //           color: theme.isDarkMode
        //               ? colors.textSecondaryDark
        //               : colors.textSecondaryLight,
        //           textOverflow: TextOverflow.ellipsis,
        //           theme: theme.isDarkMode,
        //           fw: 3),
        //     ],
        //   ),
        // ),
        Column(
          children: [
            Builder(
              builder: (context) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, __) => const ListDivider(),
                      itemCount: mfData.bestMFListStaticnew?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        if (mfData.bestMFListStaticnew == null ||
                            index >= mfData.bestMFListStaticnew.length) {
                          return const SizedBox.shrink();
                        }

                        return InkWell(
                          onTap: () async {
                            mfData.changetitle(
                                mfData.bestMFListStaticnew[index]['title']);
                            Navigator.pushNamed(
                              context,
                              Routes.bestMfScreen,
                              arguments: mfData.bestMFListStaticnew[index]
                                  ['title'],
                            );
                          },
                          child: ListTile(
                            minLeadingWidth: 25,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            dense: false,
                            leading: SvgPicture.asset(
                              mfData.bestMFListStaticnew[index]['image'] ??
                                  'assets/explore/default.svg',
                              height: 30,
                              width: 30,
                            ),
                            title: TextWidget.subText(
                              text: mfData.bestMFListStaticnew[index]
                                      ['title'] ??
                                  '',
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              textOverflow: TextOverflow.ellipsis,
                              theme: theme.isDarkMode,
                            ),
                            subtitle: TextWidget.paraText(
                              text:
                                  "${mfData.bestMFListStaticnew[index]['subtitle'] ?? ''}",
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              maxLines: 2,
                              textOverflow: TextOverflow.ellipsis,
                              theme: theme.isDarkMode,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        )
      ],
    );
  }

  Widget buildCategoriesTab(MFProvider mfData, ThemesProvider theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.only(left: 16, top: 14, bottom: 8),
          //   child: TextWidget.titleText(
          //       align: TextAlign.right,
          //       text: "All Categories",
          //       color: theme.isDarkMode
          //           ? colors.textPrimaryDark
          //           : colors.textPrimaryLight,
          //       textOverflow: TextOverflow.ellipsis,
          //       theme: theme.isDarkMode,
          //       fw: 1),
          // ),
          ListView.separated(
            separatorBuilder: (_, __) => const ListDivider(),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return buildCategoryCard(
                  context: context,
                  dataIcon: mfData.mFCategoryTypesStatic[index]['dataIcon'],
                  title: mfData.mFCategoryTypesStatic[index]['title'],
                  description: mfData.mFCategoryTypesStatic[index]
                      ['description'],
                  chips: mfData.mFCategoryTypesStatic[index]['sub'],
                  mfData: mfData,
                  theme: theme);
            },
            itemCount: mfData.mFCategoryTypesStatic.length,
          ),
          
        ],
      ),
    );
  }
}










// LayoutBuilder(
//                         builder: (context, constraints) {
//                           return SizedBox(
//                             width: constraints.maxWidth,
//                             child: GridView.builder(
//                               shrinkWrap:
//                                   true, // Allow GridView to take only required space
//                               physics:
//                                   const NeverScrollableScrollPhysics(), // Disable GridView's scrolling
//                               gridDelegate:
//                                   SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: crossAxisCount,
//                                 crossAxisSpacing: screenWidth * 0.04,
//                                 mainAxisSpacing: screenHeight * 0.02,
//                                 childAspectRatio: childAspectRatio,
//                               ),
//                               itemCount: bestMFList?.length ?? 0,
//                               itemBuilder: (BuildContext context, int index) {
//                                 if (bestMFList == null ||
//                                     index >= bestMFList.length) {
//                                   return const SizedBox.shrink();
//                                 }

//                                 return GestureDetector(
//                                   onTap: () async {
//                                     mfData.changetitle(
//                                         bestMFList[index]['title']);
//                                     Navigator.pushNamed(
//                                       context,
//                                       Routes.bestMfScreen,
//                                       arguments: bestMFList[index]['title'],
//                                     );
//                                   },
//                                   child: Container(
//                                     height: 150,
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 16, horizontal: 16),
//                                     decoration: BoxDecoration(
//                                       color: theme.isDarkMode
//                                           ? const Color.fromARGB(255, 0, 0, 0)
//                                           : colors.colorWhite,
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start, 
//                                       children: [
//                                         SvgPicture.asset(
//                                           bestMFList[index]['image'] ??
//                                               'assets/explore/default.svg',
//                                           height: 50,
//                                           width: 60,
//                                         ),
//                                         const SizedBox(
//                                           height: 12,
//                                         ),
//                                         TextWidget.subText(
//                                             align: TextAlign.left,
//                                             text: bestMFList[index]['title'] ??
//                                                 '',
//                                             color: theme.isDarkMode
//                                                 ? colors.textPrimaryDark
//                                                 : colors.textPrimaryLight,
//                                             textOverflow: TextOverflow.ellipsis,
//                                             theme: theme.isDarkMode,
//                                             fw: 0),
//                                             const SizedBox(
//                                           height: 12,
//                                         ),
//                                         TextWidget.paraText(
//                                             align: TextAlign.left,
//                                             text:
//                                                 "${bestMFList[index]['subtitle'] ?? ''}",
//                                             color: theme.isDarkMode
//                                                 ? colors.textSecondaryDark
//                                                 : colors.textSecondaryLight,
//                                             maxLines: 2,
//                                             textOverflow: TextOverflow.ellipsis,
//                                             theme: theme.isDarkMode,
//                                             fw: 3),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           );
//                         },
//                       ),







//chips old ui

//  Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//            TextWidget.subText(
          //   align: TextAlign.right,
          //   text: title,
          //   color: theme.isDarkMode
          //       ? colors.textPrimaryDark
          //       : colors.textPrimaryLight,
          //   textOverflow: TextOverflow.ellipsis,
          //   theme: theme.isDarkMode,
          // ),
         
          // const SizedBox(height: 8),
         
          // const SizedBox(height: 8),
          // TextWidget.paraText(
          //     align: TextAlign.right,
          //     text: description,
          //     color: theme.isDarkMode
          //         ? colors.textSecondaryDark
          //         : colors.textSecondaryLight,
          //     textOverflow: TextOverflow.ellipsis,
          //     theme: theme.isDarkMode,
          //     fw: 3),
          // const SizedBox(height: 16),
          // SizedBox(
          //   height: 35, // Match your chip height
          //   child: ListView.separated(
          //     scrollDirection: Axis.horizontal,
          //     itemCount: chips.length,
          //     separatorBuilder: (context, index) => const SizedBox(width: 8),
          //     itemBuilder: (context, index) {
          //       final chipText = chips[index]?.toString() ?? "";
      
          //       return TextButton(
          //         onPressed: () async {
          //           mfData.fetchcatdatanew(title, chipText);
          //           mfData.changetitle(chipText);
          //           Navigator.pushNamed(
          //             context,
          //             Routes.mfCategoryList,
          //             arguments: title,
          //           );
          //           FocusScope.of(context).unfocus();
          //         },
          //         style: TextButton.styleFrom(
          //           padding: const EdgeInsets.symmetric(
          //               horizontal: 12, vertical: 0),
          //           backgroundColor: !theme.isDarkMode
          //               ? const Color(0xffF1F3F8)
          //               : colors.colorbluegrey,
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(4),
          //             side: BorderSide(
          //               color: colors.primaryLight,
          //               width: 1,
          //             ),
          //           ),
          //         ),
          //         child: TextWidget.paraText(
          //             align: TextAlign.right,
          //             text: chipText,
          //             color: theme.isDarkMode
          //                 ? colors.textPrimaryDark
          //                 : colors.textPrimaryLight,
          //             textOverflow: TextOverflow.ellipsis,
          //             theme: theme.isDarkMode,
          //             fw: 0),
          //       );
          //     },
          //   ),
          // )