import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/thems.dart';
import '../../provider/mf_provider.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/functions.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MutualFundNewScreen extends ConsumerWidget {
  final TabController tabController;
  const MutualFundNewScreen({super.key, required this.tabController});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mfData = ref.watch(mfProvider);
    final theme = ref.watch(themeProvider);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: theme.isDarkMode
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE0E0E0),
                    width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  child: Skeletonizer(
                    enabled: mfData.holdstatload ?? false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Purchase ",
                                  style: TextStyle(
                                    color: theme.isDarkMode
                                        ? const Color(0xFF666666)
                                        : const Color(0xFF666666),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${(mfData.mfholdingnew?.purchaseValue == "" || mfData.mfholdingnew?.purchaseValue == null) ? "0.00" : mfData.mfholdingnew?.purchaseValue}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: theme.isDarkMode
                                        ? const Color.fromARGB(255, 255, 255, 255)
                                        : const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "Gain / Loss",
                                  style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${(mfData.mfholdingnew?.gainOrLoss == "" || mfData.mfholdingnew?.gainOrLoss == null) ? "0.00" : mfData.mfholdingnew?.gainOrLoss}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: (double.tryParse(mfData.mfholdingnew
                                                        ?.gainOrLoss ??
                                                    "0") ??
                                                0) >=
                                            0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Current",
                                  style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${(mfData.mfholdingnew?.currentValue == "" || mfData.mfholdingnew?.currentValue == null) ? "0.00" : mfData.mfholdingnew?.currentValue}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: theme.isDarkMode
                                        ? const Color.fromARGB(
                                            255, 255, 255, 255)
                                        : const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "Abs Returns %",
                                  style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${mfData.mfholdingnew?.percentage?.toString() ?? "0"}%", // Ensures percentage is always a valid string
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: (double.tryParse(mfData.mfholdingnew
                                                        ?.percentage
                                                        ?.toString() ??
                                                    "0") ??
                                                0) >=
                                            0
                                        ? Colors.green
                                        : const Color(
                                            0xFFFF1717), // Red color for negative values
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          buildSlidingPanelContent(mfData.bestMFListStaticnew, mfData, theme),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.only(left: 16, top: 10, bottom: 0),
            child: Text(
              "Quick Access",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: theme.isDarkMode
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              
              children: [
                nfoCard(context, mfData, theme),
              ],
            ),
          ),

         Padding(
           padding: const EdgeInsets.all(0.0),
           child: Row(
             children: [
               Expanded(
                 child: sipcaltor(context, mfData, theme),
               ),
               Expanded(
                 child: cargrcalss(context, mfData, theme),
               ),
             ],
           ),
         ),


          Container(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 10, bottom: 8),
                  child: Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color:
                          theme.isDarkMode ? Colors.white : const Color(0xFF181B19),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return buildCategoryCard(
                          context: context,
                          dataIcon: mfData.mFCategoryTypesStatic[index]
                              ['dataIcon'],
                          title: mfData.mFCategoryTypesStatic[index]['title'],
                          description: mfData.mFCategoryTypesStatic[index]
                              ['description'],
                          chips: mfData.mFCategoryTypesStatic[index]['sub'],
                          mfData: mfData,
                          theme: theme);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 20);
                    },
                    itemCount: mfData.mFCategoryTypesStatic.length,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
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

  Widget buildSlidingPanelContent(bestMFList, MFProvider mfData, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color:
          theme.isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF1F3F8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Collections",
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: theme.isDarkMode ? Colors.white : const Color(0xFF181B19)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Find the right mutual fund across these asset classes",
            style: TextStyle(
                color: theme.isDarkMode ? Colors.white : const Color(0xFF666666),
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            child: Column(
              children: [
                Builder(
                  builder: (context) {
                    double screenWidth = MediaQuery.of(context).size.width;
                    double screenHeight = MediaQuery.of(context).size.height;

                    int crossAxisCount = screenWidth > 600 ? 3 : 2;
                    double childAspectRatio =
                        screenWidth / (screenHeight / 2.0);

                    return Padding(
                      padding: const EdgeInsets.all(0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SizedBox(
                            width: constraints.maxWidth,
                            child: GridView.builder(
                              shrinkWrap:
                                  true, // Allow GridView to take only required space
                              physics:
                                  const NeverScrollableScrollPhysics(), // Disable GridView's scrolling
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: screenWidth * 0.04,
                                mainAxisSpacing: screenHeight * 0.02,
                                childAspectRatio: childAspectRatio,
                              ),
                              itemCount: bestMFList?.length ?? 0,
                              itemBuilder: (BuildContext context, int index) {
                                if (bestMFList == null || index >= bestMFList.length) {
                                  return const SizedBox.shrink();
                                }
                                
                                return GestureDetector(
                                  onTap: () async {
                                    mfData.changetitle(
                                        bestMFList[index]['title']);
                                    Navigator.pushNamed(
                                      context,
                                      Routes.bestMfScreen,
                                      arguments: bestMFList[index]['title'],
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: theme.isDarkMode
                                          ? const Color.fromARGB(255, 0, 0, 0)
                                          : colors.colorWhite,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SvgPicture.asset(
                                          bestMFList[index]['image'] ?? 'assets/explore/default.svg',
                                          height: 50,
                                          width: 60,
                                        ),
                                        Text(
                                          bestMFList[index]['title'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? Colors.white
                                                  : colors.colorBlack,
                                              19,
                                              FontWeight.w600),
                                        ),
                                        Text(
                                          "${bestMFList[index]['subtitle'] ?? ''}",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: textStyle(
                                              const Color(0xff666666),
                                              14,
                                              FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
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

  Widget buildCategoryCard({
      required String? dataIcon,
      required BuildContext context,
      required String? title,
      required String? description,
      required List<dynamic>? chips,
      required MFProvider mfData,
      required ThemesProvider theme}) {
    
    if (dataIcon == null || title == null || description == null || chips == null) {
      return const SizedBox.shrink();
    }
    
    return InkWell(
      onTap: () async {
        if (chips.isNotEmpty) {
          final firstChip = chips[0]?.toString() ?? "";
          mfData.fetchcatdatanew(title, firstChip);
          mfData.changetitle(firstChip);
          Navigator.pushNamed(context, Routes.mfCategoryList, arguments: title);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.isDarkMode
              ? const Color.fromARGB(255, 0, 0, 0)
              : Colors.white,
          border: Border.all(
            color:
                theme.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFDDDDDD),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              dataIcon,
              width: 40,
              height: 40,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 19,
                color: theme.isDarkMode
                    ? Colors.white
                    : const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                  color: Color(0xff666666),
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 34,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                itemBuilder: (context, index) {
                  final chipText = chips[index]?.toString() ?? "";
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () async {
                        mfData.fetchcatdatanew(title, chipText);
                        mfData.changetitle(chipText);
                        Navigator.pushNamed(context, Routes.mfCategoryList,
                            arguments: title);
                      },
                      child: Chip(
                        label: Text(
                          chipText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.isDarkMode
                                ? Colors.white
                                : const Color.fromARGB(255, 0, 0, 0),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        shape: const StadiumBorder(),
                        backgroundColor: theme.isDarkMode
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2.0, vertical: 2.0),
                        side: BorderSide(
                          color: theme.isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFF666666),
                          width: 1.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: theme.isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey.shade300,
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
                    const Padding(
                      padding: EdgeInsets.only(bottom: 0),
                      child: Text(
                        "INVEST IN",
                        style: TextStyle(
                          color: Color(0xFF0037B7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "New Fund Offer (NFO)",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: theme.isDarkMode ? Colors.white : Colors.black,
                      ),
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
            const SizedBox(height: 10),
            const Text(
              "A new fund offer (NFO) is the first subscription for any new fund by an investment company.",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Text(
                  "See all NFOs",
                  style: TextStyle(
                    color: Color(0xFF0037B7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF0037B7),
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

Widget sipcaltor(BuildContext context, MFProvider mf, ThemesProvider theme) {
  return GestureDetector(
    onTap: () async {
      Navigator.pushNamed(context, Routes.mfsipcalscreen);
    },
    child: Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(left:16,right:0,top:0),
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? const Color.fromARGB(255, 0, 0, 0)
            : Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: theme.isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/explore/sipca.svg',
              width: 38,
              height: 34,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              "SIP Calculator",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: theme.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget cargrcalss(BuildContext context, MFProvider mf, ThemesProvider theme) {
  return GestureDetector(
    onTap: () async {
      Navigator.pushNamed(context, Routes.mfcagrcalss);
    },
    child: Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(left:16,right:16,top:0),
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? const Color.fromARGB(255, 0, 0, 0)
            : Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: theme.isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/explore/cagrcal.svg',
              width: 40,
              height: 34,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              "CAGR Calculator",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: theme.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}
