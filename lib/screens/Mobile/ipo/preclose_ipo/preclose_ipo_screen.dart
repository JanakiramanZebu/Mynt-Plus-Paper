// ignore_for_file: deprecated_member_use

//import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/ipo_model/ipo_pre_close_model.dart';
import 'package:mynt_plus/screens/Mobile/ipo/main_sme_list/single_page.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/no_data_found.dart';

class ClosedIPOScreen extends ConsumerStatefulWidget {
  const ClosedIPOScreen({super.key});

  @override
  ConsumerState<ClosedIPOScreen> createState() => _ClosedIPOScreenState();
}

class _ClosedIPOScreenState extends ConsumerState<ClosedIPOScreen> {
  static const int _maxDisplayItems = 5;

  late List<Msg> ipoList;
  List<int> years = [];
  int? selectedYear;
  bool showAll = false;

  @override
  void initState() {
    super.initState();
    ipoList = ref.read(ipoProvide).ipoPreClose!.msg;
    ref.read(ipoProvide).sortpreCloseIPOListByDate(ipoList);

    var currentYear = DateTime.now().year;
    for (var year = 2000; year <= currentYear; year++) {
      years.add(year);
    }
    selectedYear = years.last;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final preClose = ref.watch(ipoProvide);
      final theme = ref.watch(themeProvider);
      final devHeight = MediaQuery.of(context).size.height;
      // final internet = ref.watch(networkStateProvider);
      // final market = ref.watch(marketWatchProvider);

      return SingleChildScrollView(
        // child: Expanded(
        // child: Container(
        // height: preClose.ipoPreClose!.msg.isNotEmpty
        //     ? devHeight
        //     : devHeight - 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // const SizedBox(
            //   height: 10,
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Row(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         children: [
            //           Expanded(
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Text("IPO Performance $selectedYear",
            //                     style: textStyle(const Color(0xff000000), 18,
            //                         FontWeight.w600)),
            //                 const SizedBox(height: 2),
            //                 Text(
            //                     "Monitor the IPO Performance of Mainline IPO Stocks listed at BSE and NSE",
            //                     style: textStyle(const Color(0xff666666), 14,
            //                         FontWeight.w500)),
            //                 const SizedBox(height: 10),
            //               ],
            //             ),
            //           )
            //         ],
            //       ),
            //       SizedBox(
            //         height: 40,
            //         child: TextField(
            //           controller: perfomance.performancesearchcontroller,
            //           style: textStyle(
            //               theme.isDarkMode
            //                   ? colors.colorWhite
            //                   : colors.colorBlack,
            //               15,
            //               FontWeight.w500),
            //           decoration: InputDecoration(
            //               fillColor: theme.isDarkMode
            //                   ? const Color(0xffB5C0CF).withOpacity(.15)
            //                   : const Color(0xffF1F3F8),
            //               filled: true,
            //               hintStyle: textStyle(
            //                   theme.isDarkMode
            //                       ? colors.colorWhite
            //                       : colors.colorBlack,
            //                   14,
            //                   FontWeight.w500),
            //               prefixIconColor: const Color(0xff586279),
            //               prefixIcon: Padding(
            //                 padding: const EdgeInsets.symmetric(horizontal: 20.0),
            //                 child: SvgPicture.asset(assets.searchIcon,
            //                     color: const Color(0xff586279),
            //                     fit: BoxFit.contain,
            //                     width: 15),
            //               ),
            //               suffixIcon: InkWell(
            //                 onTap: () async {
            //                   perfomance.clearPerformanceSearch();
            //                 },
            //                 child: Padding(
            //                   padding:
            //                       const EdgeInsets.symmetric(horizontal: 20.0),
            //                   child: perfomance
            //                           .performancesearchcontroller.text.isEmpty
            //                       ? null
            //                       : SvgPicture.asset(assets.removeIcon,
            //                           fit: BoxFit.scaleDown, width: 20),
            //                 ),
            //               ),
            //               enabledBorder: OutlineInputBorder(
            //                   borderSide: BorderSide.none,
            //                   borderRadius: BorderRadius.circular(30)),
            //               disabledBorder: InputBorder.none,
            //               focusedBorder: OutlineInputBorder(
            //                   borderSide: BorderSide.none,
            //                   borderRadius: BorderRadius.circular(30)),
            //               hintText: "Search company",
            //               contentPadding: const EdgeInsets.all(14),
            //               border: OutlineInputBorder(
            //                   borderSide: BorderSide.none,
            //                   borderRadius: BorderRadius.circular(30))),
            //           onChanged: (value) {
            //             perfomance.searchperformance(value, context);
            //             if (value.isEmpty) {
            //               perfomance.clearPerformanceSearch();
            //             }
            //             if (internet.connectionStatus !=
            //                 ConnectivityResult.none) {
            //               perfomance.searchperformance(value, context);
            //             }
            //           },
            //         ),
            //       ),
            //       const SizedBox(width: 10),
            //     ],
            //   ),
            // ),

            preClose.ipoPreClose!.msg.isNotEmpty
                ? _IPOListSection(
                    ipoList: ipoList,
                    preClose: preClose,
                    theme: theme,
                    showAll: showAll,
                  )
                : _NoDataSection(devHeight: devHeight),
          ],
        ),

        // ),
        // ),
      );
    });
  }

  static TextStyle textStyle(Color color, double fontSize, FontWeight fWeight) {
    return GoogleFonts.inter(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

class _IPOListSection extends StatelessWidget {
  final List<Msg> ipoList;
  final dynamic preClose;
  final ThemesProvider theme;
  final bool showAll;

  const _IPOListSection({
    required this.ipoList,
    required this.preClose,
    required this.theme,
    required this.showAll,
  });

  @override
  Widget build(BuildContext context) {
    final displayCount = showAll
        ? ipoList.length
        : ipoList.length < _ClosedIPOScreenState._maxDisplayItems
            ? ipoList.length
            : _ClosedIPOScreenState._maxDisplayItems;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        itemCount: displayCount,
        itemBuilder: (context, index) {
          return _IPOListItem(
            ipo: ipoList[index],
            preClose: preClose,
            theme: theme,
            index: index,
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 0,
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
          );
        },
      ),
    );
  }
}

class _IPOListItem extends StatelessWidget {
  final Msg ipo;
  final dynamic preClose;
  final ThemesProvider theme;
  final int index;

  const _IPOListItem({
    required this.ipo,
    required this.preClose,
    required this.theme,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onIPOTap(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 250,
                child: Text(
                  ipo.companyName!,
                  overflow: TextOverflow.ellipsis,
                  style: _ClosedIPOScreenState.textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _buildIPOTypeChip(),
            ],
          ),
        ),
        if (preClose.ipoPreClose!.msg[index].totalsub != '')
          _buildSubscriptionInfo(),
      ],
    );
  }

  Widget _buildIPOTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ipo.ipoType == "SME"
            ? theme.isDarkMode
                ? colors.colorGrey.withOpacity(.3)
                : const Color.fromARGB(255, 243, 242, 174)
            : theme.isDarkMode
                ? colors.colorGrey.withOpacity(.3)
                : const Color.fromARGB(255, 251, 215, 148),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "${ipo.ipoType}",
        style: _ClosedIPOScreenState.textStyle(
          const Color(0xff666666),
          10,
          FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSubscriptionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${preClose.ipoPreClose!.msg[index].totalsub}x",
          style: _ClosedIPOScreenState.textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            14,
            FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Subscription",
          style: _ClosedIPOScreenState.textStyle(
            const Color(0xff666666),
            10,
            FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildListingInfo(),
        _buildClosedChip(),
      ],
    );
  }

  Widget _buildListingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Listed on",
          style: _ClosedIPOScreenState.textStyle(
            const Color(0xff666666),
            10,
            FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${ipo.listingDate!.substring(4, 6)} ${ipo.listingDate!.substring(0, 3)}",
          style: _ClosedIPOScreenState.textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            14,
            FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildClosedChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? const Color(0xffFFF6E6).withOpacity(.3)
            : const Color(0xffFFF6E6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "Closed",
        style: _ClosedIPOScreenState.textStyle(
          const Color(0xffB37702),
          10,
          FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _onIPOTap(BuildContext context) async {
    await preClose.getIpoSinglePage(
      ipoName: "${preClose.ipoPreClose!.msg[index].companyName}",
    );

    if (context.mounted) {
      getResponsiveWidth(context) == 600
          ? showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.3, // set your desired width here
                    child: MainSmeSinglePage(
                      pricerange:
                          "₹${preClose.ipoPreClose!.msg[index].priceRange!}",
                      mininv: "₹${convertCurrencyINRStandard(
                        mininv(
                          preClose.ipoPreClose!.msg[index].minPrice!.toDouble(),
                          preClose.ipoPreClose!.msg[index].minBidQu!.toInt(),
                        ).toInt(),
                      )}",
                      enddate: convertClosedIpoDates(
                        preClose.ipoPreClose!.msg[index].iPOEndDate!,
                        "MMM dd, yyyy",
                        "EEE, dd MMM yyyy HH:mm:ss",
                      ),
                      startdate: convertClosedIpoDates(
                        preClose.ipoPreClose!.msg[index].iPOStartDate!,
                        "MMM dd, yyyy",
                        "dd-MM-yyyy",
                      ),
                      ipotype: "${preClose.ipoPreClose!.msg[index].ipoType}",
                      ipodetails: "",
                    ),
                  ),
                );
              },
            )
          : showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16))),
              backgroundColor: const Color(0xffffffff),
              isDismissible: false,
              enableDrag: false,
              showDragHandle: false,
              useSafeArea: false,
              isScrollControlled: true,
              context: context,
              builder: (BuildContext context) {
                return PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) async {
                    if (didPop) return;
                  },
                  child: MainSmeSinglePage(
                    pricerange:
                        "₹${preClose.ipoPreClose!.msg[index].priceRange!}",
                    mininv: "₹${convertCurrencyINRStandard(
                      mininv(
                        preClose.ipoPreClose!.msg[index].minPrice!.toDouble(),
                        preClose.ipoPreClose!.msg[index].minBidQu!.toInt(),
                      ).toInt(),
                    )}",
                    enddate: convertClosedIpoDates(
                      preClose.ipoPreClose!.msg[index].iPOEndDate!,
                      "MMM dd, yyyy",
                      "EEE, dd MMM yyyy HH:mm:ss",
                    ),
                    startdate: convertClosedIpoDates(
                      preClose.ipoPreClose!.msg[index].iPOStartDate!,
                      "MMM dd, yyyy",
                      "dd-MM-yyyy",
                    ),
                    ipotype: "${preClose.ipoPreClose!.msg[index].ipoType}",
                    ipodetails: "",
                  ),
                );
              });

      // showModalBottomSheet(
      //   isScrollControlled: true,
      //   useSafeArea: true,
      //   isDismissible: true,
      //   shape: const RoundedRectangleBorder(
      //     borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      //   ),
      //   context: context,
      //   builder: (context) => Container(
      //     padding: EdgeInsets.only(
      //       bottom: MediaQuery.of(context).viewInsets.bottom,
      //     ),
      //     child: MainSmeSinglePage(
      //       pricerange: "₹${preClose.ipoPreClose!.msg[index].priceRange!}",
      //       mininv: "₹${convertCurrencyINRStandard(
      //         mininv(
      //           preClose.ipoPreClose!.msg[index].minPrice!.toDouble(),
      //           preClose.ipoPreClose!.msg[index].minBidQu!.toInt(),
      //         ).toInt(),
      //       )}",
      //       enddate: convertClosedIpoDates(
      //         preClose.ipoPreClose!.msg[index].iPOEndDate!,
      //         "MMM dd, yyyy",
      //         "EEE, dd MMM yyyy HH:mm:ss",
      //       ),
      //       startdate: convertClosedIpoDates(
      //         preClose.ipoPreClose!.msg[index].iPOStartDate!,
      //         "MMM dd, yyyy",
      //         "dd-MM-yyyy",
      //       ),
      //       ipotype: "${preClose.ipoPreClose!.msg[index].ipoType}",
      //       ipodetails: "",
      //     ),
      //   ),
      // );
    }
  }
}

class _NoDataSection extends StatelessWidget {
  final double devHeight;

  const _NoDataSection({required this.devHeight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: devHeight - 600,
      child: const Center(child: NoDataFound()),
    );
  }
}
