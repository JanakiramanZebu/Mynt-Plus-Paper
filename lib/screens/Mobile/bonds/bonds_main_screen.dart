import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/screens/Mobile/bonds/bonds_explore_screens.dart';
import '../../../../res/res.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../utils/no_emoji_inputformatter.dart';

class BondsScreen extends ConsumerStatefulWidget {
  final int? initialTabIndex;
  final bool isBonds;
  const BondsScreen({super.key, this.initialTabIndex, required this.isBonds});

  @override
  ConsumerState<BondsScreen> createState() => _BondsmainScreenState();
}

class _BondsmainScreenState extends ConsumerState<BondsScreen> {
  // Static constants for better performance
  static const double _iconSize = 22.0;
  static const double _searchBarHeight = 45.0;
  static const double _searchBarBorderRadius = 25.0;
  static const double _searchBarFontSize = 14.0;

  int? initialTabIndex;

  @override
  void initState() {
    super.initState();

    // Check for navigation arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is int) {
        setState(() {
          initialTabIndex = args;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final bonds = ref.watch(bondsProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: widget.isBonds ? _buildAppBar(context, theme, bonds) : null,
          body: BondsExploreScreens(theme: theme, initialTabIndex: initialTabIndex),
        ),
      ),
    );
  }

  AppBar _buildAppBar(
      BuildContext context, ThemesProvider theme, BondsProvider bonds) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      leadingWidth: 48,
      centerTitle: false,
      titleSpacing: 0,
      leading: const CustomBackBtn(),
      title: TextWidget.titleText(
          text: "Bonds",
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: _buildSearchBar(context, theme, bonds),
      ),
    );
  }

  Widget _buildSearchBar(
      BuildContext context, ThemesProvider theme, BondsProvider bonds) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextFormField(
                controller: bonds.bondscommonsearchcontroller,
               style: TextWidget.textStyle(
                  fontSize: 16,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  theme: theme.isDarkMode,
                ),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  NoEmojiInputFormatter(),
                  FilteringTextInputFormatter.deny(RegExp('[π£•₹€℅™∆√¶/.,]'))
                ],
                decoration: InputDecoration(
                    hintText: "Search Bonds",
                   hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                     color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                                    ),
                  fillColor: theme.isDarkMode
                        ? colors.searchBgDark
                        : colors.searchBg,
                    filled: true,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(assets.searchIcon,
                       color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                          fit: BoxFit.scaleDown,
                          width: 20),
                    ),
                    suffixIcon:
                        bonds.bondscommonsearchcontroller.text.isNotEmpty
                            ? Material(
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
                                    bonds.clearCommonBondsSearch();
                                    Future.delayed(
                                        const Duration(milliseconds: 150), () {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                    });
                                  },
                                  child: SvgPicture.asset(assets.removeIcon,
                                      fit: BoxFit.scaleDown, width: 20,   color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,),
                                ),
                              )
                            : const SizedBox.shrink(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20)),
                    disabledBorder: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20))),
                onChanged: (value) {
                  bonds.searchCommonBonds(value, context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

// NestedScrollView(
//                 headerSliverBuilder:
//                     (BuildContext context, bool innerBoxIsScrolled) {
//                   return [
//                     SliverAppBar(
//                       automaticallyImplyLeading: false,
//                       expandedHeight: 260,
//                       floating: false,
//                       pinned: false,
//                       flexibleSpace: FlexibleSpaceBar(
//                           background: Container(
//                               padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
//                               decoration: BoxDecoration(
//                                   color: const Color(0xffFAFBFF),
//                                   borderRadius: BorderRadius.circular(0)),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.only(
//                                         top: 6, bottom: 12, left: 20),
//                                     decoration: BoxDecoration(
//                                         gradient: LinearGradient(
//                                           colors: [
//                                             const Color(0xFF148564).withOpacity(
//                                                 1.0), // #834EDA at 0% (100% opacity)
//                                             const Color(0xFF148564).withOpacity(
//                                                 0.5), // #834EDA at 100% (50% opacity)
//                                           ],
//                                           begin: Alignment.topCenter,
//                                           end: Alignment.bottomCenter,
//                                         ),
//                                         borderRadius:
//                                             BorderRadius.circular(16)),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const SizedBox(height: 12),
//                                         ListTile(
//                                           contentPadding: EdgeInsets.all(0),
//                                           title: Text("Invest in Bonds",
//                                               style: GoogleFonts.inter(
//                                                   textStyle: textStyle(
//                                                       const Color(0xffFEFDFD),
//                                                       22,
//                                                       FontWeight.w700))),
//                                           subtitle: Column(
//                                             children: [
//                                               const SizedBox(height: 6),
//                                               Text(
//                                                   "Handpicked bonds from our experts that meet your investment needs.",
//                                                   style: GoogleFonts.inter(
//                                                       textStyle: textStyle(
//                                                           const Color.fromARGB(
//                                                               255,
//                                                               246,
//                                                               242,
//                                                               255),
//                                                           14,
//                                                           FontWeight.w500))),
//                                             ],
//                                           ),
//                                         ),
//                                         const SizedBox(height: 10),
//                                         ElevatedButton(
//                                           onPressed: () {
//                                             // Add your button functionality here
//                                           },
//                                           style: ElevatedButton.styleFrom(
//                                             elevation: 0,
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 22, vertical: 0),
//                                             backgroundColor: theme.isDarkMode
//                                                 ? colors.colorWhite
//                                                 : colors.colorBlack,
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(50),
//                                             ),
//                                           ),
//                                           child: Text(
//                                             "Invest in Bonds",
//                                             style: TextStyle(
//                                               color: theme.isDarkMode
//                                                   ? colors.colorBlack
//                                                   : colors.colorWhite,
//                                               fontWeight: FontWeight.w700,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(height: 13),
//                                   Center(
//                                     child: ElevatedButton(
//                                       onPressed: () async {
//                                     Future.delayed(const Duration(microseconds: 100),
//                                           () async {
//                                         await context
//                                             .read(bondsProvider)
//                                             .fetchBondsOrderBook();
//                                       });
}
//                                         Navigator.pushNamed(
//                                             context, Routes.bondsorderbook);
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         padding: const EdgeInsets.symmetric(
//                                             vertical: 5),
//                                         backgroundColor: Colors.white,
//                                         elevation: 0,
//                                         side: const BorderSide(
//                                             color: Color(0xFF87A1DD),
//                                             width: 1.5),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(24),
//                                         ),
//                                       ),
//                                       child: Row(
//                                         mainAxisSize: MainAxisSize.max,
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           SvgPicture.asset(
//                                             'assets/explore/firefox.svg',
//                                             width: 16,
//                                             height: 16,
//                                           ),
//                                           const SizedBox(width: 8),
//                                           const Text(
//                                             "View my bids",
//                                             style: TextStyle(
//                                                 color: Color(0xFF4069C9),
//                                                 fontWeight: FontWeight.w600,
//                                                 fontSize: 14),
//                                           ),
//                                           const Icon(
//                                             Icons.expand_more,
//                                             color: Color(0xFF4069C9),
//                                             size: 28,
//                                             weight: 7,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ))),
//                     ),
//                   ];
//                 },
