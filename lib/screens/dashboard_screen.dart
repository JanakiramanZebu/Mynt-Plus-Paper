import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../res/res.dart';
import '../../provider/thems.dart';
import '../provider/stocks_provider.dart';
import '../res/global_state_text.dart';
import '../sharedWidget/custom_text_form_field.dart';
import '../utils/no_emoji_inputformatter.dart';
import 'stocks/explore/stocks/stock_screens.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    // Initialize TabController
    _tabController = TabController(
      length: 4, // Positions, Holdings, Orders, Funds
      vsync: this,
      initialIndex: 0,
    );

    setState(() {
      ref.read(stocksProvide).chngTradeAction("init");
      ref
          .read(stocksProvide)
          .requestWSTradeaction(isSubscribe: true, context: context);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      final stocks = ref.watch(stocksProvide);

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: false,
          title: Row(
            children: [
              // SvgPicture.asset(
              //   assets.myntnewLogo,
              //   width: 46,
              //   height: 46,
              // ),
              // const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: colors.searchBg,
                  ),
                  child: SizedBox(
                    height: 40,
                    child: TextFormField(
                      controller: searchController,
                      style: TextWidget.textStyle(
                        fontSize: 14,
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fw: 1,
                      ),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                        NoEmojiInputFormatter(),
                        FilteringTextInputFormatter.deny(
                            RegExp('[π£•₹€℅™∆√¶/.,]'))
                      ],
                      decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextWidget.textStyle(
                              fontSize: 14,
                              theme: theme.isDarkMode,
                              fw: 0,
                              color: colors.textSecondaryLight),
                          fillColor: colors.searchBg,
                          filled: true,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(assets.searchIcon,
                                color: colors.textPrimaryLight,
                                fit: BoxFit.scaleDown,
                                width: 20),
                          ),
                          suffixIcon: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.hardEdge,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              splashColor: theme.isDarkMode
                                  ? colors.splashColorDark
                                  : colors.splashColorLight,
                              highlightColor: theme.isDarkMode
                                  ? colors.highlightDark
                                  : colors.highlightLight,
                              onTap: () async {
                                // Future.delayed(const Duration(milliseconds: 150), () {
                                searchController.clear();
                                FocusScope.of(context).unfocus();
                                //   if (positionBook.positionSearchCtrl.text.isEmpty) {
                                //     positionBook.showPositionSearch(false);
                                //   }
                                // });
                              },
                              child: SvgPicture.asset(assets.removeIcon,
                                  fit: BoxFit.scaleDown, width: 20),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20)),
                          disabledBorder: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20))),
                      onChanged: (value) {
                        // if (value.isNotEmpty) {
                        //   // positionBook.showPositionSearch(false);
                        // } else {
                        //   positionBook.showPositionSearch(false);
                        // }

                        // positionBook.positionSearch(value, context);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: TabBar(
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
                tabs: List.generate(stocks.exploreTabName.length, (index) {
                  return AnimatedBuilder(
                    animation: _tabController.animation!,
                    builder: (context, child) {
                      final isSelected = _tabController.index == index;
                      final animationValue = _tabController.animation!.value;
                      final isTransitioning =
                          (animationValue - index).abs() < 1;

                      final color = isTransitioning
                          ? Color.lerp(
                              theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              theme.isDarkMode
                                  ? colors.secondaryDark
                                  : colors.secondaryLight,
                              1 - (animationValue - index).abs())
                          : isSelected
                              ? theme.isDarkMode
                                  ? colors.secondaryDark
                                  : colors.secondaryLight
                              : theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight;

                      return Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextWidget.subText(
                              text: stocks.exploreTabName[index].text ?? "",
                              theme: false,
                              color: color,
                              fw: isSelected ? 2 : null,
                            ),
                            // const SizedBox(width: 5),
                            // if ((index == 0 &&
                            //         portfolio
                            //             .allPostionList.isNotEmpty) ||
                            //     (index == 1 &&
                            //         (portfolio
                            //                 .holdingsModel?.isNotEmpty ??
                            //             false)))
                            //   Container(
                            //     padding: const EdgeInsets.symmetric(
                            //         horizontal: 6, vertical: 2),
                            //     decoration: BoxDecoration(
                            //       color: ((index == 0 &&
                            //                   portfolio.allPostionList
                            //                       .isNotEmpty) ||
                            //               (index == 1 &&
                            //                   (portfolio.holdingsModel
                            //                           ?.isNotEmpty ??
                            //                       false)))
                            //           ? colors.btnBg
                            //           : null,
                            //       borderRadius: BorderRadius.circular(4),
                            //     ),
                            //     child: TextWidget.subText(
                            //       text: index == 0
                            //           ? (portfolio
                            //                   .allPostionList.isNotEmpty
                            //               ? "${portfolio.allPostionList.length}"
                            //               : "")
                            //           : index == 1
                            //               ? (portfolio.holdingsModel
                            //                           ?.isNotEmpty ??
                            //                       false
                            //                   ? "${portfolio.holdingsModel!.length}"
                            //                   : "")
                            //               : "",
                            //       theme: false,
                            //       color: color,
                            //       fw: isSelected ? 2 : null,
                            //     ),
                            //   ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            StockScreen(),
            Center(child: Text('Holdings')),
            Center(child: Text('Orders')),
            Center(child: Text('Funds')),
          ],
        ),
      );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  }
}
