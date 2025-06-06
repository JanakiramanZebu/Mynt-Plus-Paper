import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
import '../../../provider/market_watch_provider.dart';
import '../../provider/network_state_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/app_routes.dart';
import '../../sharedWidget/custom_text_form_field.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/no_internet_widget.dart';
import '../../utils/no_emoji_inputformatter.dart';
import 'search_scrip_list.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String wlName;
  final String isBasket;
  const SearchScreen({super.key, required this.wlName, required this.isBasket});

  @override
  ConsumerState<SearchScreen> createState() => _AddScripState();
}

class _AddScripState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  late TabController tabCtrl;
  String _searchvalue = "";
  int tabcount = 5;

  @override
  void initState() {
    tabcount = widget.isBasket == "Basket" ? 5 : 6;
    tabCtrl = TabController(length: tabcount, vsync: this, initialIndex: 0);
    super.initState();

    tabCtrl.addListener(() {
      if (tabCtrl.indexIsChanging) {
        ref.read(marketWatchProvider).searchClear();
        ref
            .read(marketWatchProvider)
            .scripSearch(_searchvalue, context, tabCtrl.index, widget.isBasket);
      }
    });
  }

  TextEditingController textCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final searchScrip = ref.watch(marketWatchProvider);
      final internet = ref.watch(networkStateProvider);
      final theme = ref.read(themeProvider);
      return PopScope(
          canPop: true, // Allows back navigation
          onPopInvokedWithResult: (didPop, result) async {
            // if (didPop) return; // If system handled back, do nothing

            if (!(["Option||Is", "Chart||Is"].contains(widget.isBasket))) {
              ref
                  .read(marketWatchProvider)
                  .requestMWScrip(context: context, isSubscribe: true);
            }
            await searchScrip.searchClear();
            currentRouteName = 'homeScreen';
            // Navigator.pop(context);
          },
          child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
              child: Scaffold(
                  appBar: AppBar(
                      elevation: 0,
                      leadingWidth: 41,
                      titleSpacing: 3,
                      leading: InkWell(
                          onTap: () {
                            if (!(["Option||Is", "Chart||Is"]
                                .contains(widget.isBasket))) {
                              ref.read(marketWatchProvider).requestMWScrip(
                                  context: context, isSubscribe: true);
                            }
                            searchScrip.searchClear();
                            searchScrip.setpageName("");
                            currentRouteName = 'homeScreen';
                            Navigator.pop(context);
                          },
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 9),
                              child: SvgPicture.asset(assets.backArrow,
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack))),
                      title: Container(
                          height: 40,
                          padding: const EdgeInsets.only(right: 14.0),
                          child: TextFormField(
                              autofocus: true,
                              controller: textCtrl,
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  15,
                                  FontWeight.w500),
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                UpperCaseTextFormatter(),
                                NoEmojiInputFormatter(),
                                FilteringTextInputFormatter.deny(
                                    RegExp('[π£•₹€℅™∆√¶/.,]'))
                              ],
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  fillColor: theme.isDarkMode
                                      ? const Color(0xffB5C0CF).withOpacity(.15)
                                      : const Color(0xffF1F3F8),
                                  filled: true,
                                  hintStyle: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      15,
                                      FontWeight.w500),
                                  prefixIconColor: const Color(0xff586279),
                                  prefixIcon: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: SvgPicture.asset(assets.searchIcon,
                                          color: const Color(0xff586279),
                                          fit: BoxFit.contain,
                                          width: 20)),
                                  suffixIcon: InkWell(
                                    onTap: () async {
                                      textCtrl.clear();
                                      await searchScrip.searchClear();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: SvgPicture.asset(assets.removeIcon,
                                          fit: BoxFit.scaleDown, width: 20),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(30)),
                                  disabledBorder: InputBorder.none,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(30)),
                                  hintText: "Search Scrip Name",
                                  contentPadding:
                                      const EdgeInsets.only(top: 20),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(30))),
                              onChanged: (value) async {
                                _searchvalue = value;
                                if (value.isEmpty) {
                                  searchScrip.searchClear();
                                }
                                if (internet.connectionStatus !=
                                    ConnectivityResult.none) {
                                  searchScrip.scripSearch(value, context,
                                      tabCtrl.index, widget.isBasket);
                                }
                              }))),
                  body: Stack(children: [
                    Column(children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.only(bottom: 6, left: 14),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.darkColorDivider
                                          : colors.colorDivider,
                                      width: 0))),
                          height: 40,
                          child: TabBar(
                              isScrollable: true,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicatorColor: colors.colorBlack,
                              indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: theme.isDarkMode
                                      ? colors.colorbluegrey
                                      : colors.colorBlack),
                              unselectedLabelColor: colors.colorGrey,
                              unselectedLabelStyle: GoogleFonts.inter(
                                  textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              labelColor: theme.isDarkMode
                                  ? colors.colorBlack
                                  : colors.colorWhite,
                              labelStyle: GoogleFonts.inter(
                                  textStyle: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                              controller: tabCtrl,
                              tabs: ref
                                  .read(marketWatchProvider)
                                  .searchTabList
                                  .sublist(0, tabcount))),
                      Expanded(
                        child:
                            // TabBarView(controller: tabCtrl, children: [
                            SearchScripList(
                                wlName: widget.wlName,
                                searchValue: searchScrip.allSearchScrip!,
                                isBasket: widget.isBasket),
                        // SearchScripList(
                        //     wlName: widget.wlName,
                        //     searchValue: searchScrip.allSearchScrip!,
                        //     isBasket: widget.isBasket),
                        // SearchScripList(
                        //     wlName: widget.wlName,
                        //     searchValue: searchScrip.allSearchScrip!,
                        //     isBasket: widget.isBasket),
                        // SearchScripList(
                        //     wlName: widget.wlName,
                        //     searchValue: searchScrip.allSearchScrip!,
                        //     isBasket: widget.isBasket),
                        // SearchScripList(
                        //     wlName: widget.wlName,
                        //     searchValue: searchScrip.allSearchScrip!,
                        //     isBasket: widget.isBasket),
                        // SearchScripList(
                        //     wlName: widget.wlName,
                        //     searchValue: searchScrip.allSearchScrip!,
                        //     isBasket: widget.isBasket),
                        // ])
                      )
                    ]),
                    if (internet.connectionStatus ==
                        ConnectivityResult.none) ...[const NoInternetWidget()]
                  ]))));
    });
  }
}
