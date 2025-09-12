import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mynt_plus/api/core/api_core.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../sharedWidget/functions.dart';
import '../../ipo/main_sme_list/single_page.dart';

class LiveIPOList extends ConsumerWidget {
  const LiveIPOList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ipos = ref.watch(ipoProvide);
    final ipo = ref.watch(ipoProvide).dashboardIpoModel?.data;
    final theme = ref.read(themeProvider);
    String getIPOStatus(String? biddingStartDate, String? biddingEndDate) {
      if (biddingStartDate == null || biddingEndDate == null) return "";

      try {
        final start = DateFormat("dd-MM-yyyy").parseStrict(biddingStartDate);
        final cleanedEndDate = biddingEndDate.trim();
        final end =
            DateFormat("EEE, dd MMM yyyy HH:mm:ss").parseStrict(cleanedEndDate);

        final today = DateTime.now();

        // Strip time parts for comparison (keep only year, month, day)
        final todayDate = DateTime(today.year, today.month, today.day);
        final startDate = DateTime(start.year, start.month, start.day);
        final endDate = DateTime(end.year, end.month, end.day);

        if (todayDate.isBefore(startDate)) {
          return "Upcoming";
        } else if (todayDate.isAfter(endDate)) {
          return "Closed";
        } else {
          return "Open";
        }
      } catch (e) {
        debugPrint("Date parsing error: $e");
        return "";
      }
    }

    if (ipo == null || ipo.isEmpty) {
      return const NoDataFound();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      height: 80,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 0),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: ipo.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  color: theme.isDarkMode
                      ? colors.dividerDark
                      : colors.dividerLight),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: InkWell(
                onTap: () async {
                  await ipos.getIpoSinglePage(ipoName: "${ipo[index].name}");
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
                                      "₹${double.parse(ipo[index].minPrice!).toInt()} - ₹${double.parse(ipo[index].maxPrice!).toInt()}",
                                  mininv:
                                      "₹${convertCurrencyINRStandard(mininv(double.parse(ipo[index].minPrice!).toDouble(), int.parse(ipo[index].minBidQuantity!).toInt()).toInt())}",
                                  enddate: "${ipo[index].biddingEndDate}",
                                  startdate: "${ipo[index].biddingStartDate}",
                                  ipotype: "${ipo[index].mS}",
                                  ipodetails: jsonEncode(ipo[index]),
                                ),
                              ),
                            );
                          },
                        )
                      : showModalBottomSheet(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16))),
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
                                    "₹${double.parse(ipo[index].minPrice!).toInt()} - ₹${double.parse(ipo[index].maxPrice!).toInt()}",
                                mininv:
                                    "₹${convertCurrencyINRStandard(mininv(double.parse(ipo[index].minPrice!).toDouble(), int.parse(ipo[index].minBidQuantity!).toInt()).toInt())}",
                                enddate: "${ipo[index].biddingEndDate}",
                                startdate: "${ipo[index].biddingStartDate}",
                                ipotype: "${ipo[index].mS}",
                                ipodetails: jsonEncode(ipo[index]),
                              ),
                            );
                          });

                  // showModalBottomSheet(
                  //     isScrollControlled: true,
                  //     useSafeArea: true,
                  //     isDismissible: true,
                  //     shape: const RoundedRectangleBorder(
                  //         borderRadius:
                  //             BorderRadius.vertical(top: Radius.circular(16))),
                  //     context: context,
                  //     builder: (context) => Container(
                  //           padding: EdgeInsets.only(
                  //             bottom: MediaQuery.of(context).viewInsets.bottom,
                  //           ),
                  //           child: MainSmeSinglePage(
                  //             pricerange:
                  //                 "₹${double.parse(ipo[index].minPrice!).toInt()} - ₹${double.parse(ipo[index].maxPrice!).toInt()}",
                  //             mininv:
                  //                 "₹${convertCurrencyINRStandard(mininv(double.parse(ipo[index].minPrice!).toDouble(), int.parse(ipo[index].minBidQuantity!).toInt()).toInt())}",
                  //             enddate: "${ipo[index].biddingEndDate}",
                  //             startdate: "${ipo[index].biddingStartDate}",
                  //             ipotype: "${ipo[index].mS}",
                  //             ipodetails: jsonEncode(ipo[index]),
                  //           ),
                  //         ));
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.end,
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     // Container(
                      //     //     padding: const EdgeInsets.symmetric(
                      //     //         horizontal: 8, vertical: 4),
                      //     //     decoration: BoxDecoration(
                      //     //         color: index.isEven
                      //     //             ? theme.isDarkMode
                      //     //                 ? colors.colorGrey.withOpacity(.1)
                      //     //                 : const Color.fromARGB(
                      //     //                     255, 243, 242, 174)
                      //     //             : theme.isDarkMode
                      //     //                 ? colors.colorGrey.withOpacity(.1)
                      //     //                 : const Color.fromARGB(
                      //     //                     255, 251, 215, 148), //(0xffF1F3F8),
                      //     //         borderRadius: BorderRadius.circular(4)),
                      //     //     child: Text(index.isOdd ? 'IPO' : "SME",
                      //     //         style: textStyle(const Color(0xff666666), 10,
                      //     //             FontWeight.w500))),
                      //     // Column(
                      //     //   crossAxisAlignment: CrossAxisAlignment.center,
                      //     //   children: [
                      //     //     Text(
                      //     //       "${ipo[index].tlSub?.subscriptionTimes.toString() ?? '0'}x",
                      //     //       style: const TextStyle(
                      //     //           color: Color(0xff0037B7),
                      //     //           fontSize: 14,
                      //     //           fontWeight: FontWeight.w600),
                      //     //     ),
                      //     //     const Text("times",
                      //     //         style: TextStyle(
                      //     //             color: Color(0xff0037B7),
                      //     //             fontSize: 10,
                      //     //             fontWeight: FontWeight.w600))
                      //     //   ],
                      //     // )
                      //   ],
                      // ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget.paraText(
                            text: "LIVE IPO",
                            theme: theme.isDarkMode,
                            maxLines: 1,
                            textOverflow: TextOverflow.ellipsis,
                            color: theme.isDarkMode
                                ? colors.primaryDark
                                : colors.primaryLight,
                            fw: 0,
                          ),
                          TextWidget.paraText(
                            text:
                                "${getIPOStatus(ipo[index].biddingStartDate ?? '', ipo[index].biddingEndDate ?? '')}"
                                    .toUpperCase(),
                            theme: theme.isDarkMode,
                            maxLines: 1,
                            fw: 0,
                            textOverflow: TextOverflow.ellipsis,
                            color: getIPOStatus(
                                        ipo[index].biddingStartDate ?? '',
                                        ipo[index].biddingEndDate ?? '') ==
                                    "Upcoming"
                                ? colors.pending
                                : getIPOStatus(
                                            ipo[index].biddingStartDate ?? '',
                                            ipo[index].biddingEndDate ?? '') ==
                                        "Closed"
                                    ? colors.loss
                                    : getIPOStatus(
                                                ipo[index].biddingStartDate ??
                                                    '',
                                                ipo[index].biddingEndDate ??
                                                    '') ==
                                            "Open"
                                        ? colors.profit
                                        : colors.textPrimaryLight,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextWidget.subText(
                        text: ipo[index].name?.toString() ?? '',
                        theme: theme.isDarkMode,
                        maxLines: 1,
                        textOverflow: TextOverflow.ellipsis,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fw: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 20);
        },
      ),
    );
  }
}
