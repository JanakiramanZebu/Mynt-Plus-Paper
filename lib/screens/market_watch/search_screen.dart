 
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../provider/market_watch_provider.dart';
import '../../provider/network_state_provider.dart'; 
import '../../provider/thems.dart';
import '../../res/res.dart'; 
import '../../sharedWidget/custom_text_form_field.dart';
import '../../sharedWidget/no_internet_widget.dart';
import 'search_scrip_list.dart';

class SearchScreen extends StatefulWidget {
  final String wlName;
  const SearchScreen({super.key, required this.wlName});

  @override
  State<SearchScreen> createState() => _AddScripState();
}

class _AddScripState extends State<SearchScreen> with TickerProviderStateMixin {
  late TabController tabCtrl;
  
 
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read(marketWatchProvider).setpageName("edit");
    });
    // context.read(networkStateProvider).networkStream();
    tabCtrl =
        TabController(length:   context.read(marketWatchProvider).searchTabList.length, vsync: this, initialIndex: 0);

    
    super.initState();
  }

  TextEditingController textCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final searchScrip = watch(marketWatchProvider);
      final internet = watch(networkStateProvider);   final theme = context.read(themeProvider);
      return WillPopScope(
        onWillPop: () async {  context
                .read(marketWatchProvider)
                .requestMWScrip(context: context, isSubscribe: true);
          await searchScrip.searchClear();
          searchScrip.setpageName("");
      
          return true;
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
               context
                .read(marketWatchProvider)
                .requestMWScrip(context: context, isSubscribe: true);
                  searchScrip.searchClear();
                  searchScrip.setpageName("");
                  Navigator.pop(context);
                 
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: SvgPicture.asset(assets.backArrow ,color:theme.isDarkMode?colors.colorWhite:colors.colorBlack),
                ),
              ),
            
              title: Container(
                height: 40,
                padding: const EdgeInsets.only(right: 14.0),  
                child:   TextFormField(
                    controller: textCtrl,
                    style:
                       textStyle(
                           theme.isDarkMode?colors.colorWhite:colors.colorBlack, 15, FontWeight.w500),
                    inputFormatters: [UpperCaseTextFormatter()],
                    decoration: InputDecoration(
                        fillColor: theme.isDarkMode? const Color(0xffB5C0CF).withOpacity(.15): const Color(0xffF1F3F8),
                        filled: true,
                       
                        hintStyle:   textStyle(
                           theme.isDarkMode?colors.colorWhite:colors.colorBlack, 15, FontWeight.w500),
                        prefixIconColor: const Color(0xff586279),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: SvgPicture.asset(assets.searchIcon,
                              color: const Color(0xff586279),
                              fit: BoxFit.contain,
                              width: 20),
                        ),
                        suffixIcon: InkWell(
                          onTap: () async {
                            textCtrl.clear();
                            await searchScrip.searchClear();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                        contentPadding: const EdgeInsets.only(top: 20),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30))),
                    onChanged: (value) async {
                      if (value.isEmpty) {
                        searchScrip.searchClear();
                      }
                      if (internet.connectionStatus != ConnectivityResult.none) {
                        searchScrip.scripSearch(value, context);
                      }
                
                      // searchScrip.filterScrip(value);
                    },
                  ),
                
              ),
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                     Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.only(bottom: 6,left: 14),
                        decoration:   BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: theme.isDarkMode?colors.darkColorDivider: colors.colorDivider,width: 0))),
                        height: 40,
                        child: TabBar(
                            isScrollable: true,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorColor: colors.colorBlack,
                            indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: theme.isDarkMode? colors.colorWhite: colors.colorBlack),
                            unselectedLabelColor: colors.colorGrey,
                            unselectedLabelStyle: GoogleFonts.inter(
                                textStyle: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500)),
                            labelColor:theme.isDarkMode?colors.colorBlack: colors.colorWhite,
                            labelStyle: GoogleFonts.inter(
                                textStyle: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                            controller: tabCtrl,
                            tabs:   context.read(marketWatchProvider).searchTabList),
                       
                    ),
                    Expanded(
                        child: TabBarView(controller: tabCtrl, children: [
                      SearchScripList(
                          wlName: widget.wlName,
                          searchValue: searchScrip.allSearchScrip!),
                      SearchScripList(
                          wlName: widget.wlName,
                          searchValue: searchScrip.equitySearchScrip!),
                      SearchScripList(
                          wlName: widget.wlName,
                          searchValue: searchScrip.fNoSearchScrip!),
                      SearchScripList(
                          wlName: widget.wlName,
                          searchValue: searchScrip.currencySearchScrip!),
                      SearchScripList(
                          wlName: widget.wlName,
                          searchValue: searchScrip.commoditySearchScrip!),
                    ]))
                  ],
                ),
                if (internet.connectionStatus == ConnectivityResult.none) ...[
                  const NoInternetWidget()
                ]
              ],
            ),
          ),
        ),
      );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle: TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize
    ));
  }
}
