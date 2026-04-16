import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/res/res.dart';

class SetPriceAlert extends StatefulWidget {
  const SetPriceAlert({super.key});

  @override
  State<SetPriceAlert> createState() => _SetPriceAlertState();
}

List<Cars> dummyData = [
  Cars(
    alteroption: 'Status',
    alertstatus: 'Enable',
  ),
  Cars(
    alteroption: 'Alert me',
    alertstatus: 'Greater than equal to',
  ),
  Cars(
    alteroption: 'Value',
    alertstatus: '₹5,637.50',
  ),
  Cars(
    alteroption: 'Date',
    alertstatus: '16-06-2023',
  ),
  Cars(
    alteroption: 'Investment',
    alertstatus: '16-06-2023',
  ),
  Cars(
    alteroption: 'Current value',
    alertstatus: '₹1289.87',
  ),
  Cars(
    alteroption: 'Avg price',
    alertstatus: '₹5,67.50',
  ),
  Cars(
    alteroption: 'Last trade price',
    alertstatus: '₹733.65',
  ),
];

class _SetPriceAlertState extends State<SetPriceAlert> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      appBar: AppBar(
        leadingWidth: 30,
        title: Text(
          'Price Alert',
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xff000000)),
        ),
        elevation: .3,
        backgroundColor: const Color(0xffFFFFFF),
        iconTheme: const IconThemeData(color: Color(0xff000000)),
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(width: 4, color: Color(0xffEEF0F2)))),
            child: ListTile(
              title: Text(
                'Indiabulls Housing Finance Limited',
                style: GoogleFonts.inter(
                    fontSize: 15,
                    letterSpacing: 0.15,
                    color: const Color(0xff000000),
                    fontWeight: FontWeight.w600),
              ),
              subtitle: Row(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    '-76.60 ',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xff000000),
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '(-30.8%)',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: colors.darkred,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Details',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      letterSpacing: 0.128,
                      color: const Color(0xff000000),
                      fontWeight: FontWeight.w600),
                ),
                ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dummyData[index].alteroption,
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  letterSpacing: 0.112,
                                  color: const Color(0xff000000),
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              dummyData[index].alertstatus,
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  letterSpacing: 0.112,
                                  color: const Color(0xff000000),
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Divider(
                          color: Color(0xffEBEEF3),
                        ),
                      );
                    },
                    itemCount: dummyData.length)
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xffEFF2F5)))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 175,
                height: 40,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.darkred,
                     
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Delete Alert",
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xffFFFFFF),
                          fontWeight: FontWeight.w600),
                    )),
              ),
              SizedBox(
                width: 175,
                height: 40,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // ignore: deprecated_member_use
                      backgroundColor: const Color(0xff000000),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Modiy Alert",
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xffffffffff),
                          fontWeight: FontWeight.w600),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Cars {
  String alteroption;
  String alertstatus;

  Cars({
    required this.alteroption,
    required this.alertstatus,
  });
}
