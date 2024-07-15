import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../res/res.dart';
import '../../../../screens/stocks/tradeAction/trade_price_alert.dart';

class ManagePriceAlert extends StatefulWidget {
  const ManagePriceAlert({super.key});

  @override
  State<ManagePriceAlert> createState() => _ManagePriceAlertState();
}

class _ManagePriceAlertState extends State<ManagePriceAlert> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 30,
        title: Text(
          'Manage Price Alert',
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xff000000)),
        ),
        elevation: 4,
        shadowColor: const Color(0xffECEFF3),
        backgroundColor: const Color(0xffFFFFFF),
        iconTheme: const IconThemeData(color: Color(0xff000000)),
        actions: [
          Row(
            children: [
              SvgPicture.asset(assets.filterLines),
              const SizedBox(
                width: 12,
              ),
              SvgPicture.asset(assets.searchIcon),
              const SizedBox(
                width: 12,
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xffFFFFFF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16),
                  child: Text(
                    'Active alert (8)',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff666666)),
                  ),
                ),
                ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  itemCount: 6,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (contex) => const SetPriceAlert()));
                      },
                      title: Text(
                        'Indiabulls Housing Finance Limited',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff000000)),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            'Alert value :  ',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff666666)),
                          ),
                          Text(
                            '₹5,637.50',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff000000)),
                          ),
                        ],
                      ),
                      trailing: SvgPicture.asset(assets.rightArrowIcon),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      thickness: 4,
                      color: Color(0xffEEF0F2),
                    );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
