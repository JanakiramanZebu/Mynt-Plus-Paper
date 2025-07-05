import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../res/res.dart';
import '../../provider/thems.dart';
import '../../routes/route_names.dart';
import '../provider/stocks_provider.dart';
import '../provider/transcation_provider.dart';
import 'stocks/explore/stocks/stock_screens.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    setState(() {
      ref.read(stocksProvide).chngTradeAction("init");
      ref
          .read(stocksProvide)
          .requestWSTradeaction(isSubscribe: true, context: context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      final trancation = ref.watch(transcationProvider);

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
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: SearchBar(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.iposearchscreen);
                      },
                      hintText: "Search company",
                      backgroundColor: WidgetStateProperty.all(
                          colors.kColorLightGrey), // Gray background
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(50), // Rounded corners
                          side: BorderSide.none, // No border
                        ),
                      ),
                      elevation: WidgetStateProperty.all(0), // No shadow
                      leading: const Icon(Icons.search,
                          color: Colors.black54), // Prefix icon
                    )),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    expandedHeight: 260,
                    floating: false,
                    pinned: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(0)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Portfolio",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Color(theme.isDarkMode
                                            ? 0xffffffff
                                            : 0xff000000),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Icon(Icons.arrow_forward,
                                      size: 20,
                                      color: theme.isDarkMode
                                          ? colors.colorLightBlue
                                          : colors.colorBlue)
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "₹476,656.36",
                                    style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600,
                                        color: Color(theme.isDarkMode
                                            ? 0xffffffff
                                            : 0xff000000)),
                                  ),
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: () async {
                                      await trancation
                                          .fetchValidateToken(context);

                                      await trancation.ip();
                                      await trancation.fetchupiIdView(
                                          trancation.bankdetails!
                                              .dATA![trancation.indexss][1],
                                          trancation.bankdetails!
                                              .dATA![trancation.indexss][2]);

                                      await trancation.fetchcwithdraw(context);
                                      trancation.changebool(true);
                                      Navigator.pushNamed(
                                          context, Routes.fundscreen,
                                          arguments: trancation);
                                    },
                                    child: Text(
                                      "Add fund",
                                      style: TextStyle(
                                          color: colors.colorBlue,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoCard(
                                    icon: 'assets/icon/dashboard/briefcase.svg',
                                    label: "Holdings",
                                    value: "347945.90",
                                    iconColor: Colors.teal,
                                  ),
                                  const SizedBox(width: 16),
                                  _buildInfoCard(
                                    icon: 'assets/icon/dashboard/currency.svg',
                                    label: "Cash",
                                    value: "128629.91",
                                    iconColor: Colors.orange,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () async {},
                                  style: ElevatedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                    // side: const BorderSide(
                                    //     color: Color(0xFF87A1DD), width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/explore/firefox.svg',
                                        width: 16,
                                        height: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "View my portfolio",
                                        style: TextStyle(
                                            color: Color(0xFF4069C9),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                      ),
                                      const Icon(
                                        Icons.expand_more,
                                        color: Color(0xFF4069C9),
                                        size: 28,
                                        weight: 7,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                ];
              },
              body: const StockScreen()),
        ),
      );
    });
  }

  Widget _buildInfoCard({
    required String icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 16,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
            const SizedBox(width: 5),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  }
}
