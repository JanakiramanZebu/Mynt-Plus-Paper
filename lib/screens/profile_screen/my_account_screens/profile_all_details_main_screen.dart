import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/screens/profile_screen/my_account_screens/profile_details_bank_screen.dart';
// import 'package:mynt_plus/screens/profile_screen/my_account_screens/profile_details_nominee_screen.dart';
import 'package:mynt_plus/screens/profile_screen/my_account_screens/profile_details_screen.dart';
import '../../../res/res.dart';

class ProfileDetailsMainScreen extends StatefulWidget {
  const ProfileDetailsMainScreen({super.key});

  @override
  State<ProfileDetailsMainScreen> createState() =>
      _ProfileDetailsMainScreenState();
}

class _ProfileDetailsMainScreenState extends State<ProfileDetailsMainScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final tablistitems = [
    {
      "Aimgpath": "",
      "imgpath": assets.exportIcon,
      "title": "Profile",
      "index": 0,
    },
    {
      "Aimgpath": "",
      "imgpath": assets.bookmarkLineIcon,
      "title": "Bank",
      "index": 1,
    },
    // {
    //   "Aimgpath": "",
    //   "imgpath": assets.bag,
    //   "title": "Nominee",
    //   "index": 2,
    // }
  ];
  int activeTab = 0;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = watch(themeProvider);
      
      return Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
           leading: Padding(
             padding: const EdgeInsets.only(left:8.0),
             child: IconButton(
                 icon: Icon(Icons.arrow_back_ios, color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack), 
                 onPressed: () {
             
                  Navigator.pop(context);
                 },
               ),
           ),
          elevation: 0,
            leadingWidth: 41,
            centerTitle: false,
            titleSpacing: 6,
            // leading: const CustomBackBtn(),
            shadowColor: const Color(0xffECEFF3),
             title: TextWidget.headText(text: 'My Account',theme: theme.isDarkMode,fw: 2) ,
              
              // textStyles.appBarTitleTxt.copyWith(
              //   fontSize: 17,
              //   fontWeight: FontWeight.bold,
              //   color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              // ),
        
  //           actions: [
  //   IconButton(
  //     icon: Icon(Icons.search, color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
  //     onPressed: () {
  //         //  Navigator.pushNamed(context, Routes.mfsearchscreen);
 
  //     },
  //   ),
  // ],
      
        ),
         

        // appBar: AppBar(
        //   automaticallyImplyLeading: false,
        //   elevation: 0,
        //   centerTitle: false,
        //   title: Row(
        //     children: [
        //       SvgPicture.asset(
        //        assets.myntnewLogo,
        //       width: 46,
        //       height: 46,
        //       ),

        //     ],
        //   ),
        // ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const CustomDragHandler(),
              Container(
                // width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                // decoration: BoxDecoration(
                //     border: Border(
                //         top: BorderSide(
                //             color: theme.isDarkMode
                //                 ? colors.darkColorDivider
                //                 : colors.colorDivider,
                //             width: 0.4),
                //         bottom: BorderSide(
                //             color: theme.isDarkMode
                //                 ? colors.darkColorDivider
                //                 : colors.colorDivider,
                //             width: 0.4))),
                // height: 60,
                child: TabBar(
                  labelPadding:const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  // padding : EdgeInsets.symmetric(horizontal: 8),
                  tabAlignment: TabAlignment.start,
                  indicatorColor: Colors.transparent,
                  controller: _tabController,
                  isScrollable: true,
                  tabs: List.generate(
                    tablistitems.length,
                    (tab) => tabConstruce(
                        tablistitems[tab]['imgpath'].toString(),
                        tablistitems[tab]['title'].toString(),
                        theme,
                        tab,
                        () {}),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: const [
                    ProfileInfoDetails(),
                    ProfileDetailsBank(),
                    //  ProfileDetailsNominee()
                  ],
                ),
              ),
            ],
          ),
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   elevation: 0,
        //   // foregroundColor: customizations[index].$1,
        //   backgroundColor: Colors.black.withOpacity(0.2),
        //   child: const Icon(
        //     Icons.arrow_back_rounded,
        //     color: Colors.black,
        //     weight: 10,
        //   ),
        // )
      );
    });
  }

  Widget tabConstruce(String icon, String title, ThemesProvider theme, int tab,
      VoidCallback onPressed) {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            activeTab = tab;
          });
          _tabController.animateTo(tab);
          print("object act tab $tab");
        },
        style: ElevatedButton.styleFrom(
            elevation: 0,
            // padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            backgroundColor: theme.isDarkMode
                ? tab == activeTab
                    ? const Color(0xffffffff)
                    : const Color(0xff000000)
                : tab == activeTab
                    ? const Color(0xff000000)
                    : const Color(0xffffffff),
            shape: const StadiumBorder(),
            side: BorderSide(
                              width: 1,
                              color: context.read(themeProvider).isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                            ),),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SvgPicture.asset(
              //   icon,
              //   color: theme.isDarkMode
              //       ? Color(tab == activeTab ? 0xff000000 : 0xffffffff)
              //       : Color(tab == activeTab ? 0xffffffff : 0xff000000),
              // ),
              // const SizedBox(width: 8),
              TextWidget.titleText(text:title,theme: theme.isDarkMode,
              color: theme.isDarkMode
                          ? Color(tab == activeTab ? 0xff000000 : 0xffffffff)
                          : Color(tab == activeTab ? 0xffffffff : 0xff000000),
              fw: 1),
              // Text(title,
              //     style: textStyle(
              //         theme.isDarkMode
              //             ? Color(tab == activeTab ? 0xff000000 : 0xffffffff)
              //             : Color(tab == activeTab ? 0xffffffff : 0xff000000),
              //         14,
              //         FontWeight.w500))
            ]));
  }

  // TextStyle textStyle(Color color, double fontSize, fWeight) {
  //   return GoogleFonts.inter(
  //       textStyle:
  //           TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  // }
}
