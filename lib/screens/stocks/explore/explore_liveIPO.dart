import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/api/core/api_core.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../sharedWidget/functions.dart';
import '../../ipo/main_sme_list/single_page.dart';

class LiveIPOList extends ConsumerWidget {
  const LiveIPOList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ipos = ref.watch(ipoProvide);
    final ipo = ref.watch(ipoProvide).dashboardIpoModel?.data;
    final theme = ref.read(themeProvider);
    return ipo!.isNotEmpty ? Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 0),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: ipo.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () async {
                  await ipos.getIpoSinglePage(
                            ipoName: "${ipo[index].name}");
               showModalBottomSheet(
                            isScrollControlled: true,
                            useSafeArea: true,
                            isDismissible: true,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16))),
                            context: context,
                            builder: (context) => Container(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom,
                                  ),
                                  child: MainSmeSinglePage(
                                    pricerange:
                                        "₹${double.parse(ipo[index].minPrice!).toInt()} - ₹${double.parse(ipo[index].maxPrice!).toInt()}",
                                    mininv:
                                        "₹${convertCurrencyINRStandard(mininv(double.parse(ipo[index].minPrice!).toDouble(), int.parse(ipo[index].minBidQuantity!).toInt()).toInt())}",
                                    enddate:
                                        "${ipo[index].biddingEndDate}",
                                    startdate:
                                        "${ipo[index].biddingStartDate}",
                                    ipotype:
                                        "${ipo[index].mS}",
                                    ipodetails: jsonEncode(
                                        ipo[index]),
                                  ),
                                ));
            },
            child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.isDarkMode
                            ? colors.darkColorDivider
                            : colors.colorDivider,
                        width: 0.6),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12)),
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: index.isEven
                                    ? theme.isDarkMode
                                        ? colors.colorGrey.withOpacity(.1)
                                        : const Color.fromARGB(
                                            255, 243, 242, 174)
                                    : theme.isDarkMode
                                        ? colors.colorGrey.withOpacity(.1)
                                        : const Color.fromARGB(
                                            255, 251, 215, 148), //(0xffF1F3F8),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(index.isOdd ? 'IPO' : "SME",
                                style: textStyle(const Color(0xff666666), 10,
                                    FontWeight.w500))),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${ipo[index].tlSub!.subscriptionTimes.toString()}x",
                              style: const TextStyle(
                                  color: Color(0xff0037B7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            const Text("times",
                                style: TextStyle(
                                    color: Color(0xff0037B7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600))
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ipo[index].name.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle(
                          theme.isDarkMode
                              ? const Color(0xffB5C0CF)
                              : const Color(0xff000000),
                          14,
                          FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        "closes on${ipo[index].biddingEndDate.toString().substring(4, 16)}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle(
                            theme.isDarkMode
                                ? const Color(0xffE5E5E5)
                                : const Color(0xff666666),
                            13,
                            FontWeight.w500)),
                  ],
                )),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 9);
        },
      ),
    ) : const NoDataFound();
  }
}
