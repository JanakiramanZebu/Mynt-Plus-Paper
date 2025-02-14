import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../provider/mf_provider.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/functions.dart';

class MutualFundNewScreen extends ConsumerWidget {
  // final bestMFList;
  const MutualFundNewScreen({super.key});
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final mfData = watch(mfProvider);
    // final theme = watch(themeProvider);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSlidingPanelContent(mfData.bestMFListStatic, mfData),
          const SizedBox(height: 16),
          Column(
            children: [
              nfoCard(context),
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: InkWell(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Watchlist",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Now track your favourite MF by adding them to your watchlist.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ignore: prefer_const_constructors
                      SizedBox(width: 20),
                      SvgPicture.asset(
                        'assets/explore/Binocular.svg',
                        width: 46,
                        height: 46,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            // margin: EdgeInsets.only(bottom: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "All Categories",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF181B19),
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) { 
                    return buildCategoryCard(
                    dataIcon: mfData.mFCategoryTypesStatic[index]['dataIcon'],
                    title: mfData.mFCategoryTypesStatic[index]['title'],
                    description:
                        mfData.mFCategoryTypesStatic[index]['description'],
                    chips: mfData.mFCategoryTypesStatic[index]['sub'],
                    watch: watch
                  );
                   },
                  separatorBuilder: (BuildContext context, int index) { return const SizedBox(height: 20); },
                  itemCount: mfData.mFCategoryTypesStatic.length,
                  
                ),
                Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            // height: 300,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFFFFF), // #FFFFFF at 0%
                  Color(0xFFF1F3F8), // #F1F3F8 at 100%
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child:  Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 70),
                SvgPicture.asset("assets/icon/zebulogo.svg",
                              color: colors.logoColor,
                              // height: 50,
                              width: 100,
                              fit: BoxFit.contain),
                const SizedBox(height: 16),
                const Text(
                  "NSE : 13179 | BSE : 6550 | MCX : 55730 | CDSL: 12080400",
                  style: TextStyle(
                    color: Color(0xff666666),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "SEBI Registration No : INZ00174634 | AMFI ARN: 113118",
                  style: TextStyle(
                    color: Color(0xff666666),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Research Analyst : INH200006044",
                  style: TextStyle(
                    color: Color(0xff666666),
                    fontSize: 10,
                  ),
                )
              ],
            ),
          )
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

  Widget buildSlidingPanelContent(bestMFList, MFProvider mfData) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xFFF1F3F8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 9),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Best mutual funds",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF181B19)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Find the right mutual fund across these asset classes",
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
          const SizedBox(height: 24),
          SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: bestMFList.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () async{
                      await mfData.fetchMFBestList(bestMFList[index]['title']);
          Navigator.pushNamed(context, Routes.bestMfScreen,
                            arguments: bestMFList[index]['title']);
                    },
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                          color: colors.colorWhite,
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            "${bestMFList[index]['image']}",
                            height: 50,
                            width: 60,
                          ),
                          Text("${bestMFList[index]['title']}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle(
                                  colors.colorBlack, 16, FontWeight.w500)),
                          Text("${bestMFList[index]['subtitle']}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle(
                                  const Color(0xff999999), 13, FontWeight.w500)),
                          Text("${bestMFList[index]['funds']} funds",
                              style: textStyle(
                                  colors.colorBlack, 14, FontWeight.w500)),
                          // const Text(
                          //   "62 recommended",
                          //   style: TextStyle(
                          //       color: Color(0xFF43A833),
                          //       fontWeight: FontWeight.w500,
                          //       fontSize: 12),
                          // ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(width: 14);
                },
              ))
        ],
      ),
    );
  }

  Widget buildCategoryCard({
    required String dataIcon,
    required String title,
    required String description,
    required List<String> chips,
    required ScopedReader watch
  }) {
    final mfData = watch(mfProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFDDDDDD),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            dataIcon,
            width: 40,
            height: 40,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 34,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chips.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () async{
                      await mfData.fetchMFCategoryList(title,chips[index]);
                      Navigator.pushNamed(
                      context,
                      Routes.mfCategoryList,
                      arguments: chips[index]
                    );
                    },
                    child: Chip(
                      label: Text(
                        chips[index],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      side: const BorderSide(
                        color: Color(0xFF666666),
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
    );
  }

  Widget nfoCard(context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.mfnfoscreen);
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "INVEST IN",
              style: TextStyle(
                color: Color(0xFF0037B7),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Ongoing new fund offerings",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  'assets/explore/gift.svg',
                  width: 38,
                  height: 34,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "A new fund offer (NFO) is the first subscription for any new fund by an investment company.",
              style: TextStyle(
                fontSize: 14,
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
                    fontWeight: FontWeight.bold,
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
}
