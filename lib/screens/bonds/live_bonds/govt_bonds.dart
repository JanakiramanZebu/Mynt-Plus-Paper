// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/bonds_model/all_bonds_list_model.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/bonds/bonds_order_screen/orderscreenbottompage.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

class GovtBondsScreen extends StatelessWidget {
  const GovtBondsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final bonds = ref.watch(bondsProvider);
      // final mainstreamipo = ref.watch(ipoProvide);
      // List<BondsList>? bondsList = bonds.bondsList;
      // final upi = ref.watch(transcationProvider);
      final theme = ref.watch(themeProvider);
      final dev_height = MediaQuery.of(context).size.height;
      return

          bonds.govtBonds!.ncbGSec!.isNotEmpty ?
          //     ? Center(
          //         child: Padding(
          //           padding: const EdgeInsets.only(top: 225),
          //           child: Container(
          //             height: dev_height - 140,
          //             child: const Column(
          //               children: [
          //                 NoDataFound(),
          //               ],
          //             ),
          //           ),
          //         ),
          //       )
          //     :

          Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () async {
                  // Navigator.pushNamed(context,Routes.bondsPlaceOrder,arguments: bondsList[index]);
                  await bonds.fetchLedgerBal();
                  showModalBottomSheet(
                    isScrollControlled: true,
                    useSafeArea: true,
                    isDismissible: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16))),
                    context: context,
                    builder: (context) => Container(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: BondOrderScreenbottomPage(
                        bondInfo: bonds.govtBonds!.ncbGSec![index],
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               SizedBox(
                                width: 250,
                                 child: Text(bonds.govtBonds!.ncbGSec![index].name!,
                                                           overflow: TextOverflow.ellipsis,
                                                           style: textStyle(
                                                               theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                                               14,
                                                               FontWeight.w600)),
                               ),
                      //  CustomExchBadge(
                      // exch:
                      //     bonds.govtBonds!.ncbGSec![index].symbol!)
                      SizedBox(
                        height: 4,
                      ),

                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: theme.isDarkMode
                                  ? colors.colorGrey.withOpacity(.3)
                                  : const Color.fromARGB(139, 243, 242, 174),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text("G-Sec",
                              style: textStyle(const Color(0xff666666), 10,
                                  FontWeight.w500))),
                            ],
                          ),

                           bonds.govtBonds!.ncbGSec![index].yield != ''
                                           ?
                           Column(
                                               crossAxisAlignment:
                                                   CrossAxisAlignment.end,
                                                   
                                                   
                                               children: [
                                                 Text(
                                                     '${bonds.govtBonds!.ncbGSec![index].yield}%',
                                                     style: textStyle(
                                                         theme.isDarkMode
                                                             ? colors.colorWhite
                                                             : colors.colorBlack,
                                                         14,
                                                         FontWeight.w500)),
                                                 const SizedBox(
                                                   height: 4,
                                                 ),
                                                 

                                                         Text("Indicative Yield",
                                                     style: textStyle(
                                                         const Color(0xff666666),
                                                         10,
                                                         FontWeight.w500)),
                                               ],
                                             ) : SizedBox()
                        ],
                      ),

                     
                      SizedBox(
                        height: 8,
                      ),

                      // Divider(
                      //     color: theme.isDarkMode
                      //         ? colors.darkColorDivider
                      //         : colors.colorDivider),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        
                        
                        
                        children: [
                          // "${bonds.govtBonds!.ncbGSec![index].biddingStartDate!.substring(0, 2)} - ${bonds.govtBonds!.ncbGSec![index].biddingEndDate!.substring(5, 11)}",

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Closes on",
                                  style: textStyle(const Color(0xff666666), 10,
                                      FontWeight.w500)),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                  '${bonds.govtBonds!.ncbGSec![index].biddingEndDate!.substring(5, 11)}',
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w500)),
                            ],
                          ),
                          SizedBox(
                             height: 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 30),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 5),
                                  backgroundColor: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  )),
                              onPressed: () async {
                                // Navigator.pushNamed(context,Routes.bondsPlaceOrder,arguments: bondsList[index]);
                                await bonds.fetchLedgerBal();
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
                                    child: BondOrderScreenbottomPage(
                                      bondInfo: bonds.govtBonds!.ncbGSec![index],
                                    ),
                                  ),
                                );
                              },
                              child: bonds.loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xff666666)),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                            // "Invest ₹ ${convertCurrencyINRStandard(int.parse(bonds.govtBonds!.ncbGSec![index].minBidQuantity!))}",
                            
                                            'Apply',
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorBlack
                                                    : colors.colorWhite,
                                                12,
                                                FontWeight.w500))
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            itemCount: bonds.govtBonds!.ncbGSec!.length,
            separatorBuilder: (context, index) {
              return Divider(
                  height: 0,
                  color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,);
            },
          ),
          //  const Spacer(),
          // companyInfoWidget(context,true),

          Divider(
              height: 0,
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,)
        ],
      ) : const SizedBox();
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}
