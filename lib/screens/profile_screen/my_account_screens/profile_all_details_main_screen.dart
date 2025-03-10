import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/screens/profile_screen/my_account_screens/profile_details_bank_screen.dart';
// import 'package:mynt_plus/screens/profile_screen/my_account_screens/profile_details_nominee_screen.dart';
import 'package:mynt_plus/screens/profile_screen/my_account_screens/profile_details_screen.dart';
import '../../../res/res.dart';


class ProfileDetailsMainScreen extends StatefulWidget {
  const ProfileDetailsMainScreen({super.key});

  @override
  State<ProfileDetailsMainScreen> createState() => _ProfileDetailsMainScreenState();
}

class _ProfileDetailsMainScreenState extends State<ProfileDetailsMainScreen> with TickerProviderStateMixin{
 
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
            backgroundColor:
                theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            centerTitle: false,
            elevation: 0,
            leadingWidth: 41,
            titleSpacing: 6,
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child:  Icon(
                    Icons.arrow_back_ios,
                    color:theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                    size: 17,
                  ),
              ),
            ),
            title: Text('My Account',
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    15,
                    FontWeight.w600)),
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
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(bottom: 0, left: 14, top: 2),
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                              width: 0.4),
                          bottom: BorderSide(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                              width: 0.4))),
                  // height: 60,
                  child: TabBar(
                      labelPadding: const EdgeInsets.only(right: 16, bottom: 0),
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
                              () {}),),),),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            backgroundColor: theme.isDarkMode
                ? tab == activeTab
                    ? colors.colorbluegrey
                    : const Color(0xffB5C0CF).withOpacity(.15)
                : tab == activeTab
                    ? const Color(0xff000000)
                    : const Color(0xffF1F3F8),
            shape: const StadiumBorder()),
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
              Text(title,
                  style: textStyle(
                      theme.isDarkMode
                          ? Color(tab == activeTab ? 0xff000000 : 0xffffffff)
                          : Color(tab == activeTab ? 0xffffffff : 0xff000000),
                      14,
                      FontWeight.w500))
            ]));
  }


  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
