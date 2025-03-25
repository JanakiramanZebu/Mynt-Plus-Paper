// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/screens/mutual_fund/mf_timeline.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/ipo_time_line.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_exch_badge.dart';
// import '../../sharedWidget/loader_ui.dart';
import '../../sharedWidget/loader_ui.dart';
import '../mutual_fund_old/cancle_xsip_resone.dart';
// import '../mutual_fund_old/mf_order_filter_sheet.dart';
import '../portfolio_screens/mfHoldings/mf_holding_screen.dart';
import '../mutual_fund/mf_cancel_alert.dart';

class mforderdetscreen extends StatefulWidget {
  const mforderdetscreen({super.key});
  @override
  State<mforderdetscreen> createState() => _mforderdetscreen();
}

class _mforderdetscreen extends State<mforderdetscreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final theme = watch(themeProvider);
      final mfdata = watch(mfProvider);
      // print("11111111111111111${mfdata.mfsinglepageres!.invList}");

      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          leadingWidth: 41,
          titleSpacing: 6,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios,
                  color:
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          backgroundColor:
              theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          shadowColor: const Color(0xffECEFF3),
          title: Text("Order details",
              style: textStyles.appBarTitleTxt.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              )),
        ),
        body: 
        
        
        Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const SizedBox(width: 0),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // const SizedBox(
                            //     width: 6),

                            // const SizedBox(
                            //     width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Aligns text properly
                                      children: [
                                        // const SizedBox(height: 4), // Now it's correctly placed
                                        Text(
                                          "${mfdata.mforderdet?.data?.schemename}",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: textStyles.scripNameTxtStyle
                                              .copyWith(
                                            color: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // const SizedBox(height: 8),
                                  // SizedBox(
                                  //     height: 16,
                                  //     child: ListView(
                                  //         scrollDirection: Axis.horizontal,
                                  //         children: [

                                  //           // CustomExchBadge(
                                  //           //     exch:
                                  //           //         "Next Due Date :"),
                                  //           // SizedBox(width: 5),

                                  //           // CustomExchBadge(exch: "${"${mfdata.mfsinglepageres?.liveCancel}"}"),

                                  //           // Container(
                                  //           //   decoration: BoxDecoration(
                                  //           //     color: mfdata.mfsinglepageres
                                  //           //                 ?.liveCancel ==
                                  //           //             "LIVE"
                                  //           //         ? const Color(0xFFE5F5EA)
                                  //           //         : const Color(0xFFFFC7C7),
                                  //           //     borderRadius:
                                  //           //         BorderRadius.circular(3),
                                  //           //   ),
                                  //           //   padding:
                                  //           //       const EdgeInsets.symmetric(
                                  //           //           horizontal: 4,
                                  //           //           vertical: 2),
                                  //           //   child: Text(
                                  //           //     "${mfdata.mfsinglepageres?.liveCancel}",
                                  //           //     style: textStyle(
                                  //           //       mfdata.mfsinglepageres
                                  //           //                   ?.liveCancel ==
                                  //           //               "LIVE"
                                  //           //           ? const Color(0xFF42A833)
                                  //           //           : const Color(0xFFF33E4B),
                                  //           //       10,
                                  //           //       FontWeight.w400,
                                  //           //     ),
                                  //           //   ),
                                  //           // ),
                                  //         ]))
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ]),
                )),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SvgPicture.asset(
                      mfdata.mforderdet!.data?.orderstatus == "VALID"
                          ? assets.completedIcon
                          : mfdata.mforderdet!.data?.orderstatus == "INVALID"
                              ? assets.cancelledIcon
                              : assets.warningIcon,
                      width: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        mfdata.mforderdet!.data?.orderstatus == "VALID"
                            ? 'Success'
                            : mfdata.mforderdet!.data?.orderstatus == "INVALID"
                                ? 'Failed'
                                : mfdata.mforderdet!.data?.orderstatus ==
                                        'PENDING'
                                    ? 'Pending'
                                    : mfdata.mforderdet!.data!.orderstatus!,
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            FontWeight.w600),
                      ),
                    )
                  ],
                ),

                // Text(
                //   "1000",
                //   style: textStyle(
                //       theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                //       14,
                //       FontWeight.w500),
                // ),
                // const SizedBox(width: 12),
              ]),
              const SizedBox(height: 2),
              Divider(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider,
                thickness: 1.0,
              ),
              const SizedBox(height: 8),
              Text(
                "Order Details",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    16,
                    FontWeight.w500),
              ),
              const SizedBox(height: 16),
              rowOfInfoData("Transaction Type", "${mfdata.mforderdet!.data?.buysell == "P" ? "Purchase" : "Redemption"}", "Order Type",
                  "${mfdata.mforderdet!.data?.ordertype == "NRM" ? "Lumpsum" : "SIP"}", theme),
              const SizedBox(height: 16),
              //  const SizedBox(height: 16),
              rowOfInfoData("Price", "${mfdata.mforderdet!.data?.amount}", "Units",
                  "${mfdata.mforderdet!.data?.units}", theme),
              const SizedBox(height: 16),

               rowOfInfoData("Date", "${mfdata.mforderdet!.data?.date}", "Date & Time",
                  "${mfdata.mforderdet!.data?.dateTime}", theme),
              const SizedBox(height: 16),

               rowOfInfoData("Order No", "${mfdata.mforderdet!.data?.ordernumber}", "Folio No",
                  "${mfdata.mforderdet!.data?.foliono == "" ? "---" : mfdata.mforderdet!.data?.foliono}", theme),
              const SizedBox(height: 16),
               if(mfdata.mforderdet!.data?.orderstatus != "VALID")...[
          //  const SizedBox(height: 16),
              Text(
                "${mfdata.mforderdet!.data?.orderstatus ==
                                        'PENDING' ? 'Pending' : mfdata.mforderdet!.data?.orderstatus == "INVALID" ? "Reject" : mfdata.mforderdet!.data?.orderstatus} Reason",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    16,
                    FontWeight.w500),
              ),
           const SizedBox(height: 8),

 Text(
            "${mfdata.mforderdet!.data?.orderremarks}",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : const Color(0xFFF33E4B),
                    13,
                    FontWeight.w500),
              ),




              
            ],

const SizedBox( height: 20),
if (mfdata.mforderdet?.data?.ordertype == "NRM" && mfdata.mforderdet?.data?.buysell == "R" &&
    mfdata.mforderdet?.data?.orderstatus == "PENDING") ...[
 SizedBox(
  width: double.infinity, // Makes the button full width
  child: ElevatedButton(
    onPressed: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return MfCancelAlert(mfcancel: mfdata.mforderdet!.data!,message: "order") ;
          },
        );
      // if (mfdata.mforderdet?.data != null) {
        // await showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return MfCancelAlert(mfcancel: mfdata.mforderdet!.data!) ;
        //   },
        // );
      // }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white, // White background
      foregroundColor: const Color.fromARGB(255, 0, 0, 0), // Text and icon color
      side: const BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 1.5), // Outlined border
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Optional: rounded corners
      ),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon(
        //   Icons.cancel,
        //   color: Color.fromARGB(255, 0, 0, 0),
        //   size: 18,
        // ),
        // SizedBox(width: 6),
        Text(
          "Cancel Order",
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  ),
)

    ]

                                                                  //   .mflumpsumorderbook!
                                                                  //     .data![index]
                                                                  //     .ordertype ==
                                                                  // "NRM" &&
                                                          //     mfdata.mforderdet!.data?.buysell ==
                                                          //         "R" &&
                                                          //    mfdata.mforderdet!.data?.orderstatus ==
                                                          //         "PENDING"
                                                          // ? TextButton(
                                                          //     onPressed: () async {
                                                          //       showDialog(
                                                          //           context: context,
                                                          //           builder:
                                                          //               (BuildContext
                                                          //                   context) {
                                                          //             return MfCancelAlert(
                                                          //                 mfcancel:  mfdata.mforderdet!.data);
                                                          //           });
                                                          //     },
                                                          //     child: const Row(
                                                          //       mainAxisSize:
                                                          //           MainAxisSize.min,
                                                          //       children: [
                                                          //         Icon(
                                                          //           Icons.cancel,
                                                          //           color: Color(
                                                          //               0xff0037B7),
                                                          //           size: 18,
                                                          //         ),
                                                          //         SizedBox(width: 6),
                                                          //         Text(
                                                          //           "Cancel Order",
                                                          //           style: TextStyle(
                                                          //             color: Color(
                                                          //                 0xff0037B7),
                                                          //             fontSize: 14,
                                                          //             fontWeight:
                                                          //                 FontWeight
                                                          //                     .w600,
                                                          //           ),
                                                          //         ),
                                                          //       ],
                                                          //     ),
                                                          //   )


         
            ])),

     
     
     
      );
    });
  }

  Row rowOfInfoData(String title1, String value1, String title2, String value2,
      ThemesProvider theme) {
    return Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title1,
            style: textStyle(const Color(0xff666666), 12, FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value1,
            style: textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                14,
                FontWeight.w500)),
        const SizedBox(height: 2),
        Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider)
      ])),
      const SizedBox(width: 34),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title2,
            style: textStyle(const Color(0xff666666), 12, FontWeight.w500)),
        const SizedBox(height: 2),
        Text(
          value2,
          style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider)
      ]))
    ]);
  }
}
