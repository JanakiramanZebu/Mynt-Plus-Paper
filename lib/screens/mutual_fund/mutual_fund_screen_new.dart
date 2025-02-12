import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../res/res.dart';
import '../../sharedWidget/functions.dart';

class MutualFundNewScreen extends ConsumerWidget {
  final bestMFList;
  const MutualFundNewScreen({super.key, required this.bestMFList});
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    // final theme = watch(themeProvider);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSlidingPanelContent(),
          const SizedBox(height: 16),
          Column(
            children: [
              NfoCard(),
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
                                  "Create Watchlist",
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
                buildCategoryCard(
                  dataIcon: 'assets/explore/equity.png',
                  title: "Equity",
                  description:
                      "Invest primarily in stocks. High risk, high return potential.",
                  chips: ["Large Cap", "Mid Cap", "Flexi Cap", "ELSS"],
                ),
                const SizedBox(height: 20),
                buildCategoryCard(
                  dataIcon: 'assets/explore/coins.png',
                  title: "Fixed Income",
                  description:
                      "Invest in bonds and fixed-income securities. Lower risk, stable returns.",
                  chips: ["Liquid", "Short Duration", "Gilt Fund"],
                ),
                const SizedBox(height: 20),
                buildCategoryCard(
                  dataIcon: 'assets/explore/hybrid.png',
                  title: "Hybrid",
                  description:
                      "Mix of equity and debt to balance risk and return.",
                  chips: ["Arbitrage", "Aggressive", "Balanced Advantage"],
                ),
                const SizedBox(height: 20),
                buildCategoryCard(
                  dataIcon: 'assets/explore/gold.png',
                  title: "Gold",
                  description:
                      "Invest in gold and related securities. Hedge against inflation.",
                  chips: ["Gold ETF", "Sovereign Bonds"],
                ),
                const SizedBox(height: 20),
                buildCategoryCard(
                  dataIcon: 'assets/explore/solution.png',
                  title: "Solution",
                  description:
                      "Financial goals include retirement planning, funding a child's education, and etc.",
                  chips: ["Retirement Equity", "Children Equity"],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                SizedBox(height: 70),
                SvgPicture.asset("assets/icon/zebulogo.svg",
                              color: colors.logoColor,
                              // height: 50,
                              width: 100,
                              fit: BoxFit.contain),
                SizedBox(height: 16),
                Text(
                  "NSE : 13179 | BSE : 6550 | MCX : 55730 | CDSL: 12080400",
                  style: TextStyle(
                    color: Color(0xff666666),
                    fontSize: 10,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "SEBI Registration No : INZ00174634 | AMFI ARN: 113118",
                  style: TextStyle(
                    color: Color(0xff666666),
                    fontSize: 10,
                  ),
                ),
                SizedBox(height: 4),
                Text(
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
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSlidingPanelContent() {
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
                  return Container(
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
                        Text("${bestMFList[index]['funds']}",
                            style: textStyle(
                                colors.colorBlack, 14, FontWeight.w500)),
                        const Text(
                          "62 recommended",
                          style: TextStyle(
                              color: Color(0xFF43A833),
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                      ],
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
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Color(0xFFDDDDDD),
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
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 14),
          SizedBox(
            height: 34,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chips.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Chip(
                    label: Text(
                      chips[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    shape: StadiumBorder(),
                    backgroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    side: BorderSide(
                      color: Color(0xFF666666),
                      width: 1.0,
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

  Widget NfoCard() {
    return GestureDetector(
      onTap: () {
        print('hi from ngo');
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.all(16.0),
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
            Text(
              "INVEST IN",
              style: TextStyle(
                color: Color(0xFF0037B7),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
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
            SizedBox(height: 8),
            Text(
              "A new fund offer (NFO) is the first subscription for any new fund by an investment company.",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            SizedBox(height: 12),
            Row(
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
