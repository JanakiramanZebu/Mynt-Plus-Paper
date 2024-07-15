import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../models/order_book_model/sip_order_book.dart';
import '../../provider/sip_order_provider.dart'; 
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/no_data_found.dart';
import 'sip_order_details.dart';

class SipOrderBook extends ConsumerWidget {
  final List<SipDetails>? sipbook;
  const SipOrderBook({super.key, required this.sipbook});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return sipbook == null
        ? const NoDataFound()
        : Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                    color: Color(0xffFFFFFF),
                    border: Border(
                        bottom:
                            BorderSide(color: Color(0xffF1F3F8), width: 6))),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  dense: true,
                  title: Text("${sipbook!.length} Order · List by you",
                      style: textStyle(
                          const Color(0xff666666), 12, FontWeight.w600)),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return InkWell(
                              onTap: () async {
                                context.read(siprovider).fetchSipOrderHistory();
                                // Navigator.pushNamed(context, Routes.orderDetail,
                                //     arguments: orderBook[index]);
                                showModalBottomSheet(
                                    showDragHandle: true,
                                    isScrollControlled: true,
                                    useSafeArea: true,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16))),
                                    backgroundColor: const Color(0xffffffff),
                                    context: context,
                                    builder: (context) => SipOrderDetails(
                                        sipdetails: sipbook![index]));
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("${sipbook![index].sipName}",
                                              style: textStyle(
                                                  const Color(0xff000000),
                                                  15,
                                                  FontWeight.w600)),
                                          Row(
                                            children: [
                                              Text("Frequency:",
                                                  style: textStyle(
                                                      const Color(0xff5E6B7D),
                                                      14,
                                                      FontWeight.w500)),
                                              Text(
                                                  sipbook![index].frequency ==
                                                          "0"
                                                      ? "Daily"
                                                      : sipbook![index]
                                                                  .frequency ==
                                                              "1"
                                                          ? "Weekly"
                                                          : "Monthly",
                                                  style: textStyle(
                                                      const Color(0xff000000),
                                                      14,
                                                      FontWeight.w500)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                          sipformatDateTime(
                                              value:
                                                  "${sipbook![index].regDate}"),
                                          style: textStyle(
                                              const Color(0xff666666),
                                              12,
                                              FontWeight.w500)),
                                      const SizedBox(height: 5),
                                      const Divider(color: Color(0xffECEDEE)),
                                      const SizedBox(height: 3),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text("Start Date: ",
                                                  style: textStyle(
                                                      const Color(0xff5E6B7D),
                                                      14,
                                                      FontWeight.w500)),
                                              Text(
                                                  duedateformate(
                                                      value:
                                                          "${sipbook![index].startDate}"),
                                                  style: textStyle(
                                                      const Color(0xff000000),
                                                      14,
                                                      FontWeight.w500)),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text("Due Date: ",
                                                  style: textStyle(
                                                      const Color(0xff5E6B7D),
                                                      14,
                                                      FontWeight.w500)),
                                              Text(
                                                  duedateformate(
                                                      value:
                                                          "${sipbook![index].internal?.dueDate}"),
                                                  style: textStyle(
                                                      const Color(0xff000000),
                                                      14,
                                                      FontWeight.w500)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text("Pending Period: ",
                                                  style: textStyle(
                                                      const Color(0xff5E6B7D),
                                                      14,
                                                      FontWeight.w500)),
                                              Text(
                                                  "${sipbook![index].endPeriod}",
                                                  style: textStyle(
                                                      const Color(0xff000000),
                                                      14,
                                                      FontWeight.w500)),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text("Execution Date: ",
                                                  style: textStyle(
                                                      const Color(0xff5E6B7D),
                                                      14,
                                                      FontWeight.w500)),
                                              Text(
                                                  duedateformate(
                                                      value:
                                                          "${sipbook![index].internal?.execDate}"),
                                                  style: textStyle(
                                                      const Color(0xff000000),
                                                      14,
                                                      FontWeight.w500)),
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  )));
                        },
                        itemCount: sipbook!.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return Container(
                              color: const Color(0xffF1F3F8), height: 7);
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
